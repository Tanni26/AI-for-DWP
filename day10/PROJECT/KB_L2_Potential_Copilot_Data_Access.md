# KB L2: Potential Copilot Data Access

Document Owner: Security Engineering  
Version: 1.0  
Review Frequency: Monthly  
Last Updated: 2026-08-14  
Approval Required: Yes (Security Lead, Compliance Lead, Legal IT Owner)  
Support Tower: Security / IAM / M365 / Legal IT

## Source Lineage
This article is the technical L2 re-expression of the source runbook: Runbook_Potential_Copilot_Data_Access.md.

## Overview
Technical investigation and remediation guide for potential unauthorized legal content exposure through Copilot.

## Technical Background
RCA indicates root cause is not confirmed and must be treated as a potential confidentiality incident. Candidate causes include entitlement misalignment, permission inheritance issues, repository scope misconfiguration, indexing scope behavior, or session-context confusion.

## Symptoms
- Reported Copilot output appears to expose unauthorized legal matter content.
- User reports mismatch between expected access and observed Copilot response.

## Possible Causes
- Group membership or inherited entitlement granted unexpected access.
- SharePoint or Teams permissions inconsistent with legal access design.
- M365 permission or connector scope drift after recent change.
- Sensitivity labels not aligned to intended access boundaries.
- Misinterpretation of output context without verified retrieval path.

## Detailed Diagnostic Procedure

Decision Tree

IF unauthorized Copilot access is reported  
THEN open or attach to formal security incident workflow immediately.

IF evidence (screenshot/query/time/user) is not captured  
THEN preserve evidence first before broader corrective action.

IF user entitlement review shows valid access path  
THEN classify as authorization-model misalignment and remediate entitlement design.

IF user entitlement review shows no valid access path  
THEN validate repository permissions and access inheritance (SharePoint, Teams, other legal repositories in scope).

IF repository permissions are overexposed  
THEN remove unintended access and revalidate least-privilege model.

IF repository permissions are correct  
THEN validate M365 scope, connector behavior, and sensitivity label enforcement.

IF controls appear correct but issue persists  
THEN escalate to security architecture and vendor-supported deep analysis.

IF wider exposure pattern is detected  
THEN enforce broader containment and legal/compliance communication workflow.

## Data Collection Requirements
Logs and audit data:
- M365 audit activity related to reported time window.
- Identity and group membership evidence at event time.
- Repository permission snapshots and inheritance path evidence.

Policies and configuration:
- SharePoint and Teams permission model for affected matter space.
- M365 access scope and governance settings in applicable integration path.
- Sensitivity label and access control mapping for legal content.

Investigation artifacts:
- User-provided screenshot and prompt context.
- Incident timeline and containment decisions.

## Resolution Procedures
1. Mandatory: Trigger security incident workflow and assign incident commander.
Expected result: Controlled investigation ownership established.

2. Mandatory: Preserve evidence and establish timeline.
Expected result: Defensible forensic baseline for analysis.

3. Mandatory: Validate effective user permissions and group memberships.
Expected result: Entitlement path confirmed or disproven.

4. Mandatory: Validate repository permissions (including inheritance) and Teams/SharePoint access boundaries where in scope.
Expected result: Over-permissioned path corrected or ruled out.

5. Mandatory: Validate M365 permission/scoping and sensitivity label posture.
Expected result: Governance controls aligned with legal confidentiality requirements.

6. Mandatory: Apply containment and corrective actions proportionate to confirmed risk.
Expected result: Unauthorized access path removed and recurrence risk reduced.

7. Optional: Temporary role-based Copilot restrictions during active incident.
Expected result: Reduced interim exposure risk while full fix validates.

[Screenshot Placeholder – Evidence capture from reporting user]
[Screenshot Placeholder – Effective access validation record]
[Screenshot Placeholder – Post-remediation access test evidence]

## Validation
- Unauthorized role cannot reproduce access.
- Authorized role still can access permitted legal content.
- No further suspicious events in defined monitoring window.
- Security and compliance sign-off completed.

## Rollback
Rollback trigger:
- Corrective action blocks approved legal workflows unexpectedly.

Rollback actions:
1. Restore last known good permitted access model only for approved groups.
2. Keep incident controls required for confidentiality risk reduction.
3. Continue forensic investigation under controlled access state.

Rollback validation:
- Legal operations regain approved access.
- Unauthorized access path does not reappear.

## Known Issues
- User expectation may differ from actual inherited access model.
- Evidence loss risk is high if capture is delayed.

## Security Considerations
- This issue is security-first by default.
- Legal and compliance communications must follow incident policy.
- Maintain chain of custody for all captured evidence.

## Monitoring Recommendations
- Monitor for repeated access anomalies by role and content sensitivity.
- Run periodic entitlement-negative tests for legal cohorts.
- Include legal content access checks in post-change readiness gate.

## Related RCAs
- RCA_02_Potential_Copilot_Data_Access.md
- rca-floor6-copilot-potential-unauthorized-client-matter-exposure-provisional.md

## Related Runbooks
- Runbook_Potential_Copilot_Data_Access.md
