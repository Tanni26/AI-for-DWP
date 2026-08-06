# Triage Summary (DWP Service Desk)

## Context
- Charter file reference: personal-ai-usage-charter.md
- Charter content available in workspace: yes
- AI handling note: keep triage inputs sanitized, exclude end-user PII and credentials, and verify any generated script or system change before use.

## Ticket
T-1002

Raw ticket:
"Finance user cannot open a shared mailbox after migration"

### Summary (one line)
Finance user cannot open a shared mailbox following migration.

### Impact (who/how many/ business urgency)
- Who: Finance user (identity to-verify)
- How many: 1 user reported in current ticket text; wider impact to-verify
- Business urgency: to-verify (potentially elevated if mailbox is business-critical for Finance operations)

### known facts
- Ticket ID is T-1002.
- A Finance user cannot open a shared mailbox.
- Issue is reported as occurring after migration.

### Missing information to gather
- User details: name, team, location, contact.
- Shared mailbox name/address and expected access method (Outlook desktop, OWA, mobile).
- Exact error message text and when it appears.
- Migration details: mailbox type/state, completion time, and any known post-migration actions.
- Whether the user can access their primary mailbox normally.
- Whether other authorized users can open the same shared mailbox.
- Permission model in use (Full Access/Send As) and whether permissions were re-applied post-migration.
- Outlook profile status: cached mode, recent profile rebuild, and client version.
- Scope check: any similar reports from Finance or other teams after the same migration wave.

### likely catagory
Messaging and collaboration access issue (shared mailbox permissions/post-migration configuration)

### First diagnostic step
Verify shared mailbox access permissions and mailbox state post-migration, then test access via OWA to distinguish client-profile issues from backend permission/configuration issues.

---

## End-User Communication

Hi — we found that your access to the shared mailbox had not been carried across during the recent migration, which we have now fixed. You should be able to open it again straight away. If you are using Outlook on your desktop, please restart it once to pick up the change. All your emails are safe and nothing has been lost. Apologies for the disruption!

---

## Known Error Record

**Symptom:** Finance user cannot open a shared mailbox after mailbox migration — access denied or mailbox not visible in Outlook/OWA.

**Cause:** Shared mailbox Full Access permissions not re-applied following mailbox migration; permission assignments were not carried over by the migration process.

**Scope:** Users whose shared mailbox access was part of the affected migration wave. Wider scope of how many users are affected to-confirm.

**Workaround:** IT re-applies Full Access (and Send As if required) permission manually in Exchange/M365 admin; user must restart Outlook to reflect the change. Not user-fixable.

**Permanent fix:** Include shared mailbox permission validation as a mandatory step in the post-migration checklist; automate permission re-application and verification via migration runbook before closing migration tasks.

---

## Closure Note

**Ticket:** T-1002
**Status:** Resolved

**Root cause:** Full Access permission to the shared mailbox was not carried over during migration (to-confirm exact migration tool or step that dropped the permission assignment).

**Actions taken:**
- Verified shared mailbox permissions in Exchange/M365 admin — Full Access entry for affected user was absent.
- Re-applied Full Access permission to the shared mailbox for the affected Finance user.
- User restarted Outlook and confirmed shared mailbox is accessible.

**User confirmed resolution:** to-confirm (awaiting user closure confirmation).

**Prevention:** Add shared mailbox permission validation and test-access step to migration runbook; run scope check for other users in same migration wave who may have the same missing permission.
