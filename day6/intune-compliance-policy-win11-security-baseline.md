# Intune Compliance Policy – Windows 11 Security Baseline
**Authored by:** DWP Engineer  
**Date:** 2026-08-11  
**Scope:** Windows 11 managed devices enrolled in Microsoft Intune  
**Noncompliance Action:** Mark device noncompliant immediately  

---

## How to Create a Compliance Policy

Navigate to: **Devices > Manage devices > Compliance > Policies tab > + Create policy**

The **+ Create policy** button appears in the top toolbar of the Policies tab, alongside Refresh, Export, and Columns.

The policy creation wizard has 5 steps shown across the top of the screen:

> **① Basics → ② Compliance settings → ③ Actions for noncompliance → ④ Assignments → ⑤ Review + create**

---

### Step 1 – Basics

Complete the following fields before clicking **Next**:

| Field | What to enter | Notes |
|---|---|---|
| **Name** *(required)* | e.g. `WIN11-DWP-Security-Baseline-Compliance` | Use a clear, consistent naming convention |
| **Description** | e.g. `Windows 11 compliance policy enforcing DWP security baseline. Covers BitLocker, Secure Boot, OS build, Defender, Firewall, PIN, and device integrity.` | Free text — visible to other admins in the portal |
| **Platform** | `Windows 10 and later` | Pre-set and greyed out — cannot be changed after selection |
| **Profile type** | `Windows 10/11 compliance policy` | Pre-set and greyed out — auto-populated based on platform |

Click **Next** to proceed to Compliance settings.

---

### Step 2 – Compliance Settings

This is where all 7 requirements from this document are configured. See each requirement section below for the exact setting name, value, and UI path within this step.

Click **Next** to proceed to Actions for noncompliance.

---

### Step 3 – Actions for Noncompliance

Configure the noncompliance action here. Based on the available UI, the default action is **Mark device noncompliant** with the schedule set to **Immediately**.

| Action | Setting | Value |
|---|---|---|
| Mark device noncompliant | Schedule (days after noncompliance) | **Immediately** |

Leave the additional action row blank unless your tenant exposes and requires another noncompliance action. The screenshot provided does not show a configured message template or additional recipients.

Click **Next** to proceed to Assignments.

---

### Step 4 – Assignments

| Field | Guidance |
|---|---|
| **Included groups** | Assign to the Azure AD / Entra ID group containing your Windows 11 managed devices (e.g. `GRP-WIN11-ManagedDevices`) |
| **Excluded groups** | Add exclusion groups for kiosk devices, legacy hardware, or developer machines that require a separate policy |

Click **Next** to proceed to Review + create.

---

### Step 5 – Review + Create

Review all settings shown on the summary screen. Confirm Name, Platform, Compliance settings, Actions, and Assignments are correct, then click **Create**.

The policy will appear in the Compliance Policies list and begin evaluating devices within the next Intune sync cycle (default: every 8 hours, or trigger manually via Company Portal > Sync).

---

## How to Configure Noncompliance Actions

In Intune > Devices > Manage devices > Compliance > [Policy] > **Actions for noncompliance**:  
Keep the default action as **Mark device noncompliant** with **Immediately** selected. Do not populate message template or additional recipients unless those options are available and required in your tenant.

---

## Post-Assignment Validation (After First Device Sync)

Use this section after the policy is assigned and a test device has completed a sync.

### 1) Where to See This Device's Status for This Specific Policy

Use either path below to verify policy-specific status:

**Path A (from the policy):**  
Devices > Manage devices > Compliance > Policies > **WIN11-DWP-Security-Baseline-Compliance** > **Device status** > search for the test device name.

**Path B (from the device):**  
Devices > All devices > select test device > **Device compliance** > select **WIN11-DWP-Security-Baseline-Compliance** > review per-setting results.

If the status is delayed, confirm the device shows a recent check-in time and trigger another Company Portal sync.

### 2) Compliance State Meaning and Conditional Access Impact

| Compliance state | What it means | Conditional Access impact when policy requires compliant device |
|---|---|---|
| **Compliant** | Device passed all required checks for the policy. | Access allowed (assuming all other CA controls pass). |
| **Not compliant** | One or more required checks failed, and noncompliance action is already active. | Access blocked by CA policies requiring compliant device. |
| **In grace period** | Device has a failed check, but noncompliance grace timer has not expired yet. | Usually treated as allowed until grace period expires, then blocked. Validate tenant behavior if custom noncompliance actions are used. |

This baseline currently uses **Immediate** noncompliance action, so devices are expected to transition directly to **Not compliant** when a required setting fails.

### 3) BitLocker False-Positive Triage (BitLocker Enabled but Intune Shows Not Compliant)

