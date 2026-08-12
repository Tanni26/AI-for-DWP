# L2/L3 KB: Autopilot Enrolment Failure Due to Legacy MDM Conflict

Version: 1.0 | Date: 12/08/2026 | Status: Active

## Purpose
Provide engineering-grade diagnosis and remediation for Autopilot enrolment failure caused by pre-existing legacy/manual MDM enrolment state.

## Signature to Match
- EnrollmentState: Failed
- ErrorCode: 0x80180014
- ErrorDescription: Device already enrolled in MDM
- MDMEnrolled: Yes (previous/legacy)
- EnrolmentSource indicates legacy/manual path
- ProfilesApplied: 0 of 4 with 0x80070005 possible secondary symptom
- Licensing and network healthy

## Preconditions
- Intune admin role with device management permissions
- Entra device admin visibility
- Device access (remote or physical)
- Change record/ticket approved where required

## Order of Operations (Strict)
1. Identify all related objects (Intune device, Entra device, Autopilot identity) using device name + serial.
2. Remove stale Intune managed device object(s) tied to legacy/manual enrolment.
3. Remove stale duplicate Entra object(s) where unambiguously legacy.
4. Validate Autopilot hardware hash record and profile assignment.
5. Confirm enrolment prerequisites: MDM scope, restrictions, Intune/Autopilot license assignment.
6. On endpoint, disconnect old work/school account binding.
7. Remove residual legacy enrolment artifacts using approved endpoint cleanup method.
8. Reboot endpoint.
9. Re-run Autopilot OOBE/ESP enrolment.
10. Validate portal/device outcomes.

## Verification Checklist
- Enrolment completes without 0x80180014.
- Device has single active intended management object.
- Intune check-in is current.
- Policy profile assignment/apply starts successfully (no longer 0 of 4).
- Compliance evaluation runs and reports normally.

## Rollback / Fallback
If rerun still fails:
1. Reconfirm no duplicate/stale objects remain.
2. Recollect fresh MDM diagnostic export.
3. Validate enrolment restriction and platform limit policies for user/device group.
4. Escalate to platform engineering with artifact bundle.

## Artifact Bundle for Deep Escalation
- MDM diagnostic export (full)
- dsregcmd /status output
- Intune device object screenshots before/after cleanup
- Entra device object screenshots before/after cleanup
- Autopilot profile assignment screenshot
- Timeline of executed actions with timestamps

## Preventive Engineering Actions
- Automate pre-flight checks for legacy enrolment markers before Autopilot wave.
- Add duplicate object detection to migration dashboard.
- Enforce runbook gate requiring object hygiene evidence before provisioning begins.

## Related Documents
- RCA: day6/rca-autopilot-enrolment-failure-legacy-mdm-conflict.md
- Known Error: day6/known-error-autopilot-enrolment-failure-legacy-mdm-conflict.md
- Closure Note: day6/autopilot-enrolment-failure-closure-note.md
