# FAULT-B Communications

## Audience 1 - Non-technical Executive
Access and data are safe. Finance shared drive access failed for 45 users because a recent script change ran at the wrong sign-in context and could not complete drive mapping. This was not a Group Policy failure. IT is restoring mapping through the correct user sign-in method and validating access. No action is needed unless your shared drives are still missing.

## Audience 2 - Affected End-user Team (non-technical)
Hi team, Finance shared drives were unavailable because the new drive-mapping method ran in the wrong sign-in mode and could not assign the S: drive. This was not a Group Policy problem. IT is switching mapping back to the correct user sign-in method and validating access across Finance devices. If your S: drive is still missing after sign-in, contact Helpdesk and mention FAULT-B Finance shared drive mapping.

## Audience 3 - Engineer-to-engineer Internal Note
Scope:
- All Finance users impacted (45 users), DESKTOP-FB* estate, OU=Finance.

Root cause:
- Migration changed mapping from USER-context GPO logon script to SYSTEM-context Intune PowerShell script.
- Script was not updated for SYSTEM context constraints; UNC path \\finbridge-fs01\Finance inaccessible at execution time.
- No retry configured, so failure persisted.

Evidence anchors:
- Intune [08:00:01] execute Map-FinBridgeDrives.ps1.
- Intune [08:00:02] context SYSTEM.
- Intune [08:00:03] warning UNC not accessible in SYSTEM context.
- Intune [08:00:03] error exit code 1 network name cannot be found.
- Intune [08:00:04] no retry configured.
- FB041 [08:00:06] GP 1500 success (not GP issue).
- FB041 [08:00:07] NTFS 98 warning, S: not assigned.

Action taken / required:
- Restore mapping execution to USER context at sign-in.
- Trigger re-run via sign-out/sign-in and validate share access.

Preventive:
- Add context-gate, pilot validation, and retry/delay plus UNC pre-check for mapping scripts migrated to Intune.
- Require rollback readiness for mapping-critical changes.