| Common cause | Why it appears as a false positive | Fastest check |
|---|---|---|
| **Encryption state not fully reported yet** (new enrollment, upgrade, or reboot pending) | Local encryption is enabled, but CSP/WMI status is not fully updated at evaluation time. | On the device, run `manage-bde -status C:`. Confirm Conversion Status is fully encrypted and Protection Status is on. If recently changed, reboot once and sync again. |
| **Stale Intune compliance evaluation** | Device became encrypted after last policy evaluation, but portal still shows old noncompliant state. | In Intune device pane, compare Last check-in time to when BitLocker was enabled. Trigger Company Portal sync, wait 5-15 minutes, then recheck Device compliance details. |
| **BitLocker CSP/WMI reporting issue** (MDM bridge or WMI provider issue) | Device is encrypted locally, but Intune cannot reliably read the BitLocker compliance signal. | Compare `manage-bde -status C:` with `Get-BitLockerVolume -MountPoint C:`. If local tools show healthy encryption but Intune remains noncompliant after resync, collect MDM diagnostics and review DeviceManagement-Enterprise-Diagnostics-Provider admin events. |

---

## Requirement 1 – BitLocker Must Be Enabled on the OS Drive

| Field | Detail |
|---|---|
| **Setting Name** | Require BitLocker |
| **UI Path** | Endpoint security > Disk encryption > BitLocker *or* Devices > Manage devices > Compliance > [Policy] > Device Health > Require BitLocker |
| **Value** | Require |
| **Effect** | Enforces that BitLocker Drive Encryption is active on the OS (C:) drive. Devices without encryption are marked non-compliant. |
| **False-Positive Risk** | BitLocker may be fully encrypted but the WMI/CSP status not yet reported to Intune (common immediately post-enrolment or post-upgrade). Devices pending a reboot to complete encryption will also report as non-compliant. |
| **Recommendation** | Account for post-enrolment reporting delays before treating new devices as failed. Consider a remediation script to check and trigger `manage-bde -on C:` for corporate-owned devices before compliance is reviewed. |

> ⚠️ **UI Change Flag:** The Disk Encryption profile path moved to **Endpoint security > Disk encryption** in newer Intune releases. If your tenant was created after mid-2023, use that path rather than the legacy Compliance policy Device Health section. Verify current path in your tenant.

---

## Requirement 2 – Secure Boot Must Be Enabled

| Field | Detail |
|---|---|
| **Setting Name** | Require Secure Boot to be enabled on the device |
| **UI Path** | Devices > Manage devices > Compliance > [Policy] > **Device Health** > Require Secure Boot to be enabled on the device |
| **Value** | Require |
| **Effect** | Validates that UEFI Secure Boot is active, preventing unsigned boot loaders and rootkits from loading before the OS. |
| **False-Positive Risk** | Older hardware (pre-2017) may not support Secure Boot even with UEFI firmware. Devices dual-booting Linux may have Secure Boot disabled by the user. Virtual machines (non-Gen2 Hyper-V, VMware without vTPM) will also fail. |
| **Recommendation** | Maintain a hardware exclusion group for legacy devices that cannot support Secure Boot and scope this policy only to compliant hardware groups. Document exceptions in the CMDB. |

---

## Requirement 3 – Minimum OS Build

| Field | Detail |
|---|---|
| **Setting Name** | Minimum OS version |
| **UI Path** | Devices > Manage devices > Compliance > [Policy] > **Device Properties** > Minimum OS version |
| **Value** | **Not specified in available source material** |
| **Effect** | Marks any device running below the configured Windows 11 minimum OS version as non-compliant, enforcing the organisation's chosen patch baseline. |
| **False-Positive Risk** | Windows Update ring deferrals, WSUS/WUfB policies, metered connections, or devices offline during patch Tuesday can legitimately delay update installation beyond the deadline. |
| **Recommendation** | Define the minimum OS version in line with your Windows Update ring deadline and patch governance process. Review and update this value after each Patch Tuesday. Consider a phased approach: warn at N-1, block at N-2. |

> ⚠️ **UI Change Flag:** Intune now surfaces **OS version ranges** per Windows 11 release channel in some tenants. If you see "Minimum OS version for mobile" and "Minimum OS version for desktop" as separate fields, use the desktop field. Verify field labels match the above in your tenant.

---

## Requirement 4 – Windows Defender Real-Time Protection Must Be On

| Field | Detail |
|---|---|
| **Setting Name** | Require real-time protection |
| **UI Path** | Devices > Manage devices > Compliance > [Policy] > **System Security** > Require real-time protection |
| **Value** | Require |
| **Effect** | Verifies that Microsoft Defender Antivirus real-time protection is running and not disabled by policy, user action, or a conflicting third-party AV product. |
| **False-Positive Risk** | Third-party AV (CrowdStrike, Sophos, etc.) can place Defender into passive mode, which reports real-time protection as "off" even though the endpoint is protected. This is the most common source of false positives for this setting. |
| **Recommendation** | If a third-party EDR/AV is deployed, either: (a) exclude this check and replace with a Defender for Endpoint compliance connector signal, or (b) use the **Microsoft Defender for Endpoint** integration in Intune which accounts for passive mode correctly. |

> ⚠️ **UI Change Flag:** In tenants with the **Microsoft Defender for Endpoint connector** enabled, the recommended path is **Endpoint security > Endpoint detection and response** connector-based compliance, which is more accurate than the legacy System Security check. Confirm which integration your organisation uses.

---

## Requirement 5 – Firewall Must Be Enabled for All Profiles

