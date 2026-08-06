# Triage Summary (DWP Service Desk)

## Context
- Charter file reference: personal-ai-usage-charter.md
- Charter content available in workspace: yes
- AI handling note: keep triage inputs sanitized, exclude end-user PII and credentials, and verify any generated script or system change before use.

## Issue 2
Raw issue:
"cant get on the vdi thing today keeps saying cannot connect. worked friday. im at home on wifi"

### Summary (one line)
User cannot connect to VDI today from home Wi-Fi, despite it working on Friday.

### Impact (who/how many/ business urgency)
- Who: Single end user (identity to confirm)
- How many: 1 user/session reported affected
- Business urgency: to confirm (depends on role, task criticality, and inability to access required systems)

### known facts
- User reports inability to connect to VDI "today".
- Connection message shown is "cannot connect" (exact wording to confirm).
- VDI access worked on Friday.
- User is working from home on Wi-Fi.

### Missing information to gather
- User details: name, team, contact details, location.
- Exact VDI platform/service in use and connection method.
- Full error text/code and screenshot of the message.
- Whether issue occurs on first login, during MFA, or after session launch.
- Home network status: internet stability, speed, packet loss, and whether other services work.
- VPN status (required/not required), client version, and sign-in state.
- Device details: corporate/personal, OS version, recent updates.
- Whether restart of device/router has been attempted and outcome.
- Whether colleagues can access VDI at the same time (scope check).

### likely catagory
Remote access / VDI connectivity incident

### Suggest first diagnostic step
Validate basic path to service by confirming internet access and testing VDI login from the same account in a browser (or alternate approved client), while capturing the exact error message to separate local network/client issues from VDI service-side problems.
