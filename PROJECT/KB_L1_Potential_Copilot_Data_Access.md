# KB L1: Potential Copilot Data Access

Document Owner: Service Desk Operations  
Version: 1.0  
Review Frequency: Monthly  
Last Updated: 2026-08-14  
Approval Required: Yes (Service Desk Manager, Security Duty Lead)  
Support Tower: Service Desk / Security

## Source Lineage
This article is a plain-language L1 re-expression of the source runbook: Runbook_Potential_Copilot_Data_Access.md.

## Symptoms
- User reports Copilot showed client matter or content they believe they should not access.
- User reports Copilot output appears to contain sensitive legal information unexpectedly.

## Impact
- Potential confidentiality and compliance incident.
- Potential legal privilege exposure risk.

## Initial Checks
- [ ] Confirm exact user statement and when event occurred.
- [ ] Capture screenshot evidence before session state changes.  
- [ ] Open or link security incident workflow immediately.

## Quick Resolution
1. Treat as potential security incident from first contact.
2. Ask user to stop further prompting on the same matter until advised.
3. Capture evidence:
- screenshot of Copilot output  
  [Screenshot Placeholder – Copilot output with timestamp]
- user identity and device identity
- time of event and prompt context (if available)
4. Notify Security Operations and Legal IT duty contacts using critical routing.
5. Do not provide entitlement opinions at L1; hand off for formal access validation.

## When to Escalate
Escalate immediately in all cases (no delay) when:
- Unauthorized Copilot data access is reported.
- Sensitive client/legal content is involved.
- Reporter requests legal/compliance confirmation.

## Information to Collect Before Escalation
Required:
- User details: full name, department, contact.
- Device details: device name and location.
- Time of issue: exact or best-known timestamp.
- Screenshots: Copilot output and visible context.
- Error messages: if any.

Additional recommended:
- Whether output was snippet, summary, or apparent full matter details.
- Whether user shared/copied/exported the output.

## Routing Information
- Primary: Security Operations (critical).
- Secondary: Legal IT and Compliance.
- Secondary: IAM and M365 Admin for entitlement/repository checks.
- Use runbook: Runbook_Potential_Copilot_Data_Access.md

## Keywords
ServiceNow keywords: copilot unauthorized access, legal confidentiality incident, potential data exposure, m365 permissions incident, sharepoint permissions copilot, teams permissions copilot
