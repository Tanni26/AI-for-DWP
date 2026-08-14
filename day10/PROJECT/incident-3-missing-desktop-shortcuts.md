# INCIDENT 3: MISSING DESKTOP SHORTCUTS
**Incident ID:** FIN-2026-08-14-003  
**Floor:** 6 (Legal Department)  
**Reporting Time:** 09:14 (Monday)  
**Priority:** MEDIUM – User Productivity  
**Severity Level:** SEV-3 (Minor Service Degradation)  
**Users Affected:** At least 1, likely multiple

---

## INCIDENT BREAKDOWN

**What Happened:**
At least one user on Floor 6 reported that their desktop shortcuts have vanished. Desktop appears empty or has only default Windows icons.

**Why This Is a Separate Incident:**
- This is a **profile/configuration issue**, not a security breach or service outage
- Affects user experience and productivity but not data availability
- Root cause is likely distinct from login issues (likely Windows 11 migration profile issue, not app deployment)
- Typically resolvable by user action (restore shortcuts) rather than infrastructure change
- Low risk but requires investigation to determine if widespread

**Why This Is Tertiary Priority (After Copilot and Login Issues):**
- **Lower urgency:** User can still access applications via Start menu, file manager, or taskbar
- **Individual user issue:** Currently one report; could be isolated or widespread (unknown scope)
- **Productivity impact is lower:** Inconvenient (extra clicks to launch apps) but not blocking
- **Likely easy remediation:** User may have accidentally cleared desktop or profile restoration is simple

---

## PRIORITY ASSESSMENT

| Dimension | Rating | Justification |
|-----------|--------|---------------|
| **Security Risk** | NONE | No data exposure; user profile issue only |
| **Business Impact** | LOW–MEDIUM | Reduced productivity (extra steps to launch apps) but work still possible |
| **Scope** | UNKNOWN (1 confirmed, likely more) | May affect all Floor 6 users if Windows 11 migration issue |
| **Urgency** | LOW–MEDIUM | Not blocking; could wait 4–8 hours if Incidents 1 & 2 consuming resources |
| **Reversibility** | HIGH | Easy to restore shortcuts or recreate manually |

---

## FACTS vs ASSUMPTIONS vs UNKNOWNS

### VERIFIED FACTS
1. ✅ At least one user on Floor 6 is missing desktop shortcuts
2. ✅ Floor 6 was recently migrated to Windows 11
3. ✅ Floor 6 was recently enrolled in Intune
4. ✅ New document management application deployed Friday
5. ✅ Report received Monday morning (09:14)

### CRITICAL ASSUMPTIONS (Must Verify)
- ❓ Assumption: Desktop shortcuts actually disappeared (vs. user using new profile or rebooted to different account)
  - **Verify:** Is user logged into the same account? Compare profile path with Friday
  - **Why:** Different user account = different desktop

- ❓ Assumption: This is caused by Windows 11 migration
  - **Verify:** Did user previously have shortcuts on Windows 10? Were shortcuts in old profile?
  - **Why:** Could be user error or new profile created during migration

- ❓ Assumption: Shortcuts are actually deleted (vs. just off-screen or moved to another location)
  - **Verify:** Check C:\Users\[username]\Desktop directory; count actual .lnk files
  - **Why:** Shortcuts may just need repositioning

- ❓ Assumption: This affects multiple users
  - **Verify:** Ask 5–10 other Floor 6 users: "Are your desktop shortcuts still there?"
  - **Why:** If only one user, likely user error or account-specific; if multiple, migration issue

- ❓ Assumption: Application shortcuts disappeared (vs. just user-customized shortcuts)
  - **Verify:** Are Office, Teams, web browser shortcuts missing? Or only custom/industry shortcuts?
  - **Why:** Different root cause (Windows default vs. custom shortcut restoration)

### CRITICAL UNKNOWNS
- 🔴 **Which shortcuts are missing?** All of them? Some? Just custom ones?
- 🔴 **When did they disappear?** Friday during deployment? Over weekend? Monday morning on login?
- 🔴 **Did user manually delete them?** Or did something remove them automatically?
- 🔴 **What was the Windows 10 profile state?** Did this user have shortcuts set up on Windows 10?
- 🔴 **Is this user-specific or floor-wide?** Only this user or do others have the same issue?
- 🔴 **Were shortcuts stored in roaming/OneDrive profile?** If yes, why didn't they sync to new profile?
- 🔴 **Did Windows 11 migration script restore desktop files?** Or was desktop intentionally cleared?
- 🔴 **Is there a Intune policy that controls desktop customization?** If yes, is it active?

