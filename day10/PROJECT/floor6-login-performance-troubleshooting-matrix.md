# Floor 6 Legal Users: Login & Performance Issue - Troubleshooting Matrix

**Incident:** Login failures / slow logins on 45 Windows 11 devices (Intune managed)  
**Timeline:** New app deployed Friday afternoon → Issues Monday morning  
**Affected:** Floor 6 Legal department  
**Analysis Date:** 2026-08-14

---

## Quick Reference: Top 10 Ranked Causes

| Rank | Cause | Probability | Fastest Check | Time to Validate |
|------|-------|-------------|---------------|-----------------|
| 1 | Intune Compliance Policy Block | 85% | Intune Dashboard | 5 min |
| 2 | Group Policy Application Issues | 78% | `gpresult /h` | 10 min |
| 3 | User Profile Corruption | 72% | Event Viewer | 10 min |
| 4 | Login Script Incompatibility | 68% | Review GPO Scripts | 5 min |
| 5 | Intune/GPO Conflict | 64% | Policy Overlap Check | 10 min |
| 6 | Application Deployment (Friday App) | 58% | Task Manager | 10 min |
| 7 | Network Infrastructure (DNS/DC) | 52% | `nltest /dsgetdc` | 5 min |
| 8 | Windows 11 Pending Updates | 48% | Settings → Update | 5 min |
| 9 | OneDrive Cloud Sync | 44% | OneDrive Status | 5 min |
| 10 | Antivirus Scan at Logon | 38% | Defender Settings | 5 min |

---

## Detailed Troubleshooting Matrix

### RANK 1: Intune Compliance Policy Blocking Authentication

**Probability:** 85% | **Time to Validate:** 5 minutes | **Effort:** Low

#### What & Why
Intune Device Compliance policies enforce device health checks at logon. If devices are non-compliant (BitLocker not escrow'd, Defender not updated, policies not applied), Intune blocks or delays authentication.

#### Supporting Evidence ✅
- Recent Windows 11 migration → devices newly enrolled
- Monday 09:00 logons = first real workload logon post-weekend
- Intune compliance checks run at every logon
- BitLocker escrow to AAD can add 30-120 seconds
- Conditional Access policies block non-compliant devices entirely

#### Contradicting Evidence ❌
- Intune Dashboard shows all 45 devices compliant Monday 08:00
- No "Device Compliance Policy" blocks in AAD Sign-in logs
- No BitLocker escrow pending on sample devices
- Non-Intune managed devices on Floor 6 also report slow logins
- Manual policy refresh does not change login speed

#### Fastest Validation Check
```powershell
# On affected device:
1. Open: Intune Admin Center → Devices → Compliance
2. Filter: Legal-Win11 group
3. Count: Non-compliant or "Evaluating" devices at Monday 09:00 UTC
4. If >30 non-compliant → HIGH PROBABILITY
```

#### Confirm Cause
- ✅ Intune Dashboard shows 40+ devices non-compliant Monday 09:00
- ✅ "Device Compliance Policy" appears in AAD Sign-in Logs as blocking reason
- ✅ Device detail shows BitLocker escrow pending or policy evaluation in progress
- ✅ `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\` shows policy evaluation delays
- ✅ When compliance policy is disabled, logins return to normal speed
- ✅ Manually escrow BitLocker key resolves login delays on sample device

#### Rule Out Cause
- ❌ All 45 devices compliant on Monday 08:00
- ❌ No Conditional Access / Compliance Policy blocks in AAD logs
- ❌ No BitLocker escrow pending
- ❌ Intune client logs show normal policy evaluation (<10 seconds)
- ❌ Disable policy → no improvement in login speed
- ❌ Windows 10 devices on Floor 6 also slow (not Intune-specific)

#### Escalation Path
→ Intune Administrator: Review compliance policies applied to Legal-Win11 group Friday-Sunday

---

### RANK 2: Group Policy Application / Legacy Policy Migration

**Probability:** 78% | **Time to Validate:** 10 minutes | **Effort:** Low

#### What & Why
Windows 11 migration applies new/updated Group Policies. If legacy policies weren't redesigned for Windows 11, or if new policies are computationally expensive (scripts, disk quotas, security settings), logon is delayed.

#### Supporting Evidence ✅
- Post-OS-migration Group Policy issues are common enterprise cause of login delays
- Monday = first full "real workload" logon batch after weekend
- All 45 devices on same floor likely in same OU with same policies
- Group Policy processing applies at every logon
- Legacy policies may reference deprecated APIs, causing retry behavior

#### Contradicting Evidence ❌
- `gpresult.exe` output shows only 10-15 policies applied (normal count)
- No Group Policy processing warnings in Event Viewer
- No logon script errors
- No recent GPO changes to Legal-Win11 OU
- Windows 10 devices on same domain show same fast login speed
- Disabling Group Policy policies does not improve login

#### Fastest Validation Check
```powershell
# On affected device:
1. Open Command Prompt
2. gpresult /h gpresult.html
3. Review HTML → count Applied Group Policies
4. If >80 policies (vs. 20-30 typical) → SUSPICIOUS
5. Check for errors or slow processing warnings
```

#### Confirm Cause
- ✅ `gpresult.exe` shows 100+ applied Group Policies
- ✅ Event Viewer: Group Policy shows "Processing took X seconds" warnings (>30 sec)
- ✅ Logon script errors or delays in Event Viewer
- ✅ A GPO created/modified in past 2 weeks now applied to Legal-Win11
- ✅ Disable specific heavy GPO → login speed improves
- ✅ Windows 10 baseline shows same login speed (rules out GPO as cause)

#### Rule Out Cause
- ❌ Only 10-15 Group Policies applied (normal)
- ❌ No Group Policy processing warnings
- ❌ No script execution errors; script time <5 seconds
- ❌ No recent GPO changes to Legal-Win11 OU
- ❌ Disabling Group Policy → no improvement
- ❌ Windows 10 on same domain also slow (not Windows 11 / GPO specific)

#### Escalation Path
→ Domain Admins / Group Policy Administrator: Audit policies targeting Legal-Win11 OU for Windows 11 compatibility

---

### RANK 3: User Profile Corruption / Migration Issue

**Probability:** 72% | **Time to Validate:** 10 minutes | **Effort:** Medium

#### What & Why
Profile migration from Windows 10 → Windows 11 may have introduced corruption (incompatible registry, malformed NTUSER.DAT, failed OneDrive sync initialization). Windows 11 detects corruption at logon and repairs/rebuilds profile (adds 60-120 seconds).

#### Supporting Evidence ✅
- Profile issues surface at next logon after migration
- Monday = first large-scale real-work logon post-migration
- Bulk profile migration tool can cause systematic corruption
- Windows 11 profile structure differs from Windows 10
- OneDrive sync initialization on first Win11 logon adds 30-90 seconds for large folders

#### Contradicting Evidence ❌
- Event Viewer shows no Userenv errors
- Profile timestamps consistent with migration window (not Monday morning)
- OneDrive reports "All files synced" or <100 items pending
- NTUSER.DAT registry hive loads without errors
- Delete profile and rebuild → login still slow (not profile-caused)
- Clearing OneDrive cache → no improvement

#### Fastest Validation Check
```powershell
# On affected device:
1. Event Viewer → Windows Logs → System
2. Search: "Userenv" errors (profile load/repair failures)
3. If "profile service failed" or "repair in progress" → LIKELY
4. Check timestamps: NTUSER.DAT modified Monday 09:00? (indicates rebuild)
```

#### Confirm Cause
- ✅ Event Viewer: Userenv errors "profile service failed the sign-in"
- ✅ Profile repair / rebuild events in Event Viewer at Monday 09:00
- ✅ `%APPDATA%` or `%USERPROFILE%` has corrupted/incomplete folder structure
- ✅ OneDrive syncing 10,000+ items at logon
- ✅ NTUSER.DAT timestamps show Monday morning rebuilds
- ✅ Delete profile and rebuild → login normalizes
- ✅ Clear OneDrive cache → login faster

#### Rule Out Cause
- ❌ No Userenv errors in Event Viewer
- ❌ Profile timestamps consistent with Friday migration (not Monday rebuild)
- ❌ OneDrive: "All synced" or <100 items pending
- ❌ NTUSER.DAT loads without errors; registry healthy
- ❌ Rebuild profile → still slow (not profile issue)
- ❌ Clear OneDrive cache → no change

#### Escalation Path
→ End User Support / Profile Admin: Rebuild user profiles on affected devices; verify OneDrive sync is not stuck

---

### RANK 4: Login Script Incompatibility / Service Delays

**Probability:** 68% | **Time to Validate:** 5 minutes | **Effort:** Low

#### What & Why
Login scripts assigned via Group Policy may use deprecated APIs, legacy VBScript, or hardcoded paths that fail on Windows 11. Script timeout or retry behavior adds 30-60 seconds to logon.

#### Supporting Evidence ✅
- Existing login scripts often have hardcoded paths or WMI queries that break on OS upgrades
- Windows 11 defers network access during early logon
- Script reference to legacy services or deprecated APIs causes retry/fallback
- If script maps network drives, it waits for domain/network readiness
- All 45 devices affected equally suggests domain-wide or OU-wide policy

#### Contradicting Evidence ❌
- No login scripts assigned to Legal-Win11 users
- Script last modified >6 months ago (before Win11 migration)
- Script execution completes in <5 seconds per logs
- Disable login script GPO → no improvement
- Windows 10 devices with same scripts also slow
- Network drives map immediately without timeouts

#### Fastest Validation Check
```powershell
# On affected device:
1. gpedit.msc → User Configuration → Scripts (Logon/Logoff)
2. Review: are any logon scripts assigned?
3. If yes → examine script code
4. Look for: UNC paths, net.exe commands, WMI queries, hardcoded servers
5. Check Event Viewer → Applications for script execution time / errors
```

#### Confirm Cause
- ✅ A logon script is assigned to Legal-Win11 users
- ✅ Script modified in past 30 days OR never tested on Windows 11
- ✅ Script contains UNC paths, `net use`, or deprecated WMI
- ✅ Event Viewer shows script running 30+ seconds or failing Monday 09:00
- ✅ Disable script GPO → login completes in <15 seconds
- ✅ Script works on Windows 10 but hangs on Win11 test device

#### Rule Out Cause
- ❌ No logon scripts assigned
- ❌ Scripts last modified >6 months ago
- ❌ Script execution time <5 seconds per logs
- ❌ Disable scripts → no improvement
- ❌ Windows 10 with same scripts also slow
- ❌ Network drive mapping completes in <2 seconds

#### Escalation Path
→ Directory Services / Group Policy Team: Review logon scripts targeting Legal-Win11 for Windows 11 compatibility

---

### RANK 5: Intune & Group Policy Conflict / Co-Management Issues

**Probability:** 64% | **Time to Validate:** 10 minutes | **Effort:** Medium

#### What & Why
If devices are co-managed (both Intune and Group Policy), conflicting policies can trigger remediation loops. Intune remediates policy → Group Policy reapplies → conflict continues, extending logon time.

#### Supporting Evidence ✅
- Fresh Intune enrollment + existing Group Policy = co-management state
- Co-management conflicts emerge at first real logon workload (Monday)
- Both systems may manage same setting (Firewall, Defender, Compliance)
- Remediation loops can add 30-90 seconds to logon
- Intune + GPO processing both run at logon; wrong ordering causes retries

#### Contradicting Evidence ❌
- Intune and Group Policy manage different, non-overlapping settings
- No "Remediation required" or "Policy conflict" in logs
- Devices show consistent policy application without retries
- Co-management worked normally on Windows 10
- Disable Intune OR Group Policy → no improvement
- Intune audit log shows no conflicts detected Friday-Sunday

#### Fastest Validation Check
```powershell
# In Intune Admin Center:
1. Devices → Compliance → Legal-Win11
2. Review: which policies are configured?
3. Cross-reference with Group Policy objects targeting Legal-Win11 OU
4. Do they manage the SAME setting? (e.g., Firewall, Defender, BitLocker)
5. If YES → likely conflict
```

#### Confirm Cause
- ✅ Intune and Group Policy both manage the same setting (Firewall, Defender, Compliance)
- ✅ Intune audit log: "Remediation required" or "Policy conflict" at Monday 09:00
- ✅ Event logs show alternating Intune + Group Policy processing (conflict loop)
- ✅ Disable Intune policies for Legal-Win11 → login normalizes
- ✅ Co-management priority setting recently changed to favor Intune/GPO
- ✅ Intune compliance remediation blocks logon (BitLocker, update, certificate)

#### Rule Out Cause
- ❌ Intune and Group Policy manage different settings (no overlap)
- ❌ No "Remediation" or "Policy conflict" messages
- ❌ Consistent policy application without retries
- ❌ Co-management normal on Windows 10 baseline
- ❌ Disable either system → no improvement
- ❌ Intune audit: no conflicts detected Friday-Monday

#### Escalation Path
→ Intune Administrator + Domain Admins: Audit co-management policy overlap; resolve conflicts or adjust scoping filters

---

### RANK 6: Application Deployment Trigger (Friday App - Document Manager)

**Probability:** 58% | **Time to Validate:** 10 minutes | **Effort:** Medium

#### What & Why
Friday deployment of new document manager may be configured to auto-start at logon, consuming CPU/disk I/O during authentication. Alternatively, application may trigger auto-update at first Monday logon, further delaying authentication.

#### Supporting Evidence ✅
- Friday deployment + Monday issue is suspicious temporal correlation
- Application may have first-run initialization, indexing, or database setup
- Logon startup configuration in SCCM, Group Policy, or Task Scheduler
- New application may be computationally heavy on first run
- 3-day gap suggests application may have been deferred until Monday first logon

#### Contradicting Evidence ❌
- Document manager process NOT active during authentication (appears after desktop ready)
- Application configured to start AFTER logon, not at logon
- Task Scheduler shows no application-related logon startup tasks
- Application resource consumption is minimal (0-5% CPU, <50MB RAM)
- Disable application startup → login still slow
- Previous version (v2.0) does not exhibit same behavior (not version-specific)
- Users without application deployment show same slow login (not app-specific)

#### Fastest Validation Check
```powershell
# On affected device:
1. Open Task Manager → Processes
2. Perform logon test; monitor Processes tab during authentication
3. Does document manager process appear DURING login (not after)?
4. If YES → measure CPU % and Disk I/O %
5. If app >50% CPU during login → HIGHLY LIKELY
```

#### Confirm Cause
- ✅ Document manager process active DURING logon authentication (not after)
- ✅ Process consumes >50% CPU or >200MB RAM during slow login window
- ✅ Disk I/O spike visible during logon from application (Performance Monitor)
- ✅ Application startup task or service configured to start at logon
- ✅ Previous version (v2.0) does not exhibit same behavior
- ✅ Disable application startup → login immediate (no delay)
- ✅ Application vendor docs mention "initial indexing" or "first-run setup 30-120 seconds"
- ✅ SCCM deployment logs show application deployed to startup folder or logon task

#### Rule Out Cause
- ❌ Application process does NOT appear during login; only after desktop ready
- ❌ No application auto-start task or service at logon
- ❌ Resource Monitor shows 0% CPU, minimal disk I/O from application during login
- ❌ Disable application startup → login still slow
- ❌ Previous version (v2.0) also slow on Windows 11 (not version-specific)
- ❌ Users without application also report slow login (not application-specific)
- ❌ Non-Floor 6 users with application show normal login (not floor-wide issue)

#### Escalation Path
→ Application Vendor Support + SCCM Admin: Confirm v2.1 behavior; request rollback to v2.0 or disable logon startup; verify deployment method did not queue logon execution

---

### RANK 7: Network Infrastructure / DNS / Domain Controller Issues

**Probability:** 52% | **Time to Validate:** 5 minutes | **Effort:** Low

#### What & Why
If DNS or domain controller is slow to respond, Kerberos authentication timeouts and retries, adding 30-60 seconds per logon. Monday morning increased network load or infrastructure changes could degrade performance.

#### Supporting Evidence ✅
- Monday morning could coincide with increased network load (post-weekend)
- DNS/DC latency is classic cause of enterprise login delays
- All 45 devices on Floor 6 on same network segment (single point of failure)
- Windows 11 has stricter DNS validation; may reject older DNS responses
- Intune-enrolled devices must also reach cloud endpoints (login.microsoftonline.com)

#### Contradicting Evidence ❌
- `nltest /dsgetdc:[DOMAIN]` responds in <100ms (normal)
- DNS queries resolve in <50ms
- No Kerberos timeouts or retries in network trace
- Domain controller performance normal (<100ms response)
- Non-Windows 11 devices or non-migrated users show fast login on same network
- Internet connectivity to AAD endpoints is normal
- Network switch logs show no errors or bandwidth saturation Monday 09:00

#### Fastest Validation Check
```powershell
# On affected device:
1. Open Command Prompt
2. nltest /dsgetdc:[DOMAIN] (e.g., nltest /dsgetdc:corp.com)
3. Verify response time <100ms and DC accessible
4. nslookup [domain].com → verify response <50ms
5. ping login.microsoftonline.com → verify AAD endpoint reachable
6. If any response >500ms or timeout → INFRASTRUCTURE ISSUE
```

#### Confirm Cause
- ✅ Network trace shows repeated Kerberos requests (retries) during login
- ✅ Domain controller event logs show high CPU, connection count at Monday 09:00
- ✅ DNS response time elevated (>500ms; normally <100ms)
- ✅ DHCP server logs show repeated address renewal requests from Legal-Win11 at Monday logon
- ✅ Switch/firewall logs show bandwidth saturation or port errors on Floor 6 Monday 09:00
- ✅ Manually specifying alternate DC or DNS → login speed improves
- ✅ AAD authentication endpoint (login.microsoftonline.com) is slow or unreachable

#### Rule Out Cause
- ❌ Kerberos authentication <500ms in network trace
- ❌ Domain controller response <100ms
- ❌ DNS query response <50ms
- ❌ No DHCP renewal issues
- ❌ Windows 10 or non-migrated users on same network show fast login
- ❌ Internet connectivity to AAD normal
- ❌ Network switch/firewall logs show no errors

#### Escalation Path
→ Network Team / Infrastructure: Check domain controller performance, DNS response times, and network infrastructure health at Monday 09:00 UTC

---

### RANK 8: Windows 11 Pending Updates / Driver Incompatibilities

**Probability:** 48% | **Time to Validate:** 5 minutes | **Effort:** Low

#### What & Why
If Windows 11 migration completed Friday and OS has pending KB updates, Windows Update installer may run at logon on Monday, blocking authentication. Alternatively, driver incompatibilities may cause logon delays or hangs.

#### Supporting Evidence ✅
- Freshly migrated Windows 11 devices typically have multiple pending updates
- Windows 11 update installer runs asynchronously during logon (unlike Windows 10)
- Driver installation for new hardware (UEFI, storage) can trigger during OS initialization
- Pending updates would show up Monday morning if installed over weekend without restart
- Windows 11 startup repair, if triggered, runs before logon

#### Contradicting Evidence ❌
- No pending updates visible in Windows Update settings Monday 08:00
- Device Manager shows no yellow marks or unknown devices
- No driver installation events in Event Viewer at Monday logon time
- System event log shows no KB update or patch installation
- Updates were manually installed before Monday
- Manually updating all drivers does not improve login speed

#### Fastest Validation Check
```powershell
# On affected device:
1. Settings → System → About → Advanced system settings → Environment Variables
2. Settings → System → Update & Security → Windows Update
3. Check: "Update status" → any pending updates?
4. If updates pending → check "Restart required" status
5. Device Manager → look for yellow exclamation marks (drivers)
6. If yellow marks present → LIKELY DRIVER ISSUE
```

#### Confirm Cause
- ✅ Pending OS updates visible in Windows Update settings Monday morning
- ✅ Event logs show KB update installation in progress at Monday 09:00
- ✅ Device Manager shows yellow marks (driver issues) on Network, Storage, Chipset
- ✅ System event log: "Update process started" or driver installation at logon
- ✅ Manually install updates before Monday → login normalizes
- ✅ Driver reinstall or removal improves login speed

#### Rule Out Cause
- ❌ No pending updates Monday morning
- ❌ Device Manager shows no yellow marks
- ❌ No update / driver installation in Event Viewer at logon time
- ❌ Windows 10 baseline had no driver issues
- ❌ Manually updating all drivers → no improvement

#### Escalation Path
→ Endpoint Management / SCCM Admin: Verify Windows Update deployment status; force pending updates; check driver compatibility on Windows 11

---

### RANK 9: OneDrive / Cloud Profile Synchronization

**Probability:** 44% | **Time to Validate:** 5 minutes | **Effort:** Low

#### What & Why
If Intune enabled cloud profiles or OneDrive Known Folder Redirection, logon waits for profile sync to complete. Large OneDrive folders syncing for first time on Monday can add 30-90 seconds to logon.

#### Supporting Evidence ✅
- Intune enrollment often enables cloud profile sync
- Monday logon is first sync opportunity after weekend
- Cloud profiles require OneDrive sync before desktop ready
- OneDrive Known Folder Redirection redirects Desktop/Documents to OneDrive
- Large user folders (>5GB) require extended sync time
- If sync not run since Friday, Monday first sync can add significant delay

#### Contradicting Evidence ❌
- OneDrive reports "All synced" or <100 items pending at logon
- No cloud profile sync or OneDrive redirection in Intune
- OneDrive sync completed Friday afternoon (no Monday sync needed)
- OneDrive not installed on Legal-Win11 devices
- Disable OneDrive sync → login still slow
- Pause cloud profile → no improvement

#### Fastest Validation Check
```powershell
# On affected device:
1. Look for OneDrive system tray icon
2. Click → check "Status" → items pending sync?
3. If "Syncing" or "1000+ items pending" at Monday 09:00 → LIKELY
4. Check: Intune portal → Device Configuration → Profiles
5. Look for: cloud profile or OneDrive redirection policies
```

#### Confirm Cause
- ✅ OneDrive status shows "Syncing" or large number of pending items at Monday 09:00
- ✅ OneDrive configured to sync large shared drives or team sites
- ✅ Intune policy enables cloud profiles or OneDrive Known Folder Redirection
- ✅ Network trace shows OneDrive API traffic during logon
- ✅ Pause cloud profile or OneDrive sync → login normalizes
- ✅ Users with smaller folders show normal login; users with large folders show slow login

#### Rule Out Cause
- ❌ OneDrive: "All synced" or <100 items pending
- ❌ No cloud profile or OneDrive redirection in Intune
- ❌ OneDrive sync completed Friday (not Monday)
- ❌ OneDrive not installed
- ❌ Disable OneDrive → login still slow

#### Escalation Path
→ Intune Administrator: Verify cloud profile and OneDrive policies; disable or defer sync if causing login delays

---

### RANK 10: Antivirus / Security Software Scan at Logon

**Probability:** 38% | **Time to Validate:** 5 minutes | **Effort:** Low

#### What & Why
Microsoft Defender or third-party antivirus configured to scan user profile, installed applications, or system startup locations at every logon can add 20-40 seconds of I/O delay.

#### Supporting Evidence ✅
- Windows 11 Defender policies may have been upgraded post-migration
- New antivirus policy applied Friday could trigger scan at Monday logon
- Aggressive antivirus scan policies run early in logon process
- Scan of user profile or startup folders competes with authentication for disk I/O
- All 45 devices affected equally suggests fleet-wide policy

#### Contradicting Evidence ❌
- Antivirus scan scheduled for after logon (not during authentication)
- Event Viewer shows no antivirus scan at Monday 09:00
- Resource Monitor shows minimal antivirus process activity during logon
- Antivirus policy last modified >2 months ago
- Disable antivirus scan → login still slow

#### Fastest Validation Check
```powershell
# On affected device:
1. Windows Defender settings → Virus & threat protection
2. Check: "Scan schedule" and exclusions
3. Verify: no scheduled scan at logon time
4. Event Viewer → Application → Windows Defender
5. Search for scan activity at Monday 09:00
6. Resource Monitor → Disk activity → is MsMpEng.exe active? (Defender)
```

#### Confirm Cause
- ✅ Antivirus scan scheduled to run at logon or during logon
- ✅ Event logs show antivirus scan initiated at Monday 09:00
- ✅ Resource Monitor shows antivirus process >50% disk I/O during login
- ✅ Antivirus policy applied to Legal-Win11 in past 30 days
- ✅ Disable scan at logon → login normalizes
- ✅ Antivirus exclusion list missing critical paths (forcing full vs. targeted scan)

#### Rule Out Cause
- ❌ Scan scheduled after logon (not during)
- ❌ No scan events in Event Viewer at logon time
- ❌ Antivirus process minimal activity in Resource Monitor
- ❌ Policy last modified >2 months ago
- ❌ Disable scan → login still slow

#### Escalation Path
→ Security / Antivirus Administrator: Verify scan policies; exclude logon critical paths or disable scan at logon time

---

## Deployment Impact Assessment: Friday Application Deployment

### EVIDENCE THAT PROVES DEPLOYMENT IS ROOT CAUSE

✅ **All** of the following must be true:

1. **Application process active DURING authentication window**
   - Task Manager shows Document Manager process in memory during login (not after)
   - Process appears at exactly 09:00 with login authentication events

2. **Measurable resource consumption**
   - CPU >50% or Disk I/O >200 IOPS from application during login
   - Performance Monitor shows I/O spike aligned with login delay

3. **Version-specific behavior**
   - v2.0 (previous) does NOT exhibit slow login on Windows 11 baseline
   - v2.1 release notes mention "initial indexing" or "first-run setup 30-120 seconds"

4. **Deployment method includes logon startup**
   - SCCM deployment log shows Task Scheduler task created at logon
   - OR Group Policy modified Friday to add application to logon startup
   - OR Service configured to start at logon

5. **Fleet-wide pattern**
   - All 45 devices have identical application configuration
   - Devices without deployment show normal login speed
   - Disabling application startup immediately restores fast login

6. **Other causes ruled out**
   - Intune compliance normal; no BitLocker escrow or policy blocks
   - Group Policy normal; <20 policies applied, no processing warnings
   - Profiles intact; no Userenv errors or rebuild events
   - Network infrastructure responsive; DNS <50ms, DC <100ms response
   - No Windows Update pending; drivers all installed
   - OneDrive sync not active during logon

### EVIDENCE THAT PROVES DEPLOYMENT IS NOT ROOT CAUSE

✅ **Any ONE** of the following proves deployment is unrelated:

1. **Application not active during authentication**
   - Application process does NOT appear until after desktop ready
   - Application startup is "Manual" or deferred to after logon

2. **Root cause clearly identified elsewhere**
   - Intune audit: 40+ devices non-compliant with BitLocker policy
   - Group Policy: 100+ policies applied with processing errors
   - Domain Controller: offline or responding in >1 second
   - Userenv errors: profile corruption / rebuild events visible

3. **Pre-deployment issue**
   - Windows 11 baseline (Friday morning before deployment) already showed slow login >30 seconds
   - Historical DEX data shows degradation before Friday deployment

4. **Disable application = no improvement**
   - Remove application or disable startup → login remains slow
   - Application is NOT the bottleneck

5. **Selective impact not tied to deployment**
   - Only devices with <8GB RAM affected (hardware issue, not app)
   - Only specific user roles affected (Intune compliance, not app)
   - Deployment failed on some devices but they still report slow login

### MOST LIKELY SCENARIOS

| Scenario | Probability | Evidence | Remediation |
|----------|------------|----------|------------|
| **A: Deployment is primary cause** | 58% | App consuming resources during login, no other infrastructure problems | Rollback to v2.0 or disable logon startup in GPO |
| **B: Deployment + Intune policy conflict** | 24% | App + Intune compliance policy create compound delay; removing either improves partially | Rollback + audit Intune policies applied Friday |
| **C: Deployment is coincidental** | 18% | Root cause in infrastructure/policy; app is irrelevant; pre-migration baseline already slow | Address root cause independent of deployment |

---

## Diagnostic Playbook: Fastest Path to Root Cause

### Phase 1: Immediate Checks (First 15 Minutes)

**Check 1: Intune Compliance Dashboard** (5 min)
```
Intune Admin Center → Devices → Compliance
Filter: Legal-Win11 group
Decision: If >30 devices non-compliant → STOP, escalate to Intune admin
If <5 devices non-compliant → Continue to Check 2
```

**Check 2: Group Policy Count** (5 min)
```powershell
On affected device:
gpresult /h gpresult.html
Review: count Applied Group Policies
Decision: If >80 policies → STOP, escalate to Domain Admins
If <30 policies → Continue to Check 3
```

**Check 3: Application Process During Login** (5 min)
```
On affected device:
Open Task Manager → Processes tab
Perform login; monitor process list during authentication
Look for: Document Manager, Office, update processes
Decision: If app consuming >50% CPU during login → STOP, escalate to vendor
If no heavy process during login → Continue to Phase 2
```

### Phase 2: Deep Diagnostics (Next 30 Minutes)

- Event Viewer analysis (Userenv, Group Policy, Policy conflicts)
- Intune Management Extension logs
- AAD Sign-in logs
- Network trace (Kerberos, DNS response times)
- OneDrive sync status

### Phase 3: Forensic Analysis (If Cause Still Unknown)

- Disk I/O trace during login (Performance Monitor, ETW)
- Intune policy change audit (Friday-Monday)
- Application vendor escalation with first-run logs
- Domain controller performance logs

---

## Decision Tree: Find Root Cause in <1 Hour

```
START: 45 users report slow login Monday morning
│
├─ [5 min] Check Intune Compliance Dashboard
│  ├─ IF >30 non-compliant → RANK 1 CONFIRMED: Escalate to Intune Admin
│  └─ IF <5 non-compliant → Continue
│
├─ [5 min] Run gpresult.exe on affected device
│  ├─ IF >80 Group Policies applied → RANK 2 LIKELY: Audit GPOs
│  └─ IF <30 policies → Continue
│
├─ [5 min] Monitor Task Manager during login
│  ├─ IF app >50% CPU during authentication → RANK 6 LIKELY: Escalate to vendor
│  ├─ IF Userenv errors in Event Viewer → RANK 3 LIKELY: Rebuild profiles
│  ├─ IF Event log shows script delays → RANK 4 LIKELY: Review login scripts
│  └─ IF no heavy process / error → Continue
│
├─ [5 min] Check network infrastructure
│  ├─ IF DNS >500ms or DC unreachable → RANK 7 LIKELY: Escalate to Network
│  └─ IF network normal → Continue
│
├─ [5 min] Verify OS state
│  ├─ IF pending updates → RANK 8 LIKELY: Install updates
│  ├─ IF driver yellow marks → RANK 8 LIKELY: Fix drivers
│  └─ IF OS clean → Continue
│
├─ [5 min] Check profile state
│  ├─ IF OneDrive syncing large folder → RANK 9 LIKELY: Pause sync
│  ├─ IF antivirus scan active → RANK 10 LIKELY: Disable scan
│  └─ IF all above OK → Continue
│
└─ ROOT CAUSE NOT IDENTIFIED → Escalate to Engineering with full logs
   (Collect: Event Viewer, gpresult, Intune logs, network trace)
```

---

## Escalation Contacts by Rank

| Rank | Root Cause | Contact | Info Needed | Action |
|------|-----------|---------|-------------|--------|
| 1 | Intune Compliance Policy | Intune Administrator | Compliance dashboard, AAD logs, policy list | Review/adjust compliance policies |
| 2 | Group Policy | Domain Admins / GPO Team | gpresult output, policy change history, Event Viewer | Audit/fix policies for Win11 |
| 3 | User Profile Corruption | End User Support / Profile Admin | Userenv errors, profile timestamps | Rebuild profiles |
| 4 | Login Script Issue | Directory Services / Automation Team | Script code, Event logs, script test results | Fix/rewrite script for Win11 |
| 5 | Co-Management Conflict | Intune Admin + Domain Admins | Policy overlap matrix, audit logs | Resolve policy conflicts |
| 6 | Application Deployment | Application Vendor + SCCM Admin | Vendor docs, SCCM logs, resource monitoring | Rollback or fix deployment |
| 7 | Network Infrastructure | Network Team / Infrastructure | Network trace, DC logs, DNS queries | Troubleshoot infrastructure |
| 8 | OS Updates / Drivers | Endpoint Management / SCCM | Windows Update status, Device Manager, Event logs | Deploy updates / drivers |
| 9 | OneDrive Cloud Sync | Intune Administrator | OneDrive status, policy list | Adjust cloud profile policy |
| 10 | Antivirus Scan | Security / Antivirus Admin | Antivirus policy, Event logs | Disable/reschedule scan |

---

## Summary: What Evidence Would CONFIRM vs RULE OUT Application Deployment?

### IF Application Deployment is ROOT CAUSE:
✅ Application process running DURING login authentication (not after)
✅ Process consuming >50% CPU / high disk I/O during login window
✅ Previous version (v2.0) does NOT exhibit same behavior
✅ All other infrastructure / policy / profile causes ruled out
✅ Disabling application startup immediately restores normal login speed

### IF Application Deployment is NOT ROOT CAUSE:
✅ Application process only starts AFTER desktop ready (doesn't block authentication)
✅ Root cause clearly identified elsewhere (Intune, GPO, network, profile)
✅ Pre-migration baseline already showed slow login (deployment is coincidental)
✅ Disabling application has NO EFFECT on login speed
✅ Subset of devices affected doesn't correlate with deployment success/failure

**Confidence Assessment:** 58% probability deployment is root cause. Validate with Phase 1 checks before escalating. Do not assume causality based on timing alone.

