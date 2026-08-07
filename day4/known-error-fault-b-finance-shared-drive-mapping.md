Symptom: Finance users cannot access mapped shared drives because drive letter S: is not assigned during sign-in. Users experience missing shared-drive access on affected hosts.

Cause: The verified root cause is execution-context mismatch after migration: the drive mapping moved from USER-context GPO logon execution to SYSTEM-context Intune script execution without adaptation. In SYSTEM context, Map-FinBridgeDrives.ps1 failed to access \\finbridge-fs01\Finance and exited with code 1 (Network name cannot be found).

Scope: All Finance users (approximately 45) on DESKTOP-FB* devices in OU=Finance were affected. The issue began following the overnight migration change.

Workaround: Restore service by mapping the Finance share in user context after sign-in so S: can be assigned in the interactive user session. Validate that the user can access \\finbridge-fs01\Finance and that S: appears.

Permanent fix: Correct the deployment so drive mapping runs in user context for Finance users and remove reliance on the failing SYSTEM-context mapping path. Service recovery was validated with successful user login and no further issues reported at 11:00 AM.

How to spot it: Look for Intune Management Extension ScriptRunner entries showing SYSTEM context, warning that \\finbridge-fs01\Finance is not accessible, failure exit code 1, and error Network name cannot be found. Correlate with System log Event 1500 (GroupPolicy success), Event 7036 (Workstation service running), and Ntfs Event 98 showing S: not assigned.