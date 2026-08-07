# Incident Analysis: Group Policy Failure on Finance OU (3 of 4 Machines)

## Incident Summary
During startup on 2024-03-15 (07:40-07:55), three Finance machines failed Group Policy processing because they could not reach a domain controller (DC). Evidence shows those machines were given a decommissioned DNS server by DHCP after migration.

Affected pattern:
- Affected: 3 of 4 machines in OU=Finance
- Unaffected: 1 machine (manually preconfigured with correct DNS)

## What Each Event ID Recorded

| Event ID | Source | Meaning in this incident |
|---|---|---|
| 7036 | Service Control Manager | A service changed state. Here, Network Location Awareness started running, meaning network stack initialization had begun. |
| 5719 | Netlogon (Error) | Machine could not establish a secure channel to domain FINBRIDGE because no DC could be contacted. Log explicitly says DC DNS query returned no response. |
| 1058 | GroupPolicy (Error) | Group Policy could not read gpt.ini from SYSVOL path on the DC (`\\FINBRIDGE-DC01\\sysvol\\...`). In this context, failure is due to DC/path being unreachable over the network/name resolution, not a deleted GPO. |
| 1030 | GroupPolicy (Warning) | Client could not query the list of applicable GPOs from AD/DC. This is a follow-on symptom of DC connectivity failure. |
| 1129 | GroupPolicy (Error) | Group Policy processing failed because no network connectivity to a DC was available at processing time. |
| 1014 | DNS Client Events (Warning) | DNS name resolution timed out for `FINBRIDGE-DC01.finbridge.local`; configured DNS servers did not answer. Confirms name resolution failure path. |
| 50036 | DHCP Client (Information) | Client accepted DHCP lease including DNS server settings. On affected host, DHCP assigned old/decommissioned DNS server. |
| 1500 | GroupPolicy (Information) | Group Policy processed successfully (seen on unaffected comparison machine). |

## Reconstructed Sequence in Plain English
1. The affected machine boots and network services start (`7036`).
2. Very early in startup, it tries to contact domain resources.
3. Netlogon fails (`5719`) because it cannot resolve/reach a DC; the DNS query for `FINBRIDGE-DC01.finbridge.local` gets no response.
4. Group Policy immediately fails (`1058`, `1030`, repeated `1058`) because it cannot access SYSVOL and cannot retrieve GPO list from the domain.
5. Group Policy raises explicit no-DC-connectivity error (`1129`).
6. DNS client warning (`1014`) confirms DNS timeout: configured DNS servers are not responding.
7. DHCP event (`50036`) then shows why: the machine was assigned `10.10.3.250`, an old DNS server decommissioned during migration.
8. Group Policy fails again later (`1129`) because the DNS/DC reachability problem persists.

Comparison confirms causality:
- Unaffected machine `DESKTOP-FB029` received DNS `10.10.0.10` (correct new DNS) at startup and then logged GP success (`1500`).
- DHCP server logs show three affected clients got old/decommissioned Floor 3 DNS, while one machine had correct DNS due to manual preconfiguration.

## Most Likely Cause of Policy Failure
Stale DHCP scope DNS configuration on the Floor 3 subnet after migration.

The scope continued handing out decommissioned DNS server addresses (old local DNS), so affected clients could not resolve/reach domain controllers. Without DC resolution/connectivity, Group Policy could not read SYSVOL (`1058`) or enumerate GPOs (`1030`), resulting in repeated `1129` failures.

## Evidence Supporting Root Cause
- `5719`: secure channel setup failed; no DC available; DNS query to DC returned no response.
- `1014`: DNS resolution timeout for the DC FQDN; configured DNS servers did not respond.
- `50036` on affected host: DHCP assigned old DNS server (`10.10.3.250`) known to be decommissioned.
- Server-side DHCP comparison: affected set received old DNS (`172.16.5.5` in server log context for Floor 3 old DNS), unaffected host received correct DNS (`10.10.0.10`).
- Unaffected host logged `1500` (successful GP processing) under correct DNS configuration.

## Conclusion
This was not primarily a Group Policy object/content issue. It was a network name-resolution dependency failure caused by incorrect DNS values distributed by DHCP after migration. GP failures were downstream symptoms of DC discovery failure.

