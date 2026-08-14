# Runbook: Missing Desktop Shortcuts

Document Owner: End User Compute Operations  
Version: 1.0  
Review Frequency: Quarterly  
Last Updated: 2026-08-14  
Approval Required: Yes (EUC Manager)  
Support Tower: EUC / Intune / M365 Endpoint Experience

## 1. Purpose
- Provide a standard recovery method when users report missing desktop shortcuts after login.
- Address user productivity impact and prevent repeated ad hoc fixes.

## 2. Scope
- Systems covered: Windows 11 profiles, desktop path, Intune endpoint policies, OneDrive desktop synchronization where enabled, app deployment shortcut behavior.
- Teams involved: L1 Service Desk, L2 EUC, L2 Intune, M365 endpoint support, Application Team.
- Supported environments: Managed Legal endpoints and comparable managed Windows 11 cohorts.

## 3. Prerequisites
Required access:
- Endpoint remote support access.
- Intune read/admin access based on support tier.
- Access to approved user profile recovery process.

Required permissions:
- User-approved support session and ticket linkage.
- Change approval for policy or deployment modifications.

Required tools:
- Service desk platform.
- Endpoint file/path inspection tools.
- Intune policy and app deployment dashboards.
- OneDrive/KFM status visibility if applicable.

Required approvals:
- L2 approval for profile repair operations beyond standard L1 actions.

Required data/logs:
- User-reported missing items list.
- Timestamp when issue was first noticed.
- Desktop path content state.
- Intune app deployment and policy state for affected device.

Change requirements:
- Mass remediation scripts or policy changes must go through change control.

## 4. Trigger Conditions
- User reports desktop shortcuts disappeared after login.
- Multiple users in a cohort report similar desktop state drift.
- Desktop baseline mismatch after migration, enrollment, or recent application deployment.

## 5. Root Cause Overview
- RCA status: Root Cause Not Yet Confirmed.
- Working causes include profile mismatch/recreation, desktop redirection or synchronization issues, policy-driven desktop changes, and deployment-side shortcut behavior.
- Confirmed vs hypothesis: treat as unconfirmed until path is validated.

## 6. Resolution Procedure

### Step 1
Action: Mandatory. Confirm issue details with user and capture exactly which shortcuts are missing.
Expected Result: Ticket includes missing shortcut inventory and first observed time.
If Successful: Proceed to Step 2.
If Failed: Re-interview user and collect screenshot evidence.
Escalation Point: L1 to L2 EUC if unclear after second attempt.

### Step 2
Action: Mandatory. Validate user identity and profile context are correct for current session.
Expected Result: Confirmed whether expected profile context is loaded.
If Successful: Proceed to Step 3.
If Failed: Branch A (profile mismatch path).
Escalation Point: L2 EUC profile specialist.

### Step 3
Action: Mandatory. Validate desktop path content, including user desktop and Public Desktop baseline items.
Expected Result: Determine whether shortcuts are absent, moved, or baseline-only.
If Successful: Proceed to Step 4.
If Failed: Branch B (file/path state issue).
Escalation Point: L2 EUC.

### Step 4
Action: Mandatory. Validate Intune deployment and policy state for desktop-related behavior.
Expected Result: Identify whether policy/app deployment changed shortcut behavior.
If Successful: Proceed to Step 5.
If Failed: Branch C (policy/deployment path).
Escalation Point: L2 Intune + Application Team.

### Step 5
Action: Mandatory. Validate desktop redirection or OneDrive KFM state where enabled.
Expected Result: Confirm whether sync/redirection mismatch caused shortcut absence.
If Successful: Proceed to Step 6.
If Failed: Branch D (sync/redirection path).
Escalation Point: M365 endpoint support.

### Step 6
Action: Mandatory. Apply corrective action based on identified cause path.
Expected Result: Expected shortcut set is restored and persists after sign-out/sign-in.
If Successful: Proceed to verification.
If Failed: Escalate to L3 for deeper profile/deployment remediation.
Escalation Point: L3 EUC platform.

Decision Branch A (Profile mismatch)
- Mandatory: Correct session/profile mapping via approved profile recovery process.
- Mandatory: Preserve user data before profile-level correction.
- Optional: Controlled test on alternate managed endpoint.

Decision Branch B (Desktop path state)
- Mandatory: Restore baseline shortcuts from approved source and user-approved custom items from backup path if available.
- Optional: Recreate custom shortcuts manually when no backup exists.

Decision Branch C (Policy/deployment)
- Mandatory: Correct mis-scoped policy or deployment behavior through approved change.
- Mandatory: Validate no unintended impact to other user cohorts.
- Optional: Pilot fix on limited devices before broad rollout.

Decision Branch D (OneDrive/KFM or redirection)
- Mandatory: Correct sync/redirection state and verify content parity.
- Mandatory: Confirm shortcut persistence through re-login.
- Optional: Controlled re-sync for affected desktop content.

[Screenshot Placeholder – User desktop before remediation]
[Screenshot Placeholder – User and Public Desktop path validation]
[Screenshot Placeholder – Post-remediation desktop state]

## 7. Verification Procedure
- [ ] Missing shortcuts are restored.
- [ ] Restored shortcuts open expected targets.
- [ ] Shortcuts remain after user signs out and signs back in.
- [ ] No additional profile anomalies observed.

## 8. Post-Implementation Validation
- Technical validation: Desktop baseline parity with known-good user/device.
- User confirmation: User confirms expected shortcut set and usability.
- Service validation: No spike in similar desktop incidents in cohort.
- Security validation: Restoration does not bypass policy restrictions.

## 9. Rollback Procedure
Rollback trigger:
- Shortcut restoration introduces broken links or wrong targets.
- Profile correction causes broader user profile instability.

Rollback steps:
1. Revert the latest profile/policy/deployment change that introduced the regression.
2. Restore last known good shortcut baseline.
3. Revalidate login and desktop state with user.

Validation after rollback:
- User desktop stable.
- No new profile issues introduced.

Escalation path:
- L2 EUC to L3 EUC platform to vendor/application support.

## 10. Risks and Considerations
- Single-user symptoms can mask wider policy/deployment issues.
- Manual shortcut recreation can miss business-critical links unless validated with user.
- Profile operations must protect user data and follow approved methods.

## 11. Escalation Matrix
- L1: Confirm symptom, collect evidence, execute safe quick actions.
- L2: Perform profile/policy/sync diagnosis and remediation.
- L3: Resolve persistent platform-level profile or deployment defects.
- Vendor: Support unresolved app deployment or platform integration behavior.
- Security Team: Review if shortcut targets imply unexpected access control changes.
- Problem Management: Track recurring desktop-state defects and preventive controls.

## 12. Lessons Learned
- Desktop-state validation should be part of post-change readiness for Legal endpoints.
- Public Desktop and user profile paths must be checked together.
- Controlled pilot verification reduces broad user-impact risk.

## 13. References
- RCA: RCA_03_Missing_Desktop_Shortcuts.md
- Supporting analysis: rca-floor6-missing-desktop-shortcuts-provisional.md
- Prevention control: floor6-prevention-note-legal-change-readiness-gate.md
