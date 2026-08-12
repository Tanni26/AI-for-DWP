# Communications Pack: Autopilot Enrolment Failure (Legacy MDM Conflict)

Version: 1.0 | Date: 12/08/2026 | Status: Ready

## Audience 1: Affected End User (Initial Update)
Subject: Device setup issue identified - remediation in progress

Hello <UserName>,

We identified why your new device setup could not complete. The device has an older management registration that conflicts with the new Autopilot setup process.

What this means for you:
- Your account and licenses are valid.
- Network connectivity checks are healthy.
- We need to remove the old registration and restart setup.

What we need:
- Device access (remote or physical) for cleanup and re-run of setup.

Estimated next update: within 60 minutes.

Regards,
Service Desk

## Audience 2: Affected End User (Resolution Confirmed)
Subject: Device setup restored - please complete sign-in

Hello <UserName>,

The conflicting old management registration has been removed, and your device is now ready to complete Autopilot setup.

Please do the following:
1. Restart the device.
2. Sign in using your corporate credentials.
3. Keep the device online until setup completes.

If you see any error during setup, reply with a screenshot and the time shown.

Regards,
Service Desk

## Audience 3: IT Stakeholders / Duty Manager
Subject: Incident update - Autopilot enrolment conflict due to legacy MDM state

Summary:
- Incident type: Endpoint provisioning failure.
- Signature: 0x80180014 with existing legacy/manual MDM enrolment present.
- Device state: Azure AD joined, valid Intune/Autopilot licensing, network healthy.

Current status:
- Root cause confirmed.
- Remediation path defined: Intune/Entra stale object cleanup, endpoint legacy binding removal, Autopilot rerun.

Risk:
- Similar failures may recur in migration waves if legacy enrolment is not pre-cleared.

Preventive action:
- Introduce mandatory pre-flight gate for legacy enrolment and duplicate object checks before Autopilot assignment.

## Audience 4: Broad Service Notification (If Multiple Users Impacted)
Subject: Notice - Some Windows device setups may fail during Autopilot onboarding

We are investigating a known setup issue affecting a subset of devices with older management registrations. Symptoms include setup not completing during first sign-in.

Current findings:
- No tenant-wide network or licensing outage.
- Issue is linked to legacy management state on affected endpoints.

Action for users:
- If your setup fails, contact Service Desk and provide device name and error screenshot.

Next update: <Time>.
