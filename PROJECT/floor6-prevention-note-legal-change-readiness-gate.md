# Prevention Note: Legal Change Readiness Gate

Version: 1.0 | Date: 14/08/2026 | Status: Proposed for Immediate Adoption

## Prevention Control ID
PC-F6-LEGAL-CRG-01

## Name
Legal Monday Readiness Gate (LMRG)

## One Specific Process Change
No Friday production change to Legal endpoints may remain active for Monday business start unless it passes a mandatory, documented LMRG sign-off at 07:30 Monday.

This is a single hard control (go/no-go gate), not a recommendation.

## Why This Control
The three Floor 6 incidents show different symptom classes (login performance, potential Copilot confidentiality exposure, desktop experience drift) that can occur in the same change window but from different technical paths. A single readiness gate with role-based checks would have identified at least one failure signal before users started work Monday morning.

## Scope
- Applies to: Legal department endpoint/application/identity/policy changes.
- Applies to change types: app deployments, Intune policy changes, Windows migration waves, identity/permission changes, Copilot/connector scope changes.
- Trigger condition: any Friday change on Legal-managed devices or legal-data integrations.

## Mandatory Execution Window
- Initial check: Friday post-deployment smoke completion.
- Mandatory release gate: Monday 07:30 to 08:00 before Legal user login surge.
- Business opening for Legal is blocked if gate is not completed and signed.

## Required Test Set (All Must Pass)
1. Login Readiness Check
- Test population: minimum 5 Legal pilot users across role/device mix.
- Pass criterion: interactive login to usable desktop completes within defined threshold (for example, 2 minutes median; no individual test above approved maximum).
- Evidence required: timestamped login duration capture per test user.

2. Copilot Entitlement Negative Test
- Test population: at least 2 Legal roles with intentionally restricted matter access.
- Pass criterion: prompts for known restricted client matter do not return retrievable content beyond entitlement.
- Evidence required: test transcript/screenshots and matching access-control verification record.

3. Desktop State Integrity Check
- Test population: same login pilot devices.
- Pass criterion: approved standard shortcut baseline remains present after sign-in; no unexplained profile/desktop reset behavior.
- Evidence required: before/after shortcut inventory comparison.

## Go/No-Go Rule (Hard Stop)
If any one required test fails, the change is automatically set to No-Go for Monday production usage on Legal endpoints until one of these is completed:
- rollback to last known good state, or
- approved fix plus full re-run of LMRG with all tests passing.

## Required Sign-Off
All three approvers must sign before Monday go-live:
- IT Operations Lead
- Security/Compliance Representative
- Legal IT Service Owner

Missing any approver equals No-Go.

## Evidence Retention Requirement
Store LMRG evidence package in change record before 08:00 Monday:
- test user list and device IDs
- login timing captures
- Copilot negative-test evidence and permission validation
- shortcut baseline comparison output
- final Go/No-Go decision and approver names

## Escalation Path
- Security test failure: immediate escalation to Security Incident process.
- Login threshold failure: escalate to End User Compute and hold release.
- Desktop integrity failure: escalate to EUC profile team and hold release unless explicitly risk-accepted by Legal IT owner and Operations lead.

## Mapping to Current RCAs
- Login disruption coverage: [PROJECT/rca-floor6-login-failures-and-slow-logins-provisional.md](PROJECT/rca-floor6-login-failures-and-slow-logins-provisional.md)
- Copilot confidentiality concern coverage: [PROJECT/rca-floor6-copilot-potential-unauthorized-client-matter-exposure-provisional.md](PROJECT/rca-floor6-copilot-potential-unauthorized-client-matter-exposure-provisional.md)
- Desktop shortcut drift coverage: [PROJECT/rca-floor6-missing-desktop-shortcuts-provisional.md](PROJECT/rca-floor6-missing-desktop-shortcuts-provisional.md)

## Implementation Target
Adopt LMRG as mandatory control for the next Legal change wave and update the standard change template to include PC-F6-LEGAL-CRG-01 as a required gate field.
