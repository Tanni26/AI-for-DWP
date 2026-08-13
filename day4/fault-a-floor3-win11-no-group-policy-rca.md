# Root Cause Analysis (RCA) - FAULT-A

## Incident Title
Three Win11 machines on Floor 3 not processing Group Policy at startup

## Date / Window
2024-03-15, startup window 07:40-07:55

## Impact
- Affected: 3 of 4 machines in OU=Finance on Floor 3.
- User impact: startup Group Policy processing failed on affected machines.
- Unaffected control: DESKTOP-FB029 in same OU processed Group Policy successfully.

## Technical Evidence
- FB031 07:40:08 Netlogon 5719: no secure channel to FINBRIDGE, no domain controller available.
- FB031 07:40:09 and 07:40:11 GroupPolicy 1058: unable to access SYSVOL gpt.ini path, code 0x3.
- FB031 07:40:10 GroupPolicy 1030: cannot query GPO list, code 0x546.
- FB031 07:40:12 and 07:44:01 GroupPolicy 1129: no network connectivity to DC.
- FB031 07:41:05 DNS Client 1014: FINBRIDGE-DC01.finbridge.local resolution timed out; configured DNS did not respond.
- FB031 07:42:18 DHCP 50036: DNS assigned 10.10.3.250 (old DNS, decommissioned at 02:00 migration wave).
- FB029 07:40:05 DHCP 50036: DNS assigned 10.10.0.10 (correct new DNS).
- FB029 07:40:11 GroupPolicy 1500: policy processed successfully.
- DHCP comparison confirms affected segment still receiving decommissioned DNS entries.

## Root Cause
- Floor 3 DHCP scope was not updated after migration and continued assigning an old, decommissioned DNS server.
- Clients receiving that DNS entry could not resolve domain controller FQDN and therefore failed Group Policy processing at startup.

## 5 Whys
1. Why did Group Policy fail on affected machines?
- They could not contact a domain controller and SYSVOL during startup.

2. Why could they not contact a domain controller?
- Domain controller name resolution failed.

3. Why did name resolution fail?
- Configured DNS server on affected clients did not respond to DC FQDN queries.

4. Why were affected clients using a non-working DNS server?
- DHCP lease delivered old DNS 10.10.3.250, which had been decommissioned.

5. Why did DHCP deliver old DNS after migration?
- The Floor 3 DHCP scope was not updated during the migration wave.

## Actions Taken / Required for Resolution
- Correct Floor 3 DHCP scope DNS option to 10.10.0.10.
- Renew leases on affected endpoints so new DNS settings apply.
- Re-run startup policy cycle and verify successful Group Policy processing.

## Verification Criteria
- Lease on affected endpoints shows DNS 10.10.0.10.
- FINBRIDGE-DC01.finbridge.local resolves successfully.
- Group Policy startup processing succeeds (success pattern equivalent to Event 1500 seen on FB029).

## Preventive Actions
1. Add migration change-control checkpoint: verify DHCP scope DNS options post-cutover before user start time.
2. Add automated audit to detect DHCP scopes still pointing to decommissioned DNS IPs.
3. Add pre-close validation requiring one affected-host lease capture and one successful Group Policy processing event.
4. Maintain exception register for manually pre-configured hosts to avoid false confidence in mixed outcomes.