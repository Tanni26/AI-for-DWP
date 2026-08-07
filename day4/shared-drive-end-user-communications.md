# FAULT-B End-User Communications

## Audience 1 - Non-technical executive
Your access is restored and your data remained safe. After the overnight device update, Finance shared drives did not connect for Finance users because the new sign-in setup ran in a background account instead of each user sign-in. We corrected the setup to run in user sign-in, validated drive access restoration, and confirmed resolution at 11:00 AM with successful user login and no further issues. No action is required.

## Audience 2 - Affected end-user team (10 people, non-technical)
Hi team, this is fixed and your shared drive access is working. After the overnight update, Finance shared drives failed to connect because the new sign-in setup ran in a background account instead of your own sign-in, so the drive letter was not created. We corrected the setup to run in user sign-in, restored access, and confirmed recovery at 11:00 AM with successful login and no further issues. If you see this again, please contact the Service Desk.

## Audience 3 - Engineer-to-engineer internal note
Summary
- Incident: Finance shared drive mapping failure (FAULT-B).
- Scope: All Finance users (~45) on DESKTOP-FB* in OU=Finance.
- Trigger: Post-migration change (2024-03-14 23:30) from GPO USER-context logon script to Intune PowerShell SYSTEM-context execution.

Root cause
- Execution-context mismatch: `Map-FinBridgeDrives.ps1` was migrated to SYSTEM context without adapting script/deployment for user-session UNC mapping requirements.

Supporting config/evidence detail
- ScriptRunner logs:
  - 08:00:01 executing script.
  - 08:00:02 context SYSTEM.
  - 08:00:03 `\\finbridge-fs01\Finance` inaccessible from SYSTEM; exit code 1; error "Network name cannot be found".
  - 08:00:04 no retry configured.
- System log (DESKTOP-FB041):
  - 7036 Workstation service running.
  - 1500 GroupPolicy success (not a GP outage).
  - Ntfs 98: `S:` not assigned.

Exact action taken
- Corrected deployment to run mapping in user context for Finance users.
- Removed reliance on failing SYSTEM-context mapping path.
- Validated mapping/access in user sign-in session.

Verification step
- Confirmed mapped drive assignment and share access post-fix in user session.
- User login to host verified successful at 11:00 AM.
- No further issues reported.

Preventive action needed
- Add mandatory migration gate for USER vs SYSTEM context compatibility checks on login-time scripts.
- Require retry/backoff for sign-in network-dependent mapping scripts.
- Add monitoring for script exit-code failures and unmapped drive outcomes.
- Keep runbook standard: user drive mappings run in user session unless an exception is tested and approved.
