# JAMF Configuration Profile Baseline - macOS Design Team Fleet
**Authored by:** DWP Engineer  
**Date:** 2026-08-14  
**Scope:** 25 corporate macOS devices managed by JAMF Pro  
**Enforcement model:** Configuration Profiles + Smart Group compliance logic + remediation policies

---

## Important Verification Discipline (Day 6 Intune-style)

JAMF payload names, tabs, and control labels vary across JAMF Pro versions, Apple macOS releases, and deployment model (classic profiles vs newer managed software update workflows).

For every item marked **[VERIFY IN YOUR JAMF INSTANCE]**, validate the exact UI label and path in your own tenant before rollout. Treat this document as implementation guidance, not an exact UI transcript.

---

## How to Create a Configuration Profile in JAMF Pro

Navigate to: **Computers > Configuration Profiles > New** **[VERIFY IN YOUR JAMF INSTANCE]**

The profile workflow is usually organized by left navigation sections:

> **General -> Payloads -> Scope -> Self Service (optional) -> Save**

### Step 1 - General

Complete these fields first:

| Field | What to enter | Notes |
|---|---|---|
| Name | `MACOS-DWP-Design-Security-Baseline` | Keep naming consistent across profiles and smart groups |
| Description | `macOS security baseline for Design team: FileVault, Gatekeeper, Firewall, lock-on-sleep, and update controls.` | Include baseline controls and ownership |
| Distribution Method | Install Automatically | Ensures profile is pushed without end-user action |
| Level | Computer Level | Required for device-wide security settings |

### Step 2 - Payloads

Enable and configure payloads listed in Requirements 1, 2, 4, and 5 below. Some tenants expose equivalent controls under slightly different payload names.

### Step 3 - Scope

Assign to an inventory/static/smart group representing the 25-device Design fleet:

| Field | Guidance |
|---|---|
| Targets | Include `GRP-MACOS-Design-Team` (or equivalent) |
| Exclusions | Exclude lab/test, shared kiosk, and temporary migration devices |

### Step 4 - Save and Deploy

Save the profile and force inventory update on test devices. Validate effective state before full production scope.

---

## How to Implement Version Compliance and Noncompliance Handling in JAMF

JAMF does not mirror Intune's exact "mark noncompliant" control in all editions. Use this equivalent pattern:

1. Define smart groups for each compliance condition (for example, `MACOS-NonCompliant-OSVersion`, `MACOS-NonCompliant-FileVault`).
2. Scope remediation policies to noncompliant groups.
3. Add notifications/escalation via webhook, email, or ITSM integration.
4. If Conditional Access is used, map JAMF compliance signal via your identity integration path.

---

## Post-Assignment Validation (After First Device Check-in)

Use this section after assigning the baseline profile and waiting for at least one device inventory update.

### 1) Where to verify one device's status

Use either path:

**Path A (from profile):**  
Computers > Configuration Profiles > `MACOS-DWP-Design-Security-Baseline` > Scope/Status **[VERIFY IN YOUR JAMF INSTANCE]**

**Path B (from device record):**  
Computers > Inventory > [Device] > Profiles / Security / Management tabs **[VERIFY IN YOUR JAMF INSTANCE]**

### 2) State meaning for operations

| State | Meaning | Operational impact |
|---|---|---|
| Compliant | Device meets configured controls and version baseline. | No remediation action required. |
| Noncompliant | One or more controls are missing, failed, or stale in inventory. | Device enters remediation policy scope; may be blocked by downstream access controls depending on integration. |
| Unknown / Pending | Device has not checked in recently or profile state not yet reconciled. | Treat as temporary until next inventory cycle, then re-evaluate. |

### 3) Common false-positive triage flow

| Check | Why it matters | Fastest validation |
|---|---|---|
| Last inventory update time | Most "failures" are stale inventory snapshots. | Compare profile deployment time to latest recon/check-in timestamp. |
| Local setting vs JAMF state | Device may be healthy before JAMF shows success. | Validate locally, then force inventory update and recheck. |
| Update deferral windows | Version/update settings can be intentionally delayed. | Verify deferral policy and update schedule for that device group. |

---

## Baseline Mapping Table