---

## FIRST 30-MINUTE TRIAGE PLAN

### TIMELINE: 09:14 – 09:44

| Time | Action | Owner | Output | Why |
|------|--------|-------|--------|-----|
| 09:30–09:32 | **Scope Verification:** Ask 5–10 other Floor 6 users: "Are your desktop shortcuts there? All normal?" | Assigned Engineer | Scope assessment | Determine if user-specific or systemic |
| 09:32–09:35 | **Profile Check:** Ask affected user: "Is this the same computer/account you used on Windows 10? Same name? Same logon?" | Assigned Engineer | Profile continuity confirmation | Rule out user being on different account |
| 09:35–09:38 | **Desktop Directory Audit:** Check C:\Users\[username]\Desktop on affected device; count .lnk files and compare with unaffected user | Assigned Engineer | File count + comparison | Confirm shortcuts actually deleted vs. moved |
| 09:38–09:40 | **Migration Script Audit:** Pull Windows 11 migration documentation; was desktop profile specifically cleared or restored? | IT Infrastructure | Migration script details | Determine if intentional or unintended |
| 09:40–09:42 | **OneDrive Sync Check:** Is affected user's OneDrive syncing? Could desktop shortcuts been in OneDrive and not synced? | Assigned Engineer | OneDrive status | Rule in/out OneDrive as backup source |
| 09:42–09:44 | **Restoration Plan:** If user-specific, plan shortcut restoration (user recreates or restore from backup); if floor-wide, engage Level 2 for mass remediation | Assigned Engineer | Remediation decision | Determine next action |

---

## EVIDENCE REQUIRED (Before Confirming Root Cause)

### Tier 1 Evidence (Must-Have for Quick Resolution)
1. **Desktop Directory Listing:** Output of `dir C:\Users\[username]\Desktop` from affected device (count .lnk files)
2. **Baseline Comparison:** Same directory listing from an unaffected Floor 6 user (to establish normal state)
3. **Windows 10 Profile Backup:** If migration process kept backup of old profile, check if shortcuts were there
4. **User Confirmation:** Did this user have desktop shortcuts on Windows 10?
5. **Migration Documentation:** Official record of Windows 11 migration process for Floor 6

### Tier 2 Evidence (Scope and Cause Confirmation)
6. **Floor 6 Desktop Audit:** Desktop directory listing from 5–10 other Floor 6 users (to determine if systemic)
7. **Intune Policy Audit:** Check if any Intune policy controls desktop customization or resets desktop on new enrollment
8. **OneDrive Folder State:** Is affected user's Desktop folder syncing in OneDrive? Are shortcuts stored there?
9. **Windows Event Log:** Check for profile creation events or file deletion events from affected device
10. **Document Management App Impact:** Did Friday's app installation modify desktop or profile?

### Tier 3 Evidence (Prevention and Root Cause Analysis)
11. **Migration Script Audit:** Detailed review of Windows 11 migration script – does it intentionally wipe desktop?
12. **Intune Profile Restoration:** Did Intune policy apply a clean profile template on enrollment?
13. **File Restore Capability:** Can user restore shortcuts from local backup or OneDrive version history?
14. **Historical Shortcut Inventory:** Do we have a backup of this user's pre-migration desktop shortcuts?

---

## SYSTEMS AND LOGS TO CHECK

### Primary Systems (Check First – 5 Minutes)

| System | Log/Data | What to Look For | Why |
|--------|----------|------------------|-----|
| **Local Device Filesystem** | C:\Users\[username]\Desktop directory | How many .lnk files are present? Compare with baseline | Confirm shortcuts deleted vs. moved |
| **Unaffected User Device** | C:\Users\[baseline_user]\Desktop directory | How many .lnk files on normal device? What are they named? | Establish baseline/normal state |
| **Windows Event Viewer** | System log, Security log | Profile creation/modification events; file deletion events | Trace when desktop was modified |
| **OneDrive Folder** | Desktop folder in OneDrive | Are shortcuts synced to cloud? Check version history | Determine if cloud backup available |
| **User's Last Login Time** | Active Directory user properties + Windows Event Log | When did user last log in? Confirm account consistency | Verify same user account |

### Secondary Systems (If Scope is Wide – Next 10 Minutes)