| Field | Detail |
|---|---|
| **Setting Name** | Microsoft Defender Firewall |
| **UI Path** | Devices > Manage devices > Compliance > [Policy] > **System Security** > Microsoft Defender Firewall |
| **Value** | Require |
| **Effect** | Checks that Windows Firewall is enabled across Domain, Private, and Public network profiles. A device with firewall disabled on any profile is marked non-compliant. |
| **False-Positive Risk** | Some legacy enterprise applications or VPN clients programmatically disable the firewall profile during installation or connection and do not re-enable it. Group Policy applied from on-prem AD can also conflict and disable profiles. |
| **Recommendation** | Audit firewall profile status via Intune Device Configuration (Endpoint Protection profile) in addition to compliance. Use the compliance policy to detect and report; use a configuration profile to enforce and remediate. Investigate any VPN client or application known to modify firewall state. |

---

## Requirement 6 – A PIN or Password Must Be Configured

| Field | Detail |
|---|---|
| **Setting Name** | Require a password to unlock mobile devices / Password required |
| **UI Path** | Devices > Manage devices > Compliance > [Policy] > **System Security** > Password > Password required to unlock mobile devices (set to **Require**) |
| **Value** | Require |
| **Supplementary Settings** | Minimum password length: 8 characters; Password type: Alphanumeric or PIN; Maximum minutes of inactivity before password is required: 15 |
| **Effect** | Ensures the device has a screen lock PIN, password, or Windows Hello credential configured. Devices with no lock screen credential are non-compliant. |
| **False-Positive Risk** | Shared kiosk devices or shared workstations configured with auto-logon will fail this check. Domain-joined hybrid devices where the password policy is GPO-managed may report inaccurately until the Intune MDM authority fully reconciles with the device. |
| **Recommendation** | Exempt kiosk/shared device groups via a separate compliance policy with relaxed settings. For hybrid-joined devices, validate that the Intune MDM channel is the authoritative policy source for lock screen settings. |

> ⚠️ **UI Change Flag:** The label "Require a password to unlock mobile devices" is a legacy Windows Mobile-era label still present in some Intune tenants for Windows 10/11 policies. Microsoft has been incrementally relabelling this to "Password required" in newer policy creation flows. The functional setting is the same. Confirm the label in your tenant.

---

## Requirement 7 – Device Must Not Be Jailbroken or Rooted

| Field | Detail |
|---|---|
| **Setting Name** | Device must not be jail broken or rooted |
| **UI Path** | Devices > Manage devices > Compliance > [Policy] > **Device Health** > Device must not be jail broken or rooted |
| **Value** | Require |
| **Effect** | On Windows 11, this setting works in conjunction with the **Device Health Attestation (DHA)** service and Windows Defender System Guard to detect integrity violations — including boot integrity failures, Secure Boot bypass, and tampered system files. |
| **False-Positive Risk** | Developer mode enabled on a device (e.g. for sideloading applications) may trigger this check. Devices where the TPM attestation log cannot be retrieved (TPM errors, firmware bugs) can fail silently and report as non-compliant. |
| **Recommendation** | Combine with Secure Boot (Requirement 2) and TPM attestation reporting for defence-in-depth. For developer/test devices, create a separate compliance policy that permits developer mode and scope accordingly. Monitor DHA failures in the Intune Device Health Attestation report. |

> ⚠️ **UI Change Flag:** On Windows 11, "jailbroken/rooted" detection is backed by the **Microsoft Azure Attestation** service in newer Intune tenants (replacing the on-premises DHA service). The setting label in the UI remains the same but the backend has changed. Ensure your tenant has the attestation service connector configured if you are seeing widespread unexpected failures.

---

## Summary Table

| # | Requirement | Setting Name | Value | Noncompliance Action |
|---|---|---|---|---|
| 1 | BitLocker on OS drive | Require BitLocker | Require | Immediate |
| 2 | Secure Boot enabled | Require Secure Boot | Require | Immediate |
| 3 | Minimum OS build | Minimum OS version | Tenant-specific | Immediate |
| 4 | Defender real-time protection | Require real-time protection | Require | Immediate |
| 5 | Firewall all profiles | Microsoft Defender Firewall | Require | Immediate |
| 6 | PIN or password configured | Password required | Require | Immediate |
| 7 | Not jailbroken/rooted | Device must not be jail broken or rooted | Require | Immediate |

---

## UI Change Flags Summary

| Requirement | Risk Level | Note |
|---|---|---|
| BitLocker (R1) | Medium | Setting may exist in both Compliance > Device Health and Endpoint Security > Disk Encryption. Use Endpoint Security path on newer tenants. |
| Defender RTP (R4) | High | Third-party AV passive mode causes widespread false positives. Consider MDE connector integration instead. |
| Password (R6) | Low | Label may still read "mobile devices" — functional behaviour is identical for Windows 11. |
| Jailbreak (R7) | Medium | Backend attestation service changed to Azure Attestation. Confirm connector is active in your tenant. |

---

*Document owner: DWP Engineering | Review cycle: Align to Patch Tuesday + 30 days | Next review: 2026-09-11*