| # | Requirement | Payload type | Value | Effect | False-positive risk |
|---|---|---|---|---|---|
| 1 | FileVault disk encryption must be enabled | **Disk Encryption / FileVault** **[VERIFY IN YOUR JAMF INSTANCE]** | Enable FileVault for all users; escrow personal recovery key to JAMF; enforce enablement at next auth event | Encrypts local disk data at rest and protects lost/stolen endpoints | Encryption in progress, delayed escrow confirmation, or stale inventory snapshot |
| 2 | Gatekeeper must be enabled (identified developers only) | **Security & Privacy (Gatekeeper)** or equivalent Restrictions control **[VERIFY IN YOUR JAMF INSTANCE]** | Set app execution policy to **Mac App Store and identified developers** | Blocks unsigned/untrusted app execution and allows signed developer apps | Local command checks run before profile applies, temporary developer exception workflows |
| 3 | Minimum macOS version: current stable minus one point release | **Managed Software Updates** + **Smart Group criteria** **[VERIFY IN YOUR JAMF INSTANCE]** | Set compliance logic to minimum version N-1 from current stable; scope remediation to below-minimum group | Keeps endpoints in a supported security patch window | Beta/RC build string parsing, delayed check-in, update deferrals, offline devices |
| 4 | Firewall must be enabled | **Security & Privacy (Firewall)** **[VERIFY IN YOUR JAMF INSTANCE]** | Enable Application Firewall; enable stealth mode if required by policy | Reduces inbound attack surface from unsolicited network traffic | Third-party firewall tooling conflict or inventory lag after profile application |
| 5 | Login password required after sleep/screen saver | **Security & Privacy** or **Passcode/Restrictions lock settings** **[VERIFY IN YOUR JAMF INSTANCE]** | Require password after sleep or screen saver with immediate or approved short grace period | Prevents unattended-device walk-up access | OS-specific grace-period behavior differences or delayed profile reconciliation |
| 6 | Automatic security updates enabled | **Software Update** payload + managed update policy **[VERIFY IN YOUR JAMF INSTANCE]** | Enable automatic checking/downloading and automatic installation of security updates, including rapid security response/system data files where available | Improves patch timeliness and reduces user-dependent update delay | Devices off network/power, CDN restrictions, deferrals, or maintenance-window misses |

---

## Requirement 1 - FileVault Disk Encryption Must Be Enabled

| Field | Detail |
|---|---|
| Payload type | Disk Encryption / FileVault **[VERIFY IN YOUR JAMF INSTANCE]** |
| Typical UI path | Computers > Configuration Profiles > [Profile] > Disk Encryption payload **[VERIFY IN YOUR JAMF INSTANCE]** |
| Value | FileVault enabled for all targeted devices; escrow personal recovery key to JAMF |
| Effect | Enforces full-disk encryption so storage data is unreadable without valid user credential or recovery key |
| False-positive risk | Immediately after enablement, state can show failed/pending while encryption completes or escrow has not posted |
| Recommendation | Pilot first, confirm key escrow visibility in JAMF inventory, then scale to full 25-device scope |

> ⚠️ **UI Change Flag:** FileVault controls may appear as "Disk Encryption," "FileVault," or OS-specific labels in different JAMF versions. Verify exact label/path before publishing the profile.

---

## Requirement 2 - Gatekeeper Must Be Enabled (Identified Developers Only)

| Field | Detail |
|---|---|
| Payload type | Security & Privacy (Gatekeeper) or equivalent Restrictions control **[VERIFY IN YOUR JAMF INSTANCE]** |
| Typical UI path | Computers > Configuration Profiles > [Profile] > Security & Privacy / Restrictions **[VERIFY IN YOUR JAMF INSTANCE]** |
| Value | Allow apps from Mac App Store and identified developers; disallow "Anywhere" |
| Effect | Prevents unsigned/unverified software execution while preserving approved developer workflow |
| False-positive risk | Temporary local override/testing workflows can drift from managed state until next profile reconciliation |
| Recommendation | Pair with exception process for approved internal tools requiring notarization/signing remediation |

> ⚠️ **UI Change Flag:** Depending on macOS generation and JAMF UI revision, Gatekeeper may be surfaced under Security & Privacy or a Restrictions-adjacent control. Validate actual control location in your tenant.

---

## Requirement 3 - Minimum macOS Version (Current Stable Minus One Point Release)

| Field | Detail |
|---|---|
| Payload type | Managed Software Updates policy + smart group compliance criteria **[VERIFY IN YOUR JAMF INSTANCE]** |
| Typical UI path | Computers > macOS Managed Software Updates and/or Smart Groups criteria editor **[VERIFY IN YOUR JAMF INSTANCE]** |
| Value | Set minimum version rule to N-1 point release of current stable (example: stable 14.7, minimum 14.6) |
| Effect | Marks outdated endpoints for remediation and reduces vulnerability exposure from lagging patch levels |
| False-positive risk | Inventory latency, update deferral windows, devices powered off, and pre-release version naming mismatches |
| Recommendation | Maintain a monthly baseline review tied to Apple's release cadence and update smart group criteria immediately after new stable release validation |

> ⚠️ **UI Change Flag:** Some JAMF tenants expose managed update controls as "Software Updates," others as "Managed Software Updates" with additional scheduling fields. Confirm naming and behavior in your instance.

---

## Requirement 4 - Firewall Must Be Enabled

