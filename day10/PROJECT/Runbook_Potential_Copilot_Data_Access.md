# Runbook: Potential Copilot Data Access

Document Owner: Security Operations and Legal IT  
Version: 1.0  
Review Frequency: Monthly  
Last Updated: 2026-08-14  
Approval Required: Yes (CISO Delegate, Legal IT Owner, Compliance Lead)  
Support Tower: Security / M365 / IAM / Legal IT

## 1. Purpose
- Provide a controlled response path for potential unauthorized matter exposure in Copilot.
- Address confidentiality, legal privilege, compliance, and reputational risk.

## 2. Scope
- Systems covered: Copilot experience, M365-connected content sources, identity and permissions, legal data repositories.
- Teams involved: L1 Service Desk, Security Operations, IAM, M365 Admin, Legal IT, Compliance, Incident Manager.
- Supported environments: FinBridge legal-user support scope and associated M365 ecosystem.

## 3. Prerequisites
Required access:
- Security incident handling system.
- M365 audit visibility.
- Identity group and permission review access.
- Content repository permission review access (SharePoint/Teams where applicable).

Required permissions:
- Security investigation authority.
- Legal-approved access for confidential matter review.

Required tools:
- Incident/ticket platform.
- Approved audit portals for M365 and identity logs.
- Access governance and permission review tools.

Required approvals:
- Security incident declaration approval path.
- Legal/compliance approval for containment actions affecting user productivity.

Required data/logs:
- User report details, screenshot evidence, timestamp.
- Query/output details if available.
- Access and membership snapshots.
- Repository permission state at incident time.

Change requirements:
- Any broad Copilot access change requires emergency change control and legal notification alignment.

## 4. Trigger Conditions
- User reports Copilot surfaced content they believe is unauthorized.
- Security or compliance alert indicates potential data overexposure.
- Legal leadership requests immediate validation of confidential matter access.

## 5. Root Cause Overview
- RCA status: Root Cause Not Yet Confirmed.
- Working causes include permission inheritance drift, repository/connector scope misconfiguration, indexing scope issues, or misinterpreted entitlement.
- Confirmed vs hypothesis: treat as potential security incident until disproven.

## 6. Resolution Procedure

### Step 1
Action: Mandatory. Open or link a security incident record immediately and classify as potential confidentiality incident.
Expected Result: Formal incident tracking and ownership established.
If Successful: Proceed to Step 2.
If Failed: Escalate immediately to Security Duty Lead.
Escalation Point: L1 to Security Operations.

### Step 2
Action: Mandatory. Preserve evidence from reporting user before session context is lost.
Expected Result: Screenshot, time, user context, and reported prompt/output are captured.
If Successful: Proceed to Step 3.
If Failed: Continue capture attempts and document reason for evidence gap.
Escalation Point: Security Operations.

### Step 3
Action: Mandatory. Validate user entitlement at incident time (direct and inherited group memberships).
Expected Result: Clear answer on whether user had a legitimate access path.
If Successful: Proceed to Step 4.
If Failed: Branch A (identity evidence gap).
Escalation Point: IAM team.

### Step 4
Action: Mandatory. Validate source access boundaries in relevant repositories (SharePoint, Teams, other approved legal repositories in scope).
Expected Result: Repository permissions and sensitivity controls are documented.
If Successful: Proceed to Step 5.
If Failed: Branch B (repository permission path).
Escalation Point: M365 Admin + Legal IT.

### Step 5
Action: Mandatory. Preserve and review M365 and identity audit evidence to determine retrieval path and scope.
Expected Result: Determination of isolated event vs broader exposure pattern.
If Successful: Proceed to Step 6.
If Failed: Branch C (audit completeness gap).
Escalation Point: Security Operations + M365.

### Step 6
Action: Mandatory. Apply containment proportionate to risk.
Expected Result: Further potential exposure risk is reduced while investigation continues.
If Successful: Proceed to Step 7.
If Failed: Escalate to incident command.
Escalation Point: Security Incident Manager.

### Step 7
Action: Mandatory. Execute corrective action tied to confirmed cause path (permissions correction, scope correction, or access governance fix).
Expected Result: Unauthorized retrieval path is removed.
If Successful: Proceed to verification.
If Failed: Escalate to L3 and vendor support path.
Escalation Point: Security Architecture + Vendor.

Decision Branch A (Identity evidence gap)
- Mandatory: Reconstruct effective membership from authoritative identity records.
- Optional: Time-bound freeze on high-risk group changes during investigation.

Decision Branch B (Repository permission path)
- Mandatory: Correct misassigned permissions and remove unintended inheritance.
- Mandatory: Revalidate sensitivity labels and access boundaries for affected matter spaces.
- Optional: Temporarily restrict Copilot access for impacted legal cohort while fixes validate.

Decision Branch C (Audit completeness gap)
- Mandatory: Preserve available logs and document retention gaps.
- Mandatory: Escalate for advanced support to recover audit context where possible.

[Screenshot Placeholder – Reported Copilot output evidence]
[Screenshot Placeholder – Effective permission review]
[Screenshot Placeholder – Security incident timeline and containment action log]

## 7. Verification Procedure
- [ ] Reported unauthorized retrieval cannot be reproduced by unauthorized test role.
- [ ] Legitimate authorized roles retain necessary access.
- [ ] Security incident timeline and evidence package are complete.
- [ ] No additional unexpected exposure events observed in monitoring window.

## 8. Post-Implementation Validation
- Technical validation: Effective permissions match approved legal access model.
- User confirmation: Reporting user confirms issue behavior is resolved.
- Service validation: Legal users can continue approved Copilot use where allowed.
- Security validation: Security and compliance sign off containment and corrective controls.

## 9. Rollback Procedure
Rollback trigger:
- Remediation blocks legitimate legal work unexpectedly.
- Containment action introduces unacceptable operational impact.

Rollback steps:
1. Revert the last change that caused unintended service loss while preserving minimum safe containment.
2. Re-introduce access only to approved groups with legal/security approval.
3. Continue investigation under restricted mode until corrected state is confirmed.

Validation after rollback:
- Critical legal workflows remain functional.
- No unauthorized retrieval path is reintroduced.

Escalation path:
- Security Operations to Security Architecture to Vendor and Legal leadership.

## 10. Risks and Considerations
- Delayed evidence capture can prevent definitive root cause confirmation.
- Overbroad containment can disrupt legal operations.
- Under-containment can increase confidentiality exposure risk.
- Any ambiguity must default to security-first handling.

## 11. Escalation Matrix
- L1: Capture report details and trigger security process immediately.
- L2: Perform entitlement and repository validation.
- L3: Resolve complex authorization/scope architecture issues.
- Vendor: Assist with platform-specific telemetry or behavior analysis.
- Security Team: Own incident command, containment, and risk decisions.
- Problem Management: Track systemic control improvements and recurrence prevention.

## 12. Lessons Learned
- Confidentiality incidents require immediate formal security workflow, even when evidence is incomplete.
- Entitlement negative testing is mandatory for legal data-integrated AI features.
- Change windows affecting legal data access require explicit post-change validation gates.

## 13. References
- RCA: RCA_02_Potential_Copilot_Data_Access.md
- Supporting analysis: rca-floor6-copilot-potential-unauthorized-client-matter-exposure-provisional.md
- Prevention control: floor6-prevention-note-legal-change-readiness-gate.md
