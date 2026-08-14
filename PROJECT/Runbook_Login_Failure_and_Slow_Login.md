# Runbook: Login Failure and Slow Login

## Version Header
- Document ID: RB-F6-LOGIN-001
- Source RCA: RCA_01_Login_Failure_and_Slow_Login.md
- Document Owner: End User Compute Operations
- Version: 1.1
- Review Frequency: Quarterly
- Last Updated: 2026-08-14
- Approval Required: Yes (IT Operations Lead, EUC Manager)
- Support Tower: EUC / Intune / IAM

Document Owner: End User Compute Operations  
Version: 1.1  
Review Frequency: Quarterly  
Last Updated: 2026-08-14  
Approval Required: Yes (IT Operations Lead, EUC Manager)  
Support Tower: EUC / Intune / IAM

## 1. Purpose
- Provide a repeatable procedure to restore user sign-in capability and acceptable login performance for Legal endpoints.
- Address business impact of legal-user downtime, delayed case work, and start-of-day productivity loss.

## 2. Scope
- Systems covered: Windows 11 endpoints, Intune device management, identity sign-in path, startup application stack.
- Teams involved: L1 Service Desk, L2 EUC, L2 Intune, IAM, L3 Platform Engineering, Application Team.
- Supported environments: FinBridge managed Windows 11 devices in Legal support scope.

## 3. Prerequisites
Required access:
- Intune read access for L1; Intune admin for L2.
- Identity sign-in and Conditional Access visibility for IAM/L2.
- Endpoint remote support access.

Required permissions:
- Ticket-linked support authorization for affected users.
- Change approval for policy or application rollback actions.

Required tools:
- Service desk ticketing platform.
- Intune admin center.
- Identity and sign-in audit portal.
- Endpoint event and performance viewing tools approved by IT.

Required approvals:
- Emergency change approval for broad rollback.
- Application owner approval for deployment rollback.

Required data/logs:
- Affected user list and timestamps.
- Device list and Intune compliance state.
- Sign-in outcome and latency evidence.
- Startup application status on affected devices.

Change requirements:
- Any tenant-wide policy or deployment change must follow change control.

## 4. Trigger Conditions
- Multiple users report inability to log in.
- Users can log in but desktop readiness is significantly delayed.
- Incident correlated to recent endpoint/policy/application change window.
- Related incident/problem records indicate Floor-specific degradation.

## 5. Root Cause Overview
- RCA status: Root Cause Not Yet Confirmed.
- Working causes include startup application contention, Intune policy timing/conflict, authentication latency, and profile initialization delays.
- Confirmed vs hypothesis: no single confirmed root cause without diagnostic evidence.

## 6. Resolution Procedure

### Step 1
Action: Mandatory. Classify each affected user symptom into one class: cannot authenticate, authenticates but slow desktop readiness, or intermittent behavior.
Expected Result: Every affected ticket has one symptom class and first-impact time.
If Successful: Proceed to Step 2.
If Failed: Continue user interviews until classification is complete.
Escalation Point: L1 to L2 EUC if classification cannot be completed within 15 minutes.

### Step 2
Action: Mandatory. Confirm scope by checking whether issue is isolated to Legal floor cohort or broader user population.
Expected Result: Scope documented as floor-specific or cross-floor.
If Successful: Proceed to Step 3.
If Failed: Treat as potential major incident and engage incident manager.
Escalation Point: L2 EUC to Major Incident Management.

### Step 3
Action: Mandatory. Validate Intune compliance and recent policy assignment state for affected devices.
Expected Result: Device compliance and policy application status are known for each sampled device.
If Successful: Proceed to Step 4.
If Failed: Branch A (Intune remediation path).
Escalation Point: L2 Intune.

### Step 4
Action: Mandatory. Validate authentication outcomes and Conditional Access result for affected user sign-ins.
Expected Result: Sign-in is identified as success with latency, or failure with policy/auth reason.
If Successful: Proceed to Step 5.
If Failed: Branch B (IAM/Conditional Access path).
Escalation Point: IAM support team.

### Step 5
Action: Mandatory. Check user profile initialization health and desktop readiness behavior on sample affected devices.
Expected Result: Determine whether delays are during profile loading or after desktop appears.
If Successful: Proceed to Step 6.
If Failed: Branch C (profile remediation path).
Escalation Point: L2 EUC profile specialist.

