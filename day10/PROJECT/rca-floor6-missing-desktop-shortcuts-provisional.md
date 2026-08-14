# Root Cause Analysis (RCA): Floor 6 Missing Desktop Shortcuts (Provisional)

**RCA Reference:** RCA-F6-DESKTOP-2026-08-14  
**Document Owner:** End User Compute / Service Desk  
**Date Authored:** 2026-08-14  
**Incident Priority:** Medium (User Productivity)  
**Status:** Root Cause Not Yet Confirmed

---

## 1. RCA Title and Reference

- Title: Floor 6 Missing Desktop Shortcuts
- Reference: `RCA-F6-DESKTOP-2026-08-14`
- Related triage source: `incident-3-missing-desktop-shortcuts.md`

---

## 2. Executive Summary

A Floor 6 user reported that desktop shortcuts were missing after login. This is currently a productivity and user-experience issue, not a confirmed security event. It may be isolated to one profile, or it may indicate a wider migration, profile, or policy side effect.

No diagnostic evidence is available yet, so a confirmed root cause cannot be declared. Most likely explanations include profile mismatch/loading behavior, sync/desktop redirection issues, policy-driven desktop changes, or deployment-side shortcut changes.

Immediate approach is to confirm scope quickly, restore user productivity, and then validate whether this is a one-user profile issue or a broader configuration pattern.

---

## 3. Incident Description

At least one Floor 6 user reported missing desktop shortcuts on Monday morning. This occurred in the same period as other Floor 6 incidents and after recent Windows 11 migration, Intune enrollment, and Friday afternoon deployment of a new document management application.

No file inventory snapshots, profile logs, policy reports, or sync diagnostics were provided at escalation.

---

## 4. Business Impact

### Users Affected or Potentially Affected

- Confirmed affected: at least one user.
- Potentially affected: any Floor 6 users with similar profile/sync/policy state.

### Productivity Impact

- Slower access to frequently used applications and case resources.
- Additional service desk workload for restoration and user support.
- Potential disruption to time-sensitive legal tasks if specialized shortcuts are missing.

### Legal, Confidentiality, Compliance, and Reputational Risks

- No direct confidentiality breach is confirmed from this symptom.
- Secondary operational risk exists if users use ad hoc workarounds and bypass standard paths.
- Reputational impact is low to moderate unless issue is widespread and unresolved.

---

## 5. Scope

### Known Affected Population

- One reported Floor 6 user.

### Potentially Affected Population

- Additional Floor 6 users not yet reported.
- Other recently migrated/intune-enrolled users under the same policy model.

### Systems, Applications, Devices, Policies, and Services Involved

- Windows 11 user profiles and desktop folder state.
- Intune endpoint policies potentially affecting desktop experience.
- OneDrive/Known Folder behavior if desktop is redirected/synchronized.
- Friday document management application installer behavior (shortcut creation/removal).

---

## 6. Timeline of Known Events

- **Friday afternoon (exact time unknown):** New document management application deployed.
- **Recent period before Monday (exact dates/times unknown):** Windows 11 migration and Intune enrollment completed.
- **Monday 09:14 (known as reporting window):** Missing desktop shortcuts concern reported.
- **Post-report (unknown):** No confirmed restoration steps, no scope validation results yet.

Missing timeline data:
- When shortcuts were last seen by affected user.
- Whether disappearance happened immediately after migration, after Friday deployment, or first Monday login.
- Whether any account/profile changes occurred before symptom onset.

---

## 7. Confirmed Facts

1. A Floor 6 user reported missing desktop shortcuts.
2. Floor 6 underwent recent Windows 11 migration.
3. Floor 6 was recently enrolled in Intune.
4. A new document management app was deployed Friday afternoon.
5. No validated technical diagnostics were supplied with the report.

---

## 8. Unconfirmed Information and Assumptions

### Unconfirmed Information

- Whether all or only some shortcuts are missing.
- Whether shortcuts were deleted, moved, hidden, or not loaded due to profile path mismatch.
- Whether issue is isolated or replicated across multiple users.
- Whether OneDrive/desktop sync or redirection was active and healthy.

### Assumptions (Pending Validation)

- Assumption A: The user logged into the same account/profile context as prior sessions.
- Assumption B: Shortcut state changed unexpectedly rather than by intentional policy or app behavior.
- Assumption C: Friday deployment and migration-era changes may have contributed.

---

## 9. Initial Technical Assessment

