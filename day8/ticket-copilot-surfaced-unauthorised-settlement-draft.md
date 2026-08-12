# Ticket: Copilot Surfaced Unauthorised Settlement Draft — Partner

**Raised by:** Partner  
**Date:** 2026-08-12  
**Severity:** HIGH — potential data breach / oversharing incident  
**Status:** Open — escalate immediately

---

## User Report

> "Copilot surfaced and summarised a draft settlement from a matter I'm not assigned to. I didn't know I could even see that folder."

---

## Triage Analysis

**Root cause (probable):** Overly permissive SharePoint permissions — not a Copilot fault, but Copilot has made the exposure visible.

Copilot does not grant access to files. It surfaces content the user already has permission to access under their Microsoft 365 account. If Copilot returned a summary of a document from a matter this Partner is not assigned to, it means her account already had read access to that file or folder — she simply had not discovered it before.

This is a **data governance and permissions issue**, not a Copilot defect. However, Copilot has effectively revealed an oversharing problem that existed silently before Copilot was deployed. This is a known and documented risk of deploying Copilot against an environment with poorly governed SharePoint permissions.

**This ticket must be treated as a potential data breach event under the firm's information security policy.**

---

## Immediate Actions Required

1. **Do not close this ticket as a standard support request.** Escalate to the Information Security / Data Governance team and the relevant Matter Supervisor today.
2. Identify the specific document Copilot summarised — get the SharePoint URL and document name from the user.
3. Audit the permissions on that document/folder: who has access, how was access granted (direct, group, inherited)?
4. Determine whether the Partner should have had access (e.g., as part of a broad practice-group permission group) or whether this is a misconfiguration.
5. Review the matter folder's permissions across all users — if one person could see it unexpectedly, others may be able to as well.
6. Log the incident in the firm's incident register with timestamp, user, and document details.

---

## Investigation Steps

1. Obtain the document URL and folder path from the Partner.
2. In SharePoint Admin Center, run an access report on the file/folder.
3. Identify the mechanism of access: direct share, group membership, or broken inheritance from parent library.
4. Check whether the same folder is accessible to other Partners or staff not assigned to that matter.

---

## Resolution Path

- **Immediate:** Restrict permissions on the affected document/folder to matter-assigned staff only.
- **Short-term:** Conduct a permissions audit across all matter folders in SharePoint before Copilot access is broadened further.
- **Long-term:** Implement a SharePoint governance policy requiring matter folders to use unique permissions with access limited to assigned team members. Consider using SharePoint sensitivity labels or Microsoft Purview to enforce this.

---

## Key Message for Leadership

Copilot did not cause a breach — it revealed one. The access existed before Copilot was deployed; Copilot simply made it discoverable. The root issue is that SharePoint permissions were not correctly scoped to matter teams. This must be addressed as a priority before further Copilot rollout to legal staff.
