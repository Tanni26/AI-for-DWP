# End-User Communications: Finance OU Policy Incident

## Audience 1 - Non-technical executive
Your access is restored and your data remained safe throughout. This morning, 3 of 4 Finance computers had sign-in settings fail after migration because they were given an outdated network lookup address; 1 pre-configured computer was unaffected. We corrected the central automatic network settings, removed the old address, refreshed the affected computers, and confirmed recovery at 09:09 AM with successful login and no further issues. No action is required from you.

## Audience 2 - Affected end-user team (10 people, non-technical)
Hi team, this is now fixed and your access is working. After this morning’s migration, 3 of 4 Finance computers briefly could not load sign-in settings because they were automatically given an old network address, while 1 pre-set computer kept working. We corrected the central network assignment, removed the old address, refreshed the affected computers, and confirmed full recovery at 09:09 AM with a successful user login and no further issues. If you see the same symptom again, restart once and contact the Service Desk immediately.

## Audience 3 - Engineer-to-engineer internal note
Summary:
Incident affected 3 of 4 endpoints in OU Finance. Symptoms were GP processing failure and DC discovery failure during startup. One control endpoint was unaffected because it had been manually preconfigured to the correct DNS before migration.

Root cause:
Stale DHCP scope DNS configuration after migration distributed decommissioned DNS values to affected clients, breaking DC name resolution and causing downstream Netlogon and Group Policy failures.

Supporting evidence:
1. Netlogon 5719: secure channel setup failed; no DC available.
2. DNS Client 1014: FINBRIDGE-DC01 name resolution timed out; configured DNS not responding.
3. GroupPolicy 1058 and 1030: SYSVOL and GPO enumeration failures.
4. GroupPolicy 1129: explicit no-DC-connectivity processing failure.
5. DHCP Client 50036 on affected host: DNS assigned old value.
6. Control host got correct DNS and logged GP success 1500.

Exact action taken:
1. Updated DHCP Floor 3 scope Option 006.
2. Removed decommissioned DNS entries and set current DNS to 10.10.0.10.
3. Renewed client DHCP leases and refreshed DNS cache on affected endpoints.
4. Re-ran policy processing.

Configuration detail:
Affected leases were receiving old DNS values (including decommissioned Floor 3 DNS references), while control host used 10.10.0.10. Final target state is DHCP scope DNS pointing to current production DNS only.

Verification and closure:
Service restored and verified at 09:09 AM. User login to host succeeded and no further issues were reported.

Preventive action required:
1. Enforce pre and post migration validation of DHCP Option 006 for all impacted scopes.
2. Block DNS decommission sign-off until DHCP scopes and reservations are verified clean.
3. Add monitoring for correlated spikes in 5719, 1014, and 1129.
4. Add automated audit for retired DNS IPs in DHCP scope and reservation settings.