| Field | Detail |
|---|---|
| Payload type | Security & Privacy (Firewall) **[VERIFY IN YOUR JAMF INSTANCE]** |
| Typical UI path | Computers > Configuration Profiles > [Profile] > Security & Privacy > Firewall **[VERIFY IN YOUR JAMF INSTANCE]** |
| Value | Enable Application Firewall; optionally enforce stealth mode if required by internal standard |
| Effect | Ensures inbound connection control is active on managed endpoints |
| False-positive risk | Third-party firewall controls can conflict with reporting; status may appear stale right after profile deployment |
| Recommendation | Standardize on one endpoint firewall authority and document approved exception patterns |

> ⚠️ **UI Change Flag:** Firewall options and toggles may differ between OS payload versions. Validate that the enforced setting maps to Apple ALF controls expected by your baseline.

---

## Requirement 5 - Login Password Required After Sleep/Screen Saver

| Field | Detail |
|---|---|
| Payload type | Security & Privacy lock settings or Passcode/Restrictions equivalent **[VERIFY IN YOUR JAMF INSTANCE]** |
| Typical UI path | Computers > Configuration Profiles > [Profile] > Security & Privacy / Passcode **[VERIFY IN YOUR JAMF INSTANCE]** |
| Value | Require password after sleep or screen saver; preferred value is immediate lock unless approved grace period exists |
| Effect | Prevents unauthorized physical access when user leaves workstation unattended |
| False-positive risk | Local cached preference values, grace-period interpretation differences, or delayed profile processing at login |
| Recommendation | Validate with a standard user account and real sleep/wake cycle tests, not only static profile state |

> ⚠️ **UI Change Flag:** Lock behavior fields may be distributed across different payloads depending on JAMF/macOS version pairing. Verify where your tenant exposes the authoritative lock setting.

---

## Requirement 6 - Automatic Security Updates Enabled

| Field | Detail |
|---|---|
| Payload type | Software Update payload and managed update policy **[VERIFY IN YOUR JAMF INSTANCE]** |
| Typical UI path | Computers > Configuration Profiles > [Profile] > Software Update and/or Managed Software Updates **[VERIFY IN YOUR JAMF INSTANCE]** |
| Value | Enable automatic check/download/install of security updates and rapid response/system data updates where available |
| Effect | Reduces dwell time for known vulnerabilities by enabling automatic patch uptake |
| False-positive risk | Device unavailable during maintenance windows, network constraints, Apple CDN delay, or deferred update settings |
| Recommendation | Use phased rings (pilot then broad), and monitor update failure reasons via smart groups and policy logs |

> ⚠️ **UI Change Flag:** Apple and JAMF have changed update-control surfaces across recent macOS releases. Confirm whether your tenant expects profile-level settings, managed update plan settings, or both.

---

## Design Fleet Implementation Notes (25 Devices)

1. Start with 3 to 5 pilot devices spanning different Mac models/chipsets and one remote user profile.
2. Run pilot for one full check-in/update cycle before broad deployment.
3. Deploy baseline profile to full design group only after escrow, firewall, and lock behaviors are validated.
4. Keep version compliance (Requirement 3) and auto-update controls (Requirement 6) in dedicated update-focused policies for easier tuning.
5. Document approved exceptions (for example, temporary developer testing allowances) in a separate exception smart group.

---

## Summary Table

| # | Requirement | Payload type | Value | Enforcement outcome |
|---|---|---|---|---|
| 1 | FileVault enabled | Disk Encryption / FileVault | On + escrow keys | Startup disk encrypted at rest |
| 2 | Gatekeeper identified developers only | Security & Privacy / Restrictions | App Store + identified developers | Unsigned/untrusted apps blocked |
| 3 | Minimum macOS N-1 | Managed updates + smart group | Minimum version threshold | Outdated devices targeted for remediation |
| 4 | Firewall enabled | Security & Privacy (Firewall) | Firewall on (stealth optional) | Inbound exposure reduced |
| 5 | Password after sleep/screensaver | Security & Privacy / Passcode | Immediate or approved short grace | Unattended walk-up access blocked |
| 6 | Automatic security updates | Software Update / Managed updates | Auto check/download/install security updates | Faster security patch uptake |

---

## UI Change Flags Summary

| Requirement | Risk level | Note |
|---|---|---|
| FileVault (R1) | Medium | Label may appear as Disk Encryption or FileVault depending on JAMF build. |
| Gatekeeper (R2) | Medium | Control location can shift between Security & Privacy and Restrictions. |
| Minimum OS (R3) | High | Managed update naming/workflow differs most across JAMF versions. |
| Firewall (R4) | Low | Usually stable, but option granularity can vary by OS payload schema. |
| Lock after sleep (R5) | Medium | Lock timing fields may appear in different payload families. |
| Auto security updates (R6) | High | Apple/JAMF update orchestration model has changed significantly in recent releases. |

---

*Document owner: DWP Engineering | Review cycle: Monthly + after each Apple stable release | Next review: 2026-09-14*
