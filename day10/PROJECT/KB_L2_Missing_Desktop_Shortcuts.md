# KB L2: Missing Desktop Shortcuts

Document Owner: EUC Engineering  
Version: 1.0  
Review Frequency: Quarterly  
Last Updated: 2026-08-14  
Approval Required: Yes (EUC Manager)  
Support Tower: EUC / Intune / M365 Endpoint Experience / Application Team

## Source Lineage
This article is the technical L2 re-expression of the source runbook: Runbook_Missing_Desktop_Shortcuts.md.

## Overview
Technical guide for diagnosing and fixing missing desktop shortcuts on managed Windows endpoints.

## Technical Background
RCA indicates unconfirmed root cause with likely paths: profile mismatch/recreation, desktop redirection or OneDrive KFM state drift, Intune policy effects, Public Desktop or deployment shortcut changes.

## Symptoms
- Desktop shortcuts missing after login.
- Only default icons visible or subset of expected shortcuts present.
- Recurrence after sign-out/sign-in in affected cohort.

## Possible Causes
- User profile mismatch or recreated profile context.
- Desktop redirection or OneDrive KFM synchronization issue.
- Intune policy affecting desktop behavior.
- Application deployment altered or failed to restore shortcuts.
- Public Desktop baseline divergence.

## Detailed Diagnostic Procedure

Decision Tree

IF user reports missing shortcuts  
THEN validate account and profile context first.

IF profile context differs from expected  
THEN execute profile recovery branch.

IF profile context is correct  
THEN compare user desktop and Public Desktop baseline.

IF user desktop is empty but Public Desktop baseline exists  
THEN restore user-specific shortcuts and validate persistence.

IF both user and Public Desktop differ from baseline  
THEN validate Intune policy and deployment state.

IF policy/deployment mismatch is present  
THEN correct scope/configuration and reapply approved baseline.

IF policy/deployment is healthy  
THEN validate OneDrive KFM or desktop redirection state where enabled.

IF sync/redirection mismatch exists  
THEN correct and validate content parity and persistence.

IF issue remains unresolved  
THEN escalate to L3 with full profile/policy/deployment artifact bundle.

## Data Collection Requirements
Logs and audit data:
- User report timeline and recurrence pattern.
- Profile state evidence and desktop path inventory.
- Intune policy assignment and deployment status evidence.
- OneDrive KFM/redirection state evidence where applicable.

Policies and configuration:
- Desktop-related policy assignments.
- Application deployment target and install status for affected cohort.
- Baseline shortcut standard for affected user role.

## Resolution Procedures
1. Mandatory: Confirm expected shortcut inventory with user role baseline.
Expected result: Clear target state for restoration.

2. Mandatory: Validate profile identity and path consistency.
Expected result: Profile mismatch either corrected or excluded.

3. Mandatory: Validate user desktop and Public Desktop content.
Expected result: Baseline gap located.

4. Mandatory: Validate Intune policy and app deployment behavior.
Expected result: Policy/deployment cause corrected or excluded.

5. Mandatory: Validate OneDrive KFM/desktop redirection where in scope.
Expected result: Sync/redirection mismatches corrected.

6. Mandatory: Restore shortcuts using approved baseline method and verify persistence through re-login.
Expected result: Stable desktop with expected shortcuts.

7. Optional: Controlled pilot rollout of broader fix if cohort-level issue is confirmed.
Expected result: Reduced reoccurrence risk before broad deployment.

[Screenshot Placeholder – User desktop and baseline comparison]
[Screenshot Placeholder – User Desktop and Public Desktop validation]
[Screenshot Placeholder – Post-fix persistence after re-login]

## Validation
- Missing shortcuts restored and functional.
- Shortcut set remains after sign-out/sign-in cycle.
- No regression in policy compliance.
- Incident recurrence trend reduced.

## Rollback
Rollback trigger:
- Fix causes incorrect shortcut targets or profile instability.

Rollback actions:
1. Revert recent policy/deployment changes affecting desktop state.
2. Restore previous known-good desktop baseline.
3. Re-validate with user and pilot cohort.

Rollback validation:
- Desktop state stable and usable.
- No new profile anomalies introduced.

## Known Issues
- User-customized shortcuts may not exist in baseline and require user confirmation.
- Mixed cohort behavior may indicate multiple underlying causes.

## Security Considerations
- Shortcut restoration must not create access paths that violate least privilege.
- Validate shortcut targets align to approved legal applications and repositories.

## Monitoring Recommendations
- Track repeat incidents by device group and policy version.
- Add desktop-baseline check to post-change validation for legal cohort.
- Review deployment packaging for shortcut create/remove behavior before production waves.

## Related RCAs
- RCA_03_Missing_Desktop_Shortcuts.md
- rca-floor6-missing-desktop-shortcuts-provisional.md

## Related Runbooks
- Runbook_Missing_Desktop_Shortcuts.md
