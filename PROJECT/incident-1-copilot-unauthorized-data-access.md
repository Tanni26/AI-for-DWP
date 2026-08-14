# INCIDENT 1: UNAUTHORIZED DATA ACCESS VIA COPILOT
**Incident ID:** FIN-2026-08-14-001  
**Floor:** 6 (Legal Department)  
**Reporting Time:** 09:14 (Monday)  
**Priority:** CRITICAL – Security/Compliance  
**Severity Level:** SEV-1 (Potential Data Breach)

---

## INCIDENT BREAKDOWN

**What Happened:**
A paralegal on Floor 6 reported that Copilot displayed a client matter that she explicitly states she has never had access to. This represents unauthorized access to potentially privileged legal information.

**Why This Is a Separate Incident:**
- This is a **security and compliance incident**, not a service availability issue
- Involves potential data exposure of confidential client information
- Requires immediate containment regardless of other technical issues
- Has regulatory (likely GDPR, attorney-client privilege) implications
- Suggests possible misalignment between file permissions and access controls
- May indicate configuration error in document management application or Copilot integration

**Why This Is Highest Priority:**
- **Security Risk:** Client matter data in unauthorized hands
- **Compliance Risk:** Legal department data = highest sensitivity classification
- **Scope Unknown:** One reported case could indicate systemic exposure
- **Incident Pattern:** Correlates with Friday's document management deployment (timing suggests causation)
- **Potential Root Causes:**
  - New document management app granted excessive permissions to Copilot
  - User profile migration copied access rights incorrectly
  - Intune policy modification inadvertently opened document shares
  - OneDrive/SharePoint ACLs not applied correctly during migration

---

## PRIORITY ASSESSMENT

| Dimension | Rating | Justification |
|-----------|--------|---------------|
| **Security Risk** | CRITICAL | Unauthorized access to confidential legal information |
| **Business Impact** | CRITICAL | Client confidentiality breach; legal liability; client trust damage |
| **Compliance Risk** | CRITICAL | Attorney-client privilege violation; GDPR data processing breach |
| **Users Affected** | Unknown (1 confirmed, likely more) | Only one user reported so far – unknown if systemic |
| **Urgency** | IMMEDIATE | Containment required within 30 minutes |
| **Reversibility** | Unknown | Depends on what data was exposed and to where |

---

## FACTS vs ASSUMPTIONS vs UNKNOWNS

### VERIFIED FACTS
1. ✅ Paralegal on Floor 6 saw a client matter in Copilot
2. ✅ Paralegal states she has no access rights to this matter
3. ✅ New document management application deployed Friday afternoon
4. ✅ Floor 6 underwent Windows 11 migration (recently)
5. ✅ Floor 6 enrolled in Intune (recently)
6. ✅ Report came via Slack at 09:14 Monday

### CRITICAL ASSUMPTIONS (Must Verify)
- ❓ Assumption: Paralegal actually has no access rights (vs. misremembering)
  - **Verify:** Check actual ACL/permissions on the document in question
  - **Why:** User perception vs. actual permissions could differ

- ❓ Assumption: The document data actually came from Copilot's knowledge base
  - **Verify:** Did Copilot return the full document or snippets? Screenshots needed.
  - **Why:** Copilot might have misidentified or hallucinated content vs. accessing real data

- ❓ Assumption: This is caused by the Friday deployment
  - **Verify:** Timeline correlation with app rollout
  - **Why:** Could be unrelated Windows 11 or Intune issue

- ❓ Assumption: This is isolated to one user
  - **Verify:** Audit logs for Copilot access patterns Friday–Monday
  - **Why:** One report ≠ only instance

### CRITICAL UNKNOWNS
- 🔴 **Identity of the document:** What is the client matter file name/path/ID?
- 🔴 **Copilot access mechanism:** How did Copilot access the document?
  - Is it indexed in SharePoint search?
  - Does Copilot have access to the document management app database?
  - Was it cached from a previous authorized session?
