# RCA: Finance OU Group Policy Failure Due to DNS/DHCP Misconfiguration (Closed)

## Document Control
- Incident date: 2024-03-15
- Analysis date: 2026-08-07
- Affected scope: 3 of 4 endpoints in OU=Finance
- Resolution status: Resolved
- Service restored / verified: 09:09 AM (user successfully logged in to host; no issues reported)

## Executive Summary
Three Finance OU machines failed Group Policy processing during startup because they could not discover or reach a domain controller. The failure chain originated from incorrect DNS server values distributed via DHCP scope options after a migration cutover. One comparison machine in the same OU remained healthy because it had been manually preconfigured to the new DNS server before the migration wave.

The issue was resolved by correcting DHCP DNS scope configuration, refreshing client DHCP/DNS state, and reprocessing Group Policy. At 09:09 AM, user login verification confirmed normal host operation and no further issue reports.

## Business and Technical Impact
- User impact:
  - Intermittent or failed policy application at startup/logon on 3 Finance endpoints.
  - Increased risk of authentication delay, missing mapped resources, and compliance drift while policy processing failed.
- Technical impact:
  - Domain controller discovery failures.
  - SYSVOL access failures and inability to enumerate GPOs.
  - Repeated Group Policy error cycles until DNS was corrected.

## Supporting Evidence

### Affected Endpoint Evidence (DESKTOP-FB031, startup window 07:40-07:55)
- 07:40:02 `7036` Service Control Manager:
  - Network Location Awareness entered running state (network stack initialization point).
- 07:40:08 `5719` Netlogon (Error):
  - Could not set up secure channel to domain FINBRIDGE.
  - No domain controller available.
  - DNS query for `FINBRIDGE-DC01.finbridge.local` returned no response.
- 07:40:09 `1058` GroupPolicy (Error):
  - Could not access `\\FINBRIDGE-DC01\\sysvol\\...\\gpt.ini`.
  - Error `0x3` (path not found in context of unreachable DC namespace).
- 07:40:10 `1030` GroupPolicy (Warning):
  - Could not query list of Group Policy objects.
- 07:40:11 `1058` GroupPolicy (Error):
  - Repeated SYSVOL read failure.
- 07:40:12 `1129` GroupPolicy (Error):
  - Group Policy failed due to no network connectivity to a domain controller.
- 07:41:05 `1014` DNS Client Events (Warning):
  - Name resolution timeout for `FINBRIDGE-DC01.finbridge.local`.
  - Configured DNS servers did not respond.
- 07:42:18 `50036` DHCP Client (Information):
  - DHCP lease assigned DNS `10.10.3.250` (old/decommissioned DNS).
- 07:44:01 `1129` GroupPolicy (Error):
  - Repeat no-DC-connectivity failure.

### Control/Comparison Evidence (DESKTOP-FB029, same OU, unaffected)
- 07:40:05 `50036` DHCP Client:
  - DNS assigned `10.10.0.10` (correct new DNS).
- 07:40:11 `1500` GroupPolicy (Information):
  - Group Policy processed successfully.
- Additional context:
  - Host was manually reconfigured before migration.

### DHCP Server Comparison Evidence
- Affected set (FB055-057): assigned old Floor 3 DNS `172.16.5.5` (decommissioned overnight).
- Unaffected set (FB058/control): DNS `10.10.0.10` (correct central DNS).
- Evidence indicates Floor 3 DHCP scope retained stale DNS option values post-migration.

## Timeline of Events
1. 07:40:02 - Network Location Awareness starts (`7036`).
2. 07:40:08 - Netlogon secure channel setup fails (`5719`) because DC cannot be resolved/reached.
3. 07:40:09 - Group Policy fails to read SYSVOL `gpt.ini` (`1058`).
4. 07:40:10 - Group Policy cannot enumerate applicable GPOs (`1030`).
5. 07:40:11 - Group Policy SYSVOL access failure repeats (`1058`).
6. 07:40:12 - Group Policy reports no DC connectivity (`1129`).
7. 07:41:05 - DNS client confirms resolver timeout/no DNS response (`1014`).
8. 07:42:18 - DHCP lease confirms endpoint received old DNS (`50036`, `10.10.3.250`).
9. 07:44:01 - Group Policy fails again due to missing DC connectivity (`1129`).
10. Post-triage - DHCP scope DNS corrected; affected clients renewed network config and retried policy.
11. 09:09 AM - Service confirmed restored; user logged in successfully to host; no issues reported.

