# Root Cause Analysis (RCA): Floor 6 Copilot Potential Unauthorized Client-Matter Exposure (Provisional)

**RCA Reference:** RCA-F6-COPILOT-SEC-2026-08-14  
**Document Owner:** Security Operations / Legal IT  
**Date Authored:** 2026-08-14  
**Incident Priority:** Critical (Security and Confidentiality)  
**Status:** Root Cause Not Yet Confirmed

---

## 1. RCA Title and Reference

- Title: Floor 6 Copilot Potential Unauthorized Client-Matter Exposure
- Reference: `RCA-F6-COPILOT-SEC-2026-08-14`
- Related triage source: `incident-1-copilot-unauthorized-data-access.md`

---

## 2. Executive Summary

A Floor 6 paralegal reported that Microsoft Copilot displayed a client matter they believe they were not authorized to access. Because this concerns privileged legal information, the report must be handled as a potential security and confidentiality incident until proven otherwise.

At this time, no logs, screenshots, or access-control evidence have been validated. That means no final root cause can be stated yet. The immediate priority is containment, evidence preservation, and formal security/legal escalation, while confirming whether this was true unauthorized retrieval, permission misconfiguration, indexing/scope exposure, or user-permission misunderstanding.

The incident should be communicated to partners as actively contained and under formal investigation, with legal/compliance oversight and evidence-based updates.

---

## 3. Incident Description

At 09:14 Monday, IT Operations reported that a paralegal on Floor 6 stated Copilot surfaced a client matter they should not have seen. This occurred in the same operating window as other Floor 6 disruptions and follows Friday deployment of a new document management application, plus recent Windows 11 migration and Intune enrollment.

No confirmed telemetry, audit trail, or artifact package has yet been provided.

---

## 4. Business Impact

### Users Affected or Potentially Affected

- Confirmed reporter: 1 paralegal.
- Potentially affected: all Floor 6 users, and possibly broader tenant scope if permissions or indexing are systemic.

### Productivity Impact

- Investigation and containment actions can temporarily reduce Copilot availability.
- Legal users may need alternate research workflows pending validation.

### Legal, Confidentiality, Compliance, and Reputational Risks

- Potential unauthorized exposure of privileged client information.
- Potential impact to confidentiality obligations, legal privilege handling, regulatory expectations, and breach-notification decision pathways.
- Reputational risk with partners/clients if not promptly contained and transparently managed.

---

## 5. Scope

### Known Affected Population

- One reported user/session in Legal Floor 6.

### Potentially Affected Population

- Other Legal users with similar access context.
- Other users impacted by the same permission graph, integration settings, or indexing pathway.

### Systems, Applications, Devices, Policies, and Services Involved

- Microsoft Copilot user interaction layer.
- Identity and authorization services (Entra ID/Azure AD groups, role mappings).
- Document repositories and permissions (document management platform and/or Microsoft 365-connected stores).
- Friday document management application deployment and integrations.
- Intune-managed endpoint policies that may influence app/session behavior.

---

## 6. Timeline of Known Events

- **Friday afternoon (exact time unknown):** New document management application deployed to Floor 6.
- **Recent period before Monday (exact dates/times unknown):** Windows 11 migration and Intune enrollment completed for Floor 6.
- **Monday 09:14 (known):** Potential Copilot unauthorized access concern reported.
- **Monday 09:14 onward (unknown):** Exact query, output content, and source path remain unverified.

Missing timeline data:
- Exact minute the Copilot output was shown.
- Whether the content was snippet, summary, or full matter details.
- Whether similar events occurred previously or on other users.

---

## 7. Confirmed Facts

1. A paralegal reported Copilot displayed a client matter they believed they were not authorized to access.
2. The report occurred Monday morning at 09:14 through IT Operations.
3. Floor 6 had a Friday afternoon document-management application rollout.
4. Floor 6 was recently migrated to Windows 11 and enrolled in Intune.
5. No validated security logs, access logs, screenshots, or permission audits are attached yet.

---

## 8. Unconfirmed Information and Assumptions

### Unconfirmed Information

- Whether the user actually lacked permission at the time of the Copilot response.
- What exact content Copilot returned and from which source.
- Whether the event reflects one session anomaly or broader exposure.
- Whether access arose through direct authorization, inherited group access, indexing scope, or cached content.

### Assumptions (Pending Validation)

- Assumption A: The surfaced matter was genuine tenant content and not model-generated confabulation.
- Assumption B: The user had no legitimate permission path (direct or inherited) to the matter.
- Assumption C: Friday deployment changes may have altered access boundaries or integration behavior.

---

## 9. Initial Technical Assessment

This is a potential confidentiality incident and should be investigated under security incident handling standards immediately.

### Immediate Actions (Now)

