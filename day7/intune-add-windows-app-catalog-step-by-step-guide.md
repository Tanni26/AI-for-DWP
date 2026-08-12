# Intune Runbook: Add a Windows App to the Catalog Before Phased Rollout

## Purpose
Use this guide to add a Windows application to the Intune app catalog and validate it with a pilot assignment before any phased rollout.

Worked example used throughout:
- Application: FinBridge Connect v3.1
- Package type: Windows LOB app packaged as a `.intunewin` file
- Install command: `FinBridgeConnect_Setup.exe /silent`
- Uninstall command: `FinBridgeConnect_Setup.exe /uninstall /silent`
- Detection method: Registry value
- Detection target: `HKLM\SOFTWARE\FinBridge\Connect\Version = 3.1`

---

## 1. Add the app in Intune (where to go and what type to pick)

1. Sign in to the Microsoft Intune admin center.
2. Navigate to Apps > All apps > Add.
3. In Select app type, choose the type that matches your package and deployment pattern.

Tenant UI variance check:
- Exact labels and menu placement can vary by tenant version, licensing, and portal updates.
- Verify the live labels in your tenant and follow the equivalent path if wording differs.

4. Select the correct app type:
- For FinBridge Connect v3.1 (`.intunewin`): choose Windows app (Win32).
- For a Microsoft Store app: choose Microsoft Store app (new) (or the current Store option shown in your tenant).
- For a web shortcut: choose Web link.

Important:
- If your package is `.intunewin`, do not choose Microsoft Store app or Web link.
- Win32 is the expected app type for custom packaged enterprise installers.

---

## 2. Create the Windows LOB app (required fields)

### Step 2.1: Start app creation
1. Go to Apps > All apps > Add.
2. Select Windows app (Win32).
3. Upload the FinBridge `.intunewin` package.

Tenant UI variance check:
- Some tenants show a separate Select file action before the create wizard opens.
- Confirm your tenant flow before proceeding.

### Step 2.2: App Information (required metadata)
1. Set Name: `FinBridge Connect`.
2. Set Description: `FinBridge Connect desktop client for secure enterprise connectivity.`
3. Set Publisher: `FinBridge`.
4. Set Version: `3.1`.

Recommended quality checks:
- Ensure the display name is exactly what Service Desk and users should see in Company Portal.
- Keep description user-friendly and support-oriented.

### Step 2.3: Program (required execution details)
1. Installer type:
  - Set to `Command line`.
2. Install command:
  - `FinBridgeConnect_Setup.exe /silent`
3. Uninstaller type:
  - Set to `Command line`.
4. Uninstall command:
  - `FinBridgeConnect_Setup.exe /uninstall /silent`
5. Installation time required (mins):
  - Set a realistic timeout window for the package. Start with `60` unless vendor guidance says otherwise.
6. Allow available uninstall:
  - Set to `Yes` if you want users to be able to uninstall from Company Portal when the app is assigned as Available.
  - Set to `No` for tightly controlled apps that must remain installed.
7. Install behavior:
  - Choose `System` for machine-wide installs requiring elevated rights.
  - Choose `User` only if the vendor explicitly requires per-user install context.

For this example:
- Use `System` context unless the application vendor states `User` context is mandatory.
- Set both installer and uninstaller type to `Command line`.
- Use `60` minutes as the initial install timeout.

Tenant UI variance check:
- Label names such as Install behavior may appear as Install context in some tenants.
- Verify against live UI terms in your environment.

### Step 2.4: Requirements (device eligibility)
1. Check operating system architecture:
  - Choose `Yes` only if you must explicitly restrict architectures.
  - Choose `No` to allow install on all architectures supported by the app package.
2. Minimum operating system:
  - Select the minimum supported Windows release from the drop-down.
3. Disk space required (MB):
  - Leave blank unless the vendor specifies a hard minimum.
4. Physical memory required (MB):
  - Leave blank unless the vendor specifies a hard minimum.
5. Minimum number of logical processors required:
  - Leave blank unless the vendor specifies a hard minimum.
6. Minimum CPU speed required (MHz):
  - Leave blank unless the vendor specifies a hard minimum.
7. Configure additional requirement rules:
  - Add custom rules only when there is a validated technical requirement (for example, specific registry, file, or script-based prerequisite checks).

For this example:
- Set Check operating system architecture to `No`.
- Set Minimum operating system to your enterprise baseline approved for FinBridge Connect v3.1.
- Leave hardware minimum fields blank unless FinBridge vendor documentation requires specific values.

Why this matters:
- Incorrect requirement targeting causes Not applicable status for unsupported devices.

### Step 2.5: Detection rules (how Intune confirms install success)
1. Choose Rules format: manually configure detection rules (or equivalent current label).
2. Choose detection type: Registry.
3. Configure:
   - Key path: `HKLM\SOFTWARE\FinBridge\Connect`
   - Value name: `Version`
   - Detection method: String comparison equals
   - Expected value: `3.1`

