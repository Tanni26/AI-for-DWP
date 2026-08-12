# L2/L3 Knowledge Base: Finance Shared Drive Missing After Sign-In

Version Header: v 1.0, 07/08/2026, status : Draft

## Background: what the system does and why it matter
Finance endpoints use a mapped drive letter, `S:`, to reach the Finance share at `\\finbridge-fs01\Finance` during and after user sign-in. In the working design, the mapping is applied in the interactive user session so the user token can access the share as soon as logon completes.

This matters because Finance staff depend on the share for day-to-day documents, working files, and team data. If the mapping fails, users can still sign in to Windows, but they cannot reach their shared work data, which creates immediate business impact and a high volume of tickets.

## symptom: what the engineer observers and what the user report
Engineer observes:
- Affected devices are limited to the Finance population on `DESKTOP-FB*` machines.
- `S:` is missing after sign-in even though the device completed logon.
- Intune script status shows the drive mapping script failed with exit code `1`.
- Group Policy processing is otherwise healthy, so this is not a general logon policy outage.

User reports:
- "I signed in, but the Finance drive is missing."
- "My files are not gone, but I cannot open S:."
- "Restarting or signing out sometimes helps temporarily, but the problem comes back."

Comparison check:
- Affected Finance devices in the migrated Intune assignment fail to map `S:`.
- A known-good control device still using the working user-context mapping shows `S:` and no mapping error.

## root cause: the specific technical cause with the evidence that confirms it
Specific technical cause:
- The Finance drive mapping was moved from a USER-context GPO logon script to a SYSTEM-context Intune PowerShell script.
- The SYSTEM-context script could not access `\\finbridge-fs01\Finance` with the required interactive user credentials at sign-in time.
- The script failed with exit code `1` and did not retry, so the drive letter was never assigned.

Evidence that confirms this cause:
- `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log` shows the script running as `SYSTEM`.
- The same IME log shows `\\finbridge-fs01\Finance not accessible from SYSTEM context` and `Network name cannot be found`.
- The IME log also shows `No retry configured` and `exit code 1`.
- `Event Viewer > Windows Logs > System` on the affected device shows Event ID `7036` indicating the Workstation service is running, which confirms the endpoint is up and processing logon activity.
- `Event Viewer > Windows Logs > System` also shows Event ID `1500` with `ProviderName` or `Source` = `GroupPolicy`, which confirms Group Policy processed successfully and did not fail.
- `Event Viewer > Windows Logs > System` shows Event ID `98` from NTFS, which confirms the mapped drive letter `S:` was not assigned.

## Detection: exactly how to confirm this is the issue before acting- include specific event ids, log locations and what to look for
Target: confirm or reject this incident signature before changing any assignments.

### 3-minute quick confirmation flow
1. Check the Intune script status for one affected `DESKTOP-FB*` device.
2. Check the IME log on that same device for context and failure text.
3. Check the System log for Event IDs `7036`, `1500`, and `98`.
4. Compare the affected device with one known-good control device.

### Exact log locations and required fields
Affected device must be checked in these exact locations:
- Intune admin center > Devices > Scripts and remediations > Platform scripts > Finance shared drive mapping > Device status: check `Status`, `Last run time`, and `Error code`.
- `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`: check `Script context`, `\\finbridge-fs01\Finance`, `Network name cannot be found`, `exit code`, and `No retry configured`.
- `Event Viewer > Windows Logs > System`: check `Event ID`, `ProviderName` or `Source`, and `Message` for Event IDs `7036`, `1500`, and `98`.

Control device baseline must be checked in the same locations:
- Intune admin center > Devices > Scripts and remediations > Platform scripts > Finance shared drive mapping > Device status: `Status = Succeeded` or equivalent success state and `Error code = 0`.
- `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`: no `SYSTEM context` mapping failure, no `Network name cannot be found`, and no `exit code 1` for the same time window.
- `Event Viewer > Windows Logs > System`: `Event ID 1500` present, `Event ID 98` absent, and `S:` is visible in File Explorer.

### What to look for in each event and field
Intune admin center `Device status`:
- `Status = Failed`
- `Error code = 1`
- `Last run time` matches the failure window

IME log `Script context` and message text:
- `Script context: SYSTEM account`
- `Warning: \\finbridge-fs01\Finance not accessible from SYSTEM context`
- `Error: Network name cannot be found`
- `No retry configured`

System log Event ID `7036`:
- `ProviderName` or `Source`: `Service Control Manager`
- `Message`: Workstation service entered the running state

System log Event ID `1500`:
- `ProviderName` or `Source`: `GroupPolicy`
- `Message`: Group Policy settings processed successfully

