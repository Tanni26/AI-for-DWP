# cthompson Login Incident - Communications for Three Audiences

## Audience 1 - Non-Technical Executive
Your access and data are safe. This morning, only one user (cthompson) could not sign in from about 08:40 after repeated incorrect password attempts from their computer and a second source, which caused a temporary account lock. Support re-enabled the account at 09:08 and confirmed successful sign-in at 09:09 on the same host. No wider impact was found and no further issues were reported. No action is needed unless you cannot sign in.

## Audience 2 - Affected End-User Team (Non-Technical)
Hi team, today only one user (cthompson) was unable to sign in from about 08:40 because repeated wrong password attempts from their computer and a second source temporarily locked the account. Support re-enabled the account at 09:08, and sign-in succeeded at 09:09 on DESKTOP-FB022; no wider impact or further issues were seen. If you see the same problem, stop retrying your password and contact Helpdesk immediately.

## Audience 3 - Engineer-to-Engineer Internal Note
Incident facts and status:
- Single-user impact: `FINBRIDGE\cthompson` only.
- Reported onset: ~08:40.
- Primary host: `DESKTOP-FB022` (`10.10.1.88`).
- Secondary source observed: `10.10.8.112`.
- Resolved: 09:09, user verified logged in, no further issues reported.

Root cause:
- Repeated invalid credential submissions triggered account lockout threshold for `FINBRIDGE\cthompson`.
- Continued bad-password attempts from an additional source (`10.10.8.112`) increased persistence risk.

Supporting evidence (key events):
- 08:44:01 `4776` failure, `0xC000006A` wrong password, source `DESKTOP-FB022`.
- 08:44:03 / 08:44:28 / 08:44:55 `4625` failures, bad password, interactive (type 2), source `DESKTOP-FB022`.
- 08:44:56 `4740` account lockout for `FINBRIDGE\cthompson`, caller `DESKTOP-FB022`.
- 08:45:10 `4625` failure reason `Account locked out`, logon type 7, source `DESKTOP-FB022`.
- 08:45:44 / 08:46:01 / 08:46:33 `4771` Kerberos pre-auth failures, `0x18` wrong password, source IP `10.10.8.112`.

Exact action taken:
- Account recovery executed via service desk/admin path.
- Account enabled at 09:08:14 (`4722`, done by `FINBRIDGE\helpdesk-admin`).
- Credential-remediation workflow applied to remove/refresh stale stored credentials on involved sources.

Config/detail to carry forward:
- Lockout was policy-threshold behavior after clustered bad-password attempts.
- Event patterns to triage: `4776`, `4625`, `4740`, `4771`.
- Cross-source indicator in this case: primary endpoint `DESKTOP-FB022` plus secondary emitter `10.10.8.112`.

Verification step:
- Success event at 09:09:01 (`4624`, interactive type 2) for `FINBRIDGE\cthompson` on `DESKTOP-FB022`.
- User confirmed restored access and no additional issues.

Preventive action needed:
- During any lockout recovery, immediately identify all bad-password emitters (host/IP) from `4776/4771/4740`.
- Complete credential hygiene sweep before closure:
  - Credential Manager
  - mapped drive scripts
  - scheduled tasks/services in user context
  - mail/mobile/other stored-credential clients
- Enforce 30-60 minute post-recovery monitoring for fresh `4776/4771/4740` recurrence before final close.
