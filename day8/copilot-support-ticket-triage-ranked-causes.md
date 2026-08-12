# Copilot Support Ticket Triage - Ranked Causes (Finance Context)

## Method
- Causes are ranked using only the allowed categories.
- Ranking defaults to non-Copilot causes first.
- Genuine Copilot fault is kept as last resort unless evidence rules out all other causes.

## Triage Results

| ID | Ticket Summary | Likely Cause (Ranked, Most Probable First) | Fastest Check (Single First Check) | Is This Actually a Copilot Bug? |
|---|---|---|---|---|
| 1 | Finance lead cannot summarize Q3 board pack in SharePoint, can see file directly | 1) sensitivity label restriction; 2) permissions/access boundary; 3) data indexing lag; 4) license/client prerequisite issue; 5) guest/external sharing limitation; 6) genuine Copilot fault | Check the board pack file/library sensitivity label and encryption settings first (especially restrictions that block AI processing or content extraction). | No. Most likely a protection or access-control behavior on highly sensitive board content, not a product defect. |
| 2 | New hire started yesterday; Copilot in Outlook knows nothing about recent emails | 1) data indexing lag; 2) license/client prerequisite issue; 3) permissions/access boundary; 4) sensitivity label restriction; 5) guest/external sharing limitation; 6) genuine Copilot fault | Check whether the user was onboarded very recently and whether mailbox/search indexing is still catching up. | No. Timeline strongly fits indexing delay for a brand-new mailbox profile. |
| 3 | HR manager in Word cannot pull from sensitive salary spreadsheet; gets "I don't have access" | 1) permissions/access boundary; 2) sensitivity label restriction; 3) data indexing lag; 4) license/client prerequisite issue; 5) guest/external sharing limitation; 6) genuine Copilot fault | Try opening the spreadsheet directly as the same user account in Microsoft 365. | No. The explicit access-denied response indicates an access or protection boundary is working as designed. |
| 4 | Sales rep in Teams cannot find client contract shared via guest link from another org | 1) guest/external sharing limitation; 2) permissions/access boundary; 3) data indexing lag; 4) license/client prerequisite issue; 5) sensitivity label restriction; 6) genuine Copilot fault | Verify the contract is external-tenant content shared via guest link rather than stored in the user’s own tenant workspace. | No. Cross-tenant guest sharing scope is the most probable explanation. |
| 5 | IT admin reports Copilot stopped for whole Finance team this morning; worked yesterday | 1) license/client prerequisite issue; 2) permissions/access boundary; 3) data indexing lag; 4) sensitivity label restriction; 5) guest/external sharing limitation; 6) genuine Copilot fault | Check one affected user in admin center to confirm Copilot add-on license and service plan are still assigned/enabled. | Unclear. A broad, sudden outage can be service-related, but tenant licensing/config drift is still more likely until ruled out. |
| 6 | Manager says Copilot summarized a file they forgot they had access to | 1) permissions/access boundary; 2) data indexing lag; 3) sensitivity label restriction; 4) license/client prerequisite issue; 5) guest/external sharing limitation; 6) genuine Copilot fault | Check effective permissions on the file/folder for that manager account. | No. This is expected if the user has existing read access; it is a permissions governance issue, not a Copilot defect. |
| 7 | Analyst gets generic answers; Copilot seems not to use internal SharePoint content at all | 1) license/client prerequisite issue; 2) permissions/access boundary; 3) data indexing lag; 4) sensitivity label restriction; 5) guest/external sharing limitation; 6) genuine Copilot fault | Confirm the analyst has an active Copilot add-on license and is using a supported, signed-in Microsoft 365 client. | Unclear. Most often a prerequisite or access-scope issue, but needs validation before calling bug. |
| 8 | Executive assistant in Outlook cannot see shared mailbox calendar managed for director | 1) permissions/access boundary; 2) license/client prerequisite issue; 3) sensitivity label restriction; 4) data indexing lag; 5) guest/external sharing limitation; 6) genuine Copilot fault | Check the assistant’s effective delegated/shared mailbox calendar permissions in Outlook/Exchange first. | No. Most likely delegated access scope limitation or permission model behavior, not a Copilot defect. |

## Quick Triage Pattern For Similar Tickets
1. Confirm user can directly open target content with the same account.
2. Confirm Copilot license + supported client prerequisites.
3. Check whether content is external/guest-shared or newly created (indexing delay risk).
4. Check sensitivity label restrictions.
5. Escalate as potential product fault only after the above are ruled out.
