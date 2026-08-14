# Prevention Note: User Workspace Certification Check

## Issue Summary
Some users reported missing desktop shortcuts after sign-in, slowing access to core work tools and reducing start-of-day productivity.

## What Failed
The rollout process lacked a user-workspace certification step confirming that critical desktop elements persisted after migration, packaging, and deployment changes. Production acceptance occurred without evidence that the expected workspace baseline was intact.

## Preventive Control
Control Name: User Workspace Certification Check (UWCC)  
Control Owner: Workplace Engineering Manager  
Control Frequency: Every release that changes desktop experience, profile behavior, or application shortcut packaging  
Control Trigger: Any migration wave, profile transition, or endpoint application package affecting user workspace layout  
Control Objective: Ensure users receive a complete and usable workspace at first sign-in by certifying required desktop items before release closure

## How the Control Works
- When it occurs: post-deployment on Friday and pre-business verification Monday at 07:30.
- Who performs it: workplace engineer with service desk representative and release coordinator.
- What evidence is reviewed: baseline shortcut checklist, pilot user desktop comparison, and persistence check after sign-out/sign-in.
- What approval is required: Workplace Engineering Manager and Release Coordinator sign-off.
- What happens if validation fails: release marked incomplete; packaging/profile correction required; re-certification must pass before acceptance.

## Why This Would Have Prevented The Incident
The incident reached users because workspace readiness was assumed, not certified. UWCC would have identified missing or non-persistent desktop items in pilot verification and forced correction before Monday users logged in.

## Success Criteria
- 100% of required desktop baseline items present for all pilot users.
- 100% persistence of certified desktop items after sign-out/sign-in retest.
- 0 unresolved workspace-critical exceptions at Monday pre-open sign-off.

## Required Process Change
- Update release standard: workspace-impacting changes require UWCC evidence before closure.
- Update CAB template: add workspace certification status and exception section.
- Update deployment documentation: include role-based desktop baseline definitions and ownership.
- Update service desk handover: attach certified baseline snapshot for first-line reference.

## Implementation Effort
Low-Medium

Justification: Process-focused change using existing teams and release checkpoints, with moderate effort for baseline definition and evidence capture standardization.

## Prevention Statement
The specific control to add is the User Workspace Certification Check, a mandatory baseline certification that verifies required desktop items are present and still present after re-login before Monday opening. This would have detected the shortcut gap during controlled acceptance and prevented user impact at start of business.