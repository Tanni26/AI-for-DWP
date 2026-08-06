# Personal AI Usage Charter for DWP Endpoint Engineering

## Purpose
I use public AI assistants to speed up routine desktop and endpoint work, but not to outsource technical judgment or expose protected information. AI can help me draft, structure, explain, and troubleshoot. I remain responsible for accuracy, security, and change control.

## Working Context
- Role: DWP engineer / service desk analyst focused on desktop and endpoint support.
- Scope: Windows 11, endpoint troubleshooting, Intune-managed devices, BitLocker, OneDrive, Teams, VPN, meeting room devices, printers, app deployment, and general end-user support.
- Style: Practical, concise, service-desk ready, and specific to desktop/endpoint work.

## Appropriate Use
I may use public AI assistants for low-risk support tasks where prompts can stay generic or sanitized.

- Drafting PowerShell, batch, detection, remediation, or diagnostic scripts from a plain-language description.
- Rewriting or simplifying existing scripts after removing sensitive names, paths, tenant details, and identifiers.
- Explaining Windows, Intune, Entra, OneDrive, Teams, VPN, BitLocker, printer, and general endpoint concepts.
- Creating triage notes, incident summaries, troubleshooting checklists, user comms drafts, or knowledge article outlines.
- Brainstorming likely causes for common desktop issues when the description is generalized and does not include protected data.
- Translating logs, commands, or error messages into clearer next steps after sensitive values are removed.
- Comparing troubleshooting approaches for Win11 upgrades, device performance, app deployment, sync issues, and meeting room problems using non-sensitive examples.

## Not Appropriate Use
I will not use public AI assistants for tasks that expose DWP data, create unmanaged operational risk, or bypass established controls.

- Pasting tickets, logs, screenshots, exports, emails, or chat transcripts that contain end-user PII, device identifiers, internal hostnames, tenant details, or business-sensitive content.
- Sharing passwords, MFA prompts, recovery keys, tokens, connection strings, private certificates, API keys, or any credential material.
- Uploading full production scripts, configuration baselines, security rules, architecture details, or internal documentation that is not clearly approved for public sharing.
- Asking AI to make final decisions on security exceptions, access control, incident severity, or production change approval.
- Running AI-generated commands directly in production, on user devices, or in management platforms without verification.
- Using AI outputs as evidence on their own when root cause, policy position, or service impact still needs technical validation.

## Data Handling Rule
For any public AI tool, I will treat all prompts as if they may leave DWP control. I will not enter end-user PII, credentials, secrets, recovery material, or uniquely identifying device and tenant data. If I need help with a real incident, I will generalize the scenario first: replace names with roles, remove usernames and email addresses, remove exact machine names and IPs, remove screenshots, and keep only the minimum technical detail needed to ask the question.

## Generate Then Verify Rule
I may use AI to generate a draft script, command sequence, remediation step, or system change plan, but I will verify before use.

- Read the output end to end and confirm I understand what every command does.
- Check assumptions, parameters, targeting logic, exit conditions, and rollback impact.
- Validate syntax and behavior in a safe test context first: local lab, test VM, pilot device, or non-production group.
- Compare the proposed action with DWP policy, platform guidance, and existing operational standards.
- Confirm expected outcome with logs, device state, or observable results before wider rollout.
- If I cannot explain or safely test the output, I will not run it.

## Preferred Output Pattern For Future Chats
When asked to produce endpoint triage content, use this structure unless told otherwise:

- Summary (one line)
- Impact (who/how many/business urgency)
- known facts
- Missing information to gather
- likely catagory
- First diagnostic step

## Response Constraints For Later Chats
- Do not invent error codes, registry keys, KB numbers, or internal technical facts.
- Mark uncertain items as to-verify.
- Keep outputs practical and suitable for service desk triage or endpoint operations.
- Prefer minimal, supportable actions over speculative fixes.

## Personal Standard
Use public AI for acceleration, not delegation. Keep prompts sanitized, keep changes testable, and keep final responsibility with the engineer.