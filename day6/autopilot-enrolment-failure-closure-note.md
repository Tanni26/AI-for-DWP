# Incident Closure Note: Autopilot Enrolment Failure (Legacy MDM Conflict)

Version: 1.0 | Date: 12/08/2026 | Status: Closed

## Incident Summary
Autopilot enrolment failed on device DESKTOP-FB099 due to pre-existing legacy/manual MDM enrolment state. The enrolment transaction failed with 0x80180014 and did not proceed to policy/compliance completion.

## Key Evidence at Triage
- EnrollmentState: Failed
- ErrorCode: 0x80180014
- ErrorDescription: Device already enrolled in MDM
- MDMEnrolled: Yes (legacy/manual enrolment from 2023-11-04)
- ProfilesApplied: 0 of 4
- LastError: 0x80070005
- AzureADJoined: Yes
- Licensing present: Yes
- Network endpoints reachable: Yes

## Resolution Actions Completed
1. Removed stale legacy-linked managed device object(s) in Intune.
2. Removed stale duplicate device object(s) in Entra where applicable.
3. Confirmed Autopilot identity/profile assignment.
4. Removed legacy work or school binding on endpoint.
5. Rebooted endpoint and re-ran Autopilot enrolment.

## Verification Outcome
- Autopilot enrolment completed without 0x80180014.
- Device appears with single intended management identity.
- Target policy profiles can apply.
- Compliance engine no longer blocked by incomplete enrolment.

## Root Cause
Legacy/manual MDM enrolment conflict was not removed before Autopilot onboarding.

## Preventive Actions Logged
- Implement mandatory pre-flight checks for legacy enrolment before Autopilot provisioning.
- Add duplicate Intune/Entra object hygiene checks to migration runbook.
- Add service desk gate: no pre-existing MDM enrolment before scheduling Autopilot reset/redeployment.

## Closure Classification
- Category: Endpoint Management
- Subcategory: Autopilot Enrolment Conflict
- Closure code: Resolved - stale legacy enrolment state removed and provisioning retried

## Linked Records
- RCA: day6/rca-autopilot-enrolment-failure-legacy-mdm-conflict.md
- Known Error: day6/known-error-autopilot-enrolment-failure-legacy-mdm-conflict.md
- Remediation Analysis: day6/autopilot-enrolment-failure-legacy-mdm-remediation-analysis.md
