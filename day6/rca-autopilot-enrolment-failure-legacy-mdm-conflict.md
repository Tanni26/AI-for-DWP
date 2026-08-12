# Root Cause Analysis (RCA): Autopilot Enrolment Failure Due to Legacy MDM Conflict

**Document Owner:** DWP Analyst  
**Date Authored:** 2026-08-11  
**Incident Date:** 2024-03-15  
**Incident Type:** Endpoint provisioning failure (Autopilot enrolment)  
**Device:** DESKTOP-FB099  
**User:** FINBRIDGE\\rthomas  
**OS Build:** 22621.2861

---

## 1. Executive Summary

Autopilot enrolment failed because the endpoint already had an active/stale legacy manual MDM enrolment record from 2023-11-04. This created an enrolment ownership conflict that prevented the new Autopilot MDM enrolment transaction from completing.

The failure signature was explicit:
- Enrolment failed with `0x80180014`
- Diagnostic text stated: "The device is already enrolled in MDM."
- Device metadata showed existing MDM enrolment with legacy source

Licensing and network prerequisites were healthy, ruling out those domains as primary causes.

---

## 2. Incident Scope and Impact

### Scope
- Affected workflow: Windows Autopilot enrolment for Windows 11 endpoint
- Affected policy chain: Security baseline/compliance profile application during provisioning
- Affected principal: `FINBRIDGE\\rthomas`

### Impact
- Device could not complete Autopilot enrolment.
- Intune policy payload did not apply (`0 of 4` profiles).
- Compliance engine could not complete evaluation because enrolment was incomplete.
- User provisioning experience was blocked until management state conflict was remediated.

---

## 3. Supporting Evidence (From MDM Diagnostic Export)

### 3.1 Core Enrolment Evidence
- `EnrollmentType: Autopilot`
- `EnrollmentState: Failed`
- `ErrorCode: 0x80180014`
- `ErrorDescription: The device is already enrolled in MDM.`
- `Timestamp: 2024-03-15 09:18:44`

### 3.2 Existing Legacy Enrolment Evidence
- `AzureADJoined: Yes`
- `MDMEnrolled: Yes (previous enrolment)`
- `EnrolmentSource: Legacy (manual MDM enrolment, 2023-11-04)`

### 3.3 Policy Processing Evidence
- `ProfilesAttempted: 4`
- `ProfilesApplied: 0`
- `LastError: 0x80070005 (Access denied)`
- `FailedProfile: FinBridge-Win11-Security-Baseline`
- `Timestamp: 2024-03-15 09:19:01`

### 3.4 Compliance Engine Evidence
- `EvaluationResult: Could not evaluate`
- `Reason: Enrolment not complete`
- `Timestamp: 2024-03-15 09:19:45`

### 3.5 Network Health Evidence
- `login.microsoftonline.com: OK`
- `enrollment.manage.microsoft.com: OK`
- `enterpriseregistration.windows.net: OK`
- `ProxyDetected: No`

### 3.6 Licensing Evidence
- `M365LicenseFound: Yes`
- `IntuneP1License: Yes`
- `AutopilotLicense: Yes`

---

## 4. Timeline (UTC+Local Device Time as Captured)

1. **2024-03-15 09:18:44**  
   Autopilot enrolment transaction failed (`EnrollmentState: Failed`) with `0x80180014` and message indicating existing MDM enrolment.

2. **2024-03-15 09:19:01**  
   PolicyManager attempted to process 4 profiles; none applied (`ProfilesApplied: 0`). `0x80070005` observed for baseline profile.

3. **2024-03-15 09:19:45**  
   ComplianceEngine returned `Could not evaluate` with explicit reason: `Enrolment not complete`.

4. **2024-03-15 09:22**  
   Diagnostic export snapshot captured for investigation, confirming:
   - Existing legacy/manual MDM enrolment source dated 2023-11-04
   - Healthy endpoint reachability and no proxy
   - Valid Intune and Autopilot licensing

---

## 5. 5 Whys Analysis

### Problem Statement
Device failed to complete Autopilot enrolment and could not receive required policy baseline.

