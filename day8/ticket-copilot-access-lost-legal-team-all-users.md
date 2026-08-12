# Ticket: All Legal Team Lost Copilot Access — 40 Users

**Raised by:** Legal Ops Manager  
**Date:** 2026-08-12  
**Severity:** HIGH — full team outage, business impact  
**Status:** Open — priority response required

---

## User Report

> "All 40 people on the Legal team suddenly lost Copilot access this morning, worked fine all last week."

---

## Triage Analysis

**Root cause (candidates — ranked by likelihood):**

1. **Licence change or reassignment** — M365 Copilot licences were removed, reassigned, or moved to a different licence group affecting the Legal team. Most likely cause of a sudden all-or-nothing outage.
2. **Security group or Entra ID group change** — If Copilot licences are assigned via a security group and that group was modified (renamed, members removed, group deleted), all members would lose access simultaneously.
3. **Conditional Access or tenant policy change** — A policy change applied to the Legal team's Entra group could block Copilot access without removing the licence.
4. **Copilot service or tenant-level outage** — Less likely given this appears scoped to one team, but worth ruling out via the Microsoft 365 Service Health Dashboard.

The fact that it was working "all last week" and stopped "this morning" strongly indicates a configuration or administrative change made in the last 24 hours, not a gradual or user-driven issue.

---

## Immediate Investigation Steps

1. Check the **Microsoft 365 Service Health Dashboard** (admin.microsoft.com > Health > Service Health) — confirm no active Copilot incidents.
2. Check the **M365 Admin Centre > Billing > Licences** — confirm Copilot licences assigned to Legal team accounts are still active and not expired/unassigned.
3. Check **Entra ID (Azure AD) > Groups** — identify the group used to assign Copilot licences to Legal staff. Check group membership and recent change history.
4. Check **Entra ID > Audit Logs** — filter for last 24 hours, look for licence assignments, group membership changes, or policy changes affecting the Legal team.
5. Check **Conditional Access policies** — confirm no new policy was applied or modified that targets the Legal group.

---

## Resolution Path

- **Licence removed:** Re-assign M365 Copilot licences to affected users, either individually or via the group. Allow up to 30 minutes for propagation.
- **Group membership change:** Restore correct group membership. Licence access should restore automatically once group sync completes.
- **Conditional Access policy:** Identify the new policy and assess whether it is intentional. If unintentional, revert. If intentional, engage Legal Ops Manager to understand the business impact and escalate to whoever approved the policy.

---

## Communication

Acknowledge to the Legal Ops Manager within the hour. This is a full-team productivity loss. Provide a status update every 2 hours until resolved.

---

## Post-Incident Action

Once resolved, identify who made the change, when, and why — and confirm whether a change request was raised. If not, raise with IT Change Management. Add a monitoring alert so that bulk licence removals affecting more than 5 users trigger an automatic notification to the IT team.
