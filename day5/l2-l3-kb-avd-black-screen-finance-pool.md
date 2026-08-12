# L2/L3 Knowledge Base: AVD Black Screen Post-Login (Finance Pool)

Version Header: v 1.0, 07/08/2026, status : Draft

## Background: what the system does and why it matter
Azure Virtual Desktop (AVD) host pool `POOL-FIN-01` provides pooled virtual desktops for Finance users. Session hosts in this pool are built from a managed image and are expected to present a usable desktop immediately after successful user logon.

This matters because Finance operations are start-of-day critical. If desktop rendering fails after authentication, users appear to log in successfully but cannot work, which creates high operational impact and rapid ticket volume.

## Symptom: what the engineer observers and what the user report
Engineer observes:
- Affected scope is limited to `POOL-FIN-01`.
- `POOL-FIN-02` (comparison pool) remains healthy in the same period.
- AVD sign-in succeeds, then session turns black.
- Some sessions recover after about 30 seconds; others disconnect or remain unusable.

User reports:
- "I can log in, but I only see a black screen."
- "Sometimes it comes back after a short wait, sometimes I have to reconnect."

## Root cause: the specific technical cause with the evidence that confirms it
Specific cause:
- Graphics/display stack regression introduced by the overnight image update on `POOL-FIN-01`.
- `dwm.exe` crashes in `igdumd64.dll` after successful session logon.

Evidence that confirms this cause:
- Affected host (`SHFIN-01-A`, `POOL-FIN-01`) shows repeated sequence:
1. `Microsoft-Windows-TerminalServices-LocalSessionManager` Event ID `21` (logon succeeded).
2. `Application Error` Event ID `1000` (`dwm.exe` faulting module `igdumd64.dll`, exception `0xc0000005`).
3. `Microsoft-Windows-TerminalServices-LocalSessionManager` Event ID `40` (session disconnected).
4. `Desktop Window Manager` Event ID `9009` (DWM exited, code `0x40010004`).
- Comparison host (`SHFIN-02-A`, `POOL-FIN-02`) shows:
1. `Microsoft-Windows-TerminalServices-LocalSessionManager` Event ID `21`.
2. `Desktop Window Manager` Event ID `9011` (DWM started successfully).
3. No corresponding `Application Error` Event ID `1000` for `dwm.exe` in the same window.

Additional timing evidence:
- `Microsoft-Windows-Kernel-General` Event ID `1` boot timestamp aligns with post-update restart window.

## Detection: exactly how to confirm this is the issue before acting- include specific event ids, log locations and what to look for
Target: confirm or reject this incident signature in under 3 minutes.

### 3-minute quick confirmation flow
1. Run command checks on one affected host in `POOL-FIN-01`.
2. Run the same checks on one healthy control host in `POOL-FIN-02`.
3. Compare outputs against the decision gate.

### Exact log locations and required events
Affected host (`POOL-FIN-01`) must be checked in these exact logs:
- `Application` log (`Event Viewer > Windows Logs > Application`): Event ID `1000`
- `Desktop Window Manager/Operational` log (`Event Viewer > Applications and Services Logs > Microsoft > Windows > Desktop Window Manager > Operational`): Event ID `9009`
- `TerminalServices-LocalSessionManager/Operational` log (`Event Viewer > Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational`): Event IDs `21` and `40`

Healthy control host (`POOL-FIN-02`) baseline log:
- `Desktop Window Manager/Operational`: Event ID `9011` (unaffected control baseline)
- `Application` log: no matching Event ID `1000` for `dwm.exe` faulting module `igdumd64.dll`

### What to look for in each event
Event ID `1000` in `Application` log:
- `Faulting application name`: `dwm.exe`
- `Faulting module name`: `igdumd64.dll`
- `Exception code`: `0xc0000005`

Event ID `9009` in `Desktop Window Manager/Operational`:
- DWM exited (commonly `0x40010004` in this incident)

Event IDs `21` then `40` in `TerminalServices-LocalSessionManager/Operational`:
- Logon succeeded, then disconnect follows shortly for same session/user

Event ID `9011` in `POOL-FIN-02` control host:
- DWM started successfully

### Fast PowerShell commands (run on each host)
Use these commands instead of manual Event Viewer clicks.

