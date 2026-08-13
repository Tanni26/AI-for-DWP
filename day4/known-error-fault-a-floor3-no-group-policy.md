Symptom: On affected Floor 3 Win11 machines, startup Group Policy processing fails with domain-controller connectivity and SYSVOL access errors. Users may see policy not applying during startup.

Cause: The Floor 3 DHCP scope assigned an old DNS server that had been decommissioned, so clients could not resolve FINBRIDGE-DC01.finbridge.local. This prevented secure channel and Group Policy access to SYSVOL.

Scope: Three of four Win11 machines in OU=Finance on Floor 3 were affected in the incident window. A same-OU comparison host with correct DNS assignment was unaffected.

Workaround: Manually set client DNS to 10.10.0.10 and renew network configuration, then re-run Group Policy processing. This bypasses the bad DHCP-delivered DNS until scope correction is complete.

Permanent fix: Update Floor 3 DHCP scope DNS option to 10.10.0.10 and remove decommissioned DNS references from the scope. Renew leases on affected clients so corrected DNS is applied.

How to spot it: Event pattern on affected host includes Netlogon 5719, GroupPolicy 1058 with SYSVOL gpt.ini path error code 0x3, GroupPolicy 1030 code 0x546, GroupPolicy 1129 no DC connectivity, DNS Client 1014 timeout for FINBRIDGE-DC01.finbridge.local, and DHCP 50036 showing old DNS assignment.