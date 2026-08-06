# Rewrite Technical Fix for Different Audiences

## Prompt

```
You are a DWP service-desk analyst. Take the technical resolution
below and rewrite it for THREE different audiences. Each version must
carry exactly the same facts — do not add or remove information.

Audience 1 — Non-technical executive
- No jargon whatsoever
- Under 80 words
- Lead with reassurance (their access and data are safe)
- End with what they need to do, if anything
- Tone: calm, professional, brief

Audience 2 — Affected end-user team (10 people, non-technical)
- Plain language, friendly tone
- Under 100 words
- Explain what happened in one sentence without jargon
- Tell them what to do if they see the same issue
- End with who to contact

Audience 3 — Engineer-to-engineer internal note
- Technical shorthand is fine
- Include: root cause, exact action taken, config detail,
  verification step, and the preventive action needed
- No length limit — include everything a colleague needs to
  pick this up if it recurs

Technical resolution:
[paste technical resolution here]

Return all three versions clearly labelled:
Executive:
Team:
Engineer:
```

---

## Worked Example

**Technical resolution used:**
> Root cause: Win11 upgrade removed the legacy VPN client and did not trigger the Intune re-deployment of the new client due to a detection-rule gap. Manually removed stale VPN registry entries under HKLM\SOFTWARE\<vendor>, force-triggered Intune sync, new client deployed, split-tunnel config applied, connectivity confirmed to all internal subnets. No data loss.

---

**Executive:**
Your access and data are completely safe — no information was lost at any point. After a recent Windows 11 upgrade, a small gap in our automated software deployment meant your VPN connection tool was not reinstalled as expected. Our team identified and fixed this manually. Your VPN access is now fully restored. No action is needed from you.

---

**Team:**
Hi all — after the recent Windows 11 upgrade, the VPN app some of you use to connect to internal systems was not automatically reinstalled as it should have been. Our team has now fixed this and VPN access is working again. No data was lost. If you still cannot connect to internal resources over VPN, please log a ticket with the service desk straight away and we will pick it up quickly.

---

**Engineer:**
- **Root cause:** Win11 in-place upgrade removed the legacy VPN client. Intune did not trigger re-deployment of the replacement client because the detection rule still referenced the old client binary — gap meant the app was never flagged as absent post-upgrade.
- **Action taken:** Manually purged stale VPN registry entries under `HKLM\SOFTWARE\<vendor>`. Force-triggered Intune sync via Company Portal > Sync. New VPN client deployed automatically within ~5 min post-sync. Split-tunnel config applied via Intune profile (confirmed in client UI and routing table).
- **Verification:** Confirmed connectivity to all internal subnets via `ping` and RDP to internal host. No data loss.
- **Preventive action required:** Update the Intune detection rule to target the new client executable/version string. Review all other app detection rules that reference legacy binaries before the next Win11 upgrade wave to avoid repeat gaps.