```powershell
$Start = (Get-Date).AddHours(-4)

# Required crash evidence: Application log Event 1000 with igdumd64.dll
Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$Start} |
Where-Object { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' } |
Select-Object TimeCreated, MachineName, Id, ProviderName, Message -First 10

# Required DWM exit evidence: Event 9009
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=$Start} |
Select-Object TimeCreated, MachineName, Id, ProviderName, Message -First 10

# Logon then disconnect correlation: Event 21 and 40
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'; Id=21,40; StartTime=$Start} |
Select-Object TimeCreated, MachineName, Id, Message -First 20

# Healthy baseline check on control host: Event 9011
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9011; StartTime=$Start} |
Select-Object TimeCreated, MachineName, Id, ProviderName, Message -First 10
```

### Fast Azure CLI option (remote pull without interactive RDP)
Run from an admin workstation where Azure CLI is signed in.

```bash
# Affected host: verify Event 1000 (dwm.exe + igdumd64.dll) and Event 9009
az vm run-command invoke -g <RG> -n <POOL-FIN-01-VM> --command-id RunPowerShellScript --scripts "$Start=(Get-Date).AddHours(-4); Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$Start} | ? { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' } | select TimeCreated,Id,Message -First 5; Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=$Start} | select TimeCreated,Id,Message -First 5"

# Control host: verify Event 9011 and absence of matching Event 1000
az vm run-command invoke -g <RG> -n <POOL-FIN-02-VM> --command-id RunPowerShellScript --scripts "$Start=(Get-Date).AddHours(-4); Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9011; StartTime=$Start} | select TimeCreated,Id,Message -First 5; Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$Start} | ? { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' } | select TimeCreated,Id,Message -First 5"
```

### Decision gate (act only if all conditions are true)
1. `POOL-FIN-01` affected host shows Event ID `1000` in `Application` log with `dwm.exe` faulting `igdumd64.dll` and Event ID `9009` in `Desktop Window Manager/Operational`.
2. `TerminalServices-LocalSessionManager/Operational` shows Event ID `21` followed by Event ID `40` in same incident window.
3. `POOL-FIN-02` control host shows Event ID `9011` and does not show matching Event ID `1000` (`dwm.exe` + `igdumd64.dll`).

## Resolution: step-by-step fix with expected result after each step - include specific portal/console paths
Use canary-first remediation. Do not change all hosts at once.

1. Put one affected host in drain mode to stop new sessions.
Portal path and option:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > SHFIN-01-A > Properties > Allow new sessions = No (Drain mode On)
Azure CLI:
```bash
az desktopvirtualization session-host update \
  --resource-group <rg> \
  --host-pool-name POOL-FIN-01 \
  --name SHFIN-01-A \
  --allow-new-session false
```
Expected result:
- Host state shows Drain mode On and no new user sessions are assigned.

2. Take rollback snapshot of the affected VM OS disk.
Portal path and option:
- Azure Portal > Virtual machines > SHFIN-01-A > Disks > OS disk > Create snapshot > Snapshot type Standard_LRS > Create
Azure CLI:
```bash
OSDISK_ID=$(az vm show -g <rg> -n SHFIN-01-A --query "storageProfile.osDisk.managedDisk.id" -o tsv)
az snapshot create -g <rg> -n snap-SHFIN-01-A-pre-fix --source "$OSDISK_ID" --sku Standard_LRS
```
Expected result:
- Snapshot is created and snapshot resource ID is recorded in ticket notes.

3. Confirm faulty graphics signature on the affected host before fix.
Portal path and option:
- Azure Portal > Virtual machines > SHFIN-01-A > Operations > Run command > RunPowerShellScript
PowerShell script:
```powershell
$Start=(Get-Date).AddHours(-4)
Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$Start} |
Where-Object { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' } |
Select-Object TimeCreated,Id,Message -First 5
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=$Start} |
Select-Object TimeCreated,Id,Message -First 5
```
Expected result:
- Event 1000 with dwm.exe and igdumd64.dll plus Event 9009 is present on SHFIN-01-A.

4. Compare with healthy control host in POOL-FIN-02.
Portal path and option:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-02 > Session hosts > SHFIN-02-A
- Azure Portal > Virtual machines > SHFIN-02-A > Operations > Run command > RunPowerShellScript
PowerShell script:
```powershell
$Start=(Get-Date).AddHours(-4)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9011; StartTime=$Start} |
Select-Object TimeCreated,Id,Message -First 5
Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$Start} |
Where-Object { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' } |
Select-Object TimeCreated,Id,Message -First 5
```
Expected result:
- Event 9011 exists on SHFIN-02-A and matching Event 1000 signature is absent.