## Root Cause Statement
Primary root cause: Floor 3 DHCP scope option for DNS (Option 006) was not updated after DNS migration, resulting in distribution of decommissioned DNS server IPs to Finance endpoints.

Contributing factors:
- Decommission timing preceded complete DHCP scope validation.
- No enforced pre/post-cutover control to verify scope and reservation DNS values.
- Mixed endpoint configuration state (one manually preconfigured host masked broader DHCP inconsistency).

## 5 Whys Analysis
1. Why did Group Policy fail on 3 Finance machines?
   - Because clients could not contact a domain controller during startup/logon policy processing.

2. Why could they not contact a domain controller?
   - Because DC hostnames could not be resolved/reached via configured DNS.

3. Why was DNS resolution failing?
   - Because affected clients were assigned decommissioned DNS servers.

4. Why were clients assigned decommissioned DNS servers?
   - Because DHCP Floor 3 scope DNS option still referenced old DNS values after migration.

5. Why was stale DHCP configuration left in place?
   - Because migration change execution lacked a mandatory validation gate for DHCP Option 006 and reservation-level DNS entries before DNS decommission sign-off.

Corrective insight:
- The technical fault was not GPO content corruption; it was dependency failure in DNS/DC discovery caused by stale DHCP configuration.

## Resolution Actions Performed
1. Corrected DHCP Floor 3 scope Option 006 to current DNS (`10.10.0.10`) and removed decommissioned DNS IPs.
2. Verified no conflicting DNS server values remained in relevant DHCP scope/reservation settings.
3. Renewed DHCP leases and refreshed DNS cache on affected endpoints.
4. Re-ran Group Policy processing on affected endpoints.
5. Validated successful user authentication and host access.
6. Closed incident at 09:09 AM after user verification with no further issues reported.

## Validation and Closure Evidence
- Post-fix endpoint state:
  - Correct DNS assignment present.
  - DC discovery successful.
  - Group Policy processing recovered.
- Service verification:
  - User logged in to host successfully.
  - No additional issue reports after fix implementation.
- Incident closure timestamp:
  - 09:09 AM.

## Preventive and Control Actions
1. Change management controls
   - Introduce mandatory pre-cutover and post-cutover checklist item for DHCP Option 006 verification on all impacted scopes.
   - Add explicit dependency gate: DNS decommission cannot proceed until DHCP scopes/reservations are certified clean.

2. Configuration governance
   - Implement automated audit to detect and report any DHCP scopes/reservations referencing retired DNS IPs.
   - Maintain authoritative DNS target list per subnet in migration documentation.

3. Monitoring and alerting
   - Create correlated alerting for spikes of Event IDs `5719`, `1014`, and `1129` within the same OU/subnet.
   - Add daily exception report for endpoints receiving non-approved DNS servers.

4. Operational readiness
   - Standardize endpoint post-migration validation script (`ipconfig /all`, DC discovery test, GP test) for sample endpoints in each OU.
   - Require documented rollback/rapid-remediation step for DHCP option correction in migration runbooks.

## Lessons Learned
- Group Policy failures can be secondary symptoms; dependency tracing (DNS -> DC discovery -> SYSVOL/GPO processing) accelerates root cause isolation.
- Control hosts (unaffected comparators) are critical in disproving broad AD/GPO outage hypotheses.
- DHCP option hygiene is a high-risk migration dependency and must be formally controlled.

## Final Outcome
Incident resolved. Root cause confirmed as stale DHCP DNS scope values after migration. Corrective action restored normal authentication and policy processing, with end-user service verified at 09:09 AM and no residual issues reported.