- 🔴 **Who else saw this:** Have other users accessed restricted documents via Copilot?
- 🔴 **Extent of exposure:** What other client matters might be exposed?
- 🔴 **Access logs:** Are Copilot access and document retrieval logged?
- 🔴 **Document management app configuration:** What permissions did Friday's deployment grant?
- 🔴 **User profile state:** Did migration process alter security group membership?
- 🔴 **Intune policies:** Did recent enrollment change document access policies?

---

## FIRST 30-MINUTE TRIAGE PLAN

### TIMELINE: 09:14 – 09:44

| Time | Action | Owner | Output | Why |
|------|--------|-------|--------|-----|
| 09:14–09:16 | **CONTAINMENT ALERT:** Notify Security/Compliance Officer and Legal department leadership | Service Desk Lead | Incident acknowledged | Regulatory requirement; escalation path |
| 09:16–09:18 | **Preserve Evidence:** Ask paralegal NOT to close Copilot session; request screenshot of the exposed content | Assigned Engineer + Paralegal | Screenshot + timestamp | Forensic evidence before Copilot session clears cache |
| 09:18–09:20 | **Quarantine Question:** Is the paralegal's device connected to any external networks or shared remotely? | Assigned Engineer | Device isolation assessment | Determine if data could have exfiltrated beyond company network |
| 09:20–09:22 | **Scope Verification:** Contact 2–3 other Floor 6 users and ask them to test Copilot with non-accessible documents in their respective roles | Assigned Engineer | Results: Can/cannot access restricted docs | Determine if this is user-specific or floor-wide |
| 09:22–09:25 | **Permission Audit:** Query AD/Intune to pull the paralegal's group memberships and SharePoint/document access lists | IT Infrastructure | Permission matrix | Confirm what she should actually have access to |
| 09:25–09:28 | **Log Preservation:** Request IT Operations immediately preserve Copilot access logs, Azure AD audit logs, and document management app logs for Friday 14:00–Monday 09:15 | IT Operations/Security | Log exports queued | Prevent log rotation/deletion |
| 09:28–09:30 | **Document Lookup:** Retrieve the specific document name/ID from the paralegal; query document management system for access ACLs | IT Operations | Document permissions list | Identify which users/services have been granted access |
| 09:30–09:35 | **Initial Hypothesis:** Based on above findings, classify as:  A) User permission error, B) App configuration error, C) Microsoft Copilot plugin issue, D) Data exfiltration risk | Assigned Engineer | Preliminary classification | Drive next 30 minutes of investigation |
| 09:35–09:44 | **Escalation Decision:** If scope is wide or evidence suggests breach, activate Incident Response Team; if isolated, proceed to deeper investigation | Service Desk Lead | IR Activation decision | Security/legal/compliance escalation gate |

---

## EVIDENCE REQUIRED (Before Confirming Root Cause)

### Tier 1 Evidence (Must-Have for Any Resolution)
1. **Document Identity:** Actual file name, path, ID of the "client matter"
2. **Copilot Output Screenshot:** Exact text/content Copilot returned
3. **Timestamp:** When did this occur (Friday during deployment? Over weekend? This morning?)
4. **Paralegal's Current Permissions:** ACL list from document management system
5. **Copilot Access Logs:** Any entry showing access to that document
6. **Azure AD Audit:** Group membership changes for this user during Windows 11 migration

### Tier 2 Evidence (Scope Verification)
7. **Other Floor 6 Users:** Test results from 3–5 other paralegal staff attempting to access similarly restricted docs
8. **Document Management App Audit:** Deployment manifest from Friday afternoon; what permissions were granted?
9. **Intune Enrollment State:** Verify enrollment date; check if device compliance state changed
10. **File Access Logs:** Document management system access log for this file (who accessed it and when)

### Tier 3 Evidence (Root Cause Confirmation)
11. **Copilot Plugin Configuration:** Is there a Microsoft 365 Copilot plugin for the document management app? What's its permission model?
12. **SharePoint Indexing:** Is the document indexed in SharePoint Search? If so, when was indexing last updated?
13. **OneDrive Sync Status:** Is the document synced to anyone's OneDrive? If so, could Copilot be reading from cached local copies?
14. **Microsoft Copilot API Logs:** If accessing via Microsoft APIs, what scopes/permissions are being requested?

