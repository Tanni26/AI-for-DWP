# Microsoft 365 Copilot Finance Readiness - Tiered Priorities

## Scope
This document ranks the existing readiness checklist into rollout tiers for Finance (~200 users) with high-sensitivity data and legacy, unaudited SharePoint permissions from a 2019 migration.

## Tier 1 - MUST Complete Before Rollout (Blocking)
These items are release blockers. If incomplete, do not enable Copilot for the target rollout scope.

### A) Permissions and Oversharing Release Gate (All items from Section 1)
- [ ] Inventory all in-scope Finance SharePoint/Teams-connected sites and OneDrive accounts.
- [ ] Identify high-risk repositories (payroll, board packs, M&A, client financial data).
- [ ] Confirm data owners for each critical site/library.
- [ ] Export and review current permissions for all critical sites/libraries.
- [ ] Identify and assess broken inheritance across site/library/folder levels.
- [ ] Detect broad and ambiguous principals (Everyone, Everyone except external users, All Company, legacy groups).
- [ ] Validate external sharing settings at tenant/site/file levels.
- [ ] Identify stale users/disabled accounts/legacy groups with retained access.
- [ ] Run oversharing checks (org-wide links, anonymous links, broadly shared files/folders).
- [ ] Remove/reduce excessive access and enforce least privilege.
- [ ] Confirm restricted membership and no open links for payroll/board/M&A libraries.
- [ ] Confirm sensitive sites are not discoverable by unauthorized users.
- [ ] Execute persona-based validation tests (authorized and non-authorized users).
- [ ] Re-run oversharing reports and confirm no unresolved critical findings.
- [ ] Obtain Security + Finance data owner sign-off.

### B) Core Access Security Controls
- [ ] Enforce MFA for all Finance users and privileged admins.
- [ ] Validate Conditional Access for compliant device and trusted sign-in controls.
- [ ] Ensure risky sign-in/risky user protections are active.

### C) Minimum Technical Enablement for Pilot/Production Scope
- [ ] Assign Microsoft 365 Copilot add-on licenses to in-scope users.
- [ ] Confirm service plans are enabled with no licensing conflicts.
- [ ] Confirm in-scope users are on supported Microsoft 365 Apps versions for Copilot entry points (Teams/Outlook/Office apps in use).

### D) Governance and Decision Gate
- [ ] Security and Compliance approval recorded.
- [ ] Finance data owner approval recorded.
- [ ] Go/No-Go decision recorded before broad enablement.

## Tier 2 - SHOULD Complete Before Rollout (High Risk If Skipped)
These items should be done before broad rollout; skipping them raises operational or compliance risk.

### A) SharePoint/OneDrive Governance Hardening
- [ ] Set default sharing links to least permissive practical settings.
- [ ] Validate Finance site external sharing posture matches classification requirements.
- [ ] Align OneDrive sharing controls with Finance handling standards.
- [ ] Confirm current site ownership and eliminate orphaned Finance sites.

### B) Sensitivity Labelling and Data Protection Maturity
- [ ] Confirm/publish Finance label taxonomy (including highly confidential classes).
- [ ] Configure label-driven protections (encryption/access restrictions) for sensitive classes.
- [ ] Validate label behavior across SharePoint/OneDrive/Outlook/Office apps.
- [ ] Confirm DLP alignment for payroll/client/board data.

### C) Rollout Readiness Discipline
- [ ] Define pilot cohort across key Finance functions.
- [ ] Document rollback process for license removal.
- [ ] Review pilot telemetry/support readiness before scale-out.

## Tier 3 - CAN Complete During/After Rollout (Lower Risk)
These items are valuable for adoption quality and continuous improvement; they are not primary security blockers if Tiers 1 and 2 controls are already effective.

### A) End-User Comms and Enablement Expansion
- [ ] Deliver broader role-based quick start sessions.
- [ ] Expand self-service materials and FAQ coverage.
- [ ] Continue targeted guidance on safe prompting patterns.

### B) Optimization and Continuous Improvement
- [ ] Collect and trend pilot/post-go-live feedback.
- [ ] Tune adoption artifacts and support workflows based on incident patterns.
- [ ] Refine automation (label recommendations/auto-labeling) as operational maturity increases.

## Why Permissions/Oversharing Is MUST (Finance-Specific Justification)
Even though licensing checks and client version checks are technically simpler and faster, they do not reduce data exposure risk. In this Finance context, permissions and oversharing must be first because:

1. Copilot respects existing Microsoft 365 permissions.
If permissions are overly broad, Copilot can surface sensitive payroll, board, M&A, or client data to users who should not see it. The tool does not compensate for poor access hygiene.

2. Your highest known risk is legacy inherited access.
The environment explicitly has 2019-migration-era permissions that were never fully audited. That is a known control gap, not a hypothetical one.

3. Impact severity is materially higher than enablement failure.
A missing license or outdated client typically causes a feature not to work. Bad permissions can cause confidentiality breaches, regulatory exposure, and legal/reporting consequences.

4. Finance data has strict need-to-know boundaries.
Board packs, payroll, and deal documents require tight role-based boundaries. Oversharing in these sets is incompatible with safe AI-assisted discovery and summarization.

5. Security sign-off depends on demonstrated remediation, not technical readiness alone.
For high-sensitivity departments, audit evidence and validated least-privilege controls are the real release gate.

## Practical Decision Rule
- If a task prevents unauthorized data exposure, it belongs in MUST.
- If a task mainly improves control maturity/operability, it belongs in SHOULD.
- If a task mainly improves adoption quality after safe controls are in place, it belongs in CAN.
