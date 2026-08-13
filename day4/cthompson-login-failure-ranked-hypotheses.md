# cthompson Login Failure - Ranked Hypotheses (Scope-Facts Only)

## Scope Facts Used
- Symptom: user `cthompson` not able to login
- Who affected: `cthompson` only (single user)
- Since: approximately 08:40 this morning
- Change: none reported

## Ranked Most Likely Causes (Most Probable First)

### 1) Account lockout from bad password attempts (possibly from a stale saved credential)
Why this fits scope facts:
- Only one user is affected, which strongly fits a user-specific authentication state.
- Sudden start time (~08:40) is consistent with a lockout threshold being hit at a point in time.
- "No change" reported is common when the trigger is an existing cached credential (phone mail app, mapped drive, old task), not a new change.

Single fastest check:
- In AD/Azure sign-in data, check whether `cthompson` is currently locked out and review lockout/bad-password events around 08:40.

### 2) Password expired or account set to "must change password" and interactive flow failing
Why this fits scope facts:
- Affects one user only, consistent with per-account password lifecycle conditions.
- Time-bounded onset can match password expiry boundary/policy enforcement becoming active.
- Users often interpret this as "cannot login" if the prompt path is unclear or blocked.

Single fastest check:
- Inspect `cthompson` account password status (expired/force-change flags) in identity admin tools.

### 3) Account disabled, restricted, or sign-in blocked by user-level identity policy
Why this fits scope facts:
- Single-user impact strongly matches user object state or a targeted policy assignment.
- No broad impact suggests this is not a platform-wide outage.
- Sudden onset can happen if policy evaluation or admin action took effect around that time.

Single fastest check:
- Open the user object and verify enabled/sign-in-allowed status plus any targeted conditional access or sign-in block flags.

### 4) Cached/stale local credentials or profile token issue on the endpoint
Why this fits scope facts:
- One-user symptom can arise from local credential cache/token corruption specific to the user context.
- No reported environmental change is compatible with silent token/cached-credential drift.
- Abrupt failure can start at next token refresh or first login attempt after idle period.

Single fastest check:
- Attempt login for `cthompson` on a known-good alternate device/session to separate account issues from local endpoint cache/profile issues.

### 5) User principal name/domain format mismatch or wrong sign-in target selection
Why this fits scope facts:
- Single-user failures commonly occur when username format or domain context is incorrect for that user only.
- "No change" can still apply if remembered username/autofill changed behavior or user context switched (VPN/AVD/local).
- Sudden onset can occur after session context drift even without infrastructure changes.

Single fastest check:
- Have user sign in once using explicit UPN format and correct domain/tenant target, then verify the exact error returned.

## Analyst Note
- This is a hypothesis ranking from scope facts only.
- No single root cause is asserted yet; checks above are designed to confirm/eliminate each candidate quickly.