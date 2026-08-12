# Autopilot Enrolment Failure Analysis and Remediation (Legacy MDM Conflict)

**Author:** DWP Analyst  
**Date:** 2026-08-11  
**Incident Type:** Autopilot enrolment failure  
**Primary Error:** 0x80180014  
**Related Policy Error:** 0x80070005 (Access denied)

---

## 1) Confirmed Root Cause

Autopilot enrolment failed because the device already had an existing legacy/manual MDM enrolment record (dated 2023-11-04). The new Autopilot enrolment could not complete over the conflicting existing enrolment.

Evidence used:
- `EnrollmentState: Failed`
- `ErrorCode: 0x80180014`
- `ErrorDescription: The device is already enrolled in MDM.`
- `MDMEnrolled: Yes (previous enrolment)`
- `EnrolmentSource: Legacy (manual MDM enrolment, 2023-11-04)`
- `ProfilesApplied: 0 of 4`
- `LastError: 0x80070005 (Access denied)`
- `AzureADJoined: Yes`
- `IntuneP1License: Yes`
- `AutopilotLicense: Yes`
- `Network endpoints reachable; no proxy`

---

## 2) Exact Remediation Steps

### Access Legend
- **[ADMIN CENTER ONLY]**: Intune/Entra admin actions, no endpoint touch required.
- **[DEVICE ACCESS REQUIRED]**: Physical or remote access to the affected endpoint required.

### A. Admin-side cleanup (remove stale management state)

1. **Locate the device in Intune Admin Center**  
   **[ADMIN CENTER ONLY]**
   - Go to: `Intune admin center > Devices > All devices`
   - Search by device name, serial number, and (if available) Autopilot hardware hash identity.
   - Record all matching objects before deletion.

2. **Retire/Delete stale Intune managed device record(s)**  
   **[ADMIN CENTER ONLY]**
   - Open each stale/legacy-managed device record.
   - If active and user-affecting, choose **Retire** first where process requires it.
   - Delete stale device record(s) that represent the old manual enrolment path.

3. **Validate and clean duplicate Entra device object(s) if present**  
   **[ADMIN CENTER ONLY]**
   - Go to: `Microsoft Entra admin center > Devices > All devices`
   - Identify duplicate or stale objects for the same physical endpoint.
   - Remove stale duplicate object(s) that are clearly tied to the legacy enrolment, keeping the intended current identity.

4. **Validate Autopilot device identity exists and is assigned correctly**  
   **[ADMIN CENTER ONLY]**
   - Go to: `Intune admin center > Devices > Windows > Windows enrollment > Devices`
   - Confirm the device hardware hash record exists.
   - Confirm assigned Autopilot profile is correct (example: FinBridge-Autopilot-Standard).

5. **Confirm user and device licensing/scope assignments remain valid**  
   **[ADMIN CENTER ONLY]**
   - Confirm Intune and Autopilot eligible licensing is still assigned.
   - Confirm MDM user scope and enrolment restrictions do not block the user/device category.

### B. Device-side cleanup (remove old enrolment artifacts)

6. **Disconnect old work/school account binding**  
   **[DEVICE ACCESS REQUIRED]**
   - On device: `Settings > Accounts > Access work or school`
   - Select old/legacy connected account and choose **Disconnect**.

7. **Remove legacy MDM management residue (if still present after disconnect)**  
   **[DEVICE ACCESS REQUIRED]**
   - Use elevated endpoint cleanup workflow approved by DWP standards to remove stale enrolment entries.
   - Reboot device after cleanup.

8. **Re-initiate Autopilot OOBE enrolment**  
   **[DEVICE ACCESS REQUIRED]**
   - Start OOBE/Autopilot flow for corporate sign-in.
   - Complete sign-in and allow Enrollment Status Page to finish.

---

## 3) Correct Order of Operations

Use this exact sequence to avoid re-creating conflict states:

1. **[ADMIN CENTER ONLY]** Identify all related Intune/Entra/Autopilot records.
2. **[ADMIN CENTER ONLY]** Remove stale Intune managed device record(s).
3. **[ADMIN CENTER ONLY]** Remove stale duplicate Entra device object(s), if present.
4. **[ADMIN CENTER ONLY]** Confirm Autopilot hardware hash/profile assignment is correct.
5. **[ADMIN CENTER ONLY]** Reconfirm licence/scope prerequisites.
6. **[DEVICE ACCESS REQUIRED]** Disconnect legacy work/school account from device.
7. **[DEVICE ACCESS REQUIRED]** Clean leftover legacy enrolment artifacts and reboot.
8. **[DEVICE ACCESS REQUIRED]** Re-run Autopilot enrolment (OOBE/ESP).
9. **[ADMIN CENTER ONLY]** Validate successful enrolment and policy application.

---

## 4) Verification Checks (Post-Remediation)

Run all checks below to confirm Autopilot completion and policy processing success.

### Device-level checks
- **[DEVICE ACCESS REQUIRED]** Run `dsregcmd /status` and confirm Azure AD join and expected tenant state.
- **[DEVICE ACCESS REQUIRED]** Verify `Settings > Accounts > Access work or school` shows only the intended current management connection (no legacy duplicate).

### Intune portal checks
- **[ADMIN CENTER ONLY]** In Intune device record, confirm:
  - Enrolment is successful and current check-in updates.
  - Device is managed by MDM under the expected ownership/user.
- **[ADMIN CENTER ONLY]** In policy status, confirm target baseline/profile is now applying (not `0 of 4`).
- **[ADMIN CENTER ONLY]** Confirm no recurrence of `0x80180014` for this enrolment attempt.
- **[ADMIN CENTER ONLY]** Confirm compliance engine can evaluate (no longer blocked by incomplete enrolment).

### Success criteria
Autopilot remediation is complete only when all are true:
- Enrolment completes without `0x80180014`.
- Device appears once (no stale duplicate management identity).
- Assigned profiles apply successfully.
- Compliance evaluation runs normally.

---

## 5) Preventive Action (Stop Recurrence Across Legacy Devices)

Implement a pre-flight gate for all Autopilot candidates.

### Preventive control
- **[ADMIN CENTER ONLY]** Build a pre-enrolment validation process that checks for:
  - Existing MDM enrolment history.
  - Duplicate Intune/Entra device objects.
  - Correct Autopilot identity/profile assignment.

### Operational process
- Maintain a legacy-device migration runbook requiring cleanup of prior manual MDM enrolments before assigning/reassigning Autopilot profile.
- Add service desk checklist step: "No pre-existing MDM enrolment on endpoint" before scheduling Autopilot reset/redeployment.
- Add reporting query/dashboard to flag devices with legacy manual enrolment indicators before Autopilot batch waves.

### Governance recommendation
- Standardize device lifecycle: legacy manual MDM enrolment paths must be retired before Autopilot onboarding begins.
- Require CAB/change approval evidence that stale device identities were reviewed and cleaned for each migration wave.

---

## 6) Final Resolution Statement

The incident is resolved by removing the stale legacy/manual MDM enrolment state (admin-side records and device-side bindings), then re-running Autopilot so the device can enrol under a single clean management identity.

Once completed, policy and compliance processing should proceed normally because licensing and network prerequisites were already healthy.
