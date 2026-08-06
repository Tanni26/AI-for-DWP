# Root Cause Analysis — Account Lockout: jsmith
**Reference:** INC-2024-0315-001  
**Date of Incident:** 2024-03-15  
**Prepared by:** DWP Analyst  
**Status:** Closed  

---

## 1. Incident Summary

| Field | Detail |
|---|---|
| Affected User | jsmith (FINBRIDGE domain) |
| Affected Machine | DESKTOP-FB001 |
| Incident Start | 08:02:14 |
| Account Locked | 08:06:01 |
| Account Unlocked | 08:22:10 (by FINBRIDGE\helpdesk-admin) |
| Successful Logon | 08:23:44 |
| Total Duration | ~22 minutes (lockout to resolution) |
| Impact | User unable to access their workstation for 22 minutes |

---

## 2. Event Log Evidence

| Time | Event ID | Description |
|---|---|---|
| 08:02:14 | 4625 | Failed logon — bad password, Interactive (Type 2), DESKTOP-FB001 |
| 08:04:22 | 4625 | Failed logon — bad password, Interactive (Type 2), DESKTOP-FB001 |
| 08:06:01 | 4740 | Account locked out — triggered by DESKTOP-FB001 |
| 08:07:45 | 4625 | Failed unlock attempt — account already locked, Unlock (Type 7) |
| 08:22:10 | 4722 | Account enabled by FINBRIDGE\helpdesk-admin |
| 08:23:44 | 4624 | Successful interactive logon |

---

## 3. Sequence of Events

1. User `jsmith` arrived at workstation `DESKTOP-FB001` and attempted to log in.
2. The password entered was incorrect — first failure logged at 08:02:14.
3. The user tried again approximately two minutes later — second failure logged at 08:04:22.
4. The domain account lockout threshold was reached; Active Directory locked the account at 08:06:01.
5. The user attempted to unlock the screen at 08:07:45, unaware the account was now locked — this attempt was also rejected.
6. The user contacted the helpdesk. The account was unlocked by `FINBRIDGE\helpdesk-admin` at 08:22:10.
7. The user logged in successfully at 08:23:44.

---

## 4. Root Cause

The user entered an incorrect password on two consecutive interactive logon attempts at their physical workstation, reaching the domain account lockout threshold and triggering an automatic lockout.

**Contributing factors identified:**
- The lockout threshold appears to be set to 2 or 3 attempts (only 2 failures logged before lockout), which is aggressive for interactive logons.
- No other source machines or services were involved — this was a single-user, single-device event.
- The most probable reason for the failed attempts is one of: forgotten password, recent password change not remembered, or Caps Lock active.

---

## 5. Five Why Analysis

### Why 1 — Why was the user locked out?
The Active Directory account lockout policy triggered because the number of consecutive failed logon attempts exceeded the configured threshold.

---

### Why 2 — Why did the failed logon attempts occur?
The user entered an incorrect password when attempting to log in interactively at DESKTOP-FB001. This happened twice within a four-minute window (08:02:14 and 08:04:22).

---

### Why 3 — Why did the user enter the wrong password?
Most likely one of the following (to be confirmed with the user):

| Probable Cause | Supporting Evidence |
|---|---|
| Password recently changed and the new password was not remembered correctly | Common pattern when lockouts occur early in the working day |
| Caps Lock was active | No technical evidence either way — requires user confirmation |
| User was logging into the machine for the first time after a period away (e.g. leave) and used an old password from memory | Plausible given the morning timestamp and manual retry gap |

No evidence of a malicious actor: both failures originated from the user's own assigned device using an interactive (physical keyboard) logon type.

---

### Why 4 — Why did the policy lock the account after only 2 failures?
The domain Group Policy account lockout threshold is configured at 2 or 3 attempts. This is more restrictive than the Microsoft baseline recommendation of 5–10 attempts for interactive logons, which increases the likelihood of legitimate users being locked out during normal, accidental mistyping.

> **Action required:** Verify current lockout threshold in Group Policy against the organisation's security policy and Microsoft's Identity Security baseline.  
> GPO path: `Computer Configuration > Windows Settings > Security Settings > Account Policies > Account Lockout Policy`

---

### Why 5 — Why was the lockout not self-resolved and required helpdesk intervention?
The organisation does not have a self-service password reset (SSPR) solution in place. Once locked out, the user had no mechanism to unlock their own account and had to wait approximately 16 minutes for helpdesk to respond and manually enable the account.

> **Action required:** Evaluate deployment of Microsoft Entra ID SSPR or an equivalent on-premises self-service unlock tool to reduce helpdesk burden and resolution time for this class of incident.

---

## 6. Immediate Actions Taken

| Action | Owner | Status |
|---|---|---|
| Account unlocked via FINBRIDGE\helpdesk-admin | Helpdesk | Complete (08:22:10) |
| User confirmed successful logon | Helpdesk | Complete (08:23:44) |

---

## 7. Recommendations

| Priority | Recommendation | Rationale |
|---|---|---|
| High | Review and document the current account lockout threshold. Consider raising to 5 attempts for interactive logons. | A threshold of 2–3 is unnecessarily low for physical workstation logons and creates excessive helpdesk tickets. |
| High | Deploy a self-service account unlock / password reset solution (e.g. Microsoft Entra SSPR). | 22-minute resolution time for a simple lockout is avoidable. SSPR would allow users to recover in under 2 minutes without helpdesk involvement. |
| Medium | Investigate whether jsmith had a recent password change. If so, ensure post-change communication includes clear guidance. | If the lockout was caused by a forgotten new password, the onboarding process for password changes should include a confirmation prompt or reminder. |
| Low | Confirm with the user whether Caps Lock or keyboard input was a contributing factor and provide brief guidance if needed. | Prevents recurrence from the same cause. |

---

## 8. Lessons Learned

- A restrictive lockout threshold reduces brute-force risk but significantly increases helpdesk load for legitimate user incidents. The right threshold is a balance — document the rationale either way.
- Logon type in event 4625 is a key diagnostic field. Logon type 2 (Interactive) immediately ruled out background services, cached credentials on other devices, and remote attacks as contributors — narrowing investigation time.
- The absence of 4625 events from any machine other than DESKTOP-FB001 is evidence that this was not a credential stuffing or lateral movement scenario.

---

*Document end — RCA-INC-2024-0315-001*