## Recommended Corrective Actions
- Update Floor 3 DHCP scope options to only distribute current DNS (`10.10.0.10`).
- Force DHCP renew on affected clients and verify DNS settings.
- Run `gpupdate /force` after DNS correction; confirm `1500` success events.
- Add migration change control check: validate DHCP scope option 006 (DNS Servers) before and after DNS/DC cutover.
- Add monitoring alert for spikes in `5719`, `1014`, and `1129` on OU=Finance endpoints.

## Addendum: Updated Event Detail, Surviving Hypothesis, and Resolution

### Updated Event Detail Notes
- `7036` (Service Control Manager): Confirms network-awareness service startup timing. This marks the beginning of dependency chain checks, not the fault itself.
- `5719` (Netlogon): High-value indicator of domain-auth path failure. The secure channel could not be established because DC discovery failed at DNS lookup stage.
- `1058` (GroupPolicy): Unable to read `gpt.ini` from SYSVOL. In this case, path-not-found (`0x3`) is a downstream effect of unreachable DC namespace, not evidence of a missing GPO file.
- `1030` (GroupPolicy): GPO list query failure from AD. This event pairs with `1058` and typically appears when DC access fails during foreground policy processing.
- `1129` (GroupPolicy): Explicit statement that policy could not process because no DC network connectivity was available; repeated occurrence confirms fault persistence.
- `1014` (DNS Client): Resolver timeout for the DC FQDN with no response from configured DNS servers; this is direct evidence of name-resolution dependency failure.
- `50036` (DHCP Client): Lease acceptance event containing DNS configuration payload. On affected clients, this event carries the incorrect/decommissioned DNS assignment that explains preceding failures.
- `1500` (GroupPolicy, comparison host): Positive control indicator. Successful processing on host with correct DNS assignment narrows root cause away from GPO corruption or broad domain outage.

### Surviving Hypothesis
The surviving hypothesis is: **Floor 3 DHCP scope DNS option remained stale after migration and continued assigning decommissioned DNS servers, causing DC name-resolution failure and subsequent Group Policy failure on affected Finance endpoints.**

Why this hypothesis survives elimination:
- It explains all negative events (`5719`, `1014`, `1058`, `1030`, `1129`) in correct causal order.
- It matches the DHCP lease evidence (`50036`) from affected systems.
- It is consistent with the unaffected control machine that received correct DNS and processed GP successfully (`1500`).
- It fits the partial-blast-radius pattern (3 of 4 affected), which is expected from per-client DNS configuration variance, not from tenant-wide AD or SYSVOL failure.

### Detailed Resolution Steps
1. **Immediate service restoration on affected endpoints**
	- Set DNS manually to current production DNS (`10.10.0.10`) on one affected machine as a validation pilot.
	- Run `ipconfig /flushdns`.
	- Run `nltest /dsgetdc:finbridge.local` to validate DC discovery.
	- Run `gpupdate /force` and confirm successful completion.

2. **Permanent fix in DHCP configuration**
	- Open DHCP management for the Floor 3 scope.
	- Edit Scope Option `006 DNS Servers`.
	- Remove decommissioned DNS IPs (including old local values such as `10.10.3.250` or `172.16.5.5` where present).
	- Add approved current DNS (`10.10.0.10`) and approved secondary only if defined by network standard.
	- Verify there are no conflicting DNS values at reservation level or server defaults.

3. **Client re-lease and configuration refresh**
	- On each affected endpoint run:
	  - `ipconfig /release`
	  - `ipconfig /renew`
	  - `ipconfig /flushdns`
	- Confirm adapter DNS now shows only approved DNS servers.

4. **Policy-processing validation**
	- Execute `gpupdate /force` on each previously affected endpoint.
	- Validate no fresh `5719`, `1014`, `1058`, `1030`, or `1129` events are generated during the next startup/logon cycle.
	- Confirm presence of Group Policy success event (`1500`) or equivalent success indicators per endpoint.

5. **Operational hardening / prevention**
	- Add migration checklist control: validate DHCP Option `006` before and after DNS/DC cutover.
	- Add post-change audit script to detect any scope/reservation referencing retired DNS IPs.
	- Add monitoring alerts for correlated spikes in `5719` + `1014` + `1129` in OU=Finance.
	- Require decommission sign-off that confirms DHCP scopes are clean before DNS retirement is finalized.
