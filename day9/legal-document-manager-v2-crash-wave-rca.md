# Legal Document Manager v2 Issue - Crash Wave: RCA

Date of RCA: 2026-08-14  
Incident date: 2024-03-25  
Affected group: `Legal-Win11` (45 devices)  
Purpose: Formal supporting evidence and reasoning record for the selected hypothesis and corrective plan.

## Incident Summary
A morning crash wave impacted Legal users on Floor 6 after deployment of `Legal Document Manager v2.1`. The event is characterized by a sudden DEX drop, a sharp rise in app crash rate, high disk I/O, and concentration of crashes in `DocManager.exe` shortly after the deployment completed.

## A. Incident Context
- Organization area: Legal, Floor 6
- Endpoint group: `Legal-Win11`
- Fleet size: 45 devices
- Reported symptom: wave of app crashes during the morning business window

## B. Source Evidence (Verbatim Facts)

### B1. Nexthink DEX export snapshots
- 2024-03-25 08:00: DEX 91, app crash rate 0.1%, disk I/O Normal
- 2024-03-25 09:00: DEX 90, app crash rate 0.2%, disk I/O Normal
- 2024-03-25 10:00: DEX 58, app crash rate 6.2%, disk I/O High
- 2024-03-25 11:00: DEX 55, app crash rate 6.8%, disk I/O High
- Top crashing process (10:00-11:00): DocManager.exe (74% of all crashes)

### B2. SCCM deployment log
- [09:38:20] Deployment started: Legal Document Manager v2.1 to Legal-Win11 (45 devices)
- [09:44:07] Install completed: 45 of 45 devices
- [09:44:07] Install result: Success, 0 failures

### B3. Package/fleet metadata
- Previous version: Document Manager v2.0 (noted stable, deployed 6 weeks earlier)
- New version: Document Manager v2.1
- Vendor release note limitation:
  - Under 8GB RAM devices can experience high disk I/O and intermittent crashes in initial hours post-install during auto-save index build
- Hardware profile:
  - 60% 8GB RAM
  - 40% 4GB RAM

## C. Correlation Matrix

| Correlated factor | Observation | Interpretation boundary |
|---|---|---|
| Change timing | Full deployment completed at 09:44; severe telemetry shift appears at 10:00 | Strong temporal relationship, not by itself absolute proof |
| Process ownership of crashes | DocManager.exe causes 74% of crashes in impact window | Strong association to newly deployed app |
| Symptom type | High disk I/O appears exactly when crashes spike | Matches vendor-described limitation pattern |
| Fleet susceptibility | 40% under 8GB RAM | Vulnerable cohort exists in meaningful size |
| Persistence | Degraded metrics continue through 11:00 | Consistent with initial-hours index build impact window |

## D. Finalized Hypothesis (Selected)
Most likely cause selected for final remediation path:
- `Document Manager v2.1` first-hours auto-save indexing behavior triggered instability on the under-8GB segment (4GB devices), producing high disk I/O and elevated `DocManager.exe` crashes, with fleet-level telemetry degradation.

Why this is selected over alternatives:
- Exact timing alignment with deployment completion.
- Exact symptom alignment with vendor-documented limitation (high disk I/O + intermittent crashes in early post-install window).
- Process-level concentration in the deployed application.
- Material presence of vulnerable hardware profile (4GB = 40% of fleet).

## E. Ranked Cause Assessment (With Confidence)
1. v2.1 auto-save indexing limitation on <8GB endpoints
- Confidence: High
- Why: alignment across timing, process, symptom type, and known limitation text

2. Broader v2.1 regression independent of RAM profile
- Confidence: Medium
- Why: version change + process concentration support this, but RAM-specific known limitation provides a tighter fit

3. Synchronized post-install load wave from all-at-once deployment
- Confidence: Medium-Low
- Why: can amplify symptoms, but still likely secondary to app behavior itself

## F. Supporting Timeline
- 08:00-09:00: Stable pre-change baseline (high DEX, low crash rate, normal disk I/O).
- 09:38:20: v2.1 deployment starts.
- 09:44:07: v2.1 deployment completes successfully on all 45 devices.
- 10:00: First post-change measurement shows severe degradation.
- 11:00: Degradation persists; top crashing process remains DocManager.exe in this window.

## G. Corrective Action Plan (Exact Sequence)
1. Initiate incident change control and notify Legal stakeholders of mitigation plan.
2. Freeze further v2.1 deployment to Legal-related collections.
3. Identify impacted endpoints by criteria:
- RAM < 8GB and/or elevated `DocManager.exe` crash count after 09:44.
4. Roll back `Document Manager v2.1` to `v2.0` on impacted devices first (priority: 4GB endpoints), then complete rollback for remaining unstable devices.
5. Apply vendor-approved mitigation for auto-save indexing (policy/feature toggle/throttle), if available.
6. Clear/rebuild local app index only per vendor-safe procedure on devices that continue crashing.
7. Reintroduce v2.1 only in phased rings:
- Ring 1: limited 8GB subset
- Ring 2: broader 8GB
- Ring 3: 4GB cohort only after stable validation
8. Keep enhanced monitoring enabled during each ring for at least one business cycle.

## H. Correct Order of Operations
1. Stop blast radius (`freeze deployment`).
2. Stabilize service quickly (`targeted rollback on impacted devices`).
3. Apply configuration mitigation (`disable/throttle indexing behavior`).
4. Validate health metrics (`crash rate, disk I/O, DEX`).
5. Controlled re-rollout by hardware rings.
6. Confirm sustained stability and close incident.

## I. Verification Standard
Resolution is verified only if all checks pass:
- `DocManager.exe` crash share drops materially from incident levels.
- Group crash rate trends back toward pre-incident baseline.
- Disk I/O state returns from High toward Normal during business load.
- DEX trend recovers materially from 55-58 range.
- No renewed crash wave during pilot ring reintroduction.

## J. 5 Whys (Formal)
1. Why did Legal report a crash wave?
- Because app crash rate rose from 0.2% to over 6% after 10:00, with user-visible instability.

2. Why did crashes increase sharply?
- Because `DocManager.exe` accounted for most crashes (74%) in the impacted period.

3. Why did `DocManager.exe` become unstable during that window?
- A new application version (v2.1) had just been deployed to all devices, and symptoms started immediately afterward.

4. Why would v2.1 create both crash spikes and disk stress?
- Vendor notes a known limitation: first-hours auto-save indexing can cause high disk I/O and intermittent crashes on devices under 8GB RAM.

5. Why was the fleet broadly affected instead of isolated to very few users?
- 40% of the fleet is 4GB RAM and deployment was completed to all 45 devices in one wave, allowing vulnerable devices to contribute a visible group-level degradation.

## K. Preventive Actions
1. Hardware-aware deployment policies
- Block risky features/versions from low-memory cohorts until validated.
2. Ring-based deployment governance
- Prohibit full-cohort first-wave rollout for packages with known runtime caveats.
3. Post-deploy guardrail monitoring
- Trigger alerts on process-specific crash concentration and sustained high disk I/O.
4. Vendor-note operationalization
- Convert release-note limitations into pre-approved mitigation playbooks.
5. Pilot composition control
- Maintain pilot sets that intentionally include lowest-spec hardware.

## L. Assumptions and Constraints
- This RCA uses only the provided two data sources and package metadata.
- No endpoint-level crash dumps, exception signatures, or RAM-tiered crash exports were included.
- No error-code interpretation is required from the supplied data; none is asserted.