### Step 6
Action: Mandatory. Validate startup application impact, including Friday document management deployment presence and startup behavior.
Expected Result: Clear conclusion whether startup app contention is present.
If Successful: Proceed to Step 7.
If Failed: Branch D (application deployment path).
Escalation Point: Application Team + EUC.

### Step 7
Action: Mandatory. Perform the minimum-risk corrective action based on branch outcome.
Expected Result: Affected users regain login access and acceptable login duration.
If Successful: Proceed to Step 8.
If Failed: Escalate to L3 and hold further changes.
Escalation Point: L3 Platform Engineering.

### Step 8
Action: Optional troubleshooting. On unresolved devices, run deeper device performance checks during login window.
Expected Result: Additional evidence for bottleneck (policy, profile, app, or device resource).
If Successful: Apply branch-specific fix and move to verification.
If Failed: Escalate for vendor-supported diagnostics.
Escalation Point: L3 + Vendor.

Decision Branch A (Intune compliance/policy)
- Mandatory: Re-sync policy on affected devices and confirm targeted assignments.
- Mandatory: Correct mis-scoped assignments if identified through approved change.
- Optional: Temporarily exclude pilot device from suspect policy for controlled test.

Decision Branch B (Authentication/Conditional Access)
- Mandatory: Confirm user sign-in policy path and required controls.
- Mandatory: Correct broken assignment or dependency via approved IAM change.
- Optional: Controlled test with pilot user after policy correction.

Decision Branch C (Windows profile path)
- Mandatory: Resolve profile initialization issue using approved profile recovery method.
- Mandatory: Preserve user data before profile-level recovery action.
- Optional: Re-test with alternate known-good device profile for comparison.

Decision Branch D (Startup application/deployment path)
- Mandatory: Validate document management app rollout status versus unaffected controls.
- Mandatory: If linked, pause further rollout and execute targeted repair or rollback.
- Optional: Controlled uninstall/reinstall on pilot endpoint under change approval.

[Screenshot Placeholder – Intune compliance view for affected devices]
[Screenshot Placeholder – Sign-in policy result view]
[Screenshot Placeholder – Startup application impact comparison]

## 7. Verification Procedure
- [ ] User can sign in successfully.
- [ ] Login duration returns to agreed operational threshold.
- [ ] No recurring incident pattern in the next monitoring window.
- [ ] Device compliance and policy state are healthy.
- [ ] Application startup sequence no longer causes delay.

## 8. Post-Implementation Validation
- Technical validation: Compare pre-fix and post-fix login timings.
- User confirmation: Affected users confirm normal start-of-day access.
- Service validation: Incident volume trends return to baseline.
- Security validation: No policy bypass or weakened control introduced by remediation.

## 9. Rollback Procedure
Rollback trigger:
- Login failure rate increases after remediation.
- New authentication denials appear due to remediation change.
- Endpoint instability increases in affected cohort.

Rollback steps:
1. Revert changed policy/deployment assignment to last known good state.
2. Revert any emergency startup application changes performed in this runbook.
3. Re-run core validation on pilot users before broad release.

Validation after rollback:
- Pilot users can sign in.
- Incident trend does not worsen.
- Compliance/security controls remain enforced.

Escalation path:
- L2 EUC to L3 Platform Engineering to Vendor Support.

## 10. Risks and Considerations
- Multiple symptoms may represent multiple root causes.
- Aggressive rollback without evidence can delay final resolution.
- Emergency changes must not bypass security controls.
- Monday peak load can mask root cause if evidence is not preserved early.

## 11. Escalation Matrix
- L1: Capture facts, classify symptoms, collect mandatory evidence.
- L2: Execute branch remediation and validate outcomes.
- L3: Handle complex policy/auth/profile conflicts and cross-platform dependencies.
- Vendor: Engage for platform-specific unresolved behavior.
- Security Team: Review if remediation changes impact control posture.
- Problem Management: Open problem record for recurring pattern and permanent control actions.

## 12. Lessons Learned
- Friday endpoint/application changes require Monday readiness gating.
- Symptom-based triage improves speed by separating auth from post-auth issues.
- Parallel evidence collection across Intune, IAM, and application teams reduces MTTR.

## 13. References
- RCA: RCA_01_Login_Failure_and_Slow_Login.md
- Supporting analysis: rca-floor6-login-failures-and-slow-logins-provisional.md
- Prevention control: floor6-prevention-note-legal-change-readiness-gate.md
