# Runbook: Finance Shared Drive Access Failure After Migration

## Version Header
| Field | Value |
| --- | --- |
| Title | Runbook: Finance Shared Drive Access Failure After Migration |
| Version | 1.0 |
| Date | 07/08/2026 |
| Author | Tanni Das |
| Reviewed | self |
| Status | Draft |
| Change | Initial version from RCA |

## Prerequisites
### Access
- Intune Administrator access to script assignments and device script execution status. [ELEVATED]
- Local administrator access to at least one affected endpoint. [ELEVATED]
- Access to endpoint Event Viewer and Intune Management Extension logs.

### Tools
- Intune admin center in browser.
- Event Viewer (`eventvwr.msc`) on endpoint.
- Text editor for reviewing script content.
- Command Prompt or PowerShell on endpoint.

### Mandatory Input Before Start
- Two affected device names in OU=Finance (DESKTOP-FB*).
- One known timestamp where failure occurred.
- Finance share path: \\finbridge-fs01\Finance.
- Expected mapped drive letter: S:.

## Procedure
1. Open Intune admin center and go to Devices > Scripts and remediations > Platform scripts.
Expected result: You can see the drive mapping script deployment.

2. Open the script package used for Finance drive mapping.
Expected result: Script details page is open.

3. Check the script run context setting and confirm whether it is set to SYSTEM.
Expected result: You verify current runtime identity.

4. Change runtime context to user context for Finance targeting. [ELEVATED]
Expected result: Script is configured to run in interactive user context.

5. Save and assign the updated script to the Finance user/device scope. [ELEVATED]
Expected result: Updated deployment is published.

6. On one affected endpoint, sign in as affected user.
Expected result: User session is active.

7. Open Event Viewer and navigate to Windows Logs > System.
Expected result: System events are visible.

8. Filter System events for Event IDs 98, 7036, and 1500 in the failure window.
Expected result: You can compare pre-fix and post-fix behavior.

9. Open Intune Management Extension log on endpoint at C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log.
Expected result: Script execution logs are visible.

10. Confirm script no longer reports SYSTEM-context share access failure and no longer exits with code 1.
Expected result: Script completes without prior error signature.

11. Confirm S: is assigned in File Explorer for the signed-in user.
Expected result: Drive letter S: appears.

12. Open S: and confirm Finance share contents are accessible.
Expected result: User can browse shared drive successfully.

13. Repeat validation on one additional affected endpoint.
Expected result: Fix is reproducible across affected scope.

14. Trigger broader rollout to remaining Finance targets. [ELEVATED]
Expected result: Updated mapping behavior applies to full impacted group.

## Verification
1. In Intune admin center, open the script device/user status and confirm successful execution on affected targets.
2. On sampled endpoints, verify S: is assigned after user sign-in.
3. In IntuneManagementExtension.log, confirm no new "Network name cannot be found" errors for mapping run.
4. In Event Viewer > Windows Logs > System, verify no recurring Event 98 for failed S: assignment after fix time.
5. Obtain one user confirmation that login and shared drive access are normal.

## Rollback
Use this only if updated deployment causes broader access failure.

1. In Intune admin center, open the same platform script and revert to the previously working assignment profile. [ELEVATED]
Expected result: Script settings return to previous state.

2. Remove new assignment from Finance scope and re-apply last known good assignment. [ELEVATED]
Expected result: Devices receive prior mapping behavior.

3. On one affected endpoint, sign out and sign in once.
Expected result: New policy cycle applies.

4. Re-check IntuneManagementExtension.log and verify script behavior matches pre-change baseline.
Expected result: Rollback behavior confirmed.

5. If service remains degraded, escalate to Intune platform owner with script version, assignment change time, and affected device list. [ELEVATED]
Expected result: Rapid owner handoff with complete evidence.

## Notes
- Verified RCA root cause was context mismatch from USER to SYSTEM execution after migration.
- Group Policy was healthy during incident; do not treat this as a Group Policy outage.
- No retry in original deployment increased user-visible impact.
- Related reference: shared-drive-finance-shared-drive-rca-closed-2024-03-15.md.
