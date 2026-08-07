# Root Cause Analysis — RDP Connection Failure and Account Lockout
**Reference:** INC-2024-0315-RDP-001  
**Date of Incident:** 2024-03-15  
**Prepared by:** DWP Analyst  
**Status:** Closed  

---

## 1. Incident Summary

| Field | Detail |
|---|---|
| Affected Service | Remote Desktop Protocol (RDP) access |
| Affected User | `FINBRIDGE\bwalker` |
| Source Client IP | `10.10.5.44` |
| First Recorded Failure | 14:01:02 |
| Account Locked | 14:05:34 |
| Successful TCP Reconnect | 14:22:07 |
| Successful Logon | 14:22:09 |
| Impact | User unable to establish RDP session until account lockout was cleared or expired |
| User Impact Window | At least 21 minutes 7 seconds based on supplied events |

---

## 2. Event ID Reference

| Event ID | Source | What it records |
|---|---|---|
| **56** | TermDD | The Terminal Server security layer detected an error in the RDP protocol stream and disconnected the client. This often appears when authentication or session negotiation fails and the connection is dropped. On its own it does not prove a network fault. |
| **140** | RemoteDesktopServices-RdpCoreTS | An RDP connection attempt failed and records the reason. In this case it explicitly states that the user name or password was not correct. |
| **4625** | Security | A logon attempt failed. Records the account, failure reason, logon type, and source IP or workstation. Here logon type `10` confirms a failed RemoteInteractive logon, which is an RDP sign-in attempt. |
| **4740** | Security | A user account was locked out. Records which account was locked and the caller computer or source that triggered the lockout threshold. |
| **131** | RemoteDesktopServices-RdpCoreTS | The server accepted a new inbound TCP connection from an RDP client. This confirms the client could reach the RDP server network endpoint. It is a connection acceptance event, not yet proof of successful authentication. |
| **4624** | Security | A logon succeeded. Records account, logon type, and source IP or workstation. Here logon type `10` confirms a successful RDP sign-in. |

---

## 3. Event Log Evidence

| Time | Event ID | Description |
|---|---|---|
| 14:01:02 | 56 | TermDD detected an error in the protocol stream and disconnected client `10.10.5.44`. |
| 14:01:02 | 140 | RDP connection from `10.10.5.44` failed because the user name or password was not correct. |
| 14:01:04 | 4625 | Failed logon for `FINBRIDGE\bwalker`; failure reason `Unknown username or bad password`; logon type `10`; source IP `10.10.5.44`. |
| 14:03:18 | 4625 | Second failed RDP logon for `FINBRIDGE\bwalker` from `10.10.5.44` with bad credentials. |
| 14:05:33 | 4625 | Third failed RDP logon for `FINBRIDGE\bwalker` from `10.10.5.44` with bad credentials. |
| 14:05:34 | 4740 | `FINBRIDGE\bwalker` account locked out; caller computer/source `10.10.5.44`. |
| 14:22:07 | 131 | Server accepted a new TCP connection from client `10.10.5.44:52341`. |
| 14:22:09 | 4624 | Successful RDP logon for `FINBRIDGE\bwalker`; logon type `10`; source IP `10.10.5.44`. |

---

## 4. Sequence of Events — Plain English

1. At 14:01:02, the user at client `10.10.5.44` attempted to open an RDP session.
2. The RDP stack dropped the session during security negotiation, and the RDP Core event immediately clarified why: the supplied username or password was not correct.
3. Two seconds later, Security Event `4625` confirmed a failed Remote Desktop logon for `FINBRIDGE\bwalker` from the same source IP.
4. The user tried again at 14:03:18 and then again at 14:05:33. Both attempts failed for the same reason: bad credentials.
5. One second after the third failed attempt, at 14:05:34, the account lockout threshold was reached and Active Directory locked the `FINBRIDGE\bwalker` account. The lockout was attributed to source `10.10.5.44`.
6. At 14:22:07, the same client established a fresh TCP connection to the RDP server, proving network reachability to the RDP endpoint was available.
7. At 14:22:09, the user successfully authenticated over RDP. That indicates the credentials issue had been resolved by that point, either because the correct password was used and the account had been unlocked or the lockout duration had expired.

---

## 5. Most Likely Cause

**Most likely cause of the RDP connection failure:** repeated use of incorrect credentials for `FINBRIDGE\bwalker` during RDP sign-in from client `10.10.5.44`, followed by an account lockout that blocked further access until recovery.

This is stronger than calling it a generic "RDP problem." The logs point to authentication failure, not network loss, listener failure, or Remote Desktop service outage.

### Evidence