| System | Log/Data | What to Look For | Why |
|--------|----------|------------------|-----|
| **Intune Admin Center** | Device enrollment state, policy assignments | Are Floor 6 devices on a policy that resets desktop? | Identify systemic cause |
| **Group Policy Editor** | Gpresult output | What Group Policies apply to Desktop? Any policy restricts customization? | Identify policy-based removal |
| **Windows 11 Migration Logs** | Migration script output for Floor 6 | Did migration intentionally remove desktop shortcuts? | Understand migration design |
| **File Restore Options** | File History, Shadow Copies, OneDrive Version History | Can user restore shortcuts from backup? | Identify recovery options |

### Advanced Diagnostics (If Still Unclear – 15 Minutes+)

| System | Log/Data | What to Look For | Why |
|--------|----------|------------------|-----|
| **Registry Audit** | HKEY_CURRENT_USER\Software (Intune settings) | Are there Intune policies controlling desktop state? | Identify policy-based control |
| **Application Event Log** | Applications that might manage shortcuts | Did document management app or migration tool remove shortcuts? | Identify app-specific removal |
| **PowerShell Audit** | Any migration or deployment scripts run on device | Did any script contain commands to remove desktop items? | Identify script-based removal |

---

## INVESTIGATION APPROACH

### Phase 1: Verify the Problem (Minutes 0–5)
**Objective:** Confirm shortcuts are actually missing and understand what's missing.

1. **User Interview:**
   - "Show me your desktop right now. Can you describe what you see?"
   - "Were there more shortcuts there before? On Friday? When did you notice they were gone?"
   - "Are ALL your shortcuts gone, or just some specific ones (e.g., Outlook, Word)?"
   - "Have you rebooted since Friday? Logged in with a different account?"

2. **Desktop Audit:**
   - Ask user to open File Explorer
   - Navigate to C:\Users\[username]\Desktop
   - Take screenshot of what's in that folder (files and shortcuts)
   - Count actual files vs. what user says is missing

3. **Classification:**
   - **All shortcuts gone:** Likely profile issue or intentional wipe
   - **Only custom shortcuts gone:** App shortcuts may be in Start Menu; just custom ones removed
   - **Only application shortcuts gone:** May be installed applications; not user-created

### Phase 2: Establish Baseline and Scope (Minutes 5–10)
**Objective:** Determine if this is user-specific or floor-wide issue.

4. **Baseline Comparison:**
   - Ask 2–3 other Floor 6 users: "Show me your desktop (via screenshot on Slack or live walkthrough)"
   - Document what's on their desktop
   - Compare with affected user's desktop

5. **Cross-Floor Check:**
   - Ask IT Ops: "Are other floors reporting missing desktop shortcuts?"
   - If YES → floor-wide Windows 11 migration issue
   - If NO → user-specific issue

6. **Account Verification:**
   - Confirm affected user is on same account/device as Friday
   - Check: Has user account been recreated? (new SID)
   - Verify: Is OneDrive account synced to same Microsoft ID?

### Phase 3: Determine Root Cause (Minutes 10–20)
**Objective:** Identify whether removal was intentional (migration), policy-based (Intune), or accidental (user).

**Branch A: If Windows 11 Migration Is Suspected**
- Pull Windows 11 migration script/documentation
- Look for any commands that:
  - Delete Desktop folder contents
  - Restrict desktop customization
  - Clear user profile cache
- Interview IT Infrastructure: "Did migration intentionally clear desktops?"
- **Action:** If intentional, communicate as expected; if unintended, investigate script

**Branch B: If Intune Policy Is Suspected**
- Collect Intune policy assignments for Floor 6 devices
- Search for policies that:
  - Control desktop customization
  - Restrict file types on desktop
  - Reset user profile on enrollment
- Check: When did policies apply? (Friday? Monday morning?)
- **Action:** Review policy settings; determine if removal is intended

**Branch C: If User Error Is Suspected**
- Ask user: "Did you intentionally clean up your desktop? Delete old shortcuts?"
- Check: Does user have keyboard shortcut or habit of clearing desktop?
- Check: Does user's Windows 10 profile show shortcuts? (compare with backup if available)
- **Action:** If user error, proceed to restoration

**Branch D: If Application Deployment Is Suspected**
- Review Friday's document management app deployment
- Check: Does app have installer script that modifies desktop?
- Check: Does app create or remove shortcuts during installation?
- **Action:** Review app documentation; check app logs

### Phase 4: Recovery and Scope Expansion (Minutes 20–30)
**Objective:** Restore shortcuts if user-specific; investigate if floor-wide.

7. **User-Specific Recovery:**
   - If only one user affected:
     - Offer options: User recreates shortcuts manually, restore from OneDrive backup, restore from file history
     - Provide tech support if needed
     - Estimated remediation time: 15–30 minutes (user self-service)

