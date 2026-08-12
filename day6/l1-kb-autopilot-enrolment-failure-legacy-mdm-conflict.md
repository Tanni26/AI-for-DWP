# L1 KB: Autopilot Enrolment Fails (Legacy MDM Conflict)

Version: 1.0 | Date: 12/08/2026 | Status: Active

Use this article when a Windows Autopilot setup fails and evidence suggests an existing legacy/manual MDM enrolment.

## Scope
- In scope: Single-device Autopilot setup failure with 0x80180014 and previous MDM enrolment.
- Out of scope: No internet, tenant outage, missing licenses, device hardware failure.

## User-Reported Pattern
- "Setup failed during company device enrolment."
- Device cannot complete first-time corporate setup.

## L1 Triage Checklist
1. Capture screenshot/photo of enrolment error on device.
2. Confirm device name and user UPN.
3. Confirm whether device was previously company-managed.
4. Run basic network checks (internet reachable, no captive portal).
5. Confirm licenses assigned (Intune and Autopilot) via standard admin lookup.

## Required Evidence to Capture in Ticket
- Device name and serial number
- Username/UPN
- Error code and error text
- Date/time of failure
- Whether device had prior corporate ownership or rebuild history

## Decision Point
Escalate to L2/L3 immediately when all are true:
- Error code is 0x80180014.
- Error text indicates device is already enrolled.
- Device appears to have prior management history.

## L1 Safe Actions
1. Inform user issue is identified and under targeted remediation.
2. Arrange device access window (remote or physical) for engineering cleanup.
3. Do not perform registry/object deletion at L1.

## What L1 Must Not Do
- Do not factory reset repeatedly without L2/L3 direction.
- Do not remove tenant objects without approval.
- Do not change enrolment restrictions or MDM scope.

## Escalation Target
- L2/L3 KB: day6/l2-l3-kb-autopilot-enrolment-failure-legacy-mdm-conflict.md

## Closure Note for L1 Ticket
Use: "Escalated with suspected legacy MDM conflict (0x80180014). Required evidence captured and device access coordinated."
