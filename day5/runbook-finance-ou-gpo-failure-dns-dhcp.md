# Runbook: Finance OU Group Policy Failure Due to DNS/DHCP Misconfiguration

## Version Header
| Field | Value |
| --- | --- |
| Title | Runbook: Finance OU Group Policy Failure Due to DNS/DHCP Misconfiguration |
| Version | 1.0 |
| Date | 07/08/2026 |
| Author | Tanni Das |
| reviewed | self |
| status | draft |
| change | initial version from RCA |

## prerequisites
Use this pre-flight checklist before starting remediation.

### Access checklist
- [ ] Confirm you can sign in to the DHCP server with an account that can edit scope options. [ELEVATED]
- [ ] Confirm you can sign in to at least one affected endpoint as local administrator. [ELEVATED]
- [ ] Confirm you can open Event Viewer on affected endpoints (local or remote).
- [ ] Confirm you can access the incident ticket and update work notes.
- [ ] Confirm you have the escalation contact for DNS/DHCP platform owner.

### Tools checklist
- [ ] DHCP management console (`dhcpmgmt.msc`) available from the DHCP server.
- [ ] Event Viewer (`eventvwr.msc`) available on endpoint.
- [ ] Command Prompt or PowerShell available on endpoint.
- [ ] RSAT/remote admin path available if you are managing DHCP remotely.

### Mandatory information from end user/service desk
- [ ] At least two affected hostnames (example pattern: `DESKTOP-FB*`).
- [ ] One unaffected comparison hostname in the same OU, if available.
- [ ] First observed failure time window (for example 07:40-07:55).
- [ ] Symptom wording exactly as reported (for example "cannot apply policy" or "missing mapped resources after login").
- [ ] Confirmation that issue started after migration/cutover window.

### Mandatory technical inputs
- [ ] Confirm target OU is Finance.
- [ ] Confirm approved DNS server for this incident: `10.10.0.10`.
- [ ] Confirm old/decommissioned DNS values to remove (from change record).
- [ ] Confirm Floor 3 DHCP scope identifier (scope name and subnet) from DHCP team.

## Procedure
1. Open the incident ticket and copy one affected hostname and one comparison hostname into your work notes.
Expected result: You have two concrete hosts ready for validation.

2. Sign in to the affected endpoint with local administrator rights. [ELEVATED]
Expected result: You can run admin commands and open local logs.

3. Open Event Viewer by running `eventvwr.msc`.
Expected result: Event Viewer console opens.

4. Navigate to `Event Viewer > Windows Logs > System`.
Expected result: System log events are visible.

5. Apply an Event ID filter in System log for `5719,1014,1058,1030,1129`.
Expected result: You can see whether the incident signature exists in the startup window.

6. Open Command Prompt as administrator on the same endpoint. [ELEVATED]
Expected result: Elevated command window is ready.

7. Run `ipconfig /all`.
Expected result: Active adapter DNS Servers list is displayed.

8. Record the DNS server IPs shown for the active adapter in the incident ticket.
Expected result: Current endpoint DNS evidence is captured.

9. Sign in to the DHCP server and open DHCP console by running `dhcpmgmt.msc`. [ELEVATED]
Expected result: DHCP MMC opens.

10. Navigate to `DHCP > <DHCP-Server-Name> > IPv4 > <Floor3-Scope> > Scope Options`.
Expected result: Scope options for the Floor 3 subnet are visible.

11. Open Option `006 DNS Servers` in Scope Options. [ELEVATED]
Expected result: Current distributed DNS entries are listed.

12. Remove each decommissioned DNS IP listed in the change record from Option 006. [ELEVATED]
Expected result: Old DNS entries are removed from Option 006.

13. Add `10.10.0.10` as DNS server in Option 006 and place it first in order. [ELEVATED]
Expected result: Option 006 now has the approved DNS target as primary.

14. Navigate to `DHCP > <DHCP-Server-Name> > IPv4 > <Floor3-Scope> > Reservations`.
Expected result: Reservation list for the affected scope is visible.

15. Open each affected reservation and check `DNS` settings for override values. [ELEVATED]
Expected result: Reservation-level DNS overrides are identified.

16. Remove any reservation-level DNS override that is not `10.10.0.10`. [ELEVATED]
Expected result: Reservation settings no longer conflict with scope DNS.

17. Return to the affected endpoint and run `ipconfig /release`.
Expected result: DHCP lease is released.

18. Run `ipconfig /renew`.
Expected result: New DHCP lease is obtained from corrected scope options.

19. Run `ipconfig /flushdns`.
Expected result: Local DNS resolver cache is cleared.

