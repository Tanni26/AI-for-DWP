# Prevention Note: Legal Copilot Permission Exposure Review

## Issue Summary
A Legal user reported that assistant-generated output appeared to include client-related information they believed they were not authorized to view, creating a potential confidentiality and trust risk.

## What Failed
A pre-go-live entitlement exposure control was missing for Legal data access in assistant-enabled workflows. The release process did not require role-based negative testing to prove restricted matters remained inaccessible to non-authorized roles before production use.

## Preventive Control
Control Name: Legal Copilot Permission Exposure Review (LCPER)  
Control Owner: Information Security Governance Lead  
Control Frequency: Before every production change affecting Legal data access pathways or assistant-enabled retrieval behavior  
Control Trigger: Any change to legal-data-connected applications, user role mappings, or assistant data access scope  
Control Objective: Prevent confidentiality exposure by proving effective access aligns with approved Legal role boundaries before go-live

## How the Control Works
- When it occurs: pre-go-live review window, completed and approved before final release authorization.
- Who performs it: security governance analyst, Legal IT data owner, and business data custodian.
- What evidence is reviewed: role-to-matter access matrix, effective access test outcomes, failed-access proof for restricted scenarios, and approved exception register.
- What approval is required: Security Governance Lead and Legal Data Owner dual approval.
- What happens if validation fails: immediate release stop for affected scope; remediation required; re-test and re-approval mandatory before go-live.

## Why This Would Have Prevented The Incident
The issue surfaced because entitlement boundaries were not formally challenged before release. LCPER requires explicit proof that restricted client matters cannot be surfaced to non-authorized roles, which would have detected the exposure risk before Monday operations.

## Success Criteria
- 100% of defined restricted-role negative tests pass before release approval.
- 0 open high-risk access exceptions at go-live.
- 100% of Legal data changes include signed access review evidence in change record.

## Required Process Change
- Update security change standard: Legal data-affecting releases must include LCPER evidence package.
- Update CAB rules: confidentiality-impacting changes require dual security and Legal data-owner sign-off.
- Update release checklist: mandatory restricted-access negative tests and exception register review.
- Update governance documentation: standard role-to-matter access matrix and evidence retention requirements.

## Implementation Effort
Medium-High

Justification: Requires cross-functional ownership, formal role test design, evidence retention discipline, and strict release-stop enforcement for confidentiality exceptions.

## Prevention Statement
The single most important control is the Legal Copilot Permission Exposure Review: a mandatory pre-go-live access review that proves restricted client matters cannot be surfaced to non-authorized roles. This control would have identified permission exposure risk before Monday morning and prevented potential confidentiality concern from reaching end users.