System log Event ID `98`:
- `ProviderName` or `Source`: `Ntfs`
- `Message`: mapped drive letter `S:` was not assigned or could not be created

### Fast PowerShell checks on the affected device
Use these checks instead of manual hunting.

```powershell
$Start = (Get-Date).AddHours(-4)

# Intune Management Extension log: confirm SYSTEM context failure and exit code 1
Get-Content 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log' |
Select-String -Pattern 'Script context|SYSTEM context|Network name cannot be found|exit code 1|No retry configured|\\finbridge-fs01\\Finance'

# System log: confirm the event sequence used in this incident
Get-WinEvent -FilterHashtable @{LogName='System'; Id=7036,1500,98; StartTime=$Start} |
Select-Object TimeCreated, ProviderName, Id, Message -First 20
```

### Comparison check command for control vs affected device
Run the same checks on one control device and compare the output directly.

```powershell
$Start = (Get-Date).AddHours(-4)

# Control device should not show the SYSTEM-context failure pattern
Get-Content 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log' |
Select-String -Pattern 'Script context|SYSTEM context|Network name cannot be found|exit code 1|No retry configured|\\finbridge-fs01\\Finance'

# Control device should have success processing and no Event 98 for missing S:
Get-WinEvent -FilterHashtable @{LogName='System'; Id=1500,98; StartTime=$Start} |
Select-Object TimeCreated, ProviderName, Id, Message -First 20
```

### Decision gate (act only if all conditions are true)
1. Affected device Intune `Device status` shows `Failed` with `Error code = 1` in the matching time window.
2. IME log shows `Script context: SYSTEM account` and `Network name cannot be found` for `\\finbridge-fs01\Finance`.
3. `Event Viewer > Windows Logs > System` shows Event IDs `7036`, `1500`, and `98` with `ProviderName` or `Source` matching the expected providers.
4. Control device either already has `S:` mapped successfully or does not show the `SYSTEM context` failure pattern.

## Resolution: step-by-step fix with expected result after each step - include specific portal/console paths
Use a canary-first fix. Do not change the whole Finance population at once.

1. Open the Intune assignment for the Finance drive mapping script.
Portal path and option:
- Microsoft Intune admin center > Devices > Scripts and remediations > Platform scripts > Finance shared drive mapping
- Open `Properties` for the script
Expected result:
- You can see the current assignment and runtime context settings.

2. Change the script to run in the interactive user context.
Portal path and option:
- Microsoft Intune admin center > Devices > Scripts and remediations > Platform scripts > Finance shared drive mapping > Properties > Script settings
- Set `Run this script using the logged on credentials` = `Yes`
PowerShell / Graph quick path:
```powershell
Connect-MgGraph -Scopes DeviceManagementConfiguration.ReadWrite.All
$scriptId = '<finance-drive-mapping-script-id>'
Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/$scriptId" -Body (@{ runAsAccount = 'user' } | ConvertTo-Json)
```
Expected result:
- The mapping script is configured to run with the logged-on user token instead of SYSTEM.

3. Save the change and target the Finance user/device scope that owns the mapping.
Portal path and option:
- Microsoft Intune admin center > Devices > Scripts and remediations > Platform scripts > Finance shared drive mapping > Assignments
- Assign to the Finance group used for the shared-drive rollout
PowerShell / Graph quick path:
```powershell
Connect-MgGraph -Scopes DeviceManagementConfiguration.ReadWrite.All
$scriptId = '<finance-drive-mapping-script-id>'
Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/$scriptId/assign" -Body (@{
	deviceManagementScriptGroupAssignments = @(@{
		target = @{
			'@odata.type' = '#microsoft.graph.groupAssignmentTarget'
			groupId = '<finance-group-id>'
		}
	})
} | ConvertTo-Json -Depth 5)
```
Expected result:
- The updated script configuration is published to the intended Finance scope.

4. Validate on one canary device before wider rollout.
Portal path and option:
- Microsoft Intune admin center > Devices > All devices > <canary device>
- Open the device record and verify it is in the targeted Finance scope
Expected result:
- One controlled device is ready to receive the updated mapping behavior.

5. On the canary device, sign out and sign back in once.
Console path and option:
- Windows Start menu > user icon > Sign out
Expected result:
- A fresh interactive logon starts the updated Intune script in user context.

6. Check the canary device logs immediately after sign-in.
Console path and option:
- `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`
- `Event Viewer > Windows Logs > System`
Expected result:
- IME log shows `Script context: USER` or equivalent interactive-user execution, no `Network name cannot be found`, and no `exit code 1`.
- System log no longer adds Event ID `98` for missing `S:`.

7. Confirm `S:` appears and opens successfully on the canary device.
Console path and option:
- File Explorer > left navigation pane > `S:`
Expected result:
- `S:` is present and the Finance share opens without access errors.