20. Run `ipconfig /all` again.
Expected result: Active adapter shows DNS server `10.10.0.10`.

21. Run `nltest /dsgetdc:finbridge.local`.
Expected result: Domain controller discovery succeeds.

22. Run `gpupdate /force`.
Expected result: Group Policy processing completes without DC connectivity errors.

23. In Event Viewer, navigate to `Applications and Services Logs > Microsoft > Windows > GroupPolicy > Operational`.
Expected result: Group Policy operational events are visible for post-fix review.

24. In Event Viewer, return to `Windows Logs > System` and confirm no new `5719,1014,1058,1030,1129` after the fix timestamp.
Expected result: No fresh failure signature appears post-remediation.

25. Repeat steps 17 through 24 on each remaining affected endpoint.
Expected result: All affected endpoints receive corrected DNS and successful policy processing.

26. Ask one affected user to sign in on a remediated endpoint and confirm normal operation.
Expected result: User confirms issue is resolved.

## Verification
1. Open DHCP console (`dhcpmgmt.msc`) on the DHCP server and navigate to `DHCP > <DHCP-Server-Name> > IPv4 > <Floor3-Scope> > Scope Options > 006 DNS Servers`.
Expected result: Only approved DNS server `10.10.0.10` is present, and old/decommissioned DNS IPs are absent.

2. On one remediated endpoint, open Command Prompt and run `ipconfig /all`.
Expected result: Active adapter `DNS Servers` includes `10.10.0.10`.

3. On the same endpoint, run `nltest /dsgetdc:finbridge.local`.
Expected result: Command returns a discovered domain controller without errors.

4. On the same endpoint, run `gpupdate /force`.
Expected result: Group Policy update completes successfully with no DC connectivity errors.

5. Open Event Viewer (`eventvwr.msc`) and navigate to `Event Viewer > Windows Logs > System`.
Expected result: System log is open on the remediated endpoint.

6. In System log, apply filter for Event IDs `5719,1014,1058,1030,1129,1500` and set `Logged` to the post-fix time window.
Expected result: No new failures (`5719,1014,1058,1030,1129`) and success evidence includes `1500` where available.

7. Navigate to `Event Viewer > Applications and Services Logs > Microsoft > Windows > GroupPolicy > Operational` and review events after fix timestamp.
Expected result: Operational log shows successful policy processing flow with no fresh connectivity failures.

8. Ask one previously affected user to sign in on a remediated host and confirm normal operation.
Expected result: User confirms successful login and no recurring symptoms.

## Rollback
Use this rollback only if user impact increases after DNS scope edits. Target completion time: under 3 minutes.

1. Open DHCP console (`dhcpmgmt.msc`) and navigate to `DHCP > <DHCP-Server-Name> > IPv4 > <Floor3-Scope> > Scope Options > 006 DNS Servers`. [ELEVATED]
Expected result: You are on the DNS server list edit screen.

2. Replace current Option 006 entries with the exact pre-change DNS list captured in the incident work notes. [ELEVATED]
Expected result: Scope DNS values match the known pre-change baseline.

3. Click `Apply` then `OK` in the Option 006 dialog. [ELEVATED]
Expected result: Rollback configuration is committed.

4. On one impacted endpoint, run `ipconfig /release`, then run `ipconfig /renew`, then run `ipconfig /flushdns`.
Expected result: Endpoint receives rolled-back DNS settings and clears cached resolver entries.

5. On the same endpoint, run `ipconfig /all` and confirm DNS server list matches the pre-change baseline.
Expected result: Endpoint DNS reflects rollback values.

6. Open Event Viewer (`eventvwr.msc`) on the same endpoint, navigate to `Event Viewer > Windows Logs > System`, and filter for `5719,1014,1058,1030,1129` in the last 10 minutes.
Expected result: You can confirm whether rollback stabilized or worsened the signature.

7. If failure volume does not reduce immediately after step 6, escalate to DNS/DHCP platform owner with timestamp of rollback and the pre-change DNS list used. [ELEVATED]
Expected result: Rapid handoff with exact rollback evidence is completed.

## Notes
- This runbook is specific to the verified RCA pattern where stale DHCP DNS values caused DC discovery failure and downstream GP errors.
- Event sequence 5719 + 1014 + 1058/1030 + 1129 with old DNS assignment is the primary incident signature.
- Group Policy content corruption is not indicated by this RCA when DNS assignment is incorrect.
- Similar incident artifacts: unaffected control host with correct DNS (10.10.0.10) and successful GP event pattern.
- If only one endpoint is affected and DNS is already correct, stop this runbook and open a separate endpoint-specific investigation path.
