# Root Cause Analysis (RCA): Floor 6 Login Failures and Slow Windows Logins (Provisional)

**RCA Reference:** RCA-F6-LOGIN-2026-08-14  
**Document Owner:** IT Operations / End User Compute  
**Date Authored:** 2026-08-14  
**Incident Priority:** High (Service Availability)  
**Status:** Root Cause Not Yet Confirmed

---

## 1. RCA Title and Reference

- Title: Floor 6 Login Failures and Slow Windows Logins
- Reference: `RCA-F6-LOGIN-2026-08-14`
- Related triage source: `incident-2-login-and-performance-degradation.md`

---

## 2. Executive Summary

On Monday morning, multiple Legal users on Floor 6 were unable to sign in promptly, or experienced very long Windows login times. This disrupted legal work at the start of business hours and created immediate delivery risk.

At this stage, no diagnostic evidence has been provided that confirms a single technical cause. The most likely direction is a change-related issue linked to Friday's document management application rollout and/or recent Windows 11 and Intune changes, but this remains a hypothesis, not a confirmed root cause.

Immediate focus should be: stabilize user access first, preserve evidence, and run targeted checks to confirm whether the issue is caused by application startup behavior, policy processing, identity/authentication latency, or profile/synchronization delays.

---

## 3. Incident Description

IT Operations reported at 09:14 that Floor 6 was experiencing widespread login disruption. The report described at least a dozen users who either could not log in or were seeing very slow login completion. Floor 6 had recently migrated to Windows 11, been enrolled in Intune, and received a new document management application deployment on Friday afternoon.

No log extracts, event traces, diagnostic exports, or configuration diffs were available at the time of this RCA draft.

---

## 4. Business Impact

### Users Affected or Potentially Affected

- Known affected: at least 12 users (reported).
- Potentially affected: up to approximately 45 users on Floor 6 Legal.

### Productivity Impact

- Direct delay to case work, email processing, document review, and time-sensitive legal actions.
- Lost morning productivity due to repeated login attempts and wait times.
- Increased service desk and operations load due to concentration of high-priority incidents.

### Legal, Confidentiality, Compliance, and Reputational Risks

- No direct confidentiality breach is confirmed in this incident itself.
- Operational delay in Legal can still create contractual, regulatory, and client service risk.
- Reputational risk if partners and clients perceive IT instability in legal operations.

---

## 5. Scope

### Known Affected Population

- Floor 6 Legal users reporting login failure or severe slowness.

### Potentially Affected Population

- Other recently migrated Windows 11 users not yet reporting issues.
- Any users in similar Intune policy groups or deployment rings.

### Systems, Applications, Devices, Policies, and Services Involved

- Windows 11 endpoints (Floor 6).
- Intune enrollment and policy assignment.
- Identity/authentication services (Entra ID/Azure AD and related dependencies).
- Friday document management application deployment package.
- User profile and sync components (for example OneDrive/profile loading behavior).

---

## 6. Timeline of Known Events

- **Friday afternoon (exact time unknown):** New document management application deployed to Floor 6.
- **Recent period before Monday (exact dates/times unknown):** Floor 6 migration to Windows 11 completed; Intune enrollment completed.
- **Monday 09:14 (known):** IT Operations Lead reports widespread Floor 6 login failures/slowness.
- **Monday 09:14 onward (unknown details):** Number of additional users affected, exact login phase failure points, and any temporary recovery actions are not yet documented.

Missing timeline data:
- First impacted user and first symptom time.
- Whether symptoms started simultaneously or in waves.
- Whether any changes or rollbacks occurred between Friday deployment and Monday morning.

---

## 7. Confirmed Facts

1. Multiple Floor 6 users reported inability to log in or very slow login.
2. Floor 6 has approximately 45 users in Legal.
3. A new document management application was deployed Friday afternoon.
4. Floor 6 users were recently migrated to Windows 11.
5. Floor 6 users were recently enrolled in Intune.
6. No technical logs or validated diagnostics were supplied with the incident report.

---

## 8. Unconfirmed Information and Assumptions

### Unconfirmed Information

- Exact count of affected users and exact percentage at peak.
- Specific failure phase (credential entry, profile load, desktop initialization, post-login startup).
- Whether all affected users share the same device model/build/policy set.
- Whether issue reproduces outside Floor 6.
- Whether cloud authentication or on-network dependencies showed latency.

### Assumptions (Pending Validation)

- Assumption A: Friday deployment is causally related to Monday login degradation.
- Assumption B: A single common mechanism caused all reported login symptoms.
- Assumption C: Intune policy timing or profile sync behavior could have amplified delays during first business-hour sign-ins.

---

## 9. Initial Technical Assessment

Current assessment indicates a change-adjacent service degradation, but root cause remains unproven.

