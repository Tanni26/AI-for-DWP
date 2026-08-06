# Incident Analysis — Account Lockout: jsmith
**Reference:** INC-2024-0315-001  
**Date of Incident:** 2024-03-15  
**Prepared by:** DWP Analyst  

---

## Event ID Reference

| Event ID | Type | What it records |
|---|---|---|
| **4625** | Audit Failure | A logon attempt failed. Records the account name, failure reason, source machine, and logon type. Generated each time credentials are rejected. |
| **4740** | Audit Failure | An account was locked out. Records which account was locked and the machine that triggered the lockout threshold. |
| **4722** | Audit Success | A user account was enabled (re-activated or unlocked by an admin). Records who performed the action. |
| **4624** | Audit Success | A logon succeeded. Records account, machine, and logon type. Confirms the session was established. |

---

## Raw Events

| Time | Event ID | Detail |
|---|---|---|
| 08:02:14 | 4625 | Failed logon — bad password, Interactive (Type 2), DESKTOP-FB001 |
| 08:04:22 | 4625 | Failed logon — bad password, Interactive (Type 2), DESKTOP-FB001 |
| 08:06:01 | 4740 | Account locked out — triggered by DESKTOP-FB001 |
| 08:07:45 | 4625 | Failed unlock attempt — account already locked, Unlock (Type 7) |
| 08:22:10 | 4722 | Account enabled by FINBRIDGE\helpdesk-admin |
| 08:23:44 | 4624 | Successful interactive logon |

---

## Sequence of Events — Plain English

1. **08:02:14** — `jsmith` attempts to log in interactively at `DESKTOP-FB001` with the wrong password. First failed attempt recorded.
2. **08:04:22** — `jsmith` tries again at the same machine two minutes later. Still fails with bad credentials. Second failed attempt recorded.
3. **08:06:01** — The account lockout threshold is reached. Active Directory locks `jsmith`'s account. The lockout is attributed to `DESKTOP-FB001`.
4. **08:07:45** — `jsmith` attempts a screen unlock (Logon type 7) — likely tried to unlock a screensaver or Windows lock screen — but the account is already locked. Failure reason has now changed to *"Account locked out"* rather than bad password.
5. **08:22:10** — Helpdesk (`FINBRIDGE\helpdesk-admin`) enables/unlocks the account, approximately 16 minutes after lockout.
6. **08:23:44** — `jsmith` logs in successfully via interactive logon. Incident resolved.

---

## Most Likely Cause

**The user entered their password incorrectly at least twice in quick succession at the physical machine, triggering the account lockout policy.**

### Evidence

| Evidence | Significance |
|---|---|
| Both 4625 events originate from **DESKTOP-FB001** using **Logon type 2 (Interactive)** | Physical keyboard login — not a background service, scheduled task, or remote connection |
| Two-minute gap between failures | Consistent with a user manually typing, failing, pausing, and trying again — not an automated attack |
| Only 2 failures logged before lockout | Lockout threshold is configured at 2–3 attempts, which is aggressive for interactive logons |
| 4625 at 08:07:45 uses **Logon type 7 (Unlock)** | Confirms jsmith was physically present and tried to unlock the screen after lockout occurred, unaware the account was locked |
| No 4625 events from any other source machine | Rules out a password spray, stale cached credential from another device, or a background service as the trigger |

### Probable Reason for Wrong Password

- Password recently changed and the new one was not recalled correctly, **or**
- Caps Lock was active during entry, **or**
- User returned from leave and used an old memorised password

User confirmation required to determine which of the above applies.

---

*See also: [rca-jsmith-account-lockout.md](rca-jsmith-account-lockout.md) for the full Root Cause Analysis with 5 Why.*
