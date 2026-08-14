# KB L1: Missing Desktop Shortcuts

Document Owner: Service Desk Operations  
Version: 1.0  
Review Frequency: Monthly  
Last Updated: 2026-08-14  
Approval Required: Yes (Service Desk Manager)  
Support Tower: Service Desk / EUC

## Source Lineage
This article is a plain-language L1 re-expression of the source runbook: Runbook_Missing_Desktop_Shortcuts.md.

## Symptoms
- User reports desktop shortcuts are missing after login.
- Desktop shows fewer items than expected or only default icons.

## Impact
- Reduced user productivity and slower application access.
- Potential repeat calls if baseline restoration is not handled correctly.

## Initial Checks
- [ ] Confirm which shortcuts are missing (all, some, or custom only).
- [ ] Confirm user is logged into expected account and device.
- [ ] Confirm whether other users nearby report same issue.

## Quick Resolution
1. Capture affected user and device details.
2. Request screenshot of current desktop.  
   [Screenshot Placeholder – Desktop before recovery]
3. Confirm user can still access key apps via Start menu/taskbar.
4. If issue is isolated and no policy/deployment concern is apparent, assist user with approved quick shortcut recreation for urgent apps.
5. If multiple users report issue, stop ad hoc per-user rebuild and escalate for cohort-level diagnosis.

## When to Escalate
Escalate when any of the following applies:
- More than one user reports missing shortcuts in same cohort.
- User profile appears mismatched or recently recreated.
- Desktop state changes return after sign-out/sign-in.
- Incident aligns with recent migration, Intune, or application deployment changes.

## Information to Collect Before Escalation
Required:
- User details: full name, department, contact.
- Device details: device name, managed status.
- Time of issue: when shortcuts were last seen and first noticed missing.
- Screenshots: desktop before/after any quick action.
- Error messages: if present.

Additional recommended:
- List of missing shortcuts.
- Whether issue occurs after each login.

## Routing Information
- Primary: L2 EUC Operations.
- Secondary: L2 Intune for policy/deployment checks.
- Secondary: M365 endpoint support if OneDrive KFM or redirection is suspected.
- Use runbook: Runbook_Missing_Desktop_Shortcuts.md

## Keywords
ServiceNow keywords: missing desktop shortcuts, windows desktop empty, profile desktop issue, onedrive kfm desktop, intune desktop policy, public desktop shortcut missing
