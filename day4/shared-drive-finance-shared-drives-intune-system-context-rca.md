# FAULT-B RCA: Finance Shared Drive Access Failure (Intune SYSTEM Context)

## Incident Summary
- Incident: Finance team cannot access shared drives.
- Affected users/devices: All Finance users (~45) on `DESKTOP-FB*` devices in `OU=Finance`.
- Trigger window: After migration change on 2024-03-14 23:30.
- Key change: Drive mapping moved from GPO logon script (runs as USER) to Intune PowerShell script (runs as SYSTEM).

## Evidence Collected

### Intune Management Extension / ScriptRunner
- `[08:00:01]` Script execution started: `Map-FinBridgeDrives.ps1`.
- `[08:00:02]` Script context confirmed: `SYSTEM account`.
- `[08:00:03]` Warning: UNC path `\\finbridge-fs01\Finance` not accessible from SYSTEM context at execution time.
- `[08:00:03]` Error: Script failed, exit code `1`, error `Network name cannot be found`.
- `[08:00:04]` Info: No retry configured.

### System Log (DESKTOP-FB041)
- `08:00:05` Event `7036`: Workstation service entered running state.
- `08:00:06` Event `1500`: Group Policy processed successfully.
- `08:00:07` Event `98` (Ntfs Warning): Could not map drive letter `S:`; drive letter not assigned.

### Migration Change Note
- Script moved from USER-context GPO logon script to SYSTEM-context Intune script.
- Script was not updated for SYSTEM execution constraints.
- UNC mapping depends on session/user credential context that is not available in SYSTEM at login time.

## What Each Key Signal Means
- `Script context: SYSTEM account`: The mapping script runs outside the interactive user token.
- `Network path ... not accessible from SYSTEM context`: Direct confirmation that the execution identity cannot access the target share at that time.
- `Exit code 1 / Network name cannot be found`: Script terminates before drive mapping completes.
- `No retry configured`: A transient early failure becomes persistent for the user session.
- Event `1500` GroupPolicy success: Confirms this is not a Group Policy processing outage.
- Event `98` drive map warning: Confirms user-visible symptom (no `S:` assignment).

## Sequence of Failure (Plain English)
1. At sign-in time, Intune launches `Map-FinBridgeDrives.ps1`.
2. The script runs as SYSTEM, not as the signed-in Finance user.
3. The script tries to access `\\finbridge-fs01\Finance` and fails in that context.
4. Script exits with code 1 and no retry mechanism.
5. Group Policy completes successfully, so policy infrastructure is healthy.
6. Drive letter `S:` is never assigned, and users cannot access mapped shared drives.

## Most Likely Root Cause
The drive mapping process was migrated to an Intune PowerShell script that runs under SYSTEM context, but the script logic and execution design still assumed USER-context access to UNC shares at sign-in.

This created a context mismatch: all Finance endpoints executed the same failing method, producing consistent broad impact.

## Immediate Service Restoration (Workaround)
1. Map the Finance share in user context for affected users (interactive user token), not SYSTEM context.
2. Trigger mapping after user session is established.
3. If needed, run a one-time user-context mapping command for `S:` to restore access quickly while permanent deployment is prepared.

## Permanent Fix
1. Re-deploy drive mapping as a USER-context mechanism (for example, Intune user-targeted script/remediation) instead of SYSTEM-only execution.
2. Update script logic to:
   - Validate share reachability in user session.
   - Apply explicit error handling.
   - Add retry/backoff when share is unavailable at first sign-in attempt.
3. Keep drive mapping assignment scoped to Finance users/devices as required.
4. Add deployment guardrails to block context-sensitive scripts from moving to SYSTEM without compatibility validation.

## Verification Plan
1. Confirm script runtime context is USER for Finance target.
2. On pilot devices, validate successful assignment of drive `S:` after sign-in.
3. Confirm ScriptRunner shows success (no exit code 1) and no recurring `Network name cannot be found` for mapping step.
4. Validate user access to `\\finbridge-fs01\Finance` through mapped drive and direct UNC path.
5. Roll out broadly and confirm incident symptom cleared across OU=Finance population.

## Preventive Actions
1. Add pre-migration technical check: execution context compatibility (USER vs SYSTEM) for all scripts touching network shares.
2. Require retry behavior for sign-in-time dependency scripts.
3. Add post-change monitoring for script exit codes and mapped drive assignment failures.
4. Maintain runbook pattern: network drive mappings must run in user session unless explicitly engineered otherwise.

## Conclusion
This incident is a deployment-design regression introduced by migration from USER-context mapping to SYSTEM-context execution without script adaptation. Evidence consistently supports context mismatch as the failure mechanism, with Group Policy explicitly healthy and drive assignment failing as a downstream effect.
