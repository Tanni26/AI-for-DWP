# FAULT-B Analysis and Solutions

## Incident Scope Facts
- Symptom: Finance team cannot access shared drives.
- Impact: 45 users, all Finance users on DESKTOP-FB* devices in OU=Finance.
- Evidence sources: Intune Management Extension log and System log.
- Time anchor in logs: around 08:00.

## Key Evidence
- [08:00:01] ScriptRunner Info: executing Map-FinBridgeDrives.ps1.
- [08:00:02] Script context is SYSTEM account.
- [08:00:03] Warning: network path \\finbridge-fs01\Finance not accessible from SYSTEM context at execution time.
- [08:00:03] Error: script failed with exit code 1, network name cannot be found.
- [08:00:04] No retry configured.
- System log DESKTOP-FB041 at 08:00:05: Workstation service entered running state.
- System log DESKTOP-FB041 at 08:00:06: GroupPolicy Event 1500 success (GP processing is successful).
- System log DESKTOP-FB041 at 08:00:07: NTFS Event 98 warning, could not map drive letter S:, drive letter not assigned.
- Migration change log at 2024-03-14 23:30: drive mapping moved from GPO logon script running as USER to Intune PowerShell script running as SYSTEM, without script update for SYSTEM context constraints.

## Primary Cause Analysis
- This is not a Group Policy failure.
- The mapping script ran in SYSTEM context where required UNC access and user-mapped credential context were not available at execution time.
- Because no retry was configured, the initial mapping failure persisted for affected users.

## Immediate Service-Restore Actions
1. Revert drive mapping execution back to user-context logon execution for Finance users.
2. Trigger user sign-out/sign-in to re-run mapping in user context.
3. Validate S: drive mapping and \\finbridge-fs01\Finance access for test Finance users.

## Permanent Solution
1. Keep drive mapping in a user-context deployment model (for example user logon script or user-context Intune assignment).
2. If Intune must be used, redesign script for context-awareness and user-phase execution, not SYSTEM-at-login assumptions.
3. Add retry or delayed execution logic so network dependencies are available before mapping attempt.
4. Add deployment validation gates: context check, UNC reachability check, and sample-user mapping verification before broad rollout.

## Validation Checklist
- Script context confirms USER for mapping workflow.
- Test Finance user receives S: drive mapping.
- UNC path \\finbridge-fs01\Finance accessible post-login.
- No fresh script exit code 1 mapping failures in managed endpoint logs.

## Risk if Unchanged
- Recurring mass mapping failures for Finance users whenever SYSTEM-context execution is used without user credential/network readiness handling.