---

## SYSTEMS AND LOGS TO CHECK

### Primary Systems (Check First – 5 Minutes)
| System | Log/Data | What to Look For | Why |
|--------|----------|------------------|-----|
| **Azure AD Audit** | Sign-in logs, group membership changes | Floor 6 users' enrollment state; group add/remove events Friday–Monday | Intune/profile migration may have altered group membership |
| **Microsoft 365 Audit Log** | Copilot access events, document access events | Who accessed the document; when; via what service | Determine if Copilot actually retrieved it or user shared info |
| **Document Management App** | Access logs, deployment logs | Who accessed the client matter file; app permission grants | Confirm app has document access; check if permissions misconfigured |
| **Windows Event Logs (Client Device)** | Application log | Copilot session logs, app initialization | Track Copilot activity on the paralegal's device |

### Secondary Systems (If Primary Shows Indication – Next 10 Minutes)
| System | Log/Data | What to Look For | Why |
|--------|----------|------------------|-----|
| **SharePoint Admin Center** | Content access logs, file activity | Access to the specific document; who; when; from what application | Confirm data retrieval pathway |
| **Intune Device Logs** | Device compliance, enrollment state | Policy application to Floor 6 devices; any policy conflicts | Identify if Intune policy caused permission escalation |
| **OneDrive Activity** | File sync logs, access logs | Whether the document is synced; access from Copilot service account | Determine if Copilot reading from local cache |
| **Copilot Service Logs** (Microsoft Support) | Copilot query logs, API calls | Exact query results; data source; timestamp | Confirm what Copilot returned and from where |

### Network/Threat Logs (If Evidence Suggests Exfiltration)
| System | Log/Data | What to Look For | Why |
|--------|----------|------------------|-----|
| **Firewall/Proxy Logs** | Outbound data transfers | Large uploads to external IPs; suspicious external connections | Detect data exfiltration |
| **DLP (Data Loss Prevention)** | Policy violations | Any blocked or flagged transfers of legal documents | Identify attempted data theft |
| **EDR (Endpoint Detection/Response)** | Behavioral anomalies | Unusual file access patterns; clipboard operations; print operations | Detect lateral movement or exfiltration attempts |

---

## INVESTIGATION APPROACH

### Phase 1: Verify the Exposure (Minutes 0–5)
**Objective:** Confirm that unauthorized access actually occurred.

1. **Direct Interview:**
   - Ask paralegal: "Show me exactly what Copilot displayed. Was it the full document or snippets?"
   - Ask: "When did this happen? During work Friday, over weekend, or this morning?"
   - Ask: "Did you copy, share, print, or send this content to anyone?"

2. **Evidence Capture:**
   - Photograph/screenshot the Copilot output
   - Note exact timestamp (if visible)
   - Capture device ID and Copilot session ID (if available)

3. **Document Confirmation:**
   - Retrieve the actual document file from the document management system
   - Verify it matches what Copilot displayed
   - Confirm the paralegal has no role-based access to it

### Phase 2: Determine Scope (Minutes 5–15)
**Objective:** Establish whether this is isolated or systemic.

4. **Rapid Scope Test:**
   - Request 3–4 other Floor 6 users to attempt accessing restricted documents via Copilot
   - Ask: "Does Copilot show you documents you don't normally have access to?"
   - If YES → systemic; escalate immediately
   - If NO → user-specific; investigate further

5. **Parallel Access Audit:**
   - Query Intune device inventory for Floor 6
   - Check if all users have same device configuration
   - Identify if paralegal's device differs (security group, policy version, etc.)

### Phase 3: Identify Root Cause Vector (Minutes 15–25)
**Objective:** Narrow down which system failed.

**Branch A: If Document Management App Deployed Friday**
- Pull deployment manifest from IT Operations
- Check: What services were granted access to documents?
- Check: Were Microsoft 365 permissions modified during rollout?
- Check: Did app install any Copilot plugin or integration?
- **Action:** If yes to any → app misconfiguration likely cause

