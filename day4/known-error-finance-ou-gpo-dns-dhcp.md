# Known Error Record: Finance OU Group Policy Failure

Symptom: Users on affected Finance endpoints experienced startup or logon policy processing failures, including inability to apply Group Policy settings. The incident presented as repeated domain connectivity and policy processing errors during startup.

Cause: The verified root cause was stale DHCP Scope Option 006 DNS configuration on Floor 3 after migration. Decommissioned DNS server IPs were distributed, causing domain controller name-resolution failure and downstream Group Policy failure.

Scope: 3 of 4 endpoints in OU=Finance were affected. One comparison endpoint in the same OU was unaffected because it had been manually preconfigured to the correct DNS (10.10.0.10) before migration.

Workaround: To restore service immediately, set affected endpoint DNS to the current production DNS (10.10.0.10), flush DNS cache, validate domain controller discovery, and force Group Policy update. This was used as a validation pilot before the permanent DHCP correction.

Permanent fix: DHCP Floor 3 Scope Option 006 was corrected to current DNS (10.10.0.10) and decommissioned DNS entries were removed. Affected clients then renewed DHCP leases, refreshed DNS state, and re-ran Group Policy processing, with service verified restored at 09:09 AM.

How to spot it: Look for correlated events Netlogon 5719, DNS Client 1014, GroupPolicy 1058, 1030, and 1129 on affected endpoints. Typical messages include no domain controller available, DNS query/timeout for FINBRIDGE-DC01.finbridge.local, and inability to access \\FINBRIDGE-DC01\\sysvol\\...\\gpt.ini; compare against DHCP Client 50036 showing old DNS assignment and control hosts showing GroupPolicy 1500 success.
