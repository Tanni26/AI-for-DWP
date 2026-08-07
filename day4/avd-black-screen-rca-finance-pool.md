# RCA - AVD Black Screen on POOL-FIN-01

## Incident summary
On 2024-03-15, Finance users in POOL-FIN-01 reported a black screen immediately after AVD logon. Some sessions recovered after about 30 seconds, while others remained blocked and required support intervention. POOL-FIN-02, which was not included in the overnight image update, remained unaffected. The issue was resolved at 10:00 AM after the recommended remediation was applied and users were confirmed able to log in normally.

## Impact
- Affected population: approximately 40% of users assigned to POOL-FIN-01.
- Unaffected population: POOL-FIN-02 users, including IT staff.
- Business impact: Finance users could not reliably access their virtual desktops during the morning start window.
- Duration of active impact: from roughly 07:00 AM until resolution at 10:00 AM.

## Root cause
The incident was caused by a graphics or display stack regression introduced by the overnight image update on POOL-FIN-01. The strongest evidence points to a failure in Desktop Window Manager (dwm.exe) faulting in igdumd64.dll immediately after successful session logon. That pattern repeated on affected logons and did not occur on the unaffected POOL-FIN-02 host.

## Supporting evidence

### Scope facts
- Symptoms were limited to POOL-FIN-01.
- POOL-FIN-02 was not updated and had no reported black screen issues.
- The first report arrived around 07:00 AM, after the 02:00 AM image update.
- The symptom was a blank screen after logon, with partial self-recovery on some sessions.

### Event log evidence from affected host SHFIN-01-A
- 07:02:10 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21: session logon succeeded for FINBRIDGE\mlopez.
- 07:02:14 - Microsoft-Windows-Kernel-General Event 1: host boot time recorded as 2024-03-15 02:03:11, aligning with the overnight update window.
- 07:02:16 - Application Error Event 1000: dwm.exe faulted in igdumd64.dll with exception code 0xc0000005.
- 07:02:17 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 40: session disconnected.
- 07:02:18 - Desktop Window Manager Event 9009: DWM exited with code 0x40010004.
- 07:02:44 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21: logon succeeded again on reconnect.
- 07:02:46 - Application Error Event 1000: dwm.exe faulted again in igdumd64.dll.
- 07:02:47 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 40: session disconnected again.
- 07:03:01 - Desktop Window Manager Event 9009: DWM exited again with code 0x40010004.
- 07:08:22 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21: another user logon succeeded on the same host.
- 07:08:24 - Application Error Event 1000: dwm.exe faulted again in igdumd64.dll.

### Comparison evidence from unaffected host SHFIN-02-A
- 07:01:44 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21: session logon succeeded.
- 07:01:46 - Desktop Window Manager Event 9011: Desktop Window Manager started successfully.
- No Application Error events were present in the same window.
- Image version on this host was pre-update: 10.0.22621.2861-build-20240313.

### Interpretation
- The fault occurs after successful logon, not before it.
- The same fault repeats on reconnect and on subsequent users on the affected host.
- The fault is specific to dwm.exe and igdumd64.dll, which is consistent with a graphics/display regression.
- The unaffected host provides a clean comparison case that did not show the same fault pattern.

## Timeline

| Time | Event |
| --- | --- |
| 02:00 AM | Overnight image update applied to POOL-FIN-01. |
| 02:03:11 AM | Affected host boot time recorded after restart. |
| ~07:00 AM | First user reports black screen after logon. |
| 07:02:10 AM | FINBRIDGE\mlopez logs on successfully to SHFIN-01-A. |
| 07:02:16 AM | dwm.exe crashes in igdumd64.dll. |
| 07:02:17 AM | Session disconnects. |
| 07:02:18 AM | DWM exits with code 0x40010004. |
| 07:02:44 AM | Reconnect logon succeeds. |
| 07:02:46 AM | dwm.exe crashes again in igdumd64.dll. |
| 07:02:47 AM | Session disconnects again. |
| 07:03:01 AM | DWM exits again with code 0x40010004. |
| 07:08:22 AM | Another user logs on to the same host successfully. |
| 07:08:24 AM | dwm.exe crashes again in igdumd64.dll. |
| 10:00 AM | Suggested remediation applied; users confirmed able to log in to POOL-FIN-01 without issue. |

## 5 Why analysis

### 1. Why did users see a black screen after logon?
Because Desktop Window Manager failed immediately after successful logon, preventing the desktop from rendering correctly.

### 2. Why did Desktop Window Manager fail?
Because dwm.exe crashed repeatedly with Application Error Event 1000.

### 3. Why did dwm.exe crash?
Because it faulted in igdumd64.dll with exception code 0xc0000005, which points to the graphics driver path.

### 4. Why was the graphics path failing only on POOL-FIN-01?
Because POOL-FIN-01 received the overnight image update at 02:00, while POOL-FIN-02 did not and remained unaffected.

### 5. Why did the issue reach users instead of being caught earlier?
Because the updated image was not sufficiently validated on a pool-specific canary host or pilot group before broader rollout.

## Corrective action taken
- The recommended remediation was applied at 10:00 AM.
- After remediation, users were verified logging into POOL-FIN-01 successfully.
- No further black screen reports were received after the fix was in place.

## Preventive actions
1. Add POOL-FIN-01 image changes to a staged rollout process with a canary host or small pilot ring before production-wide deployment.
2. Include a post-update logon smoke test that verifies DWM starts successfully and no Application Error 1000 events are generated.
3. Track graphics driver and DWM-related component versions as a controlled dependency for AVD image changes.
4. Add automated monitoring for dwm.exe crashes, igdumd64.dll faults, and Desktop Window Manager Event 9009 on session hosts.
5. Require rollback readiness for image updates that affect the display stack or shell startup path.
6. Compare updated and non-updated pools immediately after rollout when symptoms appear in only one pool.

## Lessons learned
- Pool-scoped image updates can introduce regressions that are invisible on untouched pools.
- A black screen after logon can be a display-layer failure rather than a generic AVD connectivity problem.
- Reconnect behavior that works for some users but not others is a useful clue for timing-sensitive or component-specific failures.

## Closure statement
This incident was resolved once the image-related graphics remediation was applied and POOL-FIN-01 users were confirmed able to log in normally at 10:00 AM. The investigation supports a host-local display stack regression introduced by the overnight image update.