**Branch B: If Intune Enrollment State Changed**
- Query Intune logs for Floor 6 device enrollment events
- Check: Were device compliance policies applied?
- Check: Did policy modify document access groups?
- **Action:** Query Azure AD group membership before/after Friday

**Branch C: If Windows 11 Migration Altered User Profile**
- Check: Was paralegal's profile migrated or newly created?
- Check: Did migration script include group membership changes?
- Check: Does her new profile belong to different security groups?
- **Action:** Compare profile contents (local groups, cached credentials)

**Branch D: If Copilot Misconfigured or Compromised**
- Check: Is Copilot accessing Microsoft 365 with correct tenant context?
- Check: Are permission scopes being enforced by Copilot?
- **Action:** Contact Microsoft Support for Copilot service logs

### Phase 4: Immediate Containment (Minutes 25–30)
**Objective:** Stop further exposure while investigation continues.

**If Scope Is Wide (Affects Multiple Users):**
- Recommendation: Disable Copilot on Floor 6 devices immediately (GPO/Intune policy)
- Notification: Send message to all Floor 6 staff: "Copilot temporarily disabled for security investigation"
- Escalation: Activate Incident Response Team; notify Legal leadership and Compliance Officer

**If Scope Is Limited (Single User):**
- Recommendation: Isolate paralegal's device from file shares; preserve device state
- Recommendation: Clear Copilot cache on her device
- Action: Disable Copilot on her device pending investigation

---

## RISK ASSESSMENT

### Immediate Risks (0–30 Minutes)
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|-----------|
| **Additional unauthorized access occurs** | HIGH | CRITICAL | Disable Copilot immediately; monitor access logs |
| **User copies/shares exposed data externally** | MEDIUM | CRITICAL | Preserve device; block external network access |
| **Other users unaware they have unauthorized access** | HIGH | CRITICAL | Rapid scope testing; Slack message to Floor 6 |
| **Evidence destroyed during triage** | MEDIUM | HIGH | Preserve logs immediately; place hold on systems |

### Secondary Risks (30 Minutes – 4 Hours)
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|-----------|
| **Client notification required** | MEDIUM | CRITICAL | Legal/Compliance decision; 72-hour GDPR clock starts |
| **Regulatory investigation triggered** | MEDIUM–HIGH | HIGH | Document all investigation steps; preserve chain of custody |
| **Additional unauthorized access discovered** | MEDIUM | CRITICAL | Extend investigation scope; audit all Floor 6 users |
| **Public breach notification required** | LOW (if contained quickly) | CRITICAL | Swift containment critical to avoid media escalation |

### Root Cause Risks (If Not Document Management App)
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|-----------|
| **Intune policy misconfiguration** | MEDIUM | HIGH | Affects all Floor 6 users; wider rollback risk |
| **Windows 11 migration flaw** | MEDIUM | HIGH | May affect other departments; broader investigation |
| **Microsoft Copilot vulnerability** | LOW | CRITICAL | Requires Microsoft security response; customer-wide issue |

---

## IMMEDIATE CONTAINMENT ACTIONS (0–5 Minutes)

### Action 1: Preserve Forensic Evidence
**Responsible:** IT Operations  
**Timeline:** Immediately (before 09:16)  
**Action:**
- Place litigation hold on all logs for Floor 6:
  - Azure AD audit logs (minimum 30 days back, through Monday)
  - Office 365 audit logs (Copilot, document access, all activities)
  - Document management app logs
  - OneDrive activity logs
  - SharePoint access logs
- Preserve the paralegal's device state (no policy pushes, no clearing cache, no reboots)
- Export Copilot session cache from her device before Windows clears it

**Why:** Once logs rotate or cache clears, forensic evidence is lost forever.

---

