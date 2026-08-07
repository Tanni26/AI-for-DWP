# Finance Shared Drive Access Failure: Ranked Hypotheses (Scope-Facts Only)

## Context Used
- Symptom: Finance users unable to access mapped shared drives.
- Affected population: All Finance users (~45 users) on OU=Finance devices (DESKTOP-FB*).
- Timing: Began after overnight device management migration.
- Relevant change: Drive mapping moved from Group Policy logon script to Intune PowerShell script.
- Observations: Group Policy processing is successful, drive letter not assigned, Intune script runs during sign-in, no automatic retry, similar process worked before migration.

## Ranked Top 5 Most Likely Causes

1. Intune PowerShell script logic or parameters do not correctly map the drive in the new method.
Why this fits scope facts: The failure started immediately after the exact mapping mechanism changed from Group Policy script to Intune script, and impact is broad across the whole Finance population, which is consistent with a common script issue rather than a single endpoint fault.
Fastest check: Run the same Intune script manually on one affected Finance device as an affected user and capture immediate output/error from the script execution path used at sign-in.

2. Sign-in execution context mismatch (user/system context) prevents drive-letter mapping from applying to the interactive user session.
Why this fits scope facts: The script executes during sign-in, the drive letter is not assigned, and all users are affected; that pattern is consistent with a context/session boundary issue introduced by migration tooling.
Fastest check: Verify the script assignment and runtime context in Intune policy details, then compare mapped-drive visibility in the interactive user session immediately after script run.

3. Timing race at sign-in: script runs before required user/network/session state is fully ready, and there is no retry.
Why this fits scope facts: Observations explicitly state no automatic retry, and sign-in-time execution can fail transiently if prerequisites are not ready; this would leave users with no mapped drive letter.
Fastest check: Trigger the same mapping command manually 1-2 minutes after sign-in on an affected device; if mapping succeeds then, timing/race is strongly indicated.

4. Intune assignment/scope configuration is consistently wrong for OU=Finance target (for example wrong parameterization/path variable in deployment settings).
Why this fits scope facts: All Finance users are impacted across OU=Finance devices, indicating a systematic targeting/configuration issue tied to the migrated deployment rather than endpoint-specific problems.
Fastest check: Review Intune assignment and script configuration for the Finance target group and confirm the exact mapped-drive inputs delivered to clients match expected Finance values.

5. Failure handling gap in the migrated script (no retry/no persistence) causes one-time sign-in failure to remain unresolved for the whole user base.
Why this fits scope facts: No automatic retry is explicitly observed, and users remain without drive letters; a non-resilient implementation can convert transient sign-in failures into persistent user-visible outage.
Fastest check: Inspect script logic for retry/persistence behavior and validate whether any failed initial run is retried automatically in the same or next session.

## Analyst Note
This is a ranked hypothesis list only. No single root cause is confirmed yet.

## Addendum: Event Details, Surviving Hypothesis, and Resolution

### Event Details (Verified)
- `[08:00:01]` ScriptRunner started `Map-FinBridgeDrives.ps1`.
- `[08:00:02]` ScriptRunner confirmed execution context: `SYSTEM account`.
- `[08:00:03]` ScriptRunner warning: `\\finbridge-fs01\\Finance` not accessible from SYSTEM context at execution time.
- `[08:00:03]` ScriptRunner error: script failed with exit code `1`; error `Network name cannot be found`.
- `[08:00:04]` ScriptRunner: no retry configured.
- `08:00:05` System Event `7036`: Workstation service entered running state.
- `08:00:06` GroupPolicy Event `1500`: Group Policy processed successfully (rules out GP processing failure).
- `08:00:07` Ntfs Event `98`: drive letter `S:` could not be mapped/assigned.
- Migration note confirms process change from GPO USER-context script to Intune SYSTEM-context script without context adaptation.

### Surviving Hypothesis
The surviving hypothesis is execution-context mismatch: the migrated drive-mapping script runs as SYSTEM, while access to `\\finbridge-fs01\\Finance` and user drive-letter assignment requires user-session context at sign-in.

Why this survives elimination:
- It directly matches explicit ScriptRunner context evidence (`SYSTEM account`).
- It directly matches the logged access failure from SYSTEM context and exit code `1`.
- It explains broad scope impact (all Finance users) after a single shared deployment change.
- It is consistent with Group Policy success (`1500`) while drive mapping still fails (`Ntfs 98`).

### Detailed Resolution
1. Immediate restoration
	- Use user-context mapping to restore `S:` assignment for affected users.
	- Apply one-time user-session mapping where required to recover access quickly.

2. Deployment correction
	- Reconfigure Intune mapping so script runs in user context for Finance users.
	- Remove/disable SYSTEM-context mapping assignment to prevent repeated failures.

3. Script hardening
	- Add pre-check for `\\finbridge-fs01\\Finance` reachability.
	- Add explicit logging/error handling with clear non-zero exits.
	- Add retry/backoff logic because sign-in-time dependency failures are possible.
	- Add idempotent handling if `S:` already exists.

4. Validation
	- Pilot on a subset of OU=Finance endpoints.
	- Confirm `S:` is assigned after sign-in and users can access the share.
	- Confirm ScriptRunner no longer logs `Network name cannot be found` for mapping.

5. Preventive controls
	- Add migration gate for USER vs SYSTEM context compatibility review.
	- Require retry behavior for sign-in scripts with network dependencies.
	- Add monitoring for script failures and unmapped drive outcomes.
