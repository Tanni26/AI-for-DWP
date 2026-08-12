# Known Error: Autopilot Enrolment Failure Due to Legacy MDM Conflict

Version: 1.0 | Date: 12/08/2026 | Status: Active

## KE ID
KE-AP-1603-001

## Title
Autopilot enrolment fails when endpoint has pre-existing legacy/manual MDM enrolment.

## Symptom Pattern
- Autopilot enrolment fails during OOBE/ESP.
- User cannot complete corporate device setup.
- Policy and compliance do not complete.

## Observable Evidence Signature
- EnrollmentState: Failed
- ErrorCode: 0x80180014
- ErrorDescription: The device is already enrolled in MDM.
- MDMEnrolled: Yes (previous enrolment)
- EnrolmentSource: Legacy manual MDM enrolment (2023-11-04)
- ProfilesApplied: 0 of 4
- LastError: 0x80070005 (Access denied)
- AzureADJoined: Yes
- IntuneP1License: Yes
- AutopilotLicense: Yes
- Network endpoints reachable; no proxy

## Impact
- Device provisioning blocked.
- Security baseline and other policies are not applied.
- Compliance state cannot evaluate while enrolment is incomplete.

## Scope
- In scope: Windows Autopilot onboarding of devices with historical manual/legacy MDM enrolment.
- Out of scope: Licensing loss, network outage, tenant-wide Intune service outage.

## Confirmed Root Cause
Legacy/manual MDM enrolment state remained on the endpoint and/or corresponding management objects, causing enrolment conflict during Autopilot.

## Workaround (Short-Term)
- Remove stale management identity from Intune/Entra.
- Remove old work or school connection from endpoint.
- Reboot and rerun Autopilot enrolment.

## Permanent Fix
Implement mandatory pre-flight checks before Autopilot starts:
- No existing legacy/manual MDM enrolment.
- No stale duplicate Intune/Entra device objects.
- Correct Autopilot identity and profile assignment.

## Detection Query/Check Guidance
- Intune: verify duplicate/stale managed device records for same serial/device name.
- Entra: verify duplicate/stale device objects tied to same hardware.
- Endpoint: verify Access work or school has no legacy management binding.

## Escalation Criteria
Escalate to L2/L3 when:
- Device fails again with same signature after first cleanup attempt.
- Duplicate identity mapping cannot be safely determined.
- Multiple devices in same migration wave show same issue.

## Linked Documents
- RCA: day6/rca-autopilot-enrolment-failure-legacy-mdm-conflict.md
- Remediation analysis: day6/autopilot-enrolment-failure-legacy-mdm-remediation-analysis.md
- L1 KB: day6/l1-kb-autopilot-enrolment-failure-legacy-mdm-conflict.md
- L2/L3 KB: day6/l2-l3-kb-autopilot-enrolment-failure-legacy-mdm-conflict.md