1. **Why did Autopilot enrolment fail?**  
   Because enrolment state returned `Failed` with `0x80180014` and explicit message that the device was already enrolled in MDM.

2. **Why was the device already enrolled in MDM?**  
   Because the device had a previous legacy/manual MDM enrolment (dated 2023-11-04) that remained associated.

3. **Why did that previous enrolment remain during Autopilot onboarding?**  
   Because legacy enrolment state was not fully removed (admin-side records and/or device-side binding) before initiating Autopilot.

4. **Why was pre-existing enrolment not removed before Autopilot run?**  
   Because there was no enforced pre-flight control/checklist step that blocks Autopilot on devices with legacy MDM state.

5. **Why was there no enforced pre-flight control?**  
   Because migration governance did not include a mandatory legacy-enrolment hygiene gate (object cleanup + endpoint state validation) in the Autopilot readiness workflow.

### Root Cause
Absence of a mandatory legacy MDM cleanup and readiness gate allowed a device with a pre-existing manual MDM enrolment to enter Autopilot, causing deterministic enrolment conflict.

### Contributing Factors
- Historical coexistence of legacy/manual and Autopilot enrolment methods.
- Potential stale identity artifacts across endpoint, Intune, and Entra records.
- No hard stop in operations process for detected legacy enrolment state.

---

## 6. Technical Resolution

### Resolution Strategy
Remove conflicting legacy enrolment state, then re-run Autopilot with a single clean management identity path.

### Implemented/Required Actions
1. Admin-side cleanup of stale Intune managed device records tied to legacy enrolment.
2. Cleanup of duplicate/stale Entra device objects where applicable.
3. Validation of correct Autopilot hardware hash and profile assignment.
4. Device-side disconnect/removal of old work or school/legacy MDM binding.
5. Device reboot and rerun of Autopilot OOBE/Enrollment Status Page flow.

---

## 7. Verification Criteria (Post-Remediation)

The incident is considered resolved when all conditions below are true:

- Autopilot enrolment completes without `0x80180014`.
- Device appears as a single intended managed identity (no stale duplicates).
- Assigned policy profiles apply successfully (not `0 of 4`).
- Compliance engine performs normal evaluation (no "enrolment not complete" blocker).
- Device check-in and management status are current in Intune.

---

## 8. Preventive Actions

### 8.1 Process Controls
- Implement a mandatory Autopilot pre-flight gate for legacy devices.
- Block enrolment start if any prior manual/legacy MDM state is detected.
- Require evidence of Intune/Entra object hygiene before migration wave approval.

### 8.2 Operational Checklist (Service Desk / Engineering)
- Verify no existing MDM enrolment on endpoint before reset/redeploy.
- Verify no stale/duplicate Intune or Entra objects for same hardware.
- Verify Autopilot hash/profile assignment before OOBE begins.

### 8.3 Monitoring and Reporting
- Add recurring report/dashboard to identify devices with:
  - Legacy/manual enrolment markers
  - Duplicate device identities
  - Enrolment conflict error patterns
- Review report before each Autopilot deployment wave.

### 8.4 Governance
- Decommission legacy manual enrolment path for Autopilot-targeted fleets.
- Publish a standard migration runbook with clear ownership for cleanup and validation.
- Add change control requirement: readiness checklist must be attached to CAB/change record.

---

## 9. Residual Risk and Follow-Up

### Residual Risk
Medium until pre-flight controls are enforced tenant-wide; similar failures can recur on unmanaged legacy endpoints.

### Follow-Up Actions
- Build and approve pre-flight runbook/checklist.
- Pilot checklist on next 10 legacy devices prior to broader wave.
- Audit historical Autopilot failures for same evidence pattern and remediate backlog.

---

## 10. Final RCA Statement

This incident was caused by a pre-existing legacy/manual MDM enrolment record that conflicted with Autopilot enrolment. Network and licensing were healthy and did not contribute to failure initiation. The corrective path is full legacy enrolment cleanup (admin and endpoint) followed by fresh Autopilot enrolment under a single valid device identity, with a mandatory pre-flight control added to prevent recurrence.
