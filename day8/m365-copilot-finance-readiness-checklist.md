# Microsoft 365 Copilot Readiness Checklist - Finance Department (~200 Users)

## Deployment Context
- Department: Finance (~200 users)
- Data sensitivity: High (payroll, board packs, M&A documents, client financial data)
- Current permissions state: SharePoint permissions inherited from 2019 migration, not fully audited since
- Licensing baseline: Microsoft 365 E5 confirmed for all users
- Gap: Copilot add-on licenses not yet assigned

## How To Use This Checklist
- Mark each item complete only when evidence is captured (report, screenshot, change record, or ticket ID).
- Treat **Section 1** as a release gate: do not proceed to broad Copilot enablement until all critical permission and oversharing items are complete.

---

## 1) Critical Release Gate: Permissions and Oversharing Controls (Highest Priority)

### 1.1 Tenant and Site Discovery
- [ ] Inventory all Finance SharePoint sites, Teams-connected sites, and OneDrive accounts in scope.
- [ ] Identify high-risk repositories: payroll folders, board documentation libraries, M&A workspaces, and client finance data sites.
- [ ] Confirm data owners for each critical site/library and record escalation contacts.

### 1.2 Access Model Audit (Inherited 2019 Permissions)
- [ ] Export current permissions for every Finance site and critical document library.
- [ ] Identify broken inheritance at site/library/folder level and record rationale for each break.
- [ ] Detect broad groups and ambiguous principals (`Everyone`, `Everyone except external users`, `All Company`, legacy migration groups).
- [ ] Validate external sharing settings at tenant, site, and file/folder level.
- [ ] Identify stale users, disabled accounts, and legacy project groups still retaining access.

### 1.3 Oversharing Detection and Remediation
- [ ] Run oversharing checks on finance-critical content (organization-wide links, anonymous links, broadly shared folders/files).
- [ ] Remove or reduce excessive access from broad groups where not business-justified.
- [ ] Re-scope permissions to least privilege (role/group-based access aligned to job function).
- [ ] Validate board/M&A/payroll libraries have restricted membership and no open links.
- [ ] Confirm private/sensitive sites are not discoverable by non-authorized users.

### 1.4 Post-Remediation Validation
- [ ] Perform user-based access tests for representative personas (Finance Analyst, Payroll Admin, Finance Leadership, Non-Finance user).
- [ ] Verify non-Finance test users cannot access restricted Finance content via search or direct links.
- [ ] Re-run oversharing report and confirm no unresolved critical findings.
- [ ] Obtain sign-off from Finance data owners and Security before Copilot assignment.

---

## 2) Licensing and Service Prerequisites
- [ ] Confirm all ~200 Finance users have eligible base licenses (Microsoft 365 E5 already confirmed).
- [ ] Procure/allocate required Microsoft 365 Copilot add-on licenses for rollout scope.
- [ ] Define pilot cohort (for example 20-30 users across payroll, FP&A, accounting, leadership support).
- [ ] Assign Copilot add-on licenses to pilot users first.
- [ ] Confirm service plans are enabled and no conditional licensing conflicts exist.
- [ ] Document rollback process for license removal if needed.

## 3) Microsoft 365 Apps Client Readiness
- [ ] Verify Microsoft 365 Apps for enterprise installed on pilot endpoints.
- [ ] Confirm update channel and build meet Copilot-supported requirements.
- [ ] Ensure Teams, Outlook, Word, Excel, and PowerPoint are on supported versions.
- [ ] Validate signed-in Office account is the licensed work account for each pilot user.
- [ ] Confirm modern authentication is enabled and legacy auth dependencies are removed.

## 4) Identity and MFA Readiness
- [ ] Confirm all Finance users are cloud identities or properly synchronized hybrid identities.
- [ ] Enforce MFA for all Finance users and privileged admin roles.
- [ ] Validate Conditional Access policies for compliant device and trusted sign-in controls.
- [ ] Confirm risky sign-in/risky user policies are active and monitored.
- [ ] Ensure break-glass and admin accounts are excluded only where policy-approved and documented.

## 5) SharePoint and OneDrive Governance Baseline
- [ ] Review default sharing links (set to least permissive practical default).
- [ ] Validate external sharing policy for Finance sites is restricted per data classification.
- [ ] Confirm OneDrive sharing controls align with Finance data handling standards.
- [ ] Ensure versioning, retention, and recycle policies support auditability.
- [ ] Confirm site ownership is current and no orphaned Finance sites remain.

## 6) Sensitivity Labelling and Protection
- [ ] Define or confirm sensitivity labels covering Finance scenarios (Internal, Confidential Finance, Highly Confidential Finance).
- [ ] Publish labels to all Finance users and relevant containers (sites/groups, if applicable).
- [ ] Configure label policies for encryption and access restrictions on highly sensitive content.
- [ ] Auto-label or recommend labels for known sensitive patterns where feasible.
- [ ] Validate label behavior in SharePoint, OneDrive, Outlook, and Office apps.
- [ ] Confirm DLP policies align with label taxonomy for payroll/client/board content.

## 7) End-User Communications and Enablement
- [ ] Send pre-enablement communication: scope, timeline, and responsible-use expectations.
- [ ] Provide Finance-specific guidance on prompting safely with sensitive data.
- [ ] Publish "what Copilot can and cannot access" explainer tied to M365 permissions model.
- [ ] Deliver role-based quick start sessions (analysts, payroll, leadership support).
- [ ] Establish support path (L1/L2 escalation, known issues, response SLAs).
- [ ] Collect pilot feedback and track improvement actions before wider rollout.

## 8) Go/No-Go Decision Checklist
- [ ] Critical permissions and oversharing gate fully complete (Section 1).
- [ ] Security and Compliance approval recorded.
- [ ] Finance data owner approval recorded.
- [ ] Pilot telemetry and support readiness reviewed.
- [ ] Change advisory or internal governance approval complete.

## Recommended Rollout Sequence
1. Complete Section 1 in full and remediate critical findings.
2. Run controlled pilot with licensed subset.
3. Validate outcomes (security, productivity, support load).
4. Expand in waves by Finance function.

## Evidence Tracker (Fill In)
- Permissions audit report location:
- Oversharing remediation ticket(s):
- Security sign-off reference:
- Finance owner sign-off reference:
- Pilot cohort list and dates:
- Go-live decision date:
