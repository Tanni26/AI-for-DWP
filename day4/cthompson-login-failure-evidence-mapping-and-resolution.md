# cthompson Login Failure - Evidence Mapping and Resolution

## Incident Evidence Window
- Host log: DESKTOP-FB022 Security Log
- Time window reviewed: 2024-03-15 08:44 to 09:12

## Hypothesis-by-Hypothesis Judgement

### 1) Account lockout from bad password attempts (possibly from a stale saved credential)
Judgement: SUPPORTS

Evidence driving judgement:
- 08:44:01, Event ID 4776, `0xC000006A (wrong password)` for `FINBRIDGE\cthompson`.
- 08:44:03, 08:44:28, 08:44:55, Event ID 4625, `Unknown user name or bad password` (interactive logon type 2).
- 08:44:56, Event ID 4740, account `FINBRIDGE\cthompson` locked out.
- 08:45:10, Event ID 4625, `Failure reason: Account locked out` (logon type 7 unlock attempt).
- 08:45:44, 08:46:01, 08:46:33, Event ID 4771, Kerberos pre-auth `0x18 (wrong password)` from source IP `10.10.8.112`, indicating continued bad-password attempts after lockout.

### 2) Password expired or account set to "must change password" and interactive flow failing
Judgement: CONTRADICTS

Evidence driving judgement:
- 08:44:01, Event ID 4776 shows `0xC000006A (wrong password)`, not a password-expired indicator.
- 08:45:44/08:46:01/08:46:33, Event ID 4771 shows `0x18 (wrong password)`, again pointing to incorrect secret use rather than expiry workflow failure.

### 3) Account disabled, restricted, or sign-in blocked by user-level identity policy
Judgement: CONTRADICTS

Evidence driving judgement:
- 08:44:01, Event ID 4776 `0xC000006A (wrong password)` indicates the account is being processed as valid-but-bad-credential.
- 08:44:56, Event ID 4740 lockout occurs after bad-password sequence, consistent with a normal enabled account hitting lockout threshold.
- No event in the provided window indicates `account disabled` or explicit policy block as the immediate failure reason.

### 4) Cached/stale local credentials or profile token issue on the endpoint
Judgement: NEUTRAL

Evidence driving judgement:
- Supporting signal: repeated wrong-password events can be caused by stale saved credentials.
- Limiting signal: 08:45:44/08:46:01/08:46:33 Event ID 4771 attempts originate from `10.10.8.112`, while DESKTOP-FB022 is `10.10.1.88`; this suggests a secondary source and does not specifically confirm a local profile/token issue on DESKTOP-FB022.

### 5) User principal name/domain format mismatch or wrong sign-in target selection
Judgement: CONTRADICTS

Evidence driving judgement:
- 08:44:01, Event ID 4776 resolves and evaluates `FINBRIDGE\cthompson` with `wrong password`.
- If this were primarily a UPN/domain-target mismatch, we would expect identity-resolution style failures rather than a consistent valid-account/wrong-password pattern followed by lockout.

## Surviving Hypothesis After Elimination
- Account lockout caused by repeated bad-password attempts, likely including at least one stale stored credential source.

## Detailed Resolution Steps

1. Contain and recover user access
- Unlock `FINBRIDGE\cthompson` in AD.
- Force password reset to a new temporary value, then require user-set final password at next sign-in.
- Wait for DC replication to complete before retry.

2. Identify and stop the bad-credential sources
- Confirm source endpoints from logs:
  - Local interactive source: `DESKTOP-FB022` (`10.10.1.88`).
  - Additional Kerberos source: `10.10.8.112`.
- Resolve `10.10.8.112` to hostname/owner via DHCP/DNS/CMDB.
- On both sources, remove stale credentials:
  - Windows Credential Manager (saved domain creds, legacy creds).
  - Mapped drives reconnect scripts using old password.
  - Scheduled tasks/services running as `cthompson`.
  - Cached mail/mobile clients and any background apps using old credentials.

3. Re-authenticate cleanly
- Sign out of all active sessions for `cthompson` where possible.
- Sign in first on one known-good endpoint with explicit domain-qualified username.
- Update credentials on other devices/apps only after successful primary sign-in.

4. Validate stability
- Monitor DC/security logs for 30-60 minutes for fresh 4776/4771 failures on `cthompson`.
- Confirm no new 4740 lockout events.
- If failures persist, isolate whichever source continues emitting wrong-password events and repeat step 2.

5. Close-out notes for incident record
- Root cause statement (provisional): repeated bad-password attempts caused lockout; stale saved credential source likely contributed.
- Evidence anchors: Event IDs 4776, 4625, 4740, 4771 with timestamps above.
- Preventive action: user/device credential hygiene and periodic review of stored credentials on managed endpoints.

## Addendum - Event Details, Surviving Hypothesis, and Resolution

### Event Details (Incident Window)
- 08:44:01 - Event ID 4776 (Audit Failure): credential validation failed for `FINBRIDGE\cthompson`, error `0xC000006A` (wrong password), source workstation `DESKTOP-FB022`.
- 08:44:03 - Event ID 4625 (Audit Failure): `Unknown user name or bad password`, logon type 2 (interactive), source `DESKTOP-FB022`.
- 08:44:28 - Event ID 4625 (Audit Failure): `Unknown user name or bad password`, logon type 2 (interactive), source `DESKTOP-FB022`.
- 08:44:55 - Event ID 4625 (Audit Failure): `Unknown user name or bad password`, logon type 2 (interactive), source `DESKTOP-FB022`.
- 08:44:56 - Event ID 4740 (Audit Failure): user account `FINBRIDGE\cthompson` locked out, caller computer `DESKTOP-FB022`.
- 08:45:10 - Event ID 4625 (Audit Failure): `Account locked out`, logon type 7 (unlock attempt), source `DESKTOP-FB022`.
- 08:45:44 - Event ID 4771 (Audit Failure): Kerberos pre-auth failed for `FINBRIDGE\cthompson`, failure code `0x18` (wrong password), source IP `10.10.8.112`.
- 08:46:01 - Event ID 4771 (Audit Failure): Kerberos pre-auth failed, failure code `0x18` (wrong password), source IP `10.10.8.112`.
- 08:46:33 - Event ID 4771 (Audit Failure): Kerberos pre-auth failed, failure code `0x18` (wrong password), source IP `10.10.8.112`.

### Surviving Hypothesis
- Account lockout caused by repeated bad-password attempts, with likely contribution from stale stored credentials from one or more sources.

### Resolution (Detailed Steps)
1. Unlock and recover account access
- Unlock `FINBRIDGE\cthompson`.
- Reset password to a temporary value and enforce change at next sign-in.
- Wait for directory replication completion before re-test.

2. Remove stale credential sources
- Investigate both observed sources: `DESKTOP-FB022` (`10.10.1.88`) and `10.10.8.112`.
- Resolve `10.10.8.112` to hostname/owner through DHCP/DNS/CMDB.
- Clear or update saved credentials in:
  - Credential Manager
  - mapped drive scripts
  - scheduled tasks/services running as `cthompson`
  - mail/mobile/other apps with stored credentials

3. Perform clean sign-in sequence
- Sign out existing sessions where possible.
- Test login first from one known-good endpoint using explicit domain-qualified username.
- Update credentials on all remaining devices/apps after successful primary sign-in.

4. Validate incident containment
- Monitor for new Event IDs 4776/4771 failures and 4740 lockouts for 30-60 minutes.
- If failures continue, isolate and remediate whichever source keeps generating bad-password attempts.