### Action 2: Notify Leadership and Compliance
**Responsible:** Service Desk Lead  
**Timeline:** 09:14–09:16  
**Action:**
- Slack/call the IT Operations Lead with preliminary finding (5-minute verbal brief)
- Email: Compliance Officer, Legal Department Head, Chief Information Security Officer
- Subject: "[URGENT] Potential Unauthorized Access to Client Matter – Floor 6"
- Message: "We are investigating a report of unauthorized access to confidential client information via Copilot. Immediate containment measures in place. Detailed brief in 20 minutes."

**Why:** Regulatory requirement; establishes incident chain; prevents de-prioritization.

---

### Action 3: Rapid Scope Assessment
**Responsible:** Assigned Engineer  
**Timeline:** 09:16–09:20  
**Action:**
- Call 3–4 other Floor 6 paralegal staff (not in the same team as the reporter)
- Ask: "Have you seen documents in Copilot that you don't normally work with?"
- Ask: "Did Copilot show you anything unusual over the weekend or this morning?"
- Document all responses with timestamps

**Why:** Determines whether to escalate to full incident response team or focused investigation.

---

### Action 4: Device Isolation
**Responsible:** IT Operations  
**Timeline:** 09:20–09:22  
**Action:**
- If scope is wide: Disable Copilot on ALL Floor 6 devices via Intune policy (push immediately)
- If scope is isolated: Isolate paralegal's device:
  - Disconnect from network (keep device on; preserve state)
  - OR move to isolated VLAN with no external network access
  - Notify her that device is undergoing security investigation; provide loaner device

**Why:** Prevents ongoing data exposure; maintains forensic integrity.

---

### Action 5: Block Unsafe Data Flows
**Responsible:** IT Operations + DLP Team  
**Timeline:** 09:22–09:25  
**Action:**
- If document management app is the suspected cause:
  - Disable the app's integration with Microsoft Copilot (if exists)
  - Review and restrict document access ACLs (revert to pre-Friday state if possible)
  - Restart document indexing with corrected permissions
- If Intune policy is the suspected cause:
  - Identify and disable the offending policy
  - Audit which Floor 6 devices received it
  - Prepare policy rollback plan

**Why:** Stops the bleeding while investigation continues.

---

### Action 6: User Communication (Floor 6)
**Responsible:** IT Operations Lead + Legal Leadership  
**Timeline:** 09:25–09:30  
**Action:**
- Send Slack message to Floor 6 channel (approved by Legal leadership):
  - "We are conducting a security investigation on Floor 6 this morning. Copilot may be temporarily unavailable. This is precautionary and does not indicate an active security incident. We will provide updates at [time]. If you see anything unusual, please report it immediately to IT."

**Why:** Prevents panic; encourages reporting of additional anomalies; manages rumor mill.

---

## DECISION TREE

```
START: Copilot Unauthorized Data Access Report
│
├─→ [STEP 1] Can paralegal reproduce the access?
│   ├─ YES → Go to [STEP 2]
│   └─ NO → HYPOTHESIS: User misremembering or hallucinating content
│            ACTION: Still conduct full investigation (Copilot may have cached data)
│
├─→ [STEP 2] Is the document real and does she lack access?
│   ├─ YES → Access was truly unauthorized → Go to [STEP 3]
│   └─ NO → CONCLUSION: User was confused; close as false positive (with investigation note)
│
├─→ [STEP 3] Can 3+ other Floor 6 users access restricted documents?
│   ├─ YES (Systemic) → Go to [STEP 4-SYSTEMIC]
│   └─ NO (Isolated) → Go to [STEP 4-ISOLATED]
│
├─→ [STEP 4-SYSTEMIC] Multiple users have unauthorized access
│   ├─ ACTION: ESCALATE TO INCIDENT RESPONSE TEAM IMMEDIATELY
│   ├─ ACTION: Disable Copilot on all Floor 6 devices NOW
│   ├─ ACTION: Notify CISO, Legal, Compliance, Executive Leadership
│   └─→ [STEP 5-SYSTEMIC] Investigate root cause
│       ├─ Check document management app deployment manifest
│       ├─ Check Intune enrollment policy changes
│       ├─ Check Windows 11 migration scripts
│       └─ If cause unclear → Contact Microsoft support for Copilot logs
│
├─→ [STEP 4-ISOLATED] Only one user (or very few) affected
│   ├─ ACTION: Isolate paralegal's device (preserve state)
│   ├─ ACTION: Disable Copilot on her device
│   └─→ [STEP 5-ISOLATED] Investigate root cause
│       ├─ Check if paralegal's profile/groups differ from peers
│       ├─ Check if her device received different Intune policy
│       ├─ Check if Copilot cache contains previously accessed data
│       ├─ Interview: "Did you interact with this document before Friday?"
│       └─ If no prior access → Investigate Copilot misconfiguration
│
├─→ [STEP 5-AUDIT] Audit other floors and departments
│   ├─ Do Finance, HR, or Operations report similar Copilot issues?
│   ├─ If YES → Broader vulnerability; escalate to Microsoft
│   └─ If NO → Issue likely isolated to Floor 6 or document management app
│
└─→ [STEP 6] Root Cause Identified
    ├─ If document management app → Roll back deployment; remediate ACLs
    ├─ If Intune policy → Roll back policy; audit group membership
    ├─ If Windows 11 migration → Investigate profile/group migration script
    ├─ If Copilot bug → Engage Microsoft; prepare customer advisory
    └─ ACTION: Full audit of all Floor 6 users for additional exposure
```

