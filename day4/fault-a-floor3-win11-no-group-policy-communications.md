# FAULT-A End-User Communications

## Audience 1 - Non-technical Executive
Access and data remain safe. This issue affected three of four Floor 3 Windows 11 machines because they were given an outdated network name-service setting during startup, which prevented policy loading. One comparable machine worked because it already had the correct setting. IT has identified the source in network address assignment and is correcting it to the current standard. No broad outage was observed. No action is needed unless your machine still shows startup sign-in policy errors.

## Audience 2 - Affected End-user Team (non-technical)
Hi team, three Floor 3 Windows 11 machines could not load startup work settings because they received an old network lookup setting, while one machine with the new setting worked normally. IT has identified and is correcting the network assignment so affected machines receive the right setting. If you see policy or domain sign-in errors after restart, contact Helpdesk and mention FAULT-A Floor 3 Group Policy issue.

## Audience 3 - Engineer-to-engineer Internal Note
Scope and symptom:
- 3/4 Win11 clients on Floor 3, OU=Finance, failing GP at startup.
- Representative affected host: DESKTOP-FB031.
- Unaffected control host in same OU: DESKTOP-FB029.

Root cause:
- Floor 3 DHCP scope still assigned decommissioned DNS resolver (10.10.3.250 / legacy values), so DC FQDN resolution failed and GP could not reach SYSVOL.

Evidence anchors:
- FB031 5719 at 07:40:08: no secure channel / no DC available.
- FB031 1058 at 07:40:09 and 07:40:11: SYSVOL gpt.ini path inaccessible, code 0x3.
- FB031 1030 at 07:40:10: cannot query GPO list, code 0x546.
- FB031 1129 at 07:40:12 and 07:44:01: no DC connectivity.
- FB031 DNS 1014 at 07:41:05: FINBRIDGE-DC01 resolution timeout.
- FB031 DHCP 50036 at 07:42:18: DNS assigned 10.10.3.250 (old/decommissioned at 02:00).
- FB029 DHCP 50036 at 07:40:05: DNS 10.10.0.10 correct.
- FB029 GP 1500 at 07:40:11: GP success.

Action taken / to execute:
- Update Floor 3 DHCP scope DNS option to 10.10.0.10.
- Force lease renew on affected clients.
- Re-run GP processing and validate success.

Preventive:
- Add post-migration DHCP scope audit for deprecated DNS references.
- Require objective validation: lease capture + GP success event before incident closure.