8. **Floor-Wide Investigation (If Multiple Users):**
   - If multiple Floor 6 users missing shortcuts:
     - Escalate to Windows 11 migration team
     - Investigate migration script for desktop removal logic
     - Plan mass restoration (script-based or GPO-based)
     - Estimated remediation time: 2–4 hours (IT team execution)

---

## RISK ASSESSMENT

### Immediate Risks (0–30 Minutes)
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|-----------|
| **User cannot access frequently-used applications** | MEDIUM | LOW–MEDIUM | User can still access via Start Menu or taskbar pinning |
| **Scope expands to multiple Floor 6 users** | MEDIUM | MEDIUM | May indicate migration flaw requiring systemic fix |
| **Migration script deleted important user files** | LOW | MEDIUM | File recovery from OneDrive backup or restore point |
| **Intune policy is too restrictive** | LOW | MEDIUM | Policy modification or rollback |

### Secondary Risks (30 Minutes – 4 Hours)
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|-----------|
| **User productivity significantly impaired** | LOW | LOW | Workaround available (Start Menu, Taskbar) |
| **User requests professional restoration service** | LOW | LOW | IT provides self-service guide or limited support |
| **Issue affects entire Floor 6 or other floors** | MEDIUM | MEDIUM | Escalate to infrastructure; schedule mass remediation |

---

## IMMEDIATE CONTAINMENT ACTIONS (0–5 Minutes)

### Action 1: Assess Scope Quickly
**Responsible:** Assigned Engineer  
**Timeline:** 09:30–09:35 (can run in parallel with Incidents 1 & 2)  
**Action:**
- Message 5–10 Floor 6 users via Slack: "Quick check – are your desktop shortcuts all there this morning? Or are any missing?"
- Document responses within 5 minutes
- If 1 user says "no" → user-specific (low priority)
- If 3+ users say "no" → systemic (medium priority, escalate)

**Why:** Rapid determination of scope prevents wasted investigation time.

---

### Action 2: Provide Immediate Workaround
**Responsible:** Service Desk  
**Timeline:** 09:35–09:40  
**Action:**
- Provide affected user with quick reference:
  - "Windows Start Menu has all your applications (search or scroll)"
  - "You can right-click desktop → New → Shortcut to create replacements"
  - "OneDrive may have backed up your old shortcuts (check version history)"
  - "We're investigating this issue; you can continue work using Start Menu in the meantime"

**Why:** Unblocks user productivity while investigation continues.

---

### Action 3: Preserve Evidence (If Scope is Wide)
**Responsible:** IT Operations  
**Timeline:** 09:40–09:42 (only if multiple users affected)  
**Action:**
- If floor-wide issue:
  - Collect desktop directory listings from affected devices
  - Preserve Windows Event Logs from affected devices
  - Back up migration script and Intune policy configurations
  - Take screenshots of affected desktops (before any changes)

**Why:** Forensic evidence for post-incident review and prevention of recurrence.

---

### Action 4: Hold Off on Mass Remediation
**Responsible:** IT Infrastructure  
**Timeline:** 09:42–09:44  
**Action:**
- Do NOT attempt to mass-restore shortcuts until root cause is understood
- Prep remediation plan but do not execute:
  - Plan A: User self-service restoration instructions
  - Plan B: Script-based shortcut restoration (if migration removed them)
  - Plan C: Intune policy modification (if policy removing them)

**Why:** Mass action without understanding root cause could worsen situation.

---

## DECISION TREE

