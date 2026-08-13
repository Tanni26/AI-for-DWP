# Title: Playbook - AVD Black Screen Post-Login (POOL-FIN-01)
# Version: 1.0
# Date: 13/08/2026
# Author: Tanni
# Reviewed: self
# Status: draft
# Change: initial version from RCA
# Source RCA: day4/avd-black-screen-rca-finance-pool.md

## 1. Prerequisites

Complete every checklist item before Step 1 of the procedure.

### Access checklist

- [ ] Azure Portal access to subscription and resource group containing `POOL-FIN-01` and `POOL-FIN-02`. [ELEVATED]
Expected result: you can open Azure Portal > Azure Virtual Desktop > Host pools.

- [ ] Permission to view and edit session host properties (`Allow new sessions`). [ELEVATED]
Expected result: host Properties pane allows changing `Allow new sessions`.

- [ ] Permission to run `RunPowerShellScript` on Azure VMs (Run Command). [ELEVATED]
Expected result: VM > Operations > Run command is available.

- [ ] Permission to create OS disk snapshots. [ELEVATED]
Expected result: VM OS disk > Create snapshot is available.

- [ ] Permission to deploy or register session hosts from known-good image version. [ELEVATED]
Expected result: host pool Add session hosts workflow is available.

### Tools checklist

- [ ] Azure Portal browser session is active in the correct tenant.
Expected result: target host pools and VMs are visible without access errors.

- [ ] PowerShell 5.1 or PowerShell 7 console for local note-taking and command copy.
Expected result: you can paste and stage commands before Run Command execution.

- [ ] Incident note template open (timestamps, host names, event IDs, action log).
Expected result: all outputs can be captured as evidence in real time.

### Mandatory end-user information checklist

- [ ] Primary affected username (UPN or domain\username).
Expected result: you can map symptom timestamps to session/log entries.

- [ ] Exact time of latest failed logon and timezone.
Expected result: you can query the correct event window.

- [ ] AVD client type and version (Windows app, Web client, macOS client).
Expected result: client context is recorded for correlation.

- [ ] Screenshot or wording of symptom after logon (black screen duration, disconnect message if any).
Expected result: symptom signature is documented before host changes.

- [ ] Number of impacted users and whether all are in `POOL-FIN-01`.
Expected result: scope confirms pool-local issue and supports canary strategy.

- [ ] Confirmation whether any user in `POOL-FIN-02` is unaffected at same time.
Expected result: control pool baseline is available for comparison.

## 2. Procedure

Follow steps in order. Perform one action per step.

1. Open Azure Portal path `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts`.
Expected result: the full host list for POOL-FIN-01 is visible.

2. Select one currently impacted host (example: `SHFIN-01-A`) from the POOL-FIN-01 host list.
Expected result: the selected host details pane opens.

3. Set `Allow new sessions = No` on the selected host in `Session hosts > <host> > Properties`. [ELEVATED]
Expected result: the host enters drain mode and stops receiving new sessions.

4. Record current session count from `Session hosts > <host> > User sessions`.
Expected result: pre-change user session baseline is captured in ticket notes.

5. Open Azure Portal path `Virtual machines > <affected-host> > Disks > OS disk`.
Expected result: OS disk details are visible.

6. Click `Create snapshot` for the OS disk and save the snapshot ID in the incident ticket. [ELEVATED]
Expected result: rollback snapshot exists and is traceable.

7. Open Azure Portal path `Virtual machines > <affected-host> > Operations > Run command > RunPowerShellScript`. [ELEVATED]
Expected result: script entry pane is ready for log query execution.

8. Run the Event ID 1000 query below against log location `Windows Logs > Application` (file: `C:\Windows\System32\winevt\Logs\Application.evtx`). [ELEVATED]

```powershell
$Start=(Get-Date).AddHours(-4)
Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$Start} |
Where-Object { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' } |
Select-Object TimeCreated, Id, Message -First 10
```

Expected result: one or more events show `dwm.exe` faulting module `igdumd64.dll`.

9. Run the Event ID 9009 query below against log location `Applications and Services Logs > Microsoft > Windows > Desktop Window Manager > Operational` (file: `C:\Windows\System32\winevt\Logs\Microsoft-Windows-Desktop%20Window%20Manager%4Operational.evtx`). [ELEVATED]

```powershell
$Start=(Get-Date).AddHours(-4)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=$Start} |
Select-Object TimeCreated, Id, Message -First 10
```

Expected result: Event ID 9009 is present in the same symptom window.

10. Run the Event ID 21 and 40 query below against log location `Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational` (file: `C:\Windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx`). [ELEVATED]