| Evidence | Significance |
|---|---|
| Event `140` explicitly says the user name or password is not correct | Direct server-side authentication failure message from the RDP stack |
| Three `4625` events for `FINBRIDGE\bwalker` with logon type `10` | Confirms repeated failed RemoteInteractive sign-in attempts over RDP |
| Same source IP `10.10.5.44` on all failed attempts | Shows a single client repeatedly submitted bad credentials |
| Event `4740` occurs one second after the third `4625` | Strong evidence that the failed logons directly triggered account lockout |
| Event `131` later shows server accepted a TCP connection from the same client | Confirms the server was reachable over the network, so the earlier issue was not basic connectivity |
| Event `4624` later shows successful logon type `10` from the same IP | Confirms RDP service and network path were functioning once valid authentication was possible |
| Event `56` occurs at the same time as Event `140` | Supports the interpretation that the session was disconnected during failed security negotiation, not because of an unrelated transport fault |

### What the logs prove

- The RDP server was reachable by client `10.10.5.44`.
- The failed connection attempts were RemoteInteractive logons.
- The credentials supplied during the first three attempts were rejected.
- The failed attempts directly led to account lockout.
- The same client later connected and authenticated successfully.

### What the logs do not prove by themselves

- Whether the wrong password was typed manually, cached incorrectly in the RDP client, or sourced from a saved credential.
- Whether the account was manually unlocked by support or unlocked automatically after the lockout duration expired.
- Whether the original failure was due to mistyping, a recent password change, or use of an outdated saved credential.

---

## 6. Five Why Analysis

### Why 1 — Why could the user not connect through Remote Desktop?
Because the RDP authentication attempts for `FINBRIDGE\bwalker` failed, so the session was disconnected before a usable desktop session could be created.

---

### Why 2 — Why did the RDP authentication attempts fail?
Because the server rejected the supplied credentials as incorrect. Event `140` explicitly states the username or password was not correct, and Event `4625` records `Unknown username or bad password` with logon type `10`.

---

### Why 3 — Why did the user keep failing authentication?
Because the same incorrect credential set was submitted multiple times from client `10.10.5.44`. This could have been caused by manual password entry mistakes, a recently changed password not reflected in memory, or stale saved RDP credentials.

| Probable Trigger | Why it fits the evidence |
|---|---|
| User typed the wrong password repeatedly | Fits the spaced retry pattern at 14:01, 14:03, and 14:05 |
| Saved RDP credential was outdated | Fits repeated failures from one client until later successful connection |
| Password had recently changed | Common cause of RDP lockouts with otherwise normal connectivity |

---

### Why 4 — Why did the issue escalate from failed connection attempts to full account lockout?
Because the account lockout policy threshold was reached after repeated failed RemoteInteractive logons, causing Event `4740`.

---

### Why 5 — Why was the user unable to recover immediately?
Because once the account was locked, the user could not continue authenticating until the lockout expired or the account was unlocked. The logs show successful access only at 14:22:09, roughly 16 minutes after lockout, which indicates recovery depended on policy timeout or administrator intervention rather than immediate self-correction.

---

## 7. Root Cause Statement

The RDP connection failure was caused by repeated submission of incorrect credentials for `FINBRIDGE\bwalker` from client `10.10.5.44`. Those failed Remote Desktop sign-in attempts triggered the account lockout policy, which then prevented access until the account was unlocked or the lockout period expired. There is no evidence in the supplied events of an RDP service outage or network connectivity fault.

---

## 8. Immediate Actions Taken

| Action | Owner | Status |
|---|---|---|
| Failed RDP attempts recorded and correlated to source `10.10.5.44` | Investigation | Complete |
| Account lockout recorded for `FINBRIDGE\bwalker` | Active Directory | Complete |
| Successful reconnection and RDP logon recorded | User/Support | Complete at 14:22:09 |

---

## 9. Recommendations

| Priority | Recommendation | Rationale |
|---|---|---|
| High | Check for saved or cached RDP credentials on client `10.10.5.44` and remove outdated entries | Prevents repeat lockouts from stale stored passwords |
| High | Confirm whether the user recently changed their password and reinforce post-change guidance for RDP access | Common root cause for repeated remote logon failures |
| Medium | Review account lockout threshold and duration against security policy and support burden | Reduces avoidable lockouts while preserving security intent |
| Medium | Consider self-service password reset or unlock capability if not already available | Shortens outage time for credential-related lockouts |
| Low | Educate users to stop after one or two failed RDP attempts and verify credentials before retrying | Prevents escalation from simple typo to account lockout |

---

## 10. Confidence and Limits

**Confidence level:** High.

The supplied events are sufficient to conclude that the RDP failure was caused by bad credentials leading to account lockout. The only unresolved detail is why the wrong credentials were being used, which requires user confirmation or client-side credential review.

---

*Document end — RCA-INC-2024-0315-RDP-001*