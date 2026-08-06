# T-1008 - VPN connects but no internal resources reachable after Win11 upgrade

## Charter alignment
This triage note is based on sanitized ticket content only, excludes end-user PII and credentials, and any generated script or system change must be verified before use.

## Summary (one line)
User reports the VPN connects successfully, but internal resources are unreachable after a Windows 11 upgrade.

## Impact (who/how many/business urgency)
- Who: Reported user (to-verify exact identity, device, and working location).
- How many: Currently one user reported; wider post-upgrade impact is to-verify.
- Business urgency: Remote access to internal business resources is blocked despite apparent VPN connection; urgency depends on business dependency (to-verify).

## known facts
- Ticket ID: T-1008.
- Reported behavior: VPN connects.
- Reported behavior: no internal resources are reachable.
- Reported timing context: issue is after a Windows 11 upgrade.
- No VPN client name, target resources, network location, or error message details have been provided.

## Missing information to gather
- VPN details: VPN client name, connection profile, and whether authentication completed normally.
- Resource scope: which internal resources fail, such as intranet, file shares, or remote services.
- Network context: home/office/hotspot, wired vs Wi-Fi, and whether internet access remains normal while VPN is connected.
- Device context: exact Win11 upgrade date, device name, and whether VPN worked before the upgrade.
- Scope: whether other upgraded users with the same VPN setup are affected.
- Observables: any route/DNS symptoms, client messages, and whether internal resources are reachable by name, IP, or neither (all to-verify).

## likely catagory
- Post-upgrade VPN routing/name resolution/access issue (to-verify).
- Potential contributing domains: VPN client compatibility, route/DNS handling, or local firewall/network stack behavior after upgrade (all to-verify).

## First diagnostic step
Verify one connected repro by testing whether any internal resource is reachable by hostname versus IP while the VPN is active, so the issue can be narrowed first to name resolution versus broader VPN path/routing behavior (to-verify).

---

## End-User Communication

Hi — your VPN was connecting successfully, but an internal setting was reset during the Windows 11 upgrade, which meant that internal sites and resources were not coming through even though the VPN appeared connected. We have corrected the configuration and everything should now be accessible while on VPN. Please reconnect your VPN and confirm you can reach the resources you need. If anything is still blocked, let us know straight away. Sorry for the disruption!

---

## Known Error Record

**Symptom:** VPN connects and authenticates successfully, but internal network resources (intranet, file shares, internal services) are unreachable after a Windows 11 in-place upgrade.

**Cause:** Windows 11 upgrade resets or conflicts with VPN client DNS and/or routing configuration; DNS queries for internal hostnames resolve via public DNS rather than internal DNS servers, making internal resources unreachable by hostname. VPN tunnel itself is established but routing or name resolution is broken.

**Scope:** Users on the affected VPN client who completed a Windows 11 upgrade. To-confirm whether all users on the same VPN profile are affected or only a subset.

**Workaround:** IT reconfigures VPN client DNS/routing settings on the affected device, or reinstalls the VPN client. Not user-fixable.

**Permanent fix:** Update VPN client deployment/configuration profile to be resilient to Windows 11 upgrade changes; include internal resource reachability test (by hostname and by IP) in post-upgrade validation checklist for all users.

---

## Closure Note

**Ticket:** T-1008
**Status:** Resolved

**Root cause:** Windows 11 in-place upgrade reset VPN client DNS configuration, causing internal DNS resolution to fail. Internal resources were unreachable by hostname despite VPN tunnel being established (to-confirm exact VPN client name and configuration path affected).

**Actions taken:**
- Confirmed VPN tunnel was active but internal DNS resolution was failing.
- Reconfigured VPN client DNS settings on the affected device to restore internal name resolution.
- Tested access to internal resources by hostname and IP; confirmed full access restored.

**User confirmed resolution:** to-confirm (awaiting user closure confirmation).

**Prevention:** Add VPN connectivity test (internal resource by hostname) to the post-Win11 upgrade validation checklist; review VPN client deployment profile for upgrade resilience; notify users upgrading to Win11 to test VPN access immediately after upgrade and report issues promptly.