```powershell
$Start=(Get-Date).AddHours(-4)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'; Id=21,40; StartTime=$Start} |
Select-Object TimeCreated, Id, Message -First 30
```

Expected result: Event 21 is followed by Event 40 for the same incident period.

11. Open Azure Portal path `Azure Virtual Desktop > Host pools > POOL-FIN-02 > Session hosts`.
Expected result: the control pool host list is visible.

12. Select one healthy control host (example: `SHFIN-02-A`) from the POOL-FIN-02 host list.
Expected result: control host details pane opens.

13. Open `Virtual machines > <control-host> > Operations > Run command > RunPowerShellScript`. [ELEVATED]
Expected result: script entry pane is ready on the control VM.

14. Run the Event ID 9011 query below against `Desktop Window Manager/Operational` on the control host. [ELEVATED]

```powershell
$Start=(Get-Date).AddHours(-4)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9011; StartTime=$Start} |
Select-Object TimeCreated, Id, Message -First 10
```

Expected result: Event ID 9011 appears for successful DWM startup.

15. Run the Event ID 1000 signature query below against `Application` on the control host. [ELEVATED]

```powershell
$Start=(Get-Date).AddHours(-4)
Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$Start} |
Where-Object { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' } |
Select-Object TimeCreated, Id, Message -First 10
```

Expected result: no matching Event ID 1000 crash signature is returned.

16. Start canary replacement from `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > Add`. [ELEVATED]
Expected result: add session host wizard opens.

17. Select the last known-good image version in the Add session host wizard and create one canary host. [ELEVATED]
Expected result: canary host is created and appears under POOL-FIN-01 session hosts.

18. Assign one previously impacted user in `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Application groups > <desktop-app-group> > Assignments`. [ELEVATED]
Expected result: user is assigned and can start a fresh session path to the canary.

19. Confirm the assigned user logs in successfully to a usable desktop.
Expected result: no black screen is observed after sign-in.

20. Check `Session hosts > <canary-host> > User sessions` after 10 minutes.
Expected result: session remains connected and stable.

21. Run the post-login validation query below on the canary host from `Virtual machines > <canary-host> > Operations > Run command`. [ELEVATED]

```powershell
$Start=(Get-Date).AddMinutes(-30)
$e1000=Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$Start} |
  Where-Object { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' }
$e9009=Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=$Start}
$e9011=Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9011; StartTime=$Start}
[pscustomobject]@{Event1000=$e1000.Count;Event9009=$e9009.Count;Event9011=$e9011.Count}
```

Expected result: `Event1000=0`, `Event9009=0`, and `Event9011>=1`.

22. Set the next legacy affected host to drain mode from `POOL-FIN-01 > Session hosts > <host> > Properties`. [ELEVATED]
Expected result: no new sessions are routed to that legacy host.

23. Replace drained legacy hosts in controlled batches from `POOL-FIN-01 > Session hosts > Add` using known-good image. [ELEVATED]
Expected result: affected capacity is replaced without reintroducing black screen.

24. Re-enable `Allow new sessions = Yes` only on remediated hosts that pass verification. [ELEVATED]
Expected result: normal scheduling resumes on validated hosts only.

## 3. Verification

Complete all checks before closure.

1. Open Azure Portal path `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts`.
Expected result: remediated hosts show `Available` status.

2. Open `Session hosts > <remediated-host> > User sessions` for three previously impacted users.
Expected result: three user sessions are connected and active.

3. Open Azure Portal path `Virtual machines > <remediated-host> > Operations > Run command > RunPowerShellScript`. [ELEVATED]
Expected result: remote script pane is ready for verification queries.

4. Run the command below for Event ID 1000 against log location `Windows Logs > Application` (file: `C:\Windows\System32\winevt\Logs\Application.evtx`). [ELEVATED]

```powershell
$Start=(Get-Date).AddMinutes(-30)
Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$Start} |
Where-Object { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' } |
Select-Object TimeCreated, Id, Message -First 10
```

Expected result: no rows are returned.

5. Run the command below for Event ID 9009 against log location `Applications and Services Logs > Microsoft > Windows > Desktop Window Manager > Operational` (file: `C:\Windows\System32\winevt\Logs\Microsoft-Windows-Desktop%20Window%20Manager%4Operational.evtx`). [ELEVATED]

```powershell
$Start=(Get-Date).AddMinutes(-30)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=$Start} |
Select-Object TimeCreated, Id, Message -First 10
```

Expected result: no rows are returned.