8. Roll the fix to the remaining Finance devices in small batches.
Portal path and option:
- Microsoft Intune admin center > Devices > Scripts and remediations > Platform scripts > Finance shared drive mapping > Assignments
- Expand the assignment only after the canary is clean
Expected result:
- Remaining Finance devices receive the corrected user-context mapping.

## Verification: how to confirm the fix worked
1. In Microsoft Intune admin center, open the script `Device status` and confirm the affected devices now show success.
Expected result:
- `Status = Succeeded` and `Error code = 0` for the remediated devices.

2. On a remediated endpoint, open `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log` and confirm the failure signature is gone.
Expected result:
- No `SYSTEM context` access failure, no `Network name cannot be found`, and no `exit code 1` in the post-fix window.

3. In `Event Viewer > Windows Logs > System`, review the post-fix window for Event IDs `7036`, `1500`, and `98`.
Expected result:
- Event ID `1500` continues to show healthy policy processing, Event ID `98` does not recur, and Event ID `7036` is not paired with any mapping failure.

4. Open File Explorer on the same endpoint and confirm `S:` is present.
Expected result:
- The Finance shared drive appears immediately after sign-in or within the expected policy cycle.

5. Open `S:` and confirm the Finance share contents are accessible.
Expected result:
- The user can browse shared files normally.

6. Repeat the same checks on one additional Finance device.
Expected result:
- The fix is reproducible across the affected scope, not just on the canary.

## Rollback: what to do if the fix makes thing worse- be specific
Use rollback if the updated user-context deployment increases failed mappings, delays sign-in, or creates a broader Finance access issue.

1. Freeze the Intune rollout for the Finance drive mapping script.
Portal path and option:
- Microsoft Intune admin center > Devices > Scripts and remediations > Platform scripts > Finance shared drive mapping > Assignments
- Remove the newly changed Finance assignment or set it to `Not assigned`
PowerShell / Graph quick path:
```powershell
Connect-MgGraph -Scopes DeviceManagementConfiguration.ReadWrite.All
$scriptId = '<finance-drive-mapping-script-id>'
Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/$scriptId/assign" -Body (@{ deviceManagementScriptGroupAssignments = @() } | ConvertTo-Json -Depth 5)
```
Expected result:
- No additional Finance devices receive the problematic update.

2. Re-enable the previous GPO logon script that ran in user context.
Console path and option:
- Group Policy Management > Forest > Domains > finbridge.local > Finance OU > Drive Mapping GPO
- Re-enable the user-context logon script used before the Intune migration
PowerShell quick path after the GPO change:
```powershell
Invoke-GPUpdate -Computer '<impacted-desktop>' -Force
```
Expected result:
- The old working drive mapping path is restored as the active logon mechanism.

3. Force policy refresh on one impacted device.
Console path and option:
- Open PowerShell as administrator on the device and run `gpupdate /force`
Expected result:
- The restored policy path is refreshed without waiting for the next cycle.

4. Sign out and sign back in on the same device.
Console path and option:
- Windows Start menu > user icon > Sign out, then sign in again
Expected result:
- The previous user-context mapping should reapply and `S:` should return.

5. Re-check the IME log and System log after rollback.
Console path and option:
- `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`
- `Event Viewer > Windows Logs > System`
Expected result:
- The new failure pattern stops, and Event ID `98` stops increasing.

6. If rollback still makes service worse, stop all changes and escalate with evidence.
Portal path and option:
- Microsoft Intune admin center > Devices > Scripts and remediations > Platform scripts > Finance shared drive mapping > Device status
Expected result:
- You have the exact script version, assignment time, affected devices, and log excerpt ready for the platform owner.

## Preventive: the specific change to process or tooling that stop this recurring
1. Runtime-context gate for login-time script migrations.
- Owner: `release engineer`; Timing: `before deployment`; Mode: `manual` with Graph validation. Confirm the script is set to run as the logged-on user, not SYSTEM, for one Finance canary and one control device.
- Signal/pass-fail: Intune script metadata shows `runAsAccount = user`; canary IME log shows `Script context: USER`. If either is false, block release.
- Automation note: [REQUIRES: Intune Graph access to script metadata and assignment objects].

2. Canary ring for drive-mapping changes.
- Owner: `image owner`; Timing: `during deployment`; Mode: `manual`, realistically automatable. Deploy to one Finance canary device first and wait one sign-in cycle before expanding scope.
- Signal/pass-fail: canary shows `Status = Succeeded`, `Error code = 0`, `S:` exists, and IME log has no `exit code 1` or `Network name cannot be found`.
- Fail action: stop rollout and keep the previous path active. Automation note: a device-status and log check can be scheduled.

