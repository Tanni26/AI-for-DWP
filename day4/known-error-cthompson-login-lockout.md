Symptom: User FINBRIDGE\cthompson could not log in, with failed interactive sign-in attempts on DESKTOP-FB022 during the incident window. The issue was resolved after recovery actions, with successful login verified at 09:09.

Cause: Repeated invalid credential submissions for FINBRIDGE\cthompson triggered the account lockout threshold. Continued wrong-password attempts from an additional source (10.10.8.112) were also recorded.

Scope: This incident affected one user only: FINBRIDGE\cthompson. Systems observed in evidence were DESKTOP-FB022 (10.10.1.88) and a second source IP 10.10.8.112.

Workaround: Restore service by applying account recovery actions through service desk/admin path, including account enablement, then re-test user sign-in. In this incident, account enabled at 09:08:14 was followed by successful interactive login at 09:09:01.

Permanent fix: Perform credential remediation on involved sources to remove or update stale stored credentials and stop repeated invalid submissions. Keep the lockout recovery process coupled with source-based credential cleanup and post-recovery monitoring before closure.

How to spot it: Look for Security log sequence: Event 4776 with error 0xC000006A (wrong password), repeated Event 4625 bad-password failures, Event 4740 lockout, and Event 4771 with failure code 0x18 (wrong password). Confirmation of recovery is Event 4722 (account enabled) followed by Event 4624 successful interactive logon.