---

## EXECUTIVE UPDATE FOR LEADERSHIP (Pre-Lunch Briefing)

**TO:** Partners, Executive Leadership, Legal Department Head, CISO  
**FROM:** IT Operations  
**DATE:** Monday, 14 August 2026, 09:45  
**SUBJECT:** Security Incident Update – Floor 6 Access Issue  
**CONFIDENTIALITY:** Internal Only

---

### SITUATION (What We Know)
At 09:14 this morning, we received a report that an employee used Copilot (Microsoft's AI assistant) and was shown a client document they do not have authorization to access. This is a potential security concern that we are treating with high urgency.

**What is Copilot?** Copilot is an AI assistant built into Windows and Microsoft 365 that employees can use to help with their work. When asked a question, it can access documents and information the user has permission to see.

**The Issue:** The employee was shown a confidential client matter document that she should not have been able to access.

---

### ACTIONS TAKEN (First 30 Minutes)
1. ✅ **Immediately notified:** Compliance, Security, and Legal leadership
2. ✅ **Preserved evidence:** Captured the exact content shown and timeline
3. ✅ **Tested scope:** Surveyed other employees to determine if this is widespread
4. ✅ **Secured systems:** Temporarily disabled access as a precaution
5. ✅ **Investigation launched:** IT security team is analyzing logs and access records

---

### CURRENT STATUS
- **Scope:** Investigation ongoing; initial testing suggests this may be limited to a small number of employees
- **Business Impact:** Minimal disruption to Floor 6 operations at this time
- **Security Posture:** Contained and monitoring; additional exposure is unlikely due to immediate actions

---

### WHAT'S NEXT (Next 2–4 Hours)
- Detailed forensic analysis of access logs and system configuration
- Audit of document permissions and application settings
- Root cause determination (whether this stems from document management app configuration, policy changes, or software issue)
- Recommendations to prevent recurrence

---

### RISK LEVEL: **Moderate (Currently Contained)**
- ✅ Access has been restricted while investigation continues
- ✅ No evidence of data exfiltration at this time
- ⚠️ Full scope of exposure still being determined
- ⚠️ May require client notification depending on investigation findings

---

### NEXT BRIEFING
We will provide a comprehensive status update at **12:00 noon** with root cause findings and recommended remediation steps.

**Questions for Leadership:**
- Do we need to notify any clients pending investigation findings?
- Should we pre-draft a communication in case regulatory notification is required?
- Are there any ongoing client matters on Floor 6 that we should flag as sensitive during this investigation?

---

**Prepared by:** IT Service Desk – DWP Incident Response  
**Distribution:** CISO, Legal Department Head, Executive Leadership, Compliance Officer
