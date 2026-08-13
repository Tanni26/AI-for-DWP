# Root Cause Analysis (RCA)

## Incident Title
cthompson single-user login failure and lockout

## Incident Date
2024-03-15

## Resolution Status
Resolved at 09:09 AM. User login verified on host. No further issues reported.

## Executive Summary
At approximately 08:44, user `FINBRIDGE\cthompson` experienced repeated authentication failures on `DESKTOP-FB022`, followed by an account lockout. Additional Kerberos pre-authentication failures were observed from a second source IP (`10.10.8.112`), indicating ongoing bad-password attempts from more than one source. Recovery actions were applied (account enabled/unlocked path and credential remediation), and successful interactive login was confirmed at 09:09.

## Scope and Impact
- Affected user: `FINBRIDGE\cthompson` only
- Affected endpoint observed: `DESKTOP-FB022` (`10.10.1.88`)
- Additional failure source observed: `10.10.8.112`
- Business impact: single-user inability to log in during incident window
- Broad service impact: none observed

## Supporting Evidence (Event Logs)

### Failure and Lockout Evidence
- 08:44:01 - Event ID 4776 (Audit Failure)
  - Account: `FINBRIDGE\cthompson`
  - Error: `0xC000006A` (wrong password)
  - Source workstation: `DESKTOP-FB022`
- 08:44:03 - Event ID 4625 (Audit Failure)
  - Failure reason: `Unknown user name or bad password`
  - Logon type: 2 (Interactive)
  - Source: `DESKTOP-FB022`
- 08:44:28 - Event ID 4625 (Audit Failure)
  - Failure reason: `Unknown user name or bad password`
  - Logon type: 2 (Interactive)
  - Source: `DESKTOP-FB022`
- 08:44:55 - Event ID 4625 (Audit Failure)
  - Failure reason: `Unknown user name or bad password`
  - Logon type: 2 (Interactive)
  - Source: `DESKTOP-FB022`
- 08:44:56 - Event ID 4740 (Audit Failure)
  - Message: user account locked out
  - Account: `FINBRIDGE\cthompson`
  - Caller computer: `DESKTOP-FB022`
- 08:45:10 - Event ID 4625 (Audit Failure)
  - Failure reason: `Account locked out`
  - Logon type: 7 (Unlock attempt)
  - Source: `DESKTOP-FB022`
- 08:45:44 - Event ID 4771 (Audit Failure)
  - Kerberos pre-authentication failed
  - Failure code: `0x18` (wrong password)
  - Source IP: `10.10.8.112`
- 08:46:01 - Event ID 4771 (Audit Failure)
  - Kerberos pre-authentication failed
  - Failure code: `0x18` (wrong password)
  - Source IP: `10.10.8.112`
- 08:46:33 - Event ID 4771 (Audit Failure)
  - Kerberos pre-authentication failed
  - Failure code: `0x18` (wrong password)
  - Source IP: `10.10.8.112`

### Recovery and Validation Evidence
- 09:08:14 - Event ID 4722 (Audit Success)
  - Message: user account enabled
  - Account: `FINBRIDGE\cthompson`
  - Done by: `FINBRIDGE\helpdesk-admin`
- 09:09:01 - Event ID 4624 (Audit Success)
  - Message: account successfully logged on
  - Account: `FINBRIDGE\cthompson`
  - Logon type: 2 (Interactive)
  - Source: `DESKTOP-FB022`

## Timeline (End-to-End)
- ~08:40: user begins experiencing login failure (reported onset)
- 08:44:01: first logged wrong-password validation failure (Event 4776)
- 08:44:03 to 08:44:55: repeated interactive bad-password failures (Event 4625)
- 08:44:56: account lockout recorded (Event 4740)
- 08:45:10: locked-account login attempt observed (Event 4625, logon type 7)
- 08:45:44 to 08:46:33: additional Kerberos wrong-password attempts from `10.10.8.112` (Event 4771)
- 09:08:14: account enabled by helpdesk admin (Event 4722)
- 09:09:01: successful interactive login by user on host (Event 4624)
- 09:09: incident considered resolved; user verified as working

## Root Cause Statement
Most likely root cause: repeated invalid credential submissions for `FINBRIDGE\cthompson` triggered account lockout threshold, with continued bad-password attempts from at least one additional credential source (`10.10.8.112`) contributing to persistence risk.

## 5 Whys Analysis
1. Why could the user not log in?
- The account was locked, and authentication attempts were rejected.

2. Why was the account locked?
- Multiple bad-password attempts occurred in short succession, crossing lockout policy threshold.

3. Why did multiple bad-password attempts occur?
- Incorrect credentials were repeatedly used from interactive logon and a second Kerberos source.

4. Why were incorrect credentials still being used after lockout?
- At least one cached/stored credential source likely continued automatic authentication attempts.

5. Why did cached/stored credentials persist without early detection?
- No immediate control was in place to rapidly identify and quarantine all credential-emitting sources at first lockout signal.

## Corrective Actions Taken
- Account recovery actions executed by service desk/admin path.
- Account enabled (Event 4722 at 09:08:14).
- User re-validated on primary endpoint with successful interactive login (Event 4624 at 09:09:01).
- Incident monitoring confirmed user restored and no immediate recurrence reported.

## Preventive Actions
1. Add lockout triage playbook step to immediately identify all bad-password source hosts/IPs from Event IDs 4776, 4771, and 4740.
2. Require credential hygiene sweep during lockout recovery:
- Credential Manager entries
- mapped drive scripts
- scheduled tasks/services running under user context
- mobile/mail clients with stored passwords
3. Implement short-term post-recovery monitoring window (30-60 minutes) for recurrence events (4776/4771/4740).
4. Add helpdesk checklist item to confirm secondary source resolution before closing incident when non-primary source IPs are present.
5. Create periodic user awareness reminder on password changes and updating saved credentials across all devices.

## Closure Criteria and Outcome
- Technical closure met: successful login event recorded (4624 at 09:09:01).
- User confirmation met: user verified logged in to host and reported no issues.
- Incident status: Closed (resolved).
