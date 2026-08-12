# L1 KB: AVD Black Screen After Login (Finance Pool)

Version: 1.0 | Date: 07/08/2026 | Status: Draft

Use this article when a Finance user can sign in to AVD but sees a black screen after login.

## Scope
- In scope: Finance users on `POOL-FIN-01` with post-login black screen.
- Out of scope: Password reset, MFA failure, no internet, or full AVD outage.

## User-reported pattern
- "I can log in, but I only see a black screen."
- Some sessions recover after about 30 seconds.
- Some sessions stay black until reconnect.

## L1 quick actions (safe, no platform change)
1. Ask user to wait 30 to 60 seconds after login once.
Expected result: desktop loads for transient cases.

2. If still black, ask user to disconnect the AVD session (do not shut down endpoint).
Expected result: session closes cleanly.

3. Wait 60 seconds, then ask user to reconnect.
Expected result: a fresh session starts and desktop renders.

4. If still black, force log off the user session from AVD.
Path: Azure Portal > Azure Virtual Desktop > Host pools > `POOL-FIN-01` > Session hosts > select host > User sessions > select user > Log off
Expected result: stale/hung user session is terminated.

5. Ask user to log in again.
Expected result: desktop is usable.

## Compare check (required before escalation)
1. Confirm if issue is only on `POOL-FIN-01` users.
2. Check if users on `POOL-FIN-02` can log in normally.
Expected result: if `POOL-FIN-02` is healthy and `POOL-FIN-01` is failing, escalate as pool-specific incident.

## Escalate to L2/L3 when
- Black screen persists after one forced logoff and reconnect.
- Two or more users report same symptom within 30 minutes.
- Any host in `POOL-FIN-01` shows repeated disconnects after successful login.

Escalation article:
- [day5/l2-l3-kb-avd-black-screen-finance-pool.md](day5/l2-l3-kb-avd-black-screen-finance-pool.md)

## Evidence L1 must capture in ticket
- Username and affected time (local timezone).
- Host pool name (`POOL-FIN-01` or `POOL-FIN-02`).
- Session host name if visible.
- Whether 30 to 60 second wait helped.
- Whether disconnect/reconnect helped.
- Whether forced logoff helped.
- Number of users impacted.

## Optional log clue for L1 (only if access exists)
If Event Viewer access is available on affected host, note if these events appear around login time:
- TerminalServices-LocalSessionManager Event ID `21` (logon succeeded)
- Application Error Event ID `1000` (`dwm.exe`, `igdumd64.dll`)
- Desktop Window Manager Event ID `9009`

Do not perform driver/image changes at L1.