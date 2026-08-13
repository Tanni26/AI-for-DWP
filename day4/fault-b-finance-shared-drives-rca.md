# Root Cause Analysis (RCA) - FAULT-B

## Incident Title
Finance shared drives inaccessible after drive mapping migration

## Date / Change Anchor
- Change introduced: 2024-03-14 23:30
- Incident evidence window: around 08:00 startup/logon sequence

## Impact
- Affected population: all Finance users (45 users).
- Affected estate: DESKTOP-FB* devices in OU=Finance.
- User impact: shared drives unavailable; drive letter S: not mapped.

## Evidence Summary
- Intune log [08:00:01]: Map-FinBridgeDrives.ps1 executed.
- Intune log [08:00:02]: script context SYSTEM account.
- Intune log [08:00:03]: UNC path \\finbridge-fs01\Finance not accessible in SYSTEM context at execution time.
- Intune log [08:00:03]: script failed, exit code 1, network name cannot be found.
- Intune log [08:00:04]: no retry configured.
- System log FB041 [08:00:05]: Workstation service entered running state.
- System log FB041 [08:00:06]: GroupPolicy 1500 success (policy processing normal).
- System log FB041 [08:00:07]: NTFS Event 98 warning, S: not assigned.
- Migration note: mapping changed from GPO logon script (USER) to Intune script (SYSTEM), script not updated for SYSTEM constraints.

## Root Cause
- The drive mapping implementation was moved to SYSTEM context execution without adapting the script for SYSTEM limitations around UNC access and user credential context during login timing.
- As a result, mapping attempts failed and, with no retry policy, did not self-recover.

## 5 Whys
1. Why could Finance users not access shared drives?
- Drive mapping failed, so S: was not assigned.

2. Why did drive mapping fail?
- Map-FinBridgeDrives.ps1 could not access \\finbridge-fs01\Finance and exited with code 1.

3. Why could it not access the UNC path?
- The script ran as SYSTEM at execution time, where required mapped credential/user context was not available.

4. Why was it running as SYSTEM?
- A migration changed mapping from USER-context GPO logon script to SYSTEM-context Intune script.

5. Why did the issue affect all Finance users broadly?
- The change was applied to the Finance device/user scope and no retry or context-safety logic prevented widespread failure.

## Corrective Action
- Move mapping execution back to user-context flow and re-run at user sign-in.
- Validate mapping success across representative Finance endpoints.

## Preventive Action
1. Enforce context review gate before migration of user-dependent scripts.
2. Require pilot validation for user-mapped drives after any management-plane migration.
3. Add retry/delay and pre-checks (execution context + UNC accessibility) before marking deployment complete.
4. Keep an explicit rollback path for mapping-critical scripts.

## Verification Criteria
- Finance test users receive S: mapping at sign-in.
- \\finbridge-fs01\Finance accessible in user session.
- No new Intune script failures with exit code 1 for Map-FinBridgeDrives.ps1.
- No new NTFS Event 98 warnings related to S: assignment on remediated endpoints.