Alternative detection methods you may use for other apps:
- MSI product code
- File or folder existence/version at a known path

Tenant UI variance check:
- The detection wizard terminology can vary (for example Rule type, Detection method, or Operator labels).
- Confirm equivalent options in your tenant.

### Step 2.6: Return codes (exit code interpretation)
1. Open the Return codes section.
2. Confirm at minimum that success and reboot behaviors are mapped correctly.

Common baseline mapping:
- `0` = Success
- `1707` = Success
- `3010` = Soft reboot required
- `1641` = Hard reboot initiated
- `1618` = Retry
- Non-zero unknown codes = Failed (unless explicitly mapped)

Recommended action:
- Add these return codes explicitly in the Return codes grid for this app so status reporting aligns with installer behavior.

Important:
- Keep vendor-documented exit code mappings aligned with Intune return code settings.
- A mismatch here can mark successful installs as failed.

3. Save and create the app object.

---

## 3. Assignment basics (Required vs Available vs Uninstall)

1. Open the app you created: Apps > All apps > FinBridge Connect.
2. Go to Assignments.

### Step 3.1: Configure assignments in the Assignments page layout
1. In the Required section, select Add group.
2. Pick your pilot Azure AD group (small test scope), then save.
3. In Available for enrolled devices, optionally select Add group if you want pilot users to self-install from Company Portal.
4. Do not use Add all devices for a new app during first deployment.
5. Use Add all users only when the app is intentionally user-targeted and has completed pilot validation.

Tenant UI variance check:
- Some tenants show different column names (for example Availability, End user notifications, Installation deadline).
- Verify live labels and apply the equivalent action rather than relying on exact wording in this guide.

Operational note:
- Intune may display an information banner that Win32 apps are not automatically removed when a device is retired.
- If app removal is required at retirement, define and execute a separate uninstall/retirement process.

Tenant UI variance check:
- Grouping and section labels may differ slightly by tenant UI version.
- Verify the equivalent assignment sections in live portal.

3. Choose assignment intent:
- Required:
  - Intune enforces install automatically on targeted devices/users.
  - Best for mandatory corporate apps after pilot validation.
- Available for enrolled devices:
  - App appears in Company Portal for user self-install.
  - Best for optional tools or staged user-driven adoption.
- Uninstall:
  - Intune removes the app from targeted devices/users.
  - Use for rollback, retirement, or scope correction.

4. Assign first to a small pilot group.

Why pilot first (do not deploy to all 10,000 devices immediately):
- Detects packaging, detection, and command-line issues safely.
- Limits blast radius if install loops, reboots unexpectedly, or fails on specific hardware.
- Validates network/load impact and user experience before scale-out.
- Provides real telemetry for tuning requirements and return code handling.

Recommended pilot pattern:
- Start with a small IT-controlled device set.
- Expand to a representative business pilot.
- Only then proceed to phased production rings.

---

## 4. Verification steps (catalog and device outcome checks)

### Step 4.1: Confirm app appears correctly in catalog
1. Go to Apps > All apps.
2. Locate FinBridge Connect.
3. Confirm key properties:
- Name, Publisher, Version
- App type shows Win32
- Assignment exists for pilot group

Tenant UI variance check:
- Column names and default views may vary.
- Verify equivalent columns or open app properties directly.

### Step 4.2: Confirm install result on assigned test device
1. In Intune, open the FinBridge Connect app.
2. Review Device install status (or equivalent status blade).
3. Select a known pilot device and inspect status details.
4. On the test device, verify local evidence:
- Application installed
- Registry detection value exists and equals `3.1`

### Step 4.3: Interpret common statuses
- Installed:
  - Intune detected install success using your detection rule.
- Failed:
  - Install command returned an error code or detection failed after install attempt.
  - Check device details and return code mapping.
- Not applicable:
  - Device does not meet requirements (OS version/architecture/scope mismatch) or target conditions.

Operational tip:
- If many devices show Not applicable unexpectedly, re-check Requirements first.
- If many devices show Failed with app present, re-check Detection rules and Return codes.

---

## 5. Minimum completion checklist before phased rollout

1. App object created with correct Win32 type and metadata.
2. Program commands validated for silent install/uninstall.
3. Install behavior confirmed as System or User by design.
4. Requirements aligned to supported OS and architecture.
5. Detection rule validated against real device state.
6. Return codes reviewed against vendor documentation.
7. Assigned only to pilot group first.
8. Pilot devices show expected Installed status.
9. Any Failed/Not applicable statuses investigated and resolved.
10. Approval recorded to begin phased rollout.

If any checklist item fails, pause rollout and correct configuration before expanding assignment scope.