### Immediate Actions (Now)

1. Preserve endpoint and service evidence before further drift (event logs, Intune diagnostics, sign-in logs, deployment logs).
2. Triage by symptom phase (cannot authenticate vs authenticate but slow profile/desktop readiness).
3. Confirm scope quickly (Floor 6 only vs wider estate).
4. Apply business continuity measures (loaners, alternate devices, web-first workflows for urgent legal tasks).

### What to Tell Partners by Lunch

- The issue is being treated as a high-priority operational incident.
- User impact is real and active; root cause is not yet confirmed.
- IT is pursuing parallel checks across deployment changes, policy behavior, and sign-in/profile processing.
- Temporary workarounds are being used to keep legal operations moving while full remediation is developed.
- Next update will include evidence-backed cause statement or narrowed hypothesis set with decision points.

### Possible Relationship to Other Floor 6 Incidents

- Timing overlap suggests a shared change window, not yet a shared root cause.
- The Friday application rollout could plausibly affect login startup load, desktop state behavior, and content access pathways.
- Recent Windows 11 migration and Intune enrollment create a common configuration backdrop that can amplify multiple symptom types.
- Current position: incidents are tracked independently, with cross-correlation testing in parallel.

---

## 10. Potential Root-Cause Hypotheses

### Hypothesis 1: Friday Document Management App Introduced Login-Time Startup Contention

- **Likelihood:** High
- **Reasoning:** Strong temporal correlation with new deployment and concentrated floor-level symptoms.
- **Validate by:** Comparing affected vs unaffected devices for app install state and startup impact; testing login time with app disabled/uninstalled on controlled pilot devices.
- **Reject if:** Devices without app also show same delays, or disabling app has no measurable login improvement.

### Hypothesis 2: Intune Policy Application/Conflict Increased Login Processing Time

- **Likelihood:** Medium-High
- **Reasoning:** Recent enrollment and possible first-wave policy convergence can delay user readiness.
- **Validate by:** Reviewing policy assignment deltas, policy processing logs, and timing for affected devices.
- **Reject if:** No policy anomalies and no timing correlation between policy processing and delays.

### Hypothesis 3: Identity/Authentication or Dependency Latency During Peak Monday Sign-ins

- **Likelihood:** Medium
- **Reasoning:** Monday peak traffic can expose latency in sign-in paths, token refresh, DNS, or network dependencies.
- **Validate by:** Reviewing sign-in latency data and endpoint connectivity tests during incident window.
- **Reject if:** Authentication timings are normal while delays happen post-authentication.

### Hypothesis 4: Profile/Sync Load (for example user profile initialization or OneDrive/Known Folder behavior) Delayed Desktop Readiness

- **Likelihood:** Medium
- **Reasoning:** Recent migrations often surface profile and sync initialization bottlenecks.
- **Validate by:** Correlating slow login sessions with profile service and sync telemetry.
- **Reject if:** Affected users show normal profile/sync processing times.

### Hypothesis 5: Multiple Independent Issues Occurred Concurrently

- **Likelihood:** Medium
- **Reasoning:** Report mixes hard login failures and severe slowness, which may reflect different technical paths.
- **Validate by:** Symptom clustering and separate technical signatures per subgroup.
- **Reject if:** All cases share a single reproducible mechanism.

---

## 11. Five Whys Analysis (Provisional, Hypothesis-Based)

**Working hypothesis for Five Whys:** Change introduced Friday increased login-time processing and caused Monday degradation.

1. **Why were users unable to log in quickly?**  
   Because login processing was failing or taking unusually long for multiple Floor 6 users.

2. **Why was login processing failing/slow?**  
   Because one or more post-migration dependencies (application startup, policy application, or profile initialization) may have stalled or contended at login.

3. **Why would those dependencies stall at this time?**  
   Because a recent change set (Friday deployment plus recent migration/enrollment state) may have introduced additional login-time workload or misconfiguration.

4. **Why was this not detected before Monday peak usage?**  
   Because pre-production or pilot validation may not have fully tested Monday-morning concurrency and legal-user workflow conditions.

5. **Why was that validation gap present?**  
   Because change governance may not have required explicit sign-in performance gates for recently migrated Intune-managed legal endpoints.

**Provisional conclusion:** Root Cause Not Yet Confirmed. Most plausible direction is change-related login workload or policy/application contention, pending evidence.

---

## 12. Contributing Factors and Conditions

- Compressed change window: recent Windows 11 migration and Intune enrollment combined with Friday application deployment.
- High-concurrency timing: Monday morning legal department startup peak.
- Limited pre-incident observability in supplied data (no logs/metrics attached at escalation).
- Potential variance in endpoint state despite shared floor context (device age/model/profile history).
- Communication pressure due to simultaneous security concern and productivity incidents.
