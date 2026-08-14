# Legal Document Manager v2 Issue - Crash Wave: Analysis

Date of analysis: 2026-08-14  
Incident window (from provided data): 2024-03-25 08:00-11:00  
Analyst function: DWP

## Objective
Build a fact-grounded, cross-source validation path that tests the top three likely causes without prematurely asserting root cause.

## Scope Facts (Only)

### Source 1: Nexthink DEX export (Device group `Legal-Win11`, 45 devices)
- 08:00: DEX `91`, app crash rate `0.1%`, disk I/O `Normal`
- 09:00: DEX `90`, app crash rate `0.2%`, disk I/O `Normal`
- 10:00: DEX `58`, app crash rate `6.2%`, disk I/O `High`
- 11:00: DEX `55`, app crash rate `6.8%`, disk I/O `High`
- Top crashing process in 10:00-11:00 window: `DocManager.exe` (`74%` of all crashes in that window)

### Source 2: SCCM deployment log
- 09:38:20: Deployment started: `Legal Document Manager v2.1` to collection `Legal-Win11` (45 devices)
- 09:44:07: Install completed on `45/45` devices
- 09:44:07: Install result `Success`, `0 failures`

### Package and fleet details
- Previous version: `Document Manager v2.0` (stated stable, deployed 6 weeks earlier)
- New version: `Document Manager v2.1`
- Vendor note for v2.1: new auto-save feature; known limitation on devices with under 8GB RAM where auto-save indexing can cause high disk I/O and intermittent crashes in first few hours after installation while initial index builds
- Legal-Win11 hardware mix: `60%` with 8GB RAM, `40%` with 4GB RAM

## Consolidated Evidence Map (Cross-Source)

| Evidence point | Nexthink DEX export | SCCM/Package context | Correlation significance |
|---|---|---|---|
| Baseline stability before event | 08:00 and 09:00 show high DEX (91/90), low crashes (0.1%/0.2%), Normal disk I/O | No deployment completed yet | Establishes stable pre-change baseline |
| Change introduction | Crash and DEX deterioration begins by 10:00 | v2.1 completed at 09:44 on all 45 devices | Temporal adjacency is strong (about 16 minutes) |
| Symptom pattern | High disk I/O and sharp crash increase at 10:00 and 11:00 | Vendor note names high I/O + intermittent crashes during initial indexing post-install | Symptom-level match is direct |
| Process concentration | DocManager.exe = 74% of crashes in impact window | New app version deployed is Legal Document Manager v2.1 | Process-level match with changed component |
| Population susceptibility | Fleet contains 40% 4GB devices | Vendor limitation specifically references under-8GB devices | Exposure condition exists in affected fleet |

## Correlation Across Sources (Timing + Content)
- Baseline before deployment (08:00, 09:00): high DEX, very low crash rate, normal disk I/O.
- Deployment was fully completed by 09:44.
- First degraded telemetry point appears at 10:00 (about 16 minutes after deployment completion):
	- DEX drops from 90 to 58
	- Crash rate rises from 0.2% to 6.2%
	- Disk I/O changes from Normal to High
- Degraded state persists at 11:00 (DEX 55, crash 6.8%, disk High).
- Dominant crashing process in that exact degraded window is `DocManager.exe` (74% of crashes), which matches the newly deployed application/process family.
- Vendor known limitation explicitly links:
	- initial post-install period
	- high disk I/O
	- intermittent crashes
	- higher risk condition (<8GB RAM), present in 40% of this fleet.

## Ranked Likely Causes and Decision Tests

## 1) Vendor-known v2.1 indexing limitation on <8GB devices
Why it fits the evidence:
- Strong timing fit: symptom spike starts immediately after successful deployment completion.
- Symptom fit: high disk I/O and crash surge are exactly named in vendor limitation.
- Process fit: `DocManager.exe` is the top crashing process during impact window.
- Exposure fit: 40% of 45 devices are 4GB RAM (about 18 devices), which is a substantial at-risk segment.

Decision test:
- Query crash rate and disk I/O by RAM tier for 09:44-12:00.
Pass condition (supports cause):
- 4GB cohort shows significantly higher DocManager crash density and higher disk pressure than 8GB cohort.
Fail condition (weakens cause):
- No meaningful difference between RAM tiers.

Fast remediation if supported:
- Freeze v2.1 in Legal, rollback affected devices to v2.0, and apply vendor-recommended config/patch before controlled redeployment.

## 2) General v2.1 regression independent of RAM tier
Why it fits the evidence:
- `DocManager.exe` dominates crash share after upgrade.
- Prior version is stated stable and major metric shift aligns with version change.
- Could affect both RAM tiers if there is a broader defect in v2.1.

Decision test:
- Compare DocManager crash rate on 8GB endpoints vs 4GB endpoints; review crash signatures for a common defect pattern across both tiers.
Pass condition (supports cause):
- Similar crash signature and elevated crash rates across both RAM tiers.
Fail condition (weakens cause):
- Crashes heavily concentrated in 4GB and linked to indexing phases.

Fast remediation if supported:
- Broad rollback to v2.0 and vendor defect escalation with reproducible evidence set.

## 3) Synchronized first-run load wave from all-at-once deployment
Why it fits the evidence:
- 45/45 installs completed quickly; concurrent first-run behavior can create synchronized load.
- Telemetry shows immediate fleet-wide disk I/O elevation and sustained crash increase.
- This mechanism can coexist with and amplify the vendor-documented low-RAM limitation.

Decision test:
- Measure crash and disk spike synchronization shortly after first post-upgrade app launch across endpoints.
Pass condition (supports cause):
- Tight timing cluster across many devices around first-run indexing.
Fail condition (weakens cause):
- Load/crash timing is random and not clustered to deployment + first-run events.

Fast remediation if supported:
- Stagger rollout and/or stagger indexing startup; enforce deployment rings.

## Data Gaps / Uncertainty (Explicit)
- No device-level crash-by-RAM breakdown was provided.
- No app crash stack traces, WER signatures, or exception codes were provided.
- No endpoint storage-health counters beyond categorical `High/Normal` were provided.
- No explicit error code taxonomy is present in the supplied records; therefore no error-code meaning interpretation is asserted.

## Fast Evidence Collection Sequence (Operational)
1. Pull per-device telemetry (crash count, disk active time, disk queue) for 09:30-12:00.
2. Join telemetry with hardware RAM profile (4GB vs 8GB) and installed app version.
3. Split crash data by process and by timestamp relative to install completion.
4. Build two comparisons:
- 4GB vs 8GB behavior
- first 2 hours post-install vs pre-install baseline hour
5. Decide ranked-cause confidence using the pass/fail conditions above.

## Scope-Bounded Interpretation Rules
- Use only observed metrics and provided vendor note text.
- Do not infer undocumented error-code meanings.
- Treat SCCM `install success` as deployment transport success only, not application runtime health.

## Output of This Validation Plan
- A ranked-cause confidence update with one selected working hypothesis.
- A remediation choice tied to the confirmed pattern.
- A verification checklist to confirm post-remediation stabilization.

## Status
- This document is an analysis/validation artifact and does not assert final RCA by itself.