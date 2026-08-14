# KB L2: Login Failure and Slow Login

## Version Header
- Document ID: KB-L2-F6-LOGIN-001
- Source Runbook: Runbook_Login_Failure_and_Slow_Login.md
- Document Owner: EUC Engineering
- Version: 1.1
- Review Frequency: Quarterly
- Last Updated: 2026-08-14
- Approval Required: Yes (EUC Manager, IAM Lead)
- Support Tower: EUC / Intune / IAM / Application Team

Document Owner: EUC Engineering  
Version: 1.1  
Review Frequency: Quarterly  
Last Updated: 2026-08-14  
Approval Required: Yes (EUC Manager, IAM Lead)  
Support Tower: EUC / Intune / IAM / Application Team

## Overview
Technical procedure for diagnosing and resolving multi-user login failure and severe login slowness in managed Windows 11 environments.

This article is a technical expansion of the source runbook and follows the same step sequence and branch model.

## Technical Background
RCA indicates no confirmed single root cause at this stage. Most likely contributors include Intune compliance/policy timing, authentication and Conditional Access path issues, profile initialization problems, and startup application contention linked to recent deployment.

## Symptoms
- Users unable to complete sign-in.
- Users sign in but desktop readiness is delayed beyond normal.
- Symptom concentration within one floor/cohort after recent change window.

## Possible Causes
- Intune compliance or policy assignment conflict.
- Conditional Access or authentication dependency issue.
- Windows profile loading or post-migration profile state issue.
- Startup application conflict, including recent deployment impact.
- Device performance bottleneck during startup and login phases.

## Detailed Diagnostic Procedure

Decision Tree

IF user cannot authenticate  
THEN validate sign-in outcome and policy result in identity platform.

IF sign-in is blocked by policy  
THEN route to IAM remediation branch and correct assignment/dependency.

IF sign-in succeeds but login remains slow  
THEN validate Intune compliance and policy timing on affected devices.

IF Intune state is unhealthy or inconsistent across cohort  
THEN execute Intune policy remediation branch.

IF Intune state is healthy  
THEN check profile initialization timing and profile consistency.

IF profile path/state is abnormal  
THEN execute profile recovery branch with data protection controls.

IF profile state is normal  
THEN assess startup application impact, including Friday deployment footprint.

IF startup contention is confirmed  
THEN execute deployment repair/rollback branch under change control.

IF none of the above determine cause  
THEN escalate to L3 for deep platform diagnostics and vendor engagement.

## Data Collection Requirements
Logs and audit data:
- Identity sign-in outcomes and timing for affected users.
- Intune compliance and policy status for affected devices.
- Endpoint event evidence around login window.
- Startup application state on affected and unaffected comparison devices.

Policies and configuration:
- Conditional Access policy assignment context.
- Intune policy scope and recent assignment changes.
- Deployment group targeting for new application rollout.

## Resolution Procedures
1. Mandatory: Confirm symptom subtype for each affected user ticket.
Expected result: Auth-failure vs post-auth slowness is documented.

2. Mandatory: Validate Intune compliance and recent policy application consistency.
Expected result: Policy-related delays are confirmed or ruled out.

3. Mandatory: Validate authentication and Conditional Access evaluation for failed logins.
Expected result: Access policy path is confirmed healthy or corrected.

4. Mandatory: Validate profile initialization integrity.
Expected result: Profile-state issues are corrected or excluded.

5. Mandatory: Validate startup application impact and deployment linkage.
Expected result: Deployment-related contention is corrected or ruled out.

6. Optional: Conduct controlled pilot exclusion or rollback test under approved change.
Expected result: Clear before/after confirmation of remediation effectiveness.

7. Mandatory: Apply minimum-risk permanent fix and confirm across pilot users before wider rollout.
Expected result: Stable login and acceptable timing restored.

[Screenshot Placeholder – Identity sign-in result and policy outcome]
[Screenshot Placeholder – Intune device compliance and policy state]
[Screenshot Placeholder – Application deployment state comparison]

## Validation
- Affected users authenticate and reach usable desktop.
- Login duration returns to operational baseline threshold.
- No new spikes in related incident volume during monitoring window.
- Compliance and security controls remain intact.

## Rollback
Rollback trigger:
- Remediation change worsens authentication or login performance.

Rollback actions:
1. Revert changed policy/deployment assignment to last known good state.
2. Re-test with pilot users.
3. Re-open branch diagnostics with captured evidence.

Rollback validation:
- Sign-in success restored on pilot users.
- No added security control regression.

## Known Issues
- Mixed symptom reports can represent concurrent root causes.
- Monday peak usage can increase apparent severity of latent issues.

## Security Considerations
- Do not bypass Conditional Access controls as a permanent workaround.
- Emergency remediation must remain traceable via approved change record.

## Monitoring Recommendations
- Track login failure rate and login-duration percentile for affected cohort.
- Monitor post-change incident volume for 3 business days.
- Include startup application health checks in change-aftercare.

## Related RCAs
- RCA_01_Login_Failure_and_Slow_Login.md
- rca-floor6-login-failures-and-slow-logins-provisional.md

## Related Runbooks
- Runbook_Login_Failure_and_Slow_Login.md