5. Replace affected host with known-good image host in POOL-FIN-01.
Portal path and option:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > Add
- Add session hosts wizard:
  - Image source = Gallery/Managed image
  - Image = pre-update known-good version
  - Number of VMs = 1 (canary)
  - Validation checks = Enabled
  - Review + Create
Azure CLI (deploy or join a new host from known-good image, per environment template):
```bash
az deployment group create \
  --resource-group <rg> \
  --template-file <avd-sessionhost-template.json> \
  --parameters hostPoolName=POOL-FIN-01 vmNamePrefix=shfin01canary imageVersion=<known_good_image_version>
```
Expected result:
- Canary host appears under Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts with Status Available.

6. Move one test user to canary and validate logon.
Portal path and option:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Application groups > <desktop-app-group> > Assignments > Add user
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <canary-host> > User sessions
Expected result:
- Test login succeeds and desktop renders without black screen.

7. Roll fix across remaining POOL-FIN-01 hosts in small batches.
Portal path and option:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts
- For each old host: set Allow new sessions = No, drain active sessions, replace with known-good image host, validate, then continue
Azure CLI (per host):
```bash
az desktopvirtualization session-host update -g <rg> --host-pool-name POOL-FIN-01 --name <old-host> --allow-new-session false
```
Expected result:
- Black-screen pattern stops as old image hosts are replaced.

8. Re-enable healthy hosts for normal scheduling.
Portal path and option:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <remediated-host> > Properties > Allow new sessions = Yes
Azure CLI:
```bash
az desktopvirtualization session-host update \
  -g <rg> --host-pool-name POOL-FIN-01 --name <remediated-host> --allow-new-session true
```
Expected result:
- POOL-FIN-01 returns to normal capacity with stable logons.

## Verification: how to confirm the fix worked
1. Verify host pool and session host state.
Portal path and options:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts
- Check columns: Status, Drain mode, Sessions
Expected result:
- Remediated hosts are Available, Drain mode is Off only after validation, and sessions are stable.

2. Verify no new crash signature on remediated host.
Portal path and option:
- Azure Portal > Virtual machines > <remediated-host> > Operations > Run command > RunPowerShellScript
PowerShell script:
```powershell
$Start=(Get-Date).AddMinutes(-30)
$e1000=Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$Start} |
  Where-Object { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' }
$e9009=Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=$Start}
$e9011=Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9011; StartTime=$Start}
[pscustomobject]@{Event1000=$e1000.Count;Event9009=$e9009.Count;Event9011=$e9011.Count}
```
Expected result:
- Event1000 = 0, Event9009 = 0, Event9011 >= 1 in post-fix window.

3. Verify pool comparison against unaffected control.
Portal path and options:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Insights > Connections
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-02 > Insights > Connections
- Compare filters: same time window, same client type
Expected result:
- POOL-FIN-01 disconnect/failure pattern aligns to POOL-FIN-02 baseline.

4. Verify user outcome.
Portal path and options:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <host> > User sessions
Expected result:
- At least 3 previously impacted users log in successfully and remain connected.

5. Optional one-shot Azure CLI verification for quick run.
```bash
az vm run-command invoke -g <rg> -n <remediated-host> --command-id RunPowerShellScript --scripts "$Start=(Get-Date).AddMinutes(-30); $e1000=(Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$Start} | ? { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' }).Count; $e9009=(Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=$Start}).Count; $e9011=(Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9011; StartTime=$Start}).Count; Write-Output \"Event1000=$e1000 Event9009=$e9009 Event9011=$e9011\""
```
Expected result:
- Output shows Event1000=0 Event9009=0 and Event9011 greater than zero.

## Rollback: what to do if the fix makes thing worse- be specific
Trigger rollback if black-screen or disconnect rate increases after a remediation batch.

1. Freeze rollout and protect users from unstable hosts.
Portal path and option:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <new-or-unstable-host> > Properties > Allow new sessions = No
Azure CLI:
```bash
az desktopvirtualization session-host update -g <rg> --host-pool-name POOL-FIN-01 --name <new-or-unstable-host> --allow-new-session false
```
Expected result:
- No new sessions land on unstable hosts.

