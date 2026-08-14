# Floor 6 Login/Performance Remediation Summary

## Most Likely Cause
The case study supports Intune compliance / policy-evaluation delay on the newly migrated Windows 11 Floor 6 devices more strongly than the Friday document-management deployment. The Friday app remains a plausible hypothesis, but it is not confirmed by the evidence in the case materials.

## Immediate Technical Fix
Fastest safe remediation: pause or remove the specific Floor 6 Legal-Win11 Intune compliance assignment, or remove the conflicting GPO if sign-in logs show policy processing is the blocker. Test on one affected device first, then expand only if login time returns to baseline.

If later evidence confirms the Friday document-management deployment as the cause, the exact rollback should be:
- Remove the Required assignment for the document-management app from the Legal-Win11 / Floor 6 group in Intune.
- Exclude Floor 6 from the deployment ring.
- Add an Uninstall assignment for the affected version on a small pilot subset first.
- Roll back from v2.1 to v2.0 if that is the known good version in the case study.

## Evidence Supporting the Fix
- 45 Windows 11 Floor 6 devices are Intune managed.
- The issue began Monday morning after a Friday change window.
- The troubleshooting matrix ranks Intune compliance policy blocking above Group Policy and far above the Friday app deployment.
- The diagnostic playbook says the first checks should be Intune compliance dashboard and Azure AD sign-in logs.
- There is no direct evidence that the Friday deployment is running during authentication, which is required before recommending app rollback.

## Validation Steps After Remediation
1. Test one affected Floor 6 device and compare login time to baseline.
2. Confirm Azure AD sign-in logs no longer show compliance or Conditional Access blocks.
3. Confirm the device is no longer stuck in evaluating or non-compliant state in Intune.
4. Check Event Viewer and gpresult for reduced login-time policy processing.
5. If the app is rolled back, confirm it is not launching during sign-in and that CPU and disk activity normalize.

## Floor 6 User Message
We’ve identified a sign-in and performance issue affecting some Floor 6 devices and are applying the safest fix. If you’re impacted, please keep using the loaner or alternate access path and report exactly where the sign-in stalls. We’ll update you as soon as we’ve confirmed the issue is stable.
