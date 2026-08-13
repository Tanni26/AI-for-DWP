# FAULT-A Analysis and Solution Options

## Incident Scope Facts
- Three Win11 machines on Floor 3 in OU=Finance were affected (3 of 4).
- Symptom: Group Policy failed during startup due to no domain controller connectivity.
- Affected sample host: DESKTOP-FB031.
- Unaffected comparison host: DESKTOP-FB029 (same OU).

## Key Evidence
- 07:40:08 Netlogon 5719 on FB031: secure channel to FINBRIDGE failed, no DC available, DNS query for FINBRIDGE-DC01.finbridge.local had no response.
- 07:40:09 and 07:40:11 GroupPolicy 1058 on FB031: cannot access \\FINBRIDGE-DC01\sysvol\finbridge.local\Policies\{3A1B2C4D-E5F6-7890-ABCD-EF1234567890}\gpt.ini, code 0x3.
- 07:40:10 GroupPolicy 1030 on FB031: cannot query GPO list, code 0x546.
- 07:40:12 and 07:44:01 GroupPolicy 1129 on FB031: no network connectivity to a DC.
- 07:41:05 DNS Client 1014 on FB031: resolution for FINBRIDGE-DC01.finbridge.local timed out, configured DNS servers did not respond.
- 07:42:18 DHCP 50036 on FB031: DNS assigned as 10.10.3.250 (old, decommissioned at 02:00).
- FB029 comparison at 07:40:05: DHCP assigned DNS 10.10.0.10 (correct new DNS), then GroupPolicy 1500 success at 07:40:11.
- DHCP server comparison: affected group received decommissioned DNS entries; unaffected machine had correct central DNS.

## Most Likely Cause
- DHCP scope for Floor 3 subnet still referenced the old DNS server, so affected clients received a non-working DNS resolver and could not resolve the domain controller FQDN during startup policy processing.

## Why This Fits
- The failure pattern is DNS/DC reachability, not OU policy content corruption.
- Event order supports it: DNS timeout and no DC response occur before repeated Group Policy failures.
- Same-OU comparison isolates variable to DNS assignment, not OU policy itself.

## Immediate Service-Restore Workaround
1. Manually set affected machines DNS to 10.10.0.10.
2. Run an address/lease refresh and force Group Policy refresh after DNS correction.
3. Reboot or re-run policy processing to confirm domain controller and SYSVOL access.

## Permanent Solution
1. Update Floor 3 DHCP scope option for DNS servers from decommissioned value(s) to 10.10.0.10.
2. Validate scope configuration on all relevant ranges in the migration wave.
3. Renew DHCP leases on affected clients so corrected DNS is applied.
4. Confirm startup Group Policy success events on remediated machines.

## Validation Checks
- Client lease shows DNS server 10.10.0.10.
- DNS resolution of FINBRIDGE-DC01.finbridge.local succeeds.
- Group Policy processing completes successfully (success event pattern like FB029 Event 1500).

## Risk if Not Fixed
- Recurrent startup policy failures on clients still receiving deprecated DNS values from DHCP.
- Continued inability to contact DC and SYSVOL during policy processing windows.