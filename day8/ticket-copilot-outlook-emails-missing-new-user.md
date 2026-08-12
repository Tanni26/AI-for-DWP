# Ticket: Copilot in Outlook Cannot Find Case Emails — New User

**Raised by:** New Associate (started this week)  
**Date:** 2026-08-12  
**Severity:** Low — single user, expected behaviour for new accounts  
**Status:** Open

---

## User Report

> "Copilot in Outlook can't find any of the case emails I need context on."

---

## Triage Analysis

**Root cause (probable):** Microsoft 365 indexing lag for new accounts.

Copilot's ability to search and reference emails relies on the Microsoft Search index. For brand-new accounts, the mailbox is not fully indexed immediately — this typically takes **24–72 hours** after the account is provisioned and first used. Until indexing completes, Copilot cannot retrieve or reference email content even if the emails are visibly present in Outlook.

Additional factors to check:
- Were case emails forwarded or shared to her account, or is she a direct recipient? Forwarded emails may arrive but index more slowly.
- Was the account fully licensed with M365 Copilot from day one, or was the licence applied after the account was created? Licence application timing can affect indexing start.
- Are the emails in her primary mailbox or a shared/delegated mailbox? Copilot has limited support for shared mailbox content.

---

## Investigation Steps

1. Confirm account creation date and when the M365 Copilot licence was assigned.
2. Ask the user to try again after 48–72 hours from account creation.
3. Confirm whether the emails she needs are in her own mailbox or a shared mailbox.
4. If emails are in a shared mailbox, advise that Copilot's shared mailbox support is limited — she may need to open the shared mailbox directly in Outlook.

---

## Resolution Path

- **Indexing lag:** Monitor and advise user to retry after 72 hours. No action required unless the issue persists beyond that window.
- **Shared mailbox emails:** Escalate to M365 admin to review Copilot shared mailbox support settings, or advise user to work directly in Outlook rather than via Copilot for shared mailbox content.
- **Licence timing issue:** Raise with M365 admin team to confirm licence was applied at provisioning for future new starters.

---

## Notes

This is a common ticket pattern for new starters. Consider adding a note to the onboarding checklist: *"Copilot email search may not be available for the first 48–72 hours after your account is created — this is normal."*
