# RCA: FAULT-B Finance Shared Drive Mapping Failure (Closed)

## Document Control
- Incident: FAULT-B - Finance team cannot access shared drives
- Incident date: 2024-03-15
- Analysis date: 2026-08-07
- Affected scope: All Finance users (~45) on DESKTOP-FB* devices in OU=Finance
- Resolution status: Resolved
- Service restored and verified: 11:00 AM (user logged in to host successfully; no issues reported)

## Executive Summary
Following the overnight device management migration, Finance users lost access to mapped shared drives because the mapping process was moved from a USER-context GPO logon script to a SYSTEM-context Intune PowerShell script. The script executed at sign-in in SYSTEM context, could not access the Finance UNC path, failed with exit code 1, and did not retry. Group Policy processing was successful, confirming this was a drive-mapping execution-context issue rather than a Group Policy failure.

The fix was to restore mapping in user context, correct deployment behavior, and validate successful access. Service was confirmed restored at 11:00 AM with successful user login and no further issues reported.

## Supporting Evidence

### Intune Management Extension / ScriptRunner Evidence
- 08:00:01 - Script execution started: Map-FinBridgeDrives.ps1.
- 08:00:02 - Script context: SYSTEM account.
- 08:00:03 - Warning: \\finbridge-fs01\Finance not accessible from SYSTEM context at execution time.
- 08:00:03 - Error: script failed with exit code 1; message: Network name cannot be found.
- 08:00:04 - Info: No retry configured.

### System Log Evidence (DESKTOP-FB041)
- 08:00:05 - Event 7036 (Service Control Manager): Workstation service entered running state.
- 08:00:06 - Event 1500 (GroupPolicy): Group Policy settings processed successfully.
- 08:00:07 - Event 98 (Ntfs Warning): File system could not map drive letter S:; drive letter not assigned.

### Change Record Evidence
- 2024-03-14 23:30 - Drive mapping migrated from GPO logon script (USER context) to Intune PowerShell script (SYSTEM context).
- Change note states the script was not updated to handle SYSTEM context limitations for UNC/mapped credentials at login time.

## Event Interpretation
- SYSTEM execution context confirms the script ran outside interactive user token and user credential scope.
- UNC accessibility warning and Network name cannot be found error confirm path access failure at execution time.
- No retry configured explains persistence of the failure state after first attempt.
- GroupPolicy success event 1500 excludes GP processing as the fault domain.
- Ntfs Event 98 confirms user-facing symptom: S: drive was not assigned.

## Timeline
1. 2024-03-14 23:30 - Migration change implemented: drive mapping moved to Intune SYSTEM-context script.
2. 08:00:01 - Intune starts Map-FinBridgeDrives.ps1.
3. 08:00:02 - Script confirms SYSTEM execution context.
4. 08:00:03 - Script cannot access \\finbridge-fs01\Finance; fails with exit code 1 (Network name cannot be found).
5. 08:00:04 - No retry configured, so mapping failure is not auto-corrected.
6. 08:00:05 - Workstation service running (7036).
7. 08:00:06 - Group Policy successful (1500), ruling out GP failure.
8. 08:00:07 - Ntfs 98 logs S: mapping failure.
9. Post-triage - Mapping approach corrected to user-context execution and deployment behavior updated.
10. 11:00 AM - User login verified successful on host; no issues reported; incident resolved.

## Root Cause Statement
Primary root cause: Execution-context mismatch introduced by migration. The drive mapping script was moved from USER-context GPO execution to SYSTEM-context Intune execution without adapting script and deployment design for user-session UNC access requirements.

Contributing factors:
- No retry behavior for sign-in-time mapping dependency.
- Context compatibility was not validated as a migration gate before rollout.

## 5 Whys Analysis
1. Why could Finance users not access mapped shared drives?
   - Because drive letter S: was not assigned during sign-in.

2. Why was S: not assigned?
   - Because the mapping script failed while trying to access the Finance UNC path.

3. Why did the mapping script fail?
   - Because it ran in SYSTEM context, where the required user-session credential/access path was not available at execution time.

4. Why was it running in SYSTEM context?
   - Because mapping was migrated from USER-context GPO logon script to Intune PowerShell script configured to run as SYSTEM.

5. Why did that migration produce an outage for all Finance users?
   - Because context-sensitive behavior was not adapted or validated, and no retry safeguard existed to recover from initial sign-in-time failures.

## Resolution Actions Performed
1. Shifted mapping execution to user-context behavior for Finance users.
2. Corrected deployment configuration so the mapping is applied in the interactive user session.
3. Removed reliance on failing SYSTEM-context mapping path.
4. Validated mapped drive assignment and share access after sign-in.
5. Confirmed successful user login and no residual issue reports.

## Validation and Closure Evidence
- Group Policy remained healthy throughout (Event 1500), isolating fault to mapping execution path.
- Post-fix validation showed drive mapping restored in user session.
- End-user verification completed at 11:00 AM: user logged in to host successfully; no issues reported.

## Preventive Actions
1. Add mandatory migration gate for USER vs SYSTEM execution-context compatibility on all login-time scripts.
2. Require retry/backoff behavior for drive mapping scripts executed during sign-in.
3. Add deployment checklist item to validate UNC access from intended runtime context before broad rollout.
4. Add monitoring for Intune script failures (exit code and error text) and mapped-drive assignment failures.
5. Maintain runbook standard: user drive mappings must run in user session unless a tested exception is approved.

## Final Outcome
Incident resolved. Verified cause was execution-context mismatch after migration to Intune SYSTEM-context mapping, corrected through user-context mapping deployment and validation. Service recovery confirmed at 11:00 AM with successful user login and no further issues reported.