Current signal suggests a profile or desktop-state issue with uncertain scope. Root cause is not confirmed.

### Immediate Actions (Now)

1. Verify scope rapidly (sample additional Floor 6 users).
2. Compare affected desktop folder and profile path with known-good baseline user.
3. Check sync/redirection and policy state for desktop behavior.
4. Restore immediate usability for affected users (shortcut recreation or profile-level recovery path).

### What to Tell Partners by Lunch

- This issue is being handled as a productivity incident and is currently lower risk than security and login outages.
- Root cause is not yet confirmed; investigation is focused on profile/policy/sync behavior.
- User work can continue using Start menu, taskbar pins, and alternate launch paths while restoration is performed.
- If broader scope is found, a bulk remediation plan will be issued.

### Possible Relationship to Other Floor 6 Incidents

- Missing shortcuts may be independent, but they appeared in the same post-change window as login and Copilot concerns.
- A shared backdrop (Windows 11 migration, Intune enrollment, Friday deployment) can create parallel profile, policy, and app-state symptoms.
- Relationship is currently unproven; validation requires profile path checks, policy-result comparison, and deployment behavior review.
- This incident remains managed separately unless evidence shows a common causal chain.

---

## 10. Potential Root-Cause Hypotheses

### Hypothesis 1: User Profile Mismatch or Recreated Profile Loaded Instead of Prior Profile

- **Likelihood:** High
- **Reasoning:** Common post-migration behavior; shortcut set appears missing when profile context changes.
- **Validate by:** Compare SID/profile path continuity, profile creation timestamps, and historical account mapping.
- **Reject if:** Same profile context is confirmed and shortcut files are absent without profile switch.

### Hypothesis 2: Desktop Sync/Redirection (for example OneDrive/Known Folder) Did Not Complete Correctly

- **Likelihood:** Medium-High
- **Reasoning:** Recent migration and enrollment can expose sync timing/state errors.
- **Validate by:** Check sync status, redirection settings, and cloud/local desktop content parity.
- **Reject if:** Sync is healthy and desktop content is consistently absent across sources.

### Hypothesis 3: Intune or Policy Configuration Changed Desktop Presentation/Content

- **Likelihood:** Medium
- **Reasoning:** New endpoint management controls can alter shell behavior and user-visible desktop items.
- **Validate by:** Policy assignment review and policy-result comparison against unaffected users.
- **Reject if:** No desktop-affecting policy differences exist.

### Hypothesis 4: Friday Application Deployment Modified or Replaced Desktop Shortcuts

- **Likelihood:** Medium
- **Reasoning:** Installers can add/remove shortcut sets and occasionally overwrite user expectations.
- **Validate by:** Deployment package review and before/after file comparison on pilot devices.
- **Reject if:** Installer does not modify desktop entries.

### Hypothesis 5: Isolated User Action or Local Cleanup

- **Likelihood:** Low-Medium
- **Reasoning:** Single-user symptom could be local/manual action.
- **Validate by:** User interview, recycle-bin/history checks, and absence of similar reports.
- **Reject if:** Multiple users show the same pattern.

---

## 11. Five Whys Analysis (Provisional, Hypothesis-Based)

**Working hypothesis for Five Whys:** Profile/sync state mismatch caused shortcuts not to appear.

1. **Why were desktop shortcuts missing?**  
   Because the user desktop rendered without expected shortcut files.

2. **Why did expected files not appear on desktop?**  
   Because profile path, desktop redirection, or sync state may not have resolved to prior known content.

3. **Why would profile/sync resolution fail now?**  
   Because recent migration and enrollment changes may have altered profile mapping or sync behavior.

4. **Why was this not detected before production use?**  
   Because post-migration validation may have focused on login success and app access rather than desktop personalization continuity.

5. **Why was personalization continuity not gated?**  
   Because deployment criteria may not have included user-experience checks for shortcut retention across legal workflows.

**Provisional conclusion:** Root Cause Not Yet Confirmed. Most likely direction is profile/sync/policy state divergence pending evidence.

---

## 12. Contributing Factors and Conditions

- Concurrent change environment (migration, Intune enrollment, new app rollout).
- Limited initial observability (no attached file-state snapshots or policy/result captures).
- Potential variation in per-user desktop customization and backup/sync hygiene.
- Competing major incidents on same floor reducing early investigation depth.
- User-experience validation possibly underweighted in rollout acceptance criteria.
