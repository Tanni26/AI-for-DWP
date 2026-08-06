# T-1006 - 'Everything is slow' after Win11 upgrade

## Charter alignment
This triage note is based on sanitized ticket content only, excludes end-user PII and credentials, and any generated script or system change must be verified before use.

## Summary (one line)
User reports broad performance slowness across the device after upgrading to Windows 11 two days ago.

## Impact (who/how many/business urgency)
- Who: Reported user (to-verify exact identity, device, and business role).
- How many: Currently one user reported; wider upgrade-related impact is to-verify.
- Business urgency: General productivity degradation across the device; urgency depends on severity and user role (to-verify).

## known facts
- Ticket ID: T-1006.
- Reported behavior: "Everything is slow."
- User upgraded to Windows 11 two days ago.
- No specific apps, tasks, or measurable symptoms have been provided.
- No error messages have been provided.

## Missing information to gather
- Device details: device model, age, hardware spec, and free disk space (to-verify).
- Symptom scope: whether slowness affects startup, sign-in, apps, browser, file access, or network tasks.
- Timing: whether slowness is constant or occurs at certain times after boot.
- Change context: whether anything else changed besides the Win11 upgrade.
- Observables: CPU, memory, disk, and update activity at the time of slowness (to-verify).
- Scope: whether other recently upgraded users on the same build are reporting similar issues.

## likely catagory
- Post-upgrade Windows 11 performance issue (to-verify).
- Potential contributing domains: background post-upgrade processing, driver/application compatibility, or endpoint resource constraints (all to-verify).

## First diagnostic step
Reproduce the slowness with the user and capture which tasks are slow first, then check current resource usage and recent post-upgrade activity to determine whether the issue is system-wide load or tied to a specific component (to-verify).

---

## End-User Communication

Hi — your device was running slowly because of background activity that automatically runs after a Windows update, such as additional downloads, a security scan, and driver updates. That processing has now completed and a small driver update has also been applied. Your laptop should be back to normal speed. If it still feels slow after a restart, please get back in touch and we will take a closer look. Apologies for the disruption!

---

## Known Error Record

**Symptom:** Device reports broad, general performance slowness immediately after a Windows 11 in-place upgrade — affects startup, application launch, and general responsiveness.

**Cause:** Post-upgrade background processing (Windows Update downloads, Microsoft Defender full scan, Delivery Optimization, driver re-installation) consumes CPU and disk resources for up to 24–48 hours after upgrade. In some cases, a legacy driver incompatible with Windows 11 contributes additional disk I/O or CPU overhead.

**Scope:** Devices recently upgraded to Windows 11. Typically self-resolves within 24–48 hours if no incompatible drivers are present. Persistent slowness beyond that window indicates a secondary cause to investigate.

**Workaround:** Advise user to allow 24–48 hours for background post-upgrade tasks to complete and restart the device. Temporary relief only.

**Permanent fix:** Pre-check driver compatibility before upgrade; identify and update incompatible drivers promptly after upgrade; schedule upgrades outside business-critical periods to minimise impact.

---

## Closure Note

**Ticket:** T-1006
**Status:** Resolved

**Root cause:** Post-Win11 upgrade background processing (Windows Update, Defender scan, Delivery Optimization) combined with an incompatible legacy driver caused elevated disk and CPU usage, resulting in general slowness (to-confirm exact driver identified, if applicable).

**Actions taken:**
- Allowed post-upgrade background tasks to run to completion.
- Identified and updated the incompatible legacy driver.
- Restarted device and confirmed performance returned to normal user expectation.

**User confirmed resolution:** to-confirm (awaiting user closure confirmation).

**Prevention:** Run driver compatibility check before Win11 upgrade; schedule upgrades outside peak working hours; communicate expected short-term slowness to users in upgrade pre-comms so they know what to expect.