3. Intune failure alert for the exact incident signature.
- Owner: `service desk lead`; Timing: `during deployment`; Mode: `automated`. Alert on `Device status = Failed`, `Error code = 1`, and IME text containing `SYSTEM context` plus `Network name cannot be found`.
- Signal/pass-fail: trigger only when the alert fires within the rollout window; pass if zero alerts occur while canary and batch hosts are healthy.
- Fail action: page the `DWP engineer` and pause rollout. [REQUIRES: Intune log forwarding or alerting rule]

4. Migrated-vs-control comparison check.
- Owner: `DWP engineer`; Timing: `before deployment` and `during deployment`; Mode: `manual` with a repeatable checklist. Compare one migrated Finance device with one known-good control device still on the prior path.
- Signal/pass-fail: control has `S:` and Event ID `1500`; migrated device has `S:` with no Event ID `98` and no IME failure text.
- Fail action: do not close the change and do not widen the deployment.

5. Pre-release proof that the share is reachable from the intended execution context.
- Owner: `change manager`; Timing: `before deployment`; Mode: `manual`, realistically automatable. Run the mapping script in the same context it will use in production and record the result against `\\finbridge-fs01\Finance`.
- Signal/pass-fail: interactive-user execution reaches the share and maps `S:`; SYSTEM-context execution must not be used for production. If the context cannot reach the share, block promotion.
- Automation note: [REQUIRES: a test device or test user account that can execute the same context as production].

6. Rollback-ready GPO path until Intune proves stable.
- Owner: `change manager`; Timing: `before deployment` and `after deployment`; Mode: `manual`. Keep the previous user-context GPO drive mapping enabled until canary and post-deployment checks pass.
- Signal/pass-fail: old GPO path remains available and can reapply `S:` after `gpupdate /force` on a test device.
- Fail action: if the Intune path regresses, revert to the GPO path immediately.

7. Pre-deployment smoke test gate.
- Owner: `image owner`; Timing: `before deployment`; Mode: `manual`, realistically automatable. Validate a test device or pilot user can sign in, map `S:`, and open `\\finbridge-fs01\Finance` before production rollout.
- Signal/pass-fail: IME log has no `exit code 1`, System log has no Event ID `98`, and the drive appears in File Explorer.
- Fail action: do not release the change. Automation note: [REQUIRES: isolated test ring or pre-prod device].

8. In-flight monitoring during the rollout window.
- Owner: `service desk lead`; Timing: `during deployment`; Mode: `automated`. Watch the Finance rollout window for Event ID `98` spikes and incident tickets tagged missing shared drive access.
- Signal/pass-fail: pass if Event ID `98` stays at `0` on remediated hosts and ticket volume stays below `2` matching incidents per `15` minutes.
- Fail action: freeze the rollout and investigate the last batch. [REQUIRES: alert/dashboard for endpoint events or ticket trend]

9. Post-deployment validation before closing the change.
- Owner: `change manager`; Timing: `after deployment`; Mode: `manual`. Validate at least three affected users on remediated devices and confirm the mapping remains stable after sign-in.
- Signal/pass-fail: `Status = Succeeded`, `Error code = 0`, `S:` present, Event ID `98` absent, and users can open the Finance share.
- Fail action: keep the change open and return the host/device to drain or rollback state.

10. Manual rollback trigger for regression.
- Owner: `release engineer`; Timing: `during deployment`; Mode: `manual` with a defined threshold. Roll back if a canary or batch host shows repeated `exit code 1` or Event ID `98` after the fix is applied.
- Signal/pass-fail: one failed canary plus one repeat failure in the next validation cycle is enough to trigger rollback.
- Fail action: remove the new assignment, restore the GPO path, and confirm `S:` returns.

11. Knowledge update after closure.
- Owner: `DWP engineer`; Timing: `after deployment`; Mode: `manual`. Update the runbook, self-help notes, and any checklist with the final root cause and the exact `SYSTEM` vs user-context lesson.
- Signal/pass-fail: KB links, event IDs, and detection steps reflect this incident pattern; if not, the update is incomplete.
- Fail action: do not close the problem record until the documentation matches the final resolution.

## related: other incidents or KB article this connects to
- [Runbook: Finance Shared Drive Access Failure After Migration](day5/runbook-finance-shared-drive-access-intune-context.md)
- [Finance Shared Drive Missing After Sign-In - Self Help](day5/l1-self-service-finance-shared-drive-access.md)
- [Finance Access Problem - Help You Can Do Yourself](day5/l1-kb-finance-shared-drive-access.md)
- [FAULT-B Finance Shared Drive Mapping Failure (Closed)](day4/shared-drive-finance-shared-drive-rca-closed-2024-03-15.md)