6. Run the command below for Event ID 9011 against log location `Applications and Services Logs > Microsoft > Windows > Desktop Window Manager > Operational` (file: `C:\Windows\System32\winevt\Logs\Microsoft-Windows-Desktop%20Window%20Manager%4Operational.evtx`). [ELEVATED]

```powershell
$Start=(Get-Date).AddMinutes(-30)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9011; StartTime=$Start} |
Select-Object TimeCreated, Id, Message -First 10
```

Expected result: one or more rows are returned.

7. Run the command below for Event IDs 21 and 40 against log location `Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational` (file: `C:\Windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx`). [ELEVATED]

```powershell
$Start=(Get-Date).AddMinutes(-30)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'; Id=21,40; StartTime=$Start} |
Select-Object TimeCreated, Id, Message -First 30
```

Expected result: Event 21 appears for active users with no repeated 21-to-40 disconnect loop.

8. Open Azure Portal path `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Insights > Connections` and set time range to last 30 minutes.
Expected result: no abnormal disconnect spike is visible for POOL-FIN-01.

9. Open Azure Portal path `Azure Virtual Desktop > Host pools > POOL-FIN-02 > Insights > Connections` with the same time range.
Expected result: POOL-FIN-01 trend is aligned to POOL-FIN-02 baseline.

10. Attach verification outputs and timestamps to the ticket.
Expected result: closure evidence is complete and auditable.

## 4. Rollback

Use this section immediately if black screens increase, disconnects increase, or canary check fails.

### 3-minute emergency rollback

1. Open Azure Portal path `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts`. [ELEVATED]
Expected result: all POOL-FIN-01 hosts are visible for immediate control.

2. Set `Allow new sessions = No` for each newly added canary or replacement host from `Session hosts > <new-host> > Properties`. [ELEVATED]
Expected result: new sessions are blocked from suspect hosts.

3. Open `Session hosts > <new-host> > User sessions` and click `Log off` for each active user on each newly added host. [ELEVATED]
Expected result: users are removed from suspect hosts within minutes.

4. Set `Allow new sessions = Yes` for each known-good legacy host from `Session hosts > <known-good-host> > Properties`. [ELEVATED]
Expected result: load routing immediately returns to known-good hosts.

5. Confirm host routing state in `Session hosts` list by checking `Allow new sessions` column.
Expected result: suspect hosts show `No` and known-good hosts show `Yes`.

6. Run this command on one known-good host from `Virtual machines > <known-good-host> > Operations > Run command > RunPowerShellScript` to verify session stability logs. [ELEVATED]

```powershell
$Start=(Get-Date).AddMinutes(-15)
$e9009=Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9009; StartTime=$Start}
$e9011=Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Desktop Window Manager/Operational'; Id=9011; StartTime=$Start}
[pscustomobject]@{Event9009=$e9009.Count;Event9011=$e9011.Count}
```

Expected result: `Event9009=0` and `Event9011>=1`.

7. Run this command on the same known-good host against log location `Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational` (file: `C:\Windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx`). [ELEVATED]

```powershell
$Start=(Get-Date).AddMinutes(-15)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'; Id=21,40; StartTime=$Start} |
Select-Object TimeCreated, Id, Message -First 20
```

Expected result: logons (21) continue without repeated disconnect pattern (40 loop).

8. Record rollback trigger time, affected new host names, and recovered known-good host names in ticket notes.
Expected result: rollback action trail is complete for post-incident review.

### Extended rollback only if capacity remains insufficient

1. Open Azure Portal path `Virtual machines > <affected-host> > Disks > OS disk > Snapshots` and identify `pre-fix` snapshot. [ELEVATED]
Expected result: exact rollback snapshot is selected.

2. Create a rollback VM from the `pre-fix` snapshot. [ELEVATED]
Expected result: rollback VM deploys successfully.

3. Register rollback VM to `POOL-FIN-01` using host pool session host onboarding process. [ELEVATED]
Expected result: rollback VM appears in POOL-FIN-01 session host list.

4. Set `Allow new sessions = Yes` on rollback VM after one successful test login.
Expected result: rollback VM safely adds capacity.

## 5. Notes

- This playbook applies only to post-login black screen where authentication succeeds first.
- If both POOL-FIN-01 and POOL-FIN-02 fail simultaneously, treat as broader platform incident and switch to AVD platform outage procedure.
- Event sequence 21 to 1000 to 40 to 9009 on affected host is the strongest incident signature.
- Some users may recover after about 30 seconds, but repeated crash pattern still requires host remediation.
- Always keep one unaffected control host for comparison during diagnosis.
- Do not roll out image changes to all hosts at once; use canary then batches.
- Do not close incident until user outcome and event-log checks both pass.
