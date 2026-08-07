# AVD Black Screen Analysis and Hypothesis

## Scope facts
- Symptom: blank screen post login; clears after about 30 seconds for some users, persists for others.
- Who: about 40% of users on POOL-FIN-01.
- POOL-FIN-02 was not updated and is completely unaffected.
- Timing: first seen around 07:00 this morning.
- Change: overnight image update applied to POOL-FIN-01 at 02:00.

## Ranked causes, weighted toward the pool-only change
1. Logon shell or Explorer startup regression in the updated POOL-FIN-01 image.
2. Logon script or Group Policy change introduced by the POOL-FIN-01 image update.
3. Profile loading issue, including container timing or corruption exposed by the update.
4. Graphics or display stack regression in the updated image.
5. AVD host readiness or agent startup issue on updated POOL-FIN-01 hosts.

## Why the ranking is shaped this way
The strongest signal is that POOL-FIN-02 was not updated and is completely unaffected. That pushes the analysis toward a defect introduced by the POOL-FIN-01 overnight image, not a broader AVD, tenant, or network issue. The black screen that sometimes clears after about 30 seconds also fits a timing-sensitive logon-path failure better than a hard outage.

## Current hypothesis
The most likely issue is an image-scoped logon startup regression on POOL-FIN-01, most likely affecting shell initialization, a logon script, or a policy/profile dependency. The pool-only change and the partial self-recovery pattern both point to a startup sequence that is delayed or blocked on some sessions but eventually completes on others.

## Fastest discriminating check
Compare one affected POOL-FIN-01 host against an unaffected POOL-FIN-02 host at the same stage of logon, focusing on Explorer start, userinit, Group Policy processing, and profile load events. If POOL-FIN-01 shows a delay or failure in one of those steps and POOL-FIN-02 does not, the image-related startup-path hypothesis is strengthened.

## Working assumption
Do not assume a single root cause yet. Treat this as a pool-specific image regression until host-level or event-log evidence proves otherwise.

## Event details from affected host
- 07:02:10 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21: Remote Desktop Services session logon succeeded for FINBRIDGE\mlopez.
- 07:02:14 - Microsoft-Windows-Kernel-General Event 1: system boot time recorded as 2024-03-15 02:03:11, matching the overnight image update window.
- 07:02:16 - Application Error Event 1000: dwm.exe faulted in igdumd64.dll with exception code 0xc0000005.
- 07:02:17 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 40: session disconnected.
- 07:02:18 - Desktop Window Manager Event 9009: DWM exited with code 0x40010004.
- 07:02:44 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21: logon succeeded again on reconnect.
- 07:02:46 - Application Error Event 1000: dwm.exe faulted again in igdumd64.dll.
- 07:02:47 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 40: session disconnected again.
- 07:03:01 - Desktop Window Manager Event 9009: DWM exited again with code 0x40010004.
- 07:08:22 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21: another user logon succeeded on the same host.
- 07:08:24 - Application Error Event 1000: dwm.exe faulted again in igdumd64.dll.
- Comparison host SHFIN-02-A on POOL-FIN-02 showed 07:01:46 Desktop Window Manager Event 9011 started successfully and no Application Error events in the same window.

## Reviewed hypothesis
The evidence now most strongly supports a graphics or display stack regression in the updated POOL-FIN-01 image. The repeated pattern of successful logon followed immediately by dwm.exe crashing in igdumd64.dll, plus the matching DWM exit events, is more consistent with a display-layer failure than with shell, policy, profile, or agent startup problems.

## Revised resolution steps
1. Confirm the graphics driver and image build on POOL-FIN-01, with emphasis on igdumd64.dll version 31.0.101.4146 and the 02:00 update.
2. Compare the updated POOL-FIN-01 host against POOL-FIN-02 to verify the driver and image mismatch.
3. Check whether the dwm.exe and igdumd64.dll crash pattern appears on all POOL-FIN-01 hosts or only a subset.
4. Roll back the graphics component or the full image to the last known good version if the failure is replicated.
5. Validate the rollback on one drained host before wider rollout.
6. Retest affected user logons and confirm that DWM starts successfully without Event 1000 or 9009 entries.

## Updated working note
The pool-only update clue still matters, but the event log evidence shifts the operational focus from a general startup-path investigation to a host-local display stack regression introduced by the overnight image update.