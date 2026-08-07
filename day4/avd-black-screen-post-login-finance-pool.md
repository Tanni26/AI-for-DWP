# AVD Black Screen Post-Login — Finance Desktop Pool (POOL-FIN-01)

## Charter alignment
This triage note is based on sanitized ticket content only, excludes end-user PII and credentials, and any generated script or system change must be verified before use.

## Summary (one line)
Multiple Finance users on POOL-FIN-01 are experiencing a black screen immediately after AVD login following an overnight image update, with some sessions self-recovering after ~30 seconds and others not recovering at all.

## Impact (who/how many/business urgency)
- Who: Finance team users assigned to POOL-FIN-01.
- How many: Approximately 40% of POOL-FIN-01 affected; IT team on POOL-FIN-02 is unaffected.
- Business urgency: High — Finance users unable to access their desktop at the start of the business day; productivity impact is immediate and ongoing.

## Known facts
- First report received ~07:00 on 2024-03-15.
- Symptom: black screen displayed immediately after login; variable duration.
- Some sessions self-recover after approximately 30 seconds.
- Other sessions do not recover and require a support call to resolve.
- Affected pool: POOL-FIN-01 (Finance desktop pool).
- Unaffected pool: POOL-FIN-02 (IT team) — not included in the recent update wave.
- Overnight image update was applied to POOL-FIN-01 at approximately 02:00 on 2024-03-15.
- Issue was not present prior to this update (confirmed working yesterday).
- POOL-FIN-02 received no changes and remains healthy — isolates the cause to the POOL-FIN-01 image update.

## Missing information to gather
- Exact number of affected users and total POOL-FIN-01 user count.
- Whether all session hosts in POOL-FIN-01 received the image update or only a subset.
- Image update change log: what was changed, packages added/removed, GPO/registry changes, startup script changes.
- Whether affected users are on specific session hosts or distributed across all hosts in the pool.
- AVD Diagnostics: session start events, host health status, and any error codes logged in Azure Monitor/Log Analytics during the 02:00–07:00 window.
- Whether a rollback of the POOL-FIN-01 image to the previous version is available and tested.
- Whether forcing a logoff and fresh reconnect resolves the black screen for users where it does not self-recover.
- Windows Event Log entries on affected session hosts (System/Application) around session startup time.
- Whether the black screen duration or recovery rate correlates with a specific session host in the pool.

## Likely category
AVD session startup failure (black screen) caused by a post-image-update regression on POOL-FIN-01 session hosts — likely a startup script, GPO, shell/explorer, or profile-loading issue introduced by the overnight image change.

## First diagnostic step
Compare the POOL-FIN-01 image change log against the previous known-good image to identify any startup scripts, shell replacements, or profile-related changes; simultaneously check Windows Event Logs on an affected session host for Explorer/shell or Group Policy errors at session login time to pinpoint the failure stage.

---

## Probable root cause
The overnight image update to POOL-FIN-01 most likely introduced a change that delays or prevents Windows Explorer (shell) or a user profile/logon script from initialising correctly, producing the black screen. The fact that ~60% of sessions recover and ~40% do not suggests either a timing-sensitive startup dependency (e.g. a logon script or GPO waiting on a slow network resource) or a per-user profile condition exposed by the new image.

---

## Recommended actions

### Immediate (stabilise users)
1. For users whose session does not self-recover: have them disconnect, wait 60 seconds, and reconnect to a fresh session — do not let sessions linger on a hung host.
2. If reconnect does not resolve: force a full logoff via the AVD host pool management plane and have the user log in again.
3. Identify whether any single session host accounts for a disproportionate share of failures; if so, drain and restart that host immediately.

### Short-term (identify and fix)
4. Pull the image update change log and diff against the prior image — focus on startup scripts, shell/userinit registry keys, and any new logon GPOs.
5. Review Windows Event Logs (System, Application, Group Policy Operational) on an affected session host for errors in the 30-second window after user login.
6. Check AVD session diagnostics in Azure Monitor for error codes on failed session starts since 02:00.

### Recovery option
7. If a known-good image snapshot is available, rollback POOL-FIN-01 to the pre-update image while investigation continues; validate on one session host before rolling out to the pool.

---

## End-User Communication

Hi — we are aware that some Finance desktop users are seeing a black screen when logging into their virtual desktop this morning and are actively investigating. This appears to be linked to a scheduled maintenance update that ran overnight.

If your screen does not come back within about 30 seconds: please disconnect from the session, wait one minute, and then log back in. This should allow a fresh session to start correctly.

If the problem continues after reconnecting, please call the service desk on ext 4421 and we will resolve it for you directly. We apologise for the disruption and will provide an update as soon as we have a fix confirmed.

---

## Known Error Record

**Symptom:** Black screen displayed immediately after AVD login on POOL-FIN-01; variable recovery — some sessions recover in ~30 seconds, others do not recover without intervention.

**Cause (provisional):** Regression introduced by overnight image update to POOL-FIN-01 at 02:00 on 2024-03-15, most likely affecting shell/Explorer initialisation, a logon script, or a profile-loading dependency. To be confirmed via change log review and event log analysis.

**Scope:** Approximately 40% of POOL-FIN-01 (Finance desktop pool). POOL-FIN-02 (IT pool) is unaffected — not included in the update wave.

**Workaround:** Disconnect and reconnect to force a new session. If black screen persists, request forced logoff from service desk.

**Permanent fix:** Identify the specific change in the overnight image update that causes the regression; either revert the change in the image or apply a targeted fix, then re-deploy to POOL-FIN-01 and validate before returning to normal operation.