1. Open formal security incident record and notify Security, Legal leadership, and Compliance.
2. Preserve evidence immediately (user screenshot, query text, session metadata, relevant audit streams).
3. Restrict risk surface during investigation (targeted Copilot access controls for affected cohort if needed).
4. Freeze non-essential permission/integration changes until causal path is known.

### What to Tell Partners by Lunch

- A potential confidentiality issue was reported and is being handled as a priority security incident.
- There is no confirmed root cause yet, and no confirmed broad exposure yet.
- Evidence preservation and access-audit work are in progress under Security and Legal oversight.
- Interim controls are in place (or ready) to reduce further exposure risk while validation completes.
- Next communication will state whether exposure is confirmed, scope, and corrective actions.

### Possible Relationship to Other Floor 6 Incidents

- The Copilot concern occurred in the same window as login and desktop issues, but should not be assumed to share the same root cause.
- A single change cluster (Friday app deployment + recent Windows 11/Intune transition) could still contribute to multiple failures through different mechanisms.
- Any linkage must be proven through evidence: entitlement changes, connector behavior, indexing scope, and identity/group deltas.
- Security handling remains independent and highest priority regardless of whether operational issues are related.

---

## 10. Potential Root-Cause Hypotheses

### Hypothesis 1: Permission Inheritance or Group Misconfiguration Granted Legitimate but Unexpected Access

- **Likelihood:** High
- **Reasoning:** Most common cause of "unauthorized" perception is misaligned or inherited access the user did not realize they had.
- **Validate by:** Point-in-time ACL review, group membership history, role inheritance chain, and document access checks at event time.
- **Reject if:** ACL and group analysis prove no access path existed.

### Hypothesis 2: Friday Document Management Deployment Altered Access Scope or Connector Permissions

- **Likelihood:** Medium-High
- **Reasoning:** Temporal correlation and change introduction on same floor suggest potential integration/permission drift.
- **Validate by:** Deployment manifest review, connector/service principal scope review, before/after permission diff.
- **Reject if:** No relevant permission or integration changes were introduced.

### Hypothesis 3: Search/Index Scope Included Content Beyond Intended Security Boundary

- **Likelihood:** Medium
- **Reasoning:** Retrieval layers can expose discoverability beyond expected user perception when indexing/security trimming is misconfigured.
- **Validate by:** Search/index configuration audit, security trimming verification, test queries under constrained identities.
- **Reject if:** Index and trimming controls are correct and reproducible tests fail to expose restricted content.

### Hypothesis 4: Session/Cache Artifact Surfaced Prior Authorized Content in a Misleading Context

- **Likelihood:** Low-Medium
- **Reasoning:** Caching/session reuse can occasionally create confusing output perception.
- **Validate by:** Session telemetry and cache behavior analysis; controlled reproduction after cache/session reset.
- **Reject if:** Output is fresh retrieval with clear repository access logs.

### Hypothesis 5: Copilot Response Was Not Grounded in Restricted Document Retrieval

- **Likelihood:** Low-Medium
- **Reasoning:** A response may appear specific without actual source retrieval.
- **Validate by:** Grounding/citation checks and repository access logs tied to query time.
- **Reject if:** Logs show direct retrieval of restricted matter content.

---

## 11. Five Whys Analysis (Provisional, Hypothesis-Based)

**Working hypothesis for Five Whys:** Permission/configuration drift allowed unintended access visibility.

1. **Why was sensitive matter shown to a user who believed they lacked access?**  
   Because Copilot returned content that appeared outside expected authorization boundaries.

2. **Why could Copilot return that content?**  
   Because effective access controls may have allowed retrieval through direct or inherited permissions, or through scope misconfiguration.

3. **Why would effective permissions differ from business intent?**  
   Because role/group mappings, connector scopes, or deployment changes may not have matched legal confidentiality design.

4. **Why was this misalignment not detected earlier?**  
   Because pre-deployment validation may not have included role-based negative testing for sensitive legal matters.

5. **Why was negative testing incomplete?**  
   Because governance controls may have prioritized rollout timing over comprehensive entitlement assurance for Copilot-integrated access paths.

**Provisional conclusion:** Root Cause Not Yet Confirmed. Most probable paths involve entitlement/configuration misalignment, pending forensic validation.

---

## 12. Contributing Factors and Conditions

- Concurrent environment changes (Windows 11 migration, Intune enrollment, new legal app deployment).
- Potential complexity of multi-system authorization (identity groups, repository ACLs, connectors, indexing).
- Absence of immediate evidence package at escalation time.
- High-sensitivity data domain (Legal) where minor permission drift has outsized risk.
- Possible gap in pre-deployment "should not retrieve" control testing for Copilot and legal matters.
