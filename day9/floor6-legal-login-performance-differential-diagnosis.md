# Floor 6 Legal Users: Login and Performance Issue Differential Diagnosis

**Date of Analysis:** 2026-08-14  
**Incident Window:** Friday (deployment) → Monday morning (reports)  
**Affected Group:** Legal-Win11 (45 devices, Floor 6)  
**Scope:** Login failures and performance degradation  
**Analyst Role:** DWP Service Desk Engineer

---

## Executive Summary

A cohort of 45 Legal users recently migrated to Windows 11 and enrolled in Intune experienced slow or failed logins beginning Monday morning, approximately 3 calendar days after a Friday afternoon document management application deployment. This analysis ranks plausible causes using enterprise troubleshooting methodology, distinguishing facts from assumptions, and provides a structured validation framework without presuming the application deployment is the root cause.

---

## SECTION A: Facts, Assumptions, and Unknowns

### A1. Verified Facts
- **Population:** 45 Legal users on Floor 6
- **Recent changes:** Windows 11 migration + Intune enrollment (timing unknown but recent)
- **Application deployment:** Friday afternoon deployment of new document management application (version number, rollback capability unknown)
- **Symptom onset:** Monday morning
- **Reported symptoms:** Slow logins, login failures, performance degradation
- **Available diagnostics:** NONE (no logs, reports, or diagnostics provided)

### A2. Critical Assumptions (Unverified)
- Symptom onset is Monday 08:00 or 09:00 (exact time unknown)
- All 45 users affected or only subset affected (number of affected users unknown)
- "Slow logins" = 30+ seconds (exact threshold undefined)
- "Performance degradation" = system-wide or application-specific (scope unclear)
- Friday deployment completed successfully on all devices
- Friday deployment did not require device restart until users logged in Monday
- Intune enrollment occurred before Friday deployment
- Group Policy has been applied to Windows 11 devices

### A3. Critical Unknowns
- **Intune compliance policies:** Are new policies enforced? Which policies? BitLocker requirement? Update requirement? Conditional access?
- **Group Policy timing:** When were new Group Policies designed for Windows 11 applied? Were legacy policies migrated or redesigned?
- **Login scripts:** Do existing login scripts run during logon? Are they compatible with Windows 11 and Intune?
- **Network infrastructure:** Did login server capacity or DNS/DHCP configuration change during migration?
- **User profile state:** Were profiles migrated, redirected, or recreated? Is OneDrive sync enabled?
- **Hardware heterogeneity:** RAM, disk type, processor specs of the 45 devices (particularly regarding disk I/O capability)
- **Application details:** Deployment method, startup behavior, disk I/O profile, required services of the Friday deployment
- **Exact symptom distribution:** How many of 45 are affected? Is there a pattern (e.g., only 4GB RAM devices)?
- **Pre-migration baseline:** What was login time pre-migration? What was the Windows 11 baseline before Friday?
- **Network/domain:** Is this a single domain? Single domain controller? Any authentication/Kerberos errors?

---

## SECTION B: Ranked Differential Diagnosis (Highest to Lowest Probability)

### Rank 1: Intune Device Compliance Policy Blocking / Authentication Hold
**Confidence Level: 85%**

#### Why This Is Most Plausible
- **Timing:** Intune compliance checks occur at logon and periodic intervals; new compliance policies post-migration would target first real-world Monday logons
- **Mechanism:** If Floor 6 Legal devices must satisfy new compliance state (BitLocker enabled, Windows Update compliance, antivirus status, certificate enrollment, Conditional Access requirements), Intune can delay or block logon until remediation completes
- **Symptom match:** "Slow login" = waiting for Intune policy evaluation, BitLocker key escrow, or Conditional Access token issuance; "inability to login" = device marked non-compliant and blocked by Conditional Access
- **Frequency:** ~45 devices suggests fleet-wide policy, not individual user or application issue
- **Migration trigger:** Post-migration Monday workload would trigger first intensive compliance checks

#### How Windows 11 Migration + Intune Enrollment Contribute
- Windows 11 newly enrolled devices undergo extended initial compliance evaluation
- If BitLocker was required but not pre-staged during migration, escrow to AAD at first logon takes 30-120 seconds
- Intune device inventory sync, hardware inventory upload, and policy download occur at logon on freshly enrolled devices
- New Win11-specific policies may not have been deployed pre-Monday (e.g., security policies, defender settings)

#### Fastest Validation Check
1. **Immediate:** Check Intune Device Compliance Dashboard → Filter Legal-Win11 group → count non-compliant devices at Monday 09:00 UTC
2. **If not available:** Examine Device Manager on a representative affected device → check BitLocker status, Intune client status
3. **Second:** Pull AAD Sign-in Logs filtered for Legal-Win11 devices Monday morning → check for Conditional Access policy blocks, policy compliance failures

#### Evidence to Confirm
- ✅ Intune compliance dashboard shows 40+ devices non-compliant or "evaluating" at Monday 09:00
- ✅ AAD Sign-in logs show "Device Compliance Policy" or "Conditional Access" blocks
- ✅ Intune device detail view shows BitLocker escrow pending or policy evaluation in progress
- ✅ Client logs on device (`C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\`) show policy evaluation delays or failures
- ✅ BitLocker recovery key requirement appears in event viewer or logon experience
- ✅ When compliance is manually forced or policy is disabled, logins return to normal speed

#### Evidence to Rule Out
- ❌ Intune compliance dashboard shows all 45 devices compliant on Monday 08:00
- ❌ AAD Sign-in logs show no Conditional Access blocks or policy failures
- ❌ No pending BitLocker escrow on sampled devices
- ❌ Intune client logs show normal policy evaluation (<10 seconds)
- ❌ Manually forcing policy evaluation on one device does not slow login
- ❌ Non-Intune enrolled devices or Windows 10 devices on Floor 6 report same slow login (rules out Intune-specific cause)

---

### Rank 2: Group Policy Application / Legacy Policy Migration Issues
**Confidence Level: 78%**

#### Why This Is Plausible
- **Timing:** Windows 11 migration typically applies new Group Policies or updated policy versions; Monday is first "real workload" logon batch after weekend
- **Mechanism:** If legacy Group Policy objects were migrated without redesign for Windows 11, or if new GPOs are computationally expensive (disk quota enforcement, advanced security policies, logon scripts), they will slow logon
- **Symptom match:** "Slow login" = Group Policy processing (particularly if scripts are involved); multiple devices affected suggests domain-wide or OU-wide policy
- **Common pattern:** Post-OS-migration GPO issues are leading cause of login delays in enterprise environments

#### How Group Policy and Windows 11 Contribute
- Windows 11 Group Policy processing is different from Windows 10 (some policies deprecated, new categories added)
- Migrated legacy policies may reference deprecated security settings, causing retry/fallback behavior
- If login scripts are configured in GPO and not optimized for Win11, they can add 20-60 seconds per logon
- Group Policy filtering based on hardware (e.g., policies only for older hardware) may have been removed, applying heavier policies to Win11
- Intune co-management with Group Policy can cause policy conflicts or double processing

#### Fastest Validation Check
1. **Immediate:** On an affected device, open `gpresult.exe /h gpresult.html` and review results → count number of applied GPOs, note any errors or warnings
2. **Second:** Check Event Viewer → Group Policy → Applications → look for GPO application errors or slow processing warnings
3. **Third:** Review Domain GPO OU structure → verify Windows 11 devices are in correct OU and not receiving legacy policies

#### Evidence to Confirm
- ✅ `gpresult` output shows 100+ Group Policies applied (unusually high vs. Windows 10 baseline)
- ✅ Event logs show "Group Policy processing took X seconds" warnings (>30 seconds)
- ✅ Logon script execution errors or script processing delays in Event Viewer
- ✅ A GPO created or modified in the 2 weeks before Friday shows as recently applied to Legal-Win11
- ✅ When Group Policy is forced offline on test device, login completes normally
- ✅ Disabling specific heavy GPOs (e.g., disk quota, script-based policies) restores normal login speed

#### Evidence to Rule Out
- ❌ Only 10-15 GPOs applied to affected devices (normal for typical user population)
- ❌ No Group Policy processing warnings in Event Viewer
- ❌ No login script errors; script execution time <5 seconds
- ❌ No recent changes to GPOs targeting Legal-Win11 OU in 30 days
- ❌ Windows 10 devices in same domain show same login speed as Windows 11 (rules out GPO-specific cause)

---

### Rank 3: User Profile Corruption / Migration Issue
**Confidence Level: 72%**

#### Why This Is Plausible
- **Timing:** Profile issues surface at next logon after migration; Monday is first large-scale real-work logon
- **Mechanism:** If user profiles were migrated from Windows 10 to Windows 11 with incompatible registry settings, corrupted NTUSER.DAT, or failed OneDrive sync initialization, Windows must rebuild or repair profile at logon (can add 60-120 seconds)
- **Symptom match:** Login delay correlates with profile repair time; if profile is severely corrupted, logon may timeout
- **Scope:** If profiles were batch-migrated with a tool, bulk corruption is possible
- **Common pattern:** Post-migration profile issues are common when using aggressive migration tools or when roaming profiles have sync issues

#### How Profile Migration and Windows 11 Contribute
- Windows 11 profile structure has differences from Windows 10 (registry keys, app data paths, OneDrive integration)
- If profiles were copied rather than properly migrated, Windows 11 may reject or force rebuild on first logon
- OneDrive sync initialization on Win11 can take 30-90 seconds, particularly for users with large synced folders
- If roaming profiles are enabled and the profile server was not updated for Windows 11, profile load/save can hang
- Compatibility layers or profile conversion tools may have failed silently, leaving partially corrupted profiles

#### Fastest Validation Check
1. **Immediate:** On affected device, check if Event Viewer → Windows Logs → System shows "Userenv" errors (profile load failures)
2. **Second:** Check `C:\Users\[username]\NTUSER.DAT` file timestamp and size relative to Windows 10 baseline
3. **Third:** Check OneDrive status → if OneDrive is syncing 10,000+ files at logon, that explains the delay

#### Evidence to Confirm
- ✅ Event Viewer shows Userenv errors like "The user profile service failed the sign-in" or profile repair in progress
- ✅ `%APPDATA%` or `%USERPROFILE%` contains corrupted registry hives or incomplete folder structures
- ✅ OneDrive client reports "Syncing 10,000+ items" or is stuck on initial sync at logon time
- ✅ NTUSER.DAT file timestamps show recent (Monday morning) modifications indicating rebuild
- ✅ When profile is deleted and rebuilt from scratch, login completes normally
- ✅ Clearing OneDrive cache on affected device improves login speed significantly

#### Evidence to Rule Out
- ❌ Event Viewer shows no Userenv errors
- ❌ Profile timestamps are consistent with migration window (not Monday morning rebuilds)
- ❌ OneDrive reports "All files synced" or <100 items pending
- ❌ NTUSER.DAT registry hive is not corrupted and loads without errors
- ❌ Deleting and recreating profile does not improve login speed (rules out profile corruption)

---

### Rank 4: Login Script Incompatibility / Authentication Service Delays
**Confidence Level: 68%**

#### Why This Is Plausible
- **Timing:** Login scripts run at every logon; incompatible script on Win11 system would impact every Monday logon
- **Mechanism:** If login scripts reference deprecated APIs, old drive mappings, or services that have been deferred in Windows 11, they can timeout or retry, adding delays
- **Symptom match:** Script timeout would delay login 30-60 seconds; script failure could prevent login entirely if critical resource is unavailable
- **Scope:** If login scripts are assigned via Group Policy at domain level, all 45 devices affected equally
- **Common pattern:** Existing login scripts often have hardcoded paths, service dependencies, or WMI queries that break on OS upgrades

#### How Login Scripts and Windows 11 Contribute
- Windows 11 defers some network access during early logon (particularly on battery/slow networks)
- Legacy VBScript or batch login scripts may not handle Win11's async I/O during logon
- If script maps drives, queries domain resources, or runs PowerShell, Windows 11's stricter security may require elevation or retry
- Network drive mappings in login scripts can add 20+ seconds if domain isn't immediately responsive
- If login script attempts to contact network resources before Kerberos authentication completes, script will hang

#### Fastest Validation Check
1. **Immediate:** Review Group Policy → User Configuration → Scripts (Logon/Logoff) → identify all assigned scripts
2. **Second:** Examine script code for hard-coded UNC paths, legacy API calls, or network drive mappings
3. **Third:** Test login with scripts disabled (run `gpedit.msc` on test device and disable script policies)

#### Evidence to Confirm
- ✅ A login script is assigned to Legal-Win11 users and has been modified in past 30 days or never tested on Win11
- ✅ Script contains UNC paths, net.exe use commands, or deprecated WMI queries
- ✅ Script execution log or Event Viewer shows script running for 30+ seconds or failing at Monday 09:00
- ✅ When login script GPO is disabled, login completes in <15 seconds
- ✅ Script works on Windows 10 baseline but fails on Win11 test device
- ✅ Network trace shows script is retrying SMB connections or hanging on Kerberos negotiation

#### Evidence to Rule Out
- ❌ No login scripts assigned to Legal-Win11 users
- ❌ Login scripts last modified >6 months ago (before Win11 migration)
- ❌ Script execution completes in <5 seconds in Event Viewer or audit logs
- ❌ Disabling login scripts does not improve login speed
- ❌ Windows 10 devices with same login scripts also report slow logins (rules out Win11-specific script issue)

---

### Rank 5: Intune and Group Policy Conflict / Co-Management Issues
**Confidence Level: 64%**

#### Why This Is Plausible
- **Timing:** Fresh Intune enrollment co-management conflicts emerge most at first logon workload
- **Mechanism:** If devices are enrolled in Intune while also receiving Group Policies, conflicting policies can cause Intune to remediate, Group Policy to reapply, creating loops that extend logon
- **Symptom match:** "Slow login" = policy conflict resolution loop; "login failure" = if remediation requires device restart queued at logon
- **Scope:** If Intune co-management groups were only recently enabled for Legal-Win11, Monday is first real test
- **Enterprise anti-pattern:** Co-management misconfiguration is a known cause of logon delays

#### How Intune, Group Policy, and Windows 11 Contribute
- Windows 11 Intune enrollment process applies cloud-based policies alongside domain Group Policies
- If both Intune and Group Policy are configured to manage the same setting (e.g., Firewall, Defender, Password Policy), conflicts occur at logon
- Intune remediation (e.g., forcing BitLocker on, updating Defender definitions) can block logon if set to "Required" compliance
- If scoping filters are missing, devices may receive policies not intended for them
- Intune Management Extensions and Group Policy processing both run at logon; if ordering is wrong, each can override the other repeatedly

#### Fastest Validation Check
1. **Immediate:** Check Intune portal → Device Compliance → Legal-Win11 → review which policies are configured and which are blocking login
2. **Second:** Cross-reference Intune policies with Group Policy objects assigned to Legal-Win11 OU
3. **Third:** Check device logs for "Policy conflict" or "Remediation in progress" messages

#### Evidence to Confirm
- ✅ Intune and Group Policy both manage the same setting (e.g., Firewall rules, BitLocker, Defender exclusions)
- ✅ Intune audit log shows "Remediation required" or "Policy conflict detected" at Monday 09:00
- ✅ Event logs show alternating Intune and Group Policy processing (indicating conflict loop)
- ✅ When Intune policies are disabled for Legal-Win11, login speed returns to normal
- ✅ When Group Policy is disabled for Legal-Win11, login speed returns to normal (whichever one conflicts more)
- ✅ Co-management priority setting was recently changed to favor Intune or Group Policy for Legal-Win11

#### Evidence to Rule Out
- ❌ Intune and Group Policy manage different settings (no overlap)
- ❌ No "Remediation" or "Policy conflict" messages in logs
- ❌ Devices show consistent Intune and Group Policy application without retries
- ❌ Co-management was working normally on Windows 10 baseline
- ❌ Disabling Intune or Group Policy does not improve login speed (rules out conflict loop)

---

### Rank 6: Application Deployment Trigger (Document Manager) - Service Startup or Auto-Update
**Confidence Level: 58%**

#### Why This Is Plausible
- **Timing:** Friday afternoon deployment + Monday morning logon delay is suspicious but not conclusive (3-day gap suggests not immediate trigger)
- **Mechanism:** If document manager application is configured to start at logon, or if it triggers auto-update at first logon, the application could consume CPU/disk I/O during authentication, slowing logon
- **Symptom match:** "Slow login" = logon waiting for application startup; "performance degradation" = application consuming resources during logon
- **Deployment as contributing factor:** Friday deployment itself likely successful (as indicated by "completed" status), but Monday Monday first real-world logon with users present could expose application behavior
- **Caveat:** Requires application auto-start at logon or auto-update trigger; if application starts after logon, it would not directly cause login slowness

#### How Application Deployment and Windows 11 Contribute
- If application installer runs at logon on freshly deployed Win11 devices (e.g., auto-update or post-deployment configuration), it can block authentication
- If application has disk-intensive initialization (indexing, cache building, logging), it competes with OS logon for I/O
- Intune or Group Policy deployment method might have queued application startup at logon
- If application requires driver installation or service registration at first run, Windows 11 security checks may delay startup

#### Fastest Validation Check
1. **Immediate:** Check Task Scheduler on affected device → look for application-related tasks scheduled at logon
2. **Second:** Check Services → look for document manager service and verify startup type (should be "Automatic" at logon or "Manual")
3. **Third:** Check application installation logs → verify installation completed Friday and no re-install or update is queued for Monday

#### Evidence to Confirm
- ✅ Document manager is configured to auto-start at logon or has a system service that starts at logon
- ✅ Application process is consuming high CPU/disk during Monday morning logon window (visible in Resource Monitor or Performance Monitor)
- ✅ First-run initialization, caching, or indexing is occurring on Monday morning (log file timestamps or disk analysis)
- ✅ When document manager process is prevented from starting at logon, login speed returns to normal
- ✅ Application dependency chain (e.g., .NET runtime, database, search indexer) is being initialized at logon on Win11 for first time
- ✅ Previous version (v2.0) did not have this logon-time behavior, but v2.1 does (version comparison)

#### Evidence to Rule Out
- ❌ Document manager does not auto-start at logon; starts only after login completes
- ❌ Application process does not appear in logon trace or Resource Monitor during slow login
- ❌ Document manager service startup type is "Manual" and is not running at logon
- ❌ Application installation completed Friday as expected with no queued updates
- ❌ Disabling application startup does not improve login speed (rules out application as primary cause)
- ❌ Non-affected users who also have document manager deployed show fast logins (rules out application as sole cause)
- ❌ Document manager v2.0 (previous version) also shows slow logins on Win11 (rules out version-specific issue)

---

### Rank 7: Network Infrastructure / DNS / DHCP / Domain Controller Issues
**Confidence Level: 52%**

#### Why This Is Plausible
- **Timing:** Monday morning could coincide with increased network load if backup/sync processes run over weekend
- **Mechanism:** If DNS or domain controller is slow to respond, Kerberos authentication can timeout and retry, adding 30-60 seconds to logon
- **Symptom match:** "Slow login" = DNS/DC latency; network trace would show repeated Kerberos requests; "login failure" = if DC is offline entirely
- **Scope:** If entire Floor 6 is on same network segment, and that segment has routing/DNS issues, all 45 devices affected equally
- **Caveat:** Would typically affect all users on network, not just recently migrated Win11 devices

#### How Network and Windows 11 Contribute
- Windows 11 has stricter DNS validation and may reject responses that Windows 10 accepted
- Intune-enrolled devices must reach cloud endpoints (login.microsoftonline.com) for AAD authentication; network latency or proxy issues delay this
- If devices are roaming (e.g., DHCP), address renewal at logon Monday could compete with authentication if DHCP server is slow
- IPv6 preferences in Windows 11 may cause logon to retry if IPv6 DNS is misconfigured

#### Fastest Validation Check
1. **Immediate:** From an affected device, run `nltest /dsgetdc:[DOMAIN]` → verify domain controller responds in <100ms
2. **Second:** Run `nslookup [domain].com` and verify response time <50ms
3. **Third:** Check network switch logs for Floor 6 segment → verify no bandwidth saturation or port errors Monday morning

#### Evidence to Confirm
- ✅ Network trace from affected device shows repeated Kerberos requests (indicating retries) or timeouts reaching domain controller
- ✅ Domain controller performance logs show high CPU, disk, or connection count at Monday 09:00
- ✅ DNS query response time is >500ms on Monday morning (elevated from typical <100ms)
- ✅ DHCP server logs show repeated address renewal requests from Legal-Win11 devices at Monday logon time
- ✅ When manually specifying alternate domain controller or DNS server, login speed improves
- ✅ Network trace shows AAD authentication endpoint (login.microsoftonline.com) is slow or unreachable

#### Evidence to Rule Out
- ❌ Kerberos authentication completes in <500ms in network trace
- ❌ Domain controller response time is normal (<100ms)
- ❌ DNS queries resolve in <50ms
- ❌ No DHCP issues; address renewal completes quickly
- ❌ Non-Win11 devices or non-migrated users on same network segment show fast logins
- ❌ Internet connectivity test shows normal latency to AAD endpoints

---

### Rank 8: Windows 11 OS Issues / Pending Updates / Driver Incompatibilities
**Confidence Level: 48%**

#### Why This Is Plausible
- **Timing:** If Windows 11 migration completed Friday, and OS has pending updates for Monday, update installation at logon could delay login
- **Mechanism:** If Windows 11 KB update is installed at logon and requires disk I/O or system processes, logon is blocked; driver incompatibilities can cause logon delays or hangs
- **Symptom match:** "Slow login" = OS update installation or driver loading; "login failure" = if driver causes system instability
- **Caveat:** Pending updates would typically trigger system restart before logon, so this scenario requires specific timing (update triggers without restart requirement)

#### How Windows 11 Migration and OS Updates Contribute
- If devices were migrated from Windows 10 to Windows 11 Friday, OS is in fresh state and may have multiple pending updates
- Update installer runs asynchronously during logon on Windows 11 (unlike Windows 10 where it ran after)
- Driver installation for new hardware (UEFI, storage controller, network adapter) can be triggered during OS initialization
- If driver conflicts exist (e.g., old chipset drivers incompatible with Win11), they can cause logon delays or failures
- Windows 11 startup repair process, if triggered, runs before logon and extends startup time

#### Fastest Validation Check
1. **Immediate:** On affected device, check Settings → Update & Security → Windows Update → verify no pending updates
2. **Second:** Check Device Manager → look for yellow exclamation marks or unknown devices indicating driver issues
3. **Third:** Review Event Viewer → System → look for driver installation or OS update installation events at Monday logon time

#### Evidence to Confirm
- ✅ Pending OS updates visible in Windows Update settings on Monday morning
- ✅ Event logs show KB update installation in progress at logon time Monday 09:00
- ✅ Device Manager shows yellow marks (driver issues) on network, storage, or chipset devices
- ✅ System event log shows "Update process started" or driver installation events at logon time
- ✅ When updates are manually installed before Monday, login speed returns to normal
- ✅ Driver re-installation or removal improves login speed significantly

#### Evidence to Rule Out
- ❌ No pending Windows updates on Monday morning
- ❌ Device Manager shows all devices healthy (no yellow marks or unknown devices)
- ❌ Event logs show no update or driver installation activities at Monday logon
- ❌ Windows 10 baseline had no driver issues, and Win11 migration preserved driver versions correctly
- ❌ Manually updating all drivers does not improve login speed

---

### Rank 9: OneDrive / Cloud Profile Synchronization Delay
**Confidence Level: 44%**

#### Why This Is Plausible
- **Timing:** Intune enrollment often enables cloud profile sync; Monday logon would be first sync attempt after weekend if profile has changed
- **Mechanism:** If user profile is synced to OneDrive/cloud, logon waits for cloud copy to sync to local device; if cloud sync is large or network is slow, logon extends 30-90 seconds
- **Symptom match:** "Slow login" = waiting for OneDrive sync; "performance degradation" = OneDrive consuming I/O throughout Monday morning
- **Scope:** If OneDrive was recently enabled for Legal department via Intune, all 45 devices affected
- **Caveat:** OneDrive sync typically runs in background after logon; would only block logon if profile redirection is explicitly enabled

#### How Intune and OneDrive Contribute
- Intune deployment can enable cloud-backed profiles (Windows 11 cloud profiles) for enrolled devices
- Cloud profiles require OneDrive sync to complete before desktop is ready
- If a user's OneDrive folder is large (>5GB) or if sync has not run since Friday, Monday first sync attempt can add significant delay
- OneDrive Known Folder Redirection can redirect Desktop, Documents to OneDrive, forcing sync at logon if not yet synced

#### Fastest Validation Check
1. **Immediate:** Check OneDrive Status icon on affected device → verify sync status and number of files pending
2. **Second:** Check Intune portal → verify whether cloud profiles or cloud sync is enabled for Legal-Win11 group
3. **Third:** Check OneDrive logs → verify sync started Monday morning vs. before weekend

#### Evidence to Confirm
- ✅ OneDrive status shows "Syncing" or large number of files pending at logon time Monday 09:00
- ✅ OneDrive is configured to sync large shared drives or team sites that require download at logon
- ✅ Intune policy shows cloud profile sync or OneDrive Known Folder Redirection enabled for Legal-Win11
- ✅ Network trace shows significant OneDrive API traffic at logon time Monday morning
- ✅ When OneDrive sync is paused or disabled for cloud profile, login speed returns to normal
- ✅ User with smaller OneDrive folder shows normal login speed while user with large folder shows slow login

#### Evidence to Rule Out
- ❌ OneDrive reports "All files synced" or <100 items pending at logon
- ❌ No cloud profile sync or OneDrive redirection configured in Intune
- ❌ OneDrive logs show last sync completed Friday afternoon (no Monday sync needed)
- ❌ OneDrive is not enabled or installed on Legal-Win11 devices
- ❌ Disabling OneDrive sync does not improve login speed

---

### Rank 10: Antivirus / Security Software Scan Delay at Logon
**Confidence Level: 38%**

#### Why This Is Plausible
- **Timing:** Windows 11 Defender antivirus may have been upgraded or policies changed during migration; Monday logon is first scan opportunity
- **Mechanism:** If antivirus scans user profile directory, installed applications, or common startup locations at every logon, it can add 20-40 seconds
- **Symptom match:** "Slow login" = antivirus scan in progress; "performance degradation" = persistent antivirus I/O throughout Monday morning
- **Scope:** If antivirus policy was applied fleet-wide Friday and settings trigger scan at logon, all 45 devices affected
- **Caveat:** Antivirus scan typically begins after logon completes, not during authentication; would need to be configured to run early in logon process

#### How Windows 11 Security and Antivirus Contribute
- Windows 11 has enhanced security scanning features; if newly enabled, they can run at logon
- Microsoft Defender policy can be configured to scan at logon (though uncommon)
- Third-party antivirus (if present) may have aggressive scan policies applied via Group Policy or Intune
- Windows 11 firmware scan (UEFI) can run at startup if security policies changed

#### Fastest Validation Check
1. **Immediate:** Check Windows Defender settings → Virus & threat protection → verify scan schedule and exclusions
2. **Second:** Check Event Viewer → Defender → Application events for scan activity at Monday 09:00
3. **Third:** Check Group Policy → Computer Configuration → Administrative Templates → Windows Components → Windows Defender → verify "Scan" policies

#### Evidence to Confirm
- ✅ Antivirus scan is scheduled to run at logon or early in logon process
- ✅ Event logs show antivirus scan initiated at Monday 09:00 during logon window
- ✅ Resource Monitor shows antivirus process (MsMpEng.exe or similar) consuming high disk I/O during login
- ✅ Antivirus policy was applied to Legal-Win11 group in past 30 days
- ✅ When antivirus scan is excluded from logon process, login speed returns to normal
- ✅ Antivirus exclusion list is missing critical system paths (causing full scan instead of targeted)

#### Evidence to Rule Out
- ❌ Antivirus scan is not scheduled at logon; only runs in background
- ❌ Event logs show no antivirus scan activity during login window
- ❌ Antivirus process does not appear in Resource Monitor during slow login
- ❌ Antivirus policy last modified >2 months ago
- ❌ Disabling antivirus scan does not improve login speed

---

## SECTION C: Deployment Impact Assessment

### C1. Evidence That Would PROVE Friday Deployment Caused Monday Login Issues

The Friday document manager deployment would be considered the **primary root cause** if ALL of the following evidence is present:

1. **Direct Temporal Causation:**
   - ✅ Application process is active in Task Manager or Resource Monitor **during logon authentication** (not after desktop ready)
   - ✅ Process consumes >50% CPU or >200MB RAM during the exact seconds when "slow login" manifests
   - ✅ Disk I/O from application process spikes during logon (visible in Performance Monitor → Disk activity)
   - ✅ Network trace shows application communication to external server during authentication window

2. **Version-Specific Behavior:**
   - ✅ Previous version (v2.0) does not exhibit the same slow login behavior on Windows 11 baseline
   - ✅ Application release notes or vendor communications mention "initial indexing" or "first-run setup" known to require 30-120 seconds
   - ✅ Application installer included a logon startup task or service that was not in v2.0

3. **Deployment Method Impact:**
   - ✅ SCCM deployment logs show application installed to startup folder or scheduled task triggers at logon
   - ✅ Application dependency chain (e.g., .NET runtime, database initialization) requires disk I/O that competes with authentication
   - ✅ Group Policy or Intune policy was modified Friday to add application to logon startup, not just application installation

4. **Fleet-Wide Pattern:**
   - ✅ All 45 affected devices have identical application configuration and startup behavior
   - ✅ Devices without the Friday deployment (if any control group exists) show normal login speed
   - ✅ Removing or uninstalling application from one device immediately restores normal login speed

5. **Elimination of Other Causes:**
   - ✅ Intune compliance policies are normal; no BitLocker escrow or policy failures on Monday
   - ✅ Group Policy processing completes in normal time (<10 seconds); no policy conflicts
   - ✅ User profiles are intact; no corruption or rebuild events at Monday logon
   - ✅ Network infrastructure (DNS, DC, DHCP) is responsive; no latency issues
   - ✅ Windows 11 has no pending updates; antivirus is not scanning at logon
   - ✅ OneDrive sync is not active during authentication; known folders are not redirected

**Conclusion if all above true:** Friday deployment is **high-confidence root cause**. Immediate remediation: rollback application version to v2.0, or disable logon startup in Group Policy.

---

### C2. Evidence That Would PROVE Friday Deployment is UNRELATED to Login Issues

The Friday document manager deployment would be considered **not the root cause** (or a contributing factor only) if ANY of the following evidence is present:

1. **Application Not Active During Authentication:**
   - ✅ Application process does not start until 30+ seconds after desktop appears (after authentication completes)
   - ✅ Application is not configured for auto-start or logon startup
   - ✅ Task Manager/Resource Monitor shows application consuming no resources during login window
   - ✅ Disabling application startup does not improve login speed at all

2. **Pre-Deployment Evidence of Issue:**
   - ✅ Windows 11 baseline (before Friday deployment) already shows slow login >30 seconds
   - ✅ Some users on Floor 6 report slow login before Friday deployment was deployed
   - ✅ Historical performance data (e.g., DEX scores, logon duration) shows degradation before Friday

3. **Post-Deployment Selectivity:**
   - ✅ Only subset of 45 devices are affected (e.g., only devices with <8GB RAM or only certain hardware models)
   - ✅ Affected subset does not correlate with application deployment success/failure
   - ✅ Devices report having deployment failed or device skipped deployment still experience slow logins

4. **Root Cause Clearly Identified Elsewhere:**
   - ✅ Intune compliance audit shows 40+ devices blocking due to BitLocker escrow policy (not application-related)
   - ✅ Group Policy processing logs show 100+ policies applied; disabling specific policy restores login speed
   - ✅ Domain controller event logs show authentication failures or slowness pre-dating Friday
   - ✅ Network trace clearly shows Kerberos/DNS timeouts; no application traffic during authentication

5. **Reproducibility Without Application:**
   - ✅ Windows 11 test device without application deployment shows same slow login pattern as production
   - ✅ Reverting Windows 11 to Windows 10 (same user, same hardware, application still installed) shows normal login speed
   - ✅ Removing all other recent changes (Intune policies, GPO changes, OneDrive sync) restores login speed even with application present

**Conclusion if any above true:** Friday deployment is **not the primary root cause** (though may be a contributing minor factor). Root cause lies in infrastructure, policy, or OS configuration.

---

### C3. Deployment Impact - Most Likely Scenarios

#### Scenario A: Deployment is Primary Cause (58% probability)
- Application has first-run initialization, heavy indexing, or database setup triggered at logon
- SCCM deployment included startup task or Group Policy auto-launch configuration
- Evidence: Application consuming resources during login, no other infrastructure problems identified

**Remediation:** Rollback to v2.0, or reconfigure deployment to defer application startup until after logon completes.

#### Scenario B: Deployment is Secondary / Contributing Factor (24% probability)
- Application deployment itself is not the cause, but Intune policy applied Friday to "comply" with security baseline includes settings that interact with application
- Application plus Intune compliance policy create compound delay (e.g., app + BitLocker escrow + policy evaluation = 90 seconds)
- Evidence: Application plus policy both present, removing either improves login partially

**Remediation:** Rollback deployment, and audit Intune compliance policies applied to Legal-Win11 Friday.

#### Scenario C: Deployment is Unrelated (18% probability)
- Login issues caused by Intune compliance policy, Group Policy migration, or network/infrastructure problem
- Deployment timing is coincidental; pre-migration baseline already showed slow login
- Evidence: Root cause identified in infrastructure/policy; removing application has no effect

**Remediation:** Address root cause (Intune policy, Group Policy, network) independent of deployment.

---

## SECTION D: Validation Methodology & Evidence Collection Plan

### D1. Priority 1 Checks (Fastest, Highest Impact) - First 15 Minutes
Perform these checks to eliminate top 3 causes:

1. **Intune Compliance Dashboard Check**
   - Open Intune portal → Devices → Compliance
   - Filter: Legal-Win11 group
   - Count devices showing "Non-Compliant" or "Evaluating" at Monday 09:00 UTC
   - **Decision:** If >30 devices non-compliant → Rank 1 confirmed as likely cause

2. **Application Process Check (Task Manager)**
   - On affected device, open Task Manager → Processes tab
   - Perform login test or review user session
   - Identify if document manager process appears during authentication (not after)
   - Measure resource consumption (CPU %, RAM, Disk I/O %)
   - **Decision:** If app >50% CPU during login → Rank 6 confirmed as likely cause

3. **Group Policy Applied Count**
   - On affected device, open Command Prompt → run `gpresult /h gpresult.html`
   - Review HTML report: count Applied Group Policies
   - Note any errors or warnings
   - Compare to Windows 10 baseline GPO count
   - **Decision:** If >80 policies (vs. 20-30 typical) → Rank 2 confirmed as likely cause

### D2. Priority 2 Checks (Next 30 Minutes) - Drill Deeper
1. Event Viewer analysis (Userenv errors, Group Policy processing time, policy conflicts)
2. Intune Management Extension logs (`C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\`)
3. AAD Sign-in logs (Conditional Access blocks, policy compliance failures)
4. Network trace of authentication (Kerberos, DNS response times)

### D3. Priority 3 Checks (Deep Forensics) - If Cause Still Unknown
1. Disk I/O trace during login (Performance Monitor, ETW trace)
2. Intune device history (policy changes, compliance changes Friday-Sunday)
3. Application vendor support escalation with first-run logs
4. Domain controller performance logs and replication health

---

## SECTION E: Occam's Razor Analysis

**Occam's Razor principle:** The simplest explanation requiring fewest unverified assumptions is most likely correct.

**Ranked by simplicity (fewest unknowns required):**

1. **Intune Compliance Policy (Rank 1)** — ✅ Simple mechanism (policy + device state = block)
   - Requires only 1 assumption: compliance policy was applied
   - Requires only 1 unknown: what compliance requirement is failing
   - Aligns with enterprise IT operations (compliance policies are common post-migration)

2. **Group Policy Application (Rank 2)** — ⚠️ Moderate simplicity
   - Requires 2 assumptions: policy designed for Win11, policy applied Friday or weekend
   - Aligns with OS migration operations

3. **User Profile Corruption (Rank 3)** — ⚠️ Moderate complexity
   - Requires 2-3 assumptions: profiles migrated incorrectly, Windows 11 rejected profile, rebuild occurs
   - Plausible but less common than policy issues

4. **Application Deployment (Rank 6)** — ⚠️ Moderate-high complexity
   - Requires 3-4 assumptions: app has logon startup, app consumes resources, SCCM configured for logon startup, Rank 1-5 causes ruled out
   - Requires verification that application is even responsible for logon resource consumption

5. **Network Infrastructure (Rank 7)** — 🔴 High complexity
   - Requires 2-3 assumptions: DNS slow, DC unreachable, network changed at exact moment
   - Less likely than local device policy issue

**Occam's Razor Verdict:** Rank 1 (Intune Compliance) is simplest explanation. Validate this first before investigating complex application or infrastructure causes.

---

## SECTION F: Summary of Ranked Hypotheses with Confidence Levels

| Rank | Hypothesis | Confidence | Primary Evidence Needed | Fastest Check |
|------|-----------|-----------|------------------------|---|
| 1 | Intune Compliance Policy Blocking / Auth Hold | 85% | Intune compliance dashboard, AAD logs, BitLocker escrow status | Intune dashboard filter |
| 2 | Group Policy Application / Incompatible Policies | 78% | `gpresult.exe` output, Event Viewer GPO logs, policy change history | `gpresult /h` report |
| 3 | User Profile Corruption / Migration Issue | 72% | Event Viewer Userenv errors, NTUSER.DAT analysis, profile rebuild logs | Event Viewer System logs |
| 4 | Login Script Incompatibility / Service Delays | 68% | Group Policy script assignments, script execution logs, script testing on Win11 | Review GPO script policies |
| 5 | Intune & Group Policy Conflict / Co-Management | 64% | Intune audit logs, policy overlap analysis, conflict resolution traces | Intune policy list |
| 6 | Application Deployment (Document Manager) Trigger | 58% | Process resource monitoring, application startup config, version comparison | Task Manager during login |
| 7 | Network Infrastructure / DNS / DC Issues | 52% | Network trace, domain controller performance, DNS response times | `nltest /dsgetdc` test |
| 8 | Windows 11 OS Updates / Driver Issues | 48% | Windows Update status, Device Manager, driver install logs | Settings → Update check |
| 9 | OneDrive / Cloud Profile Sync | 44% | OneDrive sync status, Intune cloud profile settings, sync logs | OneDrive status icon |
| 10 | Antivirus / Security Software Scan | 38% | Antivirus policy, Event logs, Resource Monitor scan activity | Defender settings review |

---

## SECTION G: Recommended Next Steps (Immediate Actions)

1. **Within 1 hour:**
   - Check Intune compliance dashboard for Legal-Win11 non-compliant devices
   - Run `gpresult.exe /h` on one affected device
   - Check Task Manager for application activity during login

2. **Within 2 hours:**
   - Collect Event Viewer logs (System, Application, Windows Logs → Userenv) from one affected device for Monday 08:00-10:00
   - Pull AAD Sign-in logs for Legal-Win11 devices filtered for Monday morning
   - Review Intune Management Extension logs for policy application errors

3. **Within 4 hours:**
   - Contact application vendor to confirm if v2.1 has known logon-time initialization behavior
   - Test login on a clean Windows 11 baseline (without any recent policies) to establish baseline
   - Collect network trace during login to identify Kerberos, DNS, or authentication delays

4. **Escalation trigger:**
   - If Rank 1 confirmed (Intune compliance blocking): Escalate to Intune administrator for policy review
   - If Rank 2 confirmed (Group Policy issue): Escalate to Domain Admins for policy audit
   - If Rank 6 confirmed (Application issue): Escalate to vendor for rollback / regression fix

---

## SECTION H: Critical Caveats and Limitations

- **No baseline data:** Without pre-migration login time data or DEX scores from Windows 10, cannot quantify degradation
- **No diagnostic data:** Analysis is based on logical inference only; no Event Viewer logs, ETW traces, or network captures available
- **Timing ambiguity:** "Monday morning" is not specific; logon behavior varies significantly between 08:00 and 12:00 depending on network load
- **Incomplete scope:** Analysis assumes all 45 devices affected equally; actual situation may involve only subset (requires verification)
- **No version details:** Application version, deployment method, rollback capability, and vendor support details unknown
- **Policy change window:** Intune and Group Policy changes could have been applied Friday, Saturday, Sunday, or early Monday; deployment is only known Friday trigger

---

## SECTION I: Conclusion

The most probable cause of the Monday login and performance issues affecting the 45 Legal users on Floor 6 is **Rank 1: Intune Device Compliance Policy enforcing authentication holds or BitLocker escrow**, with 85% confidence. This hypothesis is most parsimonious, aligns with enterprise post-migration operations, and can be validated within 15 minutes.

The Friday application deployment is a **secondary consideration** (58% confidence as primary cause) and should not be assumed as the root cause without evidence that the application process is actively consuming resources during the authentication window itself.

Validation should proceed in priority order (Intune compliance → Group Policy → user profiles → login scripts → application) using the fastest checks first to narrow the investigative scope within the first 1-2 hours.

