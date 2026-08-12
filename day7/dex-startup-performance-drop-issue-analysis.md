# Finance-Win11 startup-performance drop: likely causes (ranked)

## 1) Added startup compliance logging script in the new baseline (most likely)

Why it fits the evidence:
- The degradation starts immediately after the 2026-08-04 02:00 baseline deployment to Finance-Win11 only.
- Startup time roughly doubles at the same boundary (17.5 sec to 41.3 sec), consistent with added synchronous work during logon/startup.
- IT-Win11 did not receive the change and remains flat, which strongly supports a change-localized startup-path impact.

Fastest confirm/eliminate check:
- On 3-5 affected Finance-Win11 devices, temporarily disable or unlink only the new startup script assignment and force policy sync; compare next-login startup times against unchanged Finance devices.

## 2) Defender scan policy in the same baseline increasing boot/logon-time scanning

Why it fits the evidence:
- The same 02:00 Finance-only baseline included additional Defender policy, and the performance drop appears at first measurement after deployment.
- Sustained high startup times over subsequent days (41-44 sec range) fit a persistent policy effect rather than a one-time anomaly.
- Unchanged IT-Win11 metrics align with no policy exposure in that group.

Fastest confirm/eliminate check:
- Run an A/B policy test: exclude a small Finance pilot ring from only the new Defender scan settings while retaining other baseline settings; compare startup median over 1-2 login cycles.

## 3) Combined baseline interaction effect (startup script + Defender policy contention)

Why it fits the evidence:
- Both controls were introduced together at the exact onset point; either alone may be tolerable, but overlap at logon can amplify delay.
- The clean control group indicates the issue is tied to the changed configuration set, making interaction inside that set a plausible third explanation.

Fastest confirm/eliminate check:
- Split the baseline into two staged assignments for pilot subgroups (script-only vs Defender-only) and compare startup deltas to the full-baseline group within 24 hours.
