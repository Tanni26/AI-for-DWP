Symptom: Finance users cannot access shared drives and S: is not assigned during sign-in. The issue appears across Finance endpoints in the affected deployment scope.

Cause: Map-FinBridgeDrives.ps1 ran in SYSTEM context after migration and could not access \\finbridge-fs01\Finance at execution time. The script failed with exit code 1 (network name cannot be found), and no retry was configured.

Scope: All Finance users (45 users) on DESKTOP-FB* devices in OU=Finance were affected. Group Policy processing itself remained successful in sample evidence.

Workaround: Restore drive mapping execution to user sign-in context and have users sign out/sign in to re-run mapping. Validate that S: is assigned and \\finbridge-fs01\Finance is reachable in user session.

Permanent fix: Keep mapping in user-context deployment or redesign Intune implementation to run at user phase with context-aware logic. Add retry or delayed execution with network readiness checks before final rollout.

How to spot it: Intune log pattern shows Map-FinBridgeDrives.ps1 under SYSTEM context, warning that \\finbridge-fs01\Finance is not accessible, then exit code 1 with network name cannot be found and no retry configured. System log corroborates with GroupPolicy 1500 success and NTFS Event 98 showing S: not assigned.