2. Drain and remove unstable replacement host from host pool.
Portal path and option:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <new-or-unstable-host> > Remove
Azure CLI:
```bash
az desktopvirtualization session-host delete -g <rg> --host-pool-name POOL-FIN-01 --name <new-or-unstable-host>
```
Expected result:
- Host is removed from POOL-FIN-01 scheduling.

3. Restore previous VM state from snapshot when host-level rollback is required.
Portal path and options:
- Azure Portal > Virtual machines > SHFIN-01-A > Disks > Swap OS disk > Select disk from snapshot (snap-SHFIN-01-A-pre-fix) > Save
Azure CLI (managed disk from snapshot, then swap):
```bash
SNAP_ID=$(az snapshot show -g <rg> -n snap-SHFIN-01-A-pre-fix --query id -o tsv)
az disk create -g <rg> -n osdisk-SHFIN-01-A-rollback --source "$SNAP_ID"
DISK_ID=$(az disk show -g <rg> -n osdisk-SHFIN-01-A-rollback --query id -o tsv)
az vm update -g <rg> -n SHFIN-01-A --os-disk "$DISK_ID"
```
Expected result:
- SHFIN-01-A returns to pre-fix disk state.

4. Ensure known-good hosts are enabled for scheduling.
Portal path and option:
- Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <known-good-host> > Properties > Allow new sessions = Yes
Azure CLI:
```bash
az desktopvirtualization session-host update -g <rg> --host-pool-name POOL-FIN-01 --name <known-good-host> --allow-new-session true
```
Expected result:
- User sessions are routed only to stable hosts.

5. Verify rollback effectiveness in 15-minute window.
Portal path and option:
- Azure Portal > Virtual machines > <rolled-back-host> > Operations > Run command > RunPowerShellScript
PowerShell script:
```powershell
$Start=(Get-Date).AddMinutes(-15)
$e1000=(Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$Start} | ? { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' }).Count
$e9009=(Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=$Start}).Count
Write-Output "Event1000=$e1000 Event9009=$e9009"
```
Expected result:
- Event1000 and Event9009 counts do not increase after rollback.

6. Escalate with evidence if rollback does not stabilize.
Portal path and option:
- Azure Portal > Monitor > Logs > Query editor
Expected result:
- Evidence pack includes host names, host pool name POOL-FIN-01, timestamps, Event IDs 21, 40, 1000, 9009, 9011, and before/after comparison with POOL-FIN-02.

## Preventive: the specific change to process or tooling that stop this recurring
1. Mandatory canary ring for image changes.
- Owner: `change manager`; Timing: `during deployment`; Type: `manual` with approval gate. Deploy 1 canary host to `POOL-FIN-01` for 60 minutes before wider rollout; pass only if 5/5 test logons succeed and Event IDs `1000` and `9009` both remain at `0`.
- Signal and fail action: canary host shows `Available`, no black screen, and no DWM crash signature; if any failure occurs, stop release, keep existing hosts in service, and escalate to `image owner`. Automation approach: pipeline approval gate can enforce this. [REQUIRES: release approval gate]

2. Automated event-gate in rollout pipeline.
- Owner: `release engineer`; Timing: `during deployment`; Type: `automated`. Query canary telemetry for Event ID `1000` (`dwm.exe` + `igdumd64.dll`) and Event ID `9009` every 5 minutes during rollout; pass only if both counts stay `0`.
- Signal and fail action: observable signal is event count by host and timestamp; if `1000 > 0` or `9009 > 0`, block promotion to next batch, mark change failed, and notify `DWP engineer` and `image owner`. [REQUIRES: Log Analytics query in release pipeline]

3. Baseline and diff graphics stack per pool.
- Owner: `image owner`; Timing: `before deployment`; Type: `manual` review with automated drift check. Maintain approved manifest for `igdumd64.dll` version, driver package version, and image build for `POOL-FIN-01` and `POOL-FIN-02`; pass only if staged image matches approved manifest exactly.
- Signal and fail action: version comparison report shows `0` unexpected deltas; if any delta exists, block image promotion and require updated risk review and sign-off from `change manager`. Automation approach: nightly script can compare live versions to manifest. [REQUIRES: version manifest process]

4. Pool comparison dashboard and alerting.
- Owner: `DWP engineer`; Timing: `during deployment`; Type: `automated`. Dashboard must compare `POOL-FIN-01` vs `POOL-FIN-02` on disconnect rate, Event ID `1000` count, and Event ID `9009` count; pass only if `POOL-FIN-01` stays within agreed threshold of control.
- Signal and fail action: alert fires if `POOL-FIN-01` exceeds `POOL-FIN-02` by more than `3` crash/disconnect events in `10` minutes; if triggered, pause rollout and drain newly updated hosts. [REQUIRES: AVD comparison dashboard and alert rule]

5. Post-update synthetic logon test.
- Owner: `DWP engineer`; Timing: `after deployment` on canary and before batch close; Type: `manual`, realistically automatable. Use service account to perform scripted AVD login and open desktop shell; pass only if desktop renders within `30` seconds and Event IDs `1000` and `9009` remain `0` while Event ID `9011` is present.
- Signal and fail action: observable signal is login duration plus event output from host logs; if test fails once, do not close the change and revert canary to drain mode. Automation approach: scheduled login harness can run and record pass/fail. [REQUIRES: synthetic login test account/process]

6. Pre-deployment smoke test gate.
- Owner: `image owner`; Timing: `before deployment`; Type: `manual`, realistically automatable. Boot the new image on isolated test VM and run local shell-start check plus `Get-WinEvent` queries for Event IDs `1000`, `9009`, and `9011`; pass only if `1000=0`, `9009=0`, and `9011>=1` after 3 test logons.
- Signal and fail action: test evidence is saved to change record; if any threshold fails, image is not released to `POOL-FIN-01`. Automation approach: bake this into image-pipeline validation. [REQUIRES: image pre-prod test VM]

7. In-flight rollout monitoring alert.
- Owner: `service desk lead`; Timing: `during deployment`; Type: `automated`. Monitor incident volume tagged `AVD black screen` plus telemetry for `POOL-FIN-01`; pass only if ticket count stays below `2` matching incidents and host crash events remain below threshold during rollout window.
- Signal and fail action: if `2` or more matching tickets arrive in `15` minutes or any host logs Event ID `1000` with `igdumd64.dll`, page `DWP engineer` and freeze rollout immediately. [REQUIRES: ticket categorization rule]

8. Post-deployment validation before change closure.
- Owner: `change manager`; Timing: `after deployment`; Type: `manual`. Do not close the change until 30-minute validation shows `0` new Event IDs `1000/9009` on remediated hosts, `Event 9011` present on test logons, and 3 affected users confirm successful login.
- Signal and fail action: closure checklist records event counts and user confirmations; if any criterion is missing, keep change open and assign follow-up to `DWP engineer`.

9. Rollback trigger threshold.
- Owner: `release engineer`; Timing: `during deployment`; Type: `manual trigger from automated signals`. Trigger rollback if any updated host records `Event 1000` with `dwm.exe` and `igdumd64.dll`, or if black-screen reports reach `2` users in `15` minutes, or if disconnect events exceed `3` on a single host in `10` minutes.
- Signal and fail action: threshold breach is the observable trigger; if breached, stop rollout, set updated hosts to drain mode, and execute rollback section immediately. [REQUIRES: agreed rollback threshold in change template]

10. Knowledge update from incident learnings.
- Owner: `service desk lead`; Timing: `after deployment` and after incident closure; Type: `manual`. Update the runbook, KB, and change checklist within `2` business days with exact Event IDs `1000`, `9009`, `9011`, comparison step `POOL-FIN-01` vs `POOL-FIN-02`, and command snippets used.
- Signal and fail action: observable signal is new version number and dated update entry in the KB/runbook; if not completed in time, raise overdue action in CAB review. Automation approach: workflow reminder can be created in change system. [REQUIRES: document review workflow]

## Related: other incidents or KB article this connects to
- [day4/avd-black-screen-post-login-finance-pool.md](day4/avd-black-screen-post-login-finance-pool.md)
- [day4/avd-black-screen-analysis-hypothesis.md](day4/avd-black-screen-analysis-hypothesis.md)
- [day4/avd-black-screen-rca-finance-pool.md](day4/avd-black-screen-rca-finance-pool.md)
- [day2/avd-session-disconnects-after-10-min-then-reconnects.md](day2/avd-session-disconnects-after-10-min-then-reconnects.md)