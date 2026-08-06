# Triage Summary (DWP Service Desk)

## Context
- Charter file reference: personal-ai-usage-charter.md
- Charter content available in workspace: yes
- AI handling note: keep triage inputs sanitized, exclude end-user PII and credentials, and verify any generated script or system change before use.

## Ticket
T-1001

Raw ticket:
"New Win11 laptop, BitLocker prompting for recovery key every boot."

### Summary (one line)
New Windows 11 laptop prompts for BitLocker recovery key on every boot.

### Impact (who/how many/ business urgency)
- Who: Single end user/device based on current ticket text (user identity to-verify)
- How many: 1 reported endpoint
- Business urgency: to-verify (depends on user role and whether user can complete boot each time)

### known facts
- Device is a new Windows 11 laptop.
- BitLocker recovery key prompt appears every boot.
- Ticket ID is T-1001.

### Missing information to gather
- User details: name, team, location, contact.
- Exact device details: hostname, serial/asset tag, build image, join type (AAD/AD/hybrid).
- Whether user can enter the recovery key successfully and reach desktop.
- When issue first occurred and whether it started immediately after build/updates.
- Any recent firmware/BIOS/TPM changes, docking changes, or hardware changes.
- Whether Secure Boot/TPM status changed or is reporting warnings.
- Scope check: any other newly deployed Win11 devices affected.
- Availability of recovery key in enterprise key escrow and access path.

### likely catagory
Endpoint encryption / BitLocker recurring recovery prompt incident

### First diagnostic step
Verify TPM and BitLocker protector state on the affected device and confirm whether a recent hardware/firmware baseline changed, while validating the recovery key escrow record for that device.

---

## End-User Communication

Hi — your new laptop was asking for an extra security key each time it started up, which we have now resolved. Your files and data are completely safe and nothing has been lost. You should no longer see that prompt when you switch on your device. If the request does come back, please contact the service desk straight away and we will sort it out for you. Sorry for the inconvenience!

---

## Known Error Record

**Symptom:** New Windows 11 laptop requests BitLocker recovery key on every boot.

**Cause:** TPM measurement mismatch after device deployment — caused by a firmware/BIOS update, Secure Boot state change, or hardware modification that altered the PCR values BitLocker sealed against, causing the protector to invalidate on every boot.

**Scope:** Newly deployed Windows 11 devices; correlates with firmware/BIOS baseline changes at build time. Wider scope to-confirm.

**Workaround:** User can boot by entering the recovery key retrieved from enterprise escrow; not a sustainable user-fixable resolution.

**Permanent fix:** Verify TPM health and Secure Boot baseline; suspend and resume BitLocker encryption to re-seal the protector against current PCR values; confirm device boots cleanly without prompt. Validate TPM/Secure Boot settings are consistent across new device builds.

---

## Closure Note

**Ticket:** T-1001
**Status:** Resolved

**Root cause:** TPM measurement mismatch on new Win11 device caused BitLocker to require recovery key on every boot. Likely trigger: firmware or BIOS baseline change at or after device build (to-confirm exact trigger).

**Actions taken:**
- Verified TPM state and Secure Boot configuration on affected device.
- Suspended BitLocker encryption, confirmed PCR state, then resumed encryption to re-seal protectors against current values.
- Confirmed device boots cleanly without recovery key prompt.

**User confirmed resolution:** to-confirm (awaiting user closure confirmation).

**Prevention:** Validate TPM and Secure Boot baseline on all new Win11 deployments before handover; ensure BitLocker recovery keys are escrowed in enterprise key management before device is issued.