```
START: Desktop Shortcuts Missing Report
│
├─→ [STEP 1] Verify Shortcuts Are Actually Missing
│   ├─ User describes what they see on desktop
│   ├─ Check File Explorer: C:\Users\[username]\Desktop
│   └─ Count actual .lnk files vs. what user reports missing
│
├─→ [STEP 2] Is This Floor 6-Specific or User-Specific?
│   ├─ Poll 5–10 other Floor 6 users (quick Slack check)
│   ├─ If 1 user: User-specific → [STEP 3-ISOLATED]
│   └─ If 3+: Floor-wide issue → [STEP 3-SYSTEMIC]
│
├─→ [STEP 3-ISOLATED] Only One User Affected
│   ├─ Check: Is user on same account/device as Friday?
│   ├─ Check: Did user intentionally delete shortcuts?
│   ├─ If user error → Offer self-service restoration options
│   ├─ If account/profile issue → Investigate profile creation
│   └─ RESOLUTION: User-self service or IT-assisted shortcut restoration
│
├─→ [STEP 3-SYSTEMIC] Multiple Users Affected
│   ├─ This indicates a flaw in Windows 11 migration or Intune policy
│   ├─ → [STEP 4-ROOT-CAUSE]
│
├─→ [STEP 4-ROOT-CAUSE] Determine If Intentional or Unintended
│   ├─ Review Windows 11 migration script
│   │  ├─ Does script contain commands to remove Desktop shortcuts?
│   │  ├─ Was removal intentional by migration team?
│   │  └─ If yes → Expected behavior; user self-service restoration OK
│   │  └─ If no → Unintended removal; investigate further
│   │
│   ├─ Review Intune Policy
│   │  ├─ Do any policies control desktop customization?
│   │  ├─ Did policy apply Friday or Monday?
│   │  └─ If yes to restriction → Policy working as designed OR policy too restrictive
│   │
│   ├─ Review Document Management App
│   │  ├─ Does Friday's deployment include desktop removal?
│   │  └─ If yes → App uninstall testing needed
│   │
│   └─ → [STEP 5-REMEDIATION]
│
├─→ [STEP 5-REMEDIATION] Plan Fix
│   ├─ If user-specific (1–2 users)
│   │  └─ ACTION: Provide self-service guide + IT support if needed
│   │
│   ├─ If migration unintended
│   │  └─ ACTION: Provide shortcut restoration script or user instructions
│   │  └─ TEST: Restore on 5 test devices; validate
│   │  └─ EXECUTE: Mass deployment to Floor 6
│   │
│   ├─ If Intune policy too restrictive
│   │  └─ ACTION: Review policy intent with Security/Policy team
│   │  └─ Modify policy (loosen restriction or add exceptions)
│   │
│   └─ If app caused it
│       └─ ACTION: Test app rollback (tied to Incident 2 investigation)
│
└─→ [STEP 6] Validation and Prevention
    ├─ Confirm shortcuts restored for affected users
    ├─ Document root cause in incident record
    ├─ Update Windows 11 migration checklist (if script issue)
    ├─ Schedule post-incident review
    └─ No further action if user-specific and resolved
```

---

## EXECUTIVE UPDATE FOR LEADERSHIP (Pre-Lunch Briefing)

**TO:** IT Operations Lead, Floor 6 Department Head (Legal)  
**FROM:** IT Service Desk  
**DATE:** Monday, 14 August 2026, 09:45  
**SUBJECT:** Floor 6 Desktop Customization Issue – Status Update  
**CONFIDENTIALITY:** Internal Only

---

### SITUATION (What We Know)
At 09:14 this morning, at least one employee on Floor 6 reported that desktop shortcuts have disappeared from their computer. Desktop customizations (quick-access icons) are missing.

**Scope:** Currently one reported case; investigation underway to determine if others are affected.

---

### ROOT CAUSE (Investigation Ongoing)
Three possible causes are being investigated:
1. **Windows 11 migration** may have cleared desktop shortcuts during profile migration
2. **Intune policy** may have reset desktop customization after enrollment
3. **User action** – employee may have inadvertently deleted shortcuts

Initial investigation suggests this is isolated to one user; if true, likely user-specific issue rather than infrastructure problem.

---

### BUSINESS IMPACT: **Minimal**
- ✅ No data loss or security issue
- ✅ User can still access applications via Windows Start Menu and Taskbar
- ✅ Quick workaround available (recreate shortcuts manually)
- ⚠️ Minor productivity inconvenience (extra clicks to open applications)

---

### ACTIONS TAKEN (First 30 Minutes)
1. ✅ **Verified shortcuts are actually missing** – not just off-screen
2. ✅ **Surveyed other Floor 6 users** – initial indication this is isolated
3. ✅ **Provided immediate workaround** – user can continue work via Start Menu
4. ✅ **Escalated to infrastructure team** – Windows 11 migration logs under review

---

### RESOLUTION PLAN
**If isolated to one user:**
- User self-service: Recreate shortcuts manually (15–30 minutes)
- OR IT assistance: Restore from OneDrive backup if available

**If floor-wide issue discovered:**
- Investigate Windows 11 migration script
- Execute mass restoration of shortcuts
- Estimated remediation: 2–4 hours

---

### NEXT STEPS
- Root cause determination by **10:00 AM**
- User provided workaround instructions by **09:50 AM**
- Final resolution by **11:00 AM** (if floor-wide) or **10:00 AM** (if isolated)

---

**Prepared by:** IT Service Desk – DWP Incident Response  
**Distribution:** IT Operations Lead, Floor 6 Department Head
