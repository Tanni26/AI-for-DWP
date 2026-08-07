# FAULT-B: Surviving Hypothesis and Detailed Resolution

## Surviving Hypothesis
The shared-drive mapping failure is caused by an execution-context mismatch: the migrated Intune mapping script runs as SYSTEM, but Finance drive mapping to `\\finbridge-fs01\Finance` requires user-session context and user credentials at sign-in.

## Detailed Resolution Steps
1. Stabilize service immediately
   - Use a user-context mapping method so the drive maps in the signed-in user session, not SYSTEM context.
   - Apply a one-time user-session mapping of the Finance share to `S:` for impacted users to restore access quickly.

2. Correct deployment design
   - Reconfigure Intune deployment so the mapping runs in user context for Finance users.
   - Keep targeting aligned to Finance scope only.
   - Disable/remove the SYSTEM-context mapping assignment to avoid conflict.

3. Improve script reliability
   - Add a pre-check for UNC reachability before attempting map.
   - Add explicit error handling and clear logging/exit codes.
   - Add retry with short backoff during sign-in.
   - Validate whether `S:` already exists and remap cleanly when required.

4. Validate on pilot set
   - Test on a small subset of Finance devices.
   - Confirm `S:` is assigned after user sign-in.
   - Confirm access via mapped drive and direct UNC path.
   - Confirm mapping step no longer returns "Network name cannot be found".

5. Roll out and close
   - Deploy corrected user-context mapping to all Finance users.
   - Monitor sign-in cycles and mapping success across OU=Finance.
   - Confirm symptom is cleared for all affected users before closure.

6. Prevent recurrence
   - Add migration gate requiring context-compatibility review for scripts moved between GPO and Intune.
   - Require retry behavior for sign-in-time scripts that depend on network resources.
   - Add monitoring for script failure signals and unmapped drive-letter outcomes.
