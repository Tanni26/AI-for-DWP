# Ticket: Copilot Cannot Access NDA in SharePoint

**Raised by:** Paralegal  
**Date:** 2026-08-12  
**Severity:** Low — single user, no data loss  
**Status:** Open

---

## User Report

> "Asked Copilot to summarise a client NDA in SharePoint, got 'I don't have access to that content.' The file is in a folder she's never actually opened before, just heard about it in a meeting."

---

## Triage Analysis

**Root cause (probable):** SharePoint permissions — not a Copilot fault.

Copilot can only surface and summarise content the signed-in user already has permission to access. It does not grant access to files; it inherits whatever permissions the user has in SharePoint.

The user has never opened the folder, which strongly suggests she does not have direct access to it. Hearing about a file in a meeting does not confer SharePoint permissions. The error message "I don't have access to that content" is Copilot correctly reporting a permissions boundary, not a bug.

**Secondary consideration:** Even if the folder is in a library she technically has read access to at a top level, SharePoint uses item-level and folder-level permissions that can restrict access below the library root.

---

## Investigation Steps

1. Ask the user for the full SharePoint URL or folder path of the NDA.
2. Check the folder's sharing settings in SharePoint Admin Center — confirm whether her account has any direct or group-based access.
3. Check whether the file has unique permissions (broken inheritance) that exclude her.
4. Confirm whether she *should* have access as part of her role, or whether this is a case where access was never provisioned.

---

## Resolution Path

- **If she should have access:** Request a SharePoint permission grant from the document owner or site admin. Once access is granted, Copilot will be able to read and summarise the file at her next attempt.
- **If she should not have access:** Close as expected behaviour. Advise user that Copilot respects all SharePoint permissions and she should request access through the document owner.

---

## Notes for Wider Review

Flag to the data governance team: if this NDA was discussed in a meeting and shared verbally, confirm that the SharePoint folder has appropriate permissions and is not inadvertently over-shared elsewhere.
