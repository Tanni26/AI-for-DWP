# SECURITY INCIDENT ANALYSIS: COPILOT UNAUTHORIZED DATA ACCESS
## FinBridge Case Study – Floor 6, Legal Department

**Incident ID:** FIN-2026-08-14-SEC-001  
**Reported By:** IT Operations Lead (via Slack)  
**Reporting Time:** 09:14, Monday, 14 August 2026  
**Reporting User:** Floor 6 Paralegal (name TBD)  
**Classification:** Security Incident – Unauthorized Access / Potential Data Exposure  
**Initial Severity:** SEV-1 CRITICAL  
**Analysis Date:** 14 August 2026, 09:30

---

## EXECUTIVE SUMMARY

A Floor 6 paralegal reported that Microsoft Copilot displayed a confidential client legal matter that she explicitly states she has never been authorized to access. This report indicates a **control failure in document access permissions** and represents evidence of unauthorized access to confidential data. This is **not** a support ticket, **not** a Copilot product bug, and **not** user confusion. This is a **potential data breach indicator** requiring immediate security investigation, forensic evidence preservation, and compliance review.

---

## WHY THIS IS A SECURITY INCIDENT (Not a Support Ticket)

### 1. **Unauthorized Access Actually Occurred**

**Fact:** A user accessed data without authorization.

The user is not reporting:
- "Copilot doesn't work" ← support issue
- "I need help using Copilot" ← training issue
- "Copilot is slow" ← performance issue

The user is reporting:
- ✅ "Copilot showed me a document I don't have access to"

This is evidence that **your access control boundary has been crossed**. Confidential data left the protection of your permission model and was displayed to an unauthorized party.

**Why this matters:** When a system shows data to someone without permission, that is the definition of unauthorized access. The method (Copilot, browser, mobile app) is irrelevant. The fact that it happened is the incident.

---

### 2. **This Is Confidential Legal Data (Highest Sensitivity)**

**Fact:** The data is described as "a client matter" in the Legal department.

Legal data has the highest sensitivity classification because:
- ✅ **Attorney-client privileged** – May be protected by attorney-client privilege laws
- ✅ **Confidential work product** – Protected by attorney-work-product doctrine
- ✅ **Client confidential** – Breach violates client confidentiality agreements
- ✅ **Regulatory sensitive** – Subject to multiple compliance requirements

**Unauthorized access to this category of data triggers:**
- GDPR breach notification (72-hour assessment clock starts now)
- Attorney ethics rules (potentially bar association report requirement)
- Client notification obligations (depends on data sensitivity and applicable law)
- Potential litigation hold (evidence preservation requirements)

Contrast with: "User saw a company policy document by accident" (low priority support) vs. "User saw a confidential client matter by accident" (SEV-1 security incident).

---

### 3. **This Indicates Systemic Control Failure**

**Assumption to Verify:** This is not an isolated data exposure.

If Copilot can display a confidential document to an unauthorized user, the fundamental question is: **Why does Copilot have access to this document at all?**

Possible answers (all pointing to control failure):
- **Option A:** Copilot's service account has read permissions it shouldn't have
- **Option B:** The document's ACL is misconfigured (grants everyone access)
- **Option C:** Friday's document management app deployment incorrectly elevated permissions
- **Option D:** Intune policy change inadvertently granted permissions
- **Option E:** The user is in a security group she shouldn't be in

**Each of these indicates a systemic problem affecting potentially many users and documents.**

We don't know yet if this is:
- One document exposed to one user (highly concerning but smallest scope)
- One document exposed to many users (larger breach)
- Many documents exposed to one user (broader permission problem)
- Many documents exposed to many users (systemic access control failure)

**Until we investigate, assume scope could be wide.**

---

### 4. **Why This Is NOT a Copilot Product Bug or "AI Weirdness"**

#### Common Misconception: "AI Hallucinated the Data"

**False.** Here's why:

Copilot does not:
- ❌ Make up file names and folder paths
- ❌ Invent confidential business information
- ❌ Generate client names and case details from thin air
- ❌ Hallucinate legal matter descriptions

Copilot does:
- ✅ Query document indexes (SharePoint search, OneDrive, document management app)
- ✅ Retrieve actual files from actual storage
- ✅ Return real content from your company's actual systems

**If Copilot returned a specific, detailed client matter, it retrieved that document from your systems.** The data came from somewhere. Copilot doesn't invent confidential information—only your files contain that.

---

#### Common Misconception: "This Is How Copilot Works"

**False.** This is not expected behavior.

Copilot is designed with permission boundaries. Correct Copilot configuration means:
- Copilot should only retrieve documents the user has permission to access
- Copilot should respect SharePoint/OneDrive ACLs
- Copilot should not bypass your document permission model

If Copilot showed unauthorized documents, that means:
- ✅ Permission boundaries failed (not "how Copilot works")
- ✅ Access controls were circumvented (not expected)
- ✅ Configuration or policy allows unauthorized access (not normal operation)

**Dismissing this as "just how Copilot works" means you stop investigating and miss a real control failure.**

---

#### Common Misconception: "User Must Have Had Access and Forgot"

**Possible but not assumed.** Here's what we need to verify:

User says: "I never had access to this matter."

This could mean:
- ✅ She is correct – she truly has no authorization (most likely reason she's reporting it)
- ⚠️ She forgot she had access – but then why report it as a security concern?
- ⚠️ She is confused about what access level she has – but Copilot showed specific real data, not a hallucination

**We verify this by:**
1. Checking her actual permissions in the document system (ACL)
2. Checking her Azure AD group memberships
3. Checking if she previously accessed this document
4. Checking if anyone else has the same access she has

**Until verified, take the report at face value: She reports unauthorized access, so we investigate unauthorized access.**

---

## INCIDENT SEVERITY CLASSIFICATION

### **Assigned Severity: SEV-1 (CRITICAL)**

| Severity Factor | Assessment | Rating |
|---|---|---|
| **Data Sensitivity** | Confidential client legal matter; attorney-client privileged | CRITICAL |
| **Access Violation** | Unauthorized access to confidential data confirmed | CRITICAL |
| **Compliance Trigger** | GDPR breach notification required; bar association implications | CRITICAL |
| **Scope** | Unknown – could affect 1 user or many users | HIGH (unknown = worst case) |
| **Active Threat** | Ongoing – Copilot may continue showing unauthorized data to other users | HIGH |
| **Evidence Age** | Forensic evidence degrading now (cache clearing, log rotation) | CRITICAL |
| **Business Impact** | Confidentiality breach; client trust damage; legal liability | CRITICAL |

---

### **Justification for SEV-1 Classification**

**Severity is determined by:**
1. **Data sensitivity** – Legal/confidential data = highest category
2. **Verification of breach** – Not suspected, not potential; user reports actual access occurred
3. **Regulatory requirement** – GDPR 72-hour breach assessment is mandatory
4. **Unknown scope** – One reported case could indicate systemic exposure
5. **Evidence at risk** – Every minute delays investigation, evidence ages

**Comparison to other incidents:**
- User can't log in (SEV-2): Blocks one user, no security breach, recoverable by password reset
- Missing shortcuts (SEV-3): Inconvenience, no data breach, easy workaround
- **Copilot showing confidential data (SEV-1): Data exposed, unknown scope, legal trigger, forensics needed**

**SEV-1 incidents demand:**
- ✅ Immediate escalation (not at end of shift)
- ✅ Security team engagement (not support ticket)
- ✅ Forensic evidence preservation (not standard troubleshooting)
- ✅ Leadership notification (not routine communication)
- ✅ 30-minute initial assessment (not "get to it when you can")

---

## FACTS vs. ASSUMPTIONS vs. UNKNOWNS

### **VERIFIED FACTS** ✅

1. **User made a report** – At 09:14 Monday, Floor 6 paralegal reported via IT Ops Lead
2. **User described specific content** – "A client matter" (specific, not vague)
3. **User claims no authorization** – She explicitly states "swears she's never had access"
4. **Data is confidential** – Legal department; client matters are inherently confidential
5. **Copilot is deployed on Floor 6** – Windows 11/Intune deployment includes Copilot
6. **Friday deployment occurred** – Document management app deployed Friday afternoon
7. **User is concerned** – "That one worries me" suggests she recognized this as a problem

### **CRITICAL ASSUMPTIONS** ⚠️ (Must Verify)

- ❓ **Assumption:** User actually has no authorization
  - **Verify:** Check document ACL; check her Azure AD group memberships; check her role-based access
  - **Why:** Her perception of her access ≠ actual system permissions
  - **If false:** May be legitimate access; investigation takes different path

- ❓ **Assumption:** The data Copilot showed is real (not hallucination)
  - **Verify:** Find the actual document in the system; compare content Copilot showed with real document
  - **Why:** If it's real data, someone retrieved it; if hallucination, it's a different issue
  - **If false:** Changes investigation (AI product issue vs. access control issue)

- ❓ **Assumption:** Copilot actually accessed the document (vs. user sharing it with Copilot)
  - **Verify:** Check Copilot session logs; check what query she asked; check document access logs
  - **Why:** User might have asked Copilot "summarize this file I just showed you" (user initiated)
  - **If false:** Changes investigation (user behavior vs. system misconfiguration)

- ❓ **Assumption:** This is caused by Friday's deployment
  - **Verify:** Timeline of when access occurred; when app deployed; when Intune policies applied
  - **Why:** Timing correlation ≠ causation; could be unrelated issue
  - **If false:** Root cause is elsewhere (Intune default behavior, Windows 11 indexing, etc.)

- ❓ **Assumption:** This access is ongoing (not just a one-time incident)
  - **Verify:** Can she access it again now? Can other users access restricted documents via Copilot?
  - **Why:** If ongoing, suggests misconfiguration; if one-time, suggests accidental condition
  - **If false:** May be easier to contain

- ❓ **Assumption:** This is the only document exposed
  - **Verify:** Audit what other documents Copilot can access for this user
  - **Why:** One exposed document could indicate many are exposed (systemic)
  - **If false:** Scope is wider than one document

---

### **CRITICAL UNKNOWNS** 🔴 (Must Determine in First 30 Minutes)

**About the Incident:**
- 🔴 **When did this happen?** Friday during deployment? Over weekend? Monday morning?
- 🔴 **How did she discover it?** Did she ask Copilot about client matters? Or did it appear unprompted?
- 🔴 **What exactly did Copilot show?** Full document? Snippets? File path? Client name and case details?
- 🔴 **Did she take any action?** Copy? Download? Screenshot? Share? Print? Forward?
- 🔴 **How many times did this occur?** Once? Multiple times?

**About the Document:**
- 🔴 **Which document is it?** File name, path, document ID, client name (for audit trail)
- 🔴 **Who is supposed to have access?** What team/role? What client team?
- 🔴 **Where is it stored?** SharePoint? OneDrive? Document management app database? Local file share?
- 🔴 **Is it indexed for search?** Is the document in SharePoint search or document management search index?
- 🔴 **What are the ACLs?** Who currently has read access? Did Friday's app deployment change ACLs?

**About Access Control:**
- 🔴 **What is her actual permission set?** What groups is she in? What role does she have?
- 🔴 **Does her account have the document?** Check OneDrive, SharePoint, shared folders for this document
- 🔴 **Has she previously accessed this document?** Check audit logs for her account
- 🔴 **Is this a team document she shouldn't see?** Is it in a shared folder for a different team?

**About Copilot Configuration:**
- 🔴 **What scopes does Copilot use?** Does Copilot query all SharePoint? All OneDrive? Document management app?
- 🔴 **What service account runs Copilot?** What permissions does that service account have?
- 🔴 **Are there permission filters in Copilot?** Does Copilot restrict results based on user permissions? Or show all indexed documents?
- 🔴 **Is Copilot properly configured for your environment?** Did Friday's app integration enable unrestricted indexing?

**About Scope:**
- 🔴 **Can other Floor 6 users access restricted documents?** Test with 3–5 other paralegal staff
- 🔴 **Is this specific to Copilot, or is it also in regular SharePoint search?** Can she find the same document in SharePoint search without Copilot?
- 🔴 **Is this user-specific or floor-wide issue?** Do other users see documents they shouldn't?
- 🔴 **Does this affect other departments?** Do Finance/HR/Operations users also see unauthorized documents?

**About Friday's Deployment:**
- 🔴 **What is the document management app?** What does it do? What does it install?
- 🔴 **Did it change permission settings?** Deployment manifest should list all changes made
- 🔴 **Does it have Copilot integration?** Did Friday's app enable a new Copilot plugin?
- 🔴 **Did it grant service account permissions?** Did app installation add permissions to a service account?
- 🔴 **What changed on Floor 6 devices?** Registry changes? Intune policy changes? File permissions?

---

## IMMEDIATE EVIDENCE COLLECTION (0–5 Minutes)

### **Tier 1: Preserve Before Anything Else**

#### On User's Device (Paralegal's Laptop)
- **Copilot chat/session history** – Screenshot or log capture of the conversation where she saw the document
  - Do NOT ask user to recreate it; capture what's currently visible
  - Preserve exact timestamp
- **Copilot cache files** – Before device restarts or cache clears
  - Location: `C:\Users\[username]\AppData\Local\CopilotCache` or similar
  - Preserve entire cache directory (do not analyze, just backup)
- **Device Event Viewer logs** – Preserve before system logs rotate
  - Applications log (last 24 hours)
  - System log (last 24 hours)
  - Security log (last 24 hours)
- **OneDrive sync logs** – If OneDrive is syncing this document
  - Sync history for this document
  - Local sync folder (if document synced locally)

#### Copilot Service Logs (Microsoft 365)
- **Copilot access logs** – Request from Microsoft Support immediately
  - Query logs (what user asked)
  - Result logs (what Copilot returned)
  - Document access logs (what file was accessed, when, from where)
- **Copilot service configuration** – Capture current state
  - Copilot permissions within your tenant
  - Service account used by Copilot
  - Scope of document indexing (what's included?)

#### Document Access Logs
- **SharePoint Audit Log** – For the specific document
  - Who has accessed it?
  - When?
  - Via what method (Copilot, search, direct access)?
  - Who currently has permissions?
- **OneDrive Audit Log** – If document is in OneDrive
  - Access history
  - Sync history
  - Share history
- **Document Management App Logs** – If document is in the new app
  - Access logs from Friday to present
  - Who accessed the document?
  - Permission change logs (did Friday's deployment change ACLs?)

#### Permission Snapshots (Before Any Changes)
- **Current ACL on the document** – Exact permissions as of 09:14 Monday
  - Owner
  - All users/groups with access
  - Permission level (read, edit, manage)
  - Inherited vs. explicit permissions
- **User's Azure AD group membership** – As of 09:14 Monday
  - All groups she belongs to
  - When each group was assigned
  - Role-based access control (RBAC) assignments
- **User's document access list** – What documents does she have permission to access?
  - By system (SharePoint, OneDrive, shared folders, document management app)

#### Intune Configuration (Friday's State)
- **Device policy state for Floor 6 devices** – As deployed
  - Copilot settings/restrictions
  - Document access policies
  - Any policies that changed Friday
- **Document Management App manifest** – From Friday's deployment
  - What was installed
  - What permissions were granted
  - What services/accounts were created

---

### **Tier 2: Preserve Within 30 Minutes (Forensic Investigation)**

- User device full forensic image (before any restarts or updates)
- Full Copilot tenant configuration export
- Azure AD sign-in logs for this user and Copilot service account (Friday to Monday)
- All document management app installation logs
- Intune device enrollment logs for Floor 6
- Network firewall/proxy logs for user device (look for exfiltration attempts)

---

### **Tier 3: Preserve for Compliance (Chain of Custody)**

- Investigation timeline documentation
- Screenshots of all findings
- Email trails of investigation decisions
- Signed evidence collection records
- Investigator notes (time-stamped, signed)

---

## PERMISSION, MICROSOFT 365, SHAREPOINT, TEAMS, AND DOCUMENT MANAGEMENT CHECKS

### **PERMISSION CHECKS** (Azure AD & IAM)

| Check | What to Look For | Why | Timeline |
|---|---|---|---|
| **User's Azure AD Group Membership** | What groups is she member of? When were groups assigned? Are there unexpected groups? | Groups determine file access. Unauthorized group membership = unauthorized file access. | 0–5 min |
| **Role-Based Access Control (RBAC)** | What role does she have? (Paralegal, Associate, Senior Partner, etc.) | Role determines what documents she should access by job function. | 0–5 min |
| **Service Accounts** | What service accounts have access to this document? Does Copilot service account have excessive permissions? | Copilot uses a service account to read documents. If service account is over-privileged, all Copilot users see everything. | 5–15 min |
| **Delegation & Sharing** | Has anyone shared this document with her account? (Direct share, shared folder, shared mailbox) | User might have received access through sharing, not direct permission. | 5–15 min |
| **Permission Change History** | Did her permissions change Friday? Did Intune policy grant new permissions? | Friday deployment might have inadvertently added her to an access group. | 10–20 min |
| **Inherited Permissions** | Is she getting access through folder inheritance? (Permissions on parent folder applied to this document) | Documents in shared folders inherit folder permissions. If folder permissions are wrong, all docs in folder are accessible. | 10–20 min |

---

### **SHAREPOINT CHECKS** (If Document Stored in SharePoint)

| Check | What to Look For | Why | Timeline |
|---|---|---|---|
| **Document Library Permissions** | Who has access to the document library? Is it site-wide, team-wide, or restricted? | Over-permissioned library = all documents visible to unintended users. | 5–10 min |
| **Site Permissions** | Who can access the SharePoint site? Are all Floor 6 users members of this site? | Site access grants visibility of all documents on that site. | 5–10 min |
| **Sharing Settings** | Is the document shared externally? Can anyone with link access view it? | Overly permissive sharing settings = wider audience than intended. | 5–10 min |
| **Search Indexing** | Is the document indexed in SharePoint search? What metadata is indexed? | If indexed, Copilot can find it via search even if file permissions are correct. | 5–10 min |
| **Search Query Results** | Can she find this document in SharePoint search? Try the exact document name. | If she can find it in search, that's the pathway Copilot used. | 5–10 min |
| **Audit Logs** | When was the document accessed? By whom? Via what method (Copilot, search, direct link)? | Audit trail shows access pattern: was it Copilot? User search? Direct URL? | 10–20 min |
| **Permission Inheritance Chain** | Trace permission inheritance: Site → Library → Folder → Document | Identify where over-permissioning occurred. | 15–30 min |

---

### **MICROSOFT 365 CHECKS** (Azure AD & M365 Tenant)

| Check | What to Look For | Why | Timeline |
|---|---|---|---|
| **Copilot Permissions in Tenant** | What scopes is Copilot allowed to search? All SharePoint? All OneDrive? Document management app? | Copilot's search scope determines what it can access. Unrestricted scope = sees everything. | 5–10 min |
| **M365 Search Configuration** | What's indexed in Microsoft Search? Which SharePoint sites? Which OneDrive folders? | If not indexed, Copilot can't see it. If indexed with no filter, Copilot sees all. | 5–10 min |
| **Azure AD Audit Logs** | Sign-in logs for this user, Copilot service account, and document management app service account | Look for: When did she sign in? When did Copilot access document? Any suspicious patterns? | 10–20 min |
| **M365 Audit Log (Office 365)** | Document access events, Copilot events, search events for this user and service accounts | Detailed record of: Document viewed, viewed by whom, via what app, when | 10–20 min |
| **Copilot Service Account Permissions** | What is the service account? What can it do? Can it read all SharePoint? All OneDrive? | If Copilot's service account can read everything, then Copilot shows everything to all users. | 10–20 min |
| **Conditional Access Policies** | Are there conditional access policies restricting search/Copilot? Are they configured correctly? | Policies should restrict Copilot results to user-accessible documents only. | 15–30 min |
| **Information Barriers (IB)** | Are information barriers configured to prevent cross-team access? Is this document protected by IB? | Information barriers should prevent paralegals from accessing documents from other clients. | 15–30 min |

---

### **TEAMS CHECKS** (If Document is in Teams)

| Check | What to Look For | Why | Timeline |
|---|---|---|---|
| **Team Membership** | Is she a member of the Team where this document is stored? What is her membership date? | Team members can see all documents in the Team channel. | 5–10 min |
| **Channel Permissions** | What are the channel's permission settings? Standard channel or private? | Private channels restrict access; public channels don't. | 5–10 min |
| **Guest Access** | Are external users or guests added to the Team? | Guests shouldn't see confidential client documents. | 5–10 min |
| **Shared Channel Access** | Is this a shared channel? With whom is it shared? | Shared channels extend access beyond team members. | 5–10 min |
| **Message/File Search in Teams** | Can she find this document via Teams search? Try searching for it. | If Copilot integrates with Teams search, this is a potential pathway. | 5–10 min |
| **Copilot for Teams Configuration** | Is Copilot enabled in Teams? What documents can it access? | Copilot for Teams can search Teams files and messages. | 10–20 min |

---

### **DOCUMENT MANAGEMENT APP CHECKS** (Friday's Deployment)

| Check | What to Look For | Why | Timeline |
|---|---|---|---|
| **App Installation Manifest** | What did the app install on Friday? What services/accounts created? What permissions granted? | Manifest shows everything the app changed on devices and in cloud. | 5–10 min |
| **App Database Permissions** | Does the app have a database? Who can query it? Can Copilot access it? | If app exposes data without permission filters, Copilot might see all documents. | 5–10 min |
| **ACL Changes on Friday** | Did Friday's app deployment change document ACLs? Add users/groups to file permissions? | Many app deployments reset permissions as part of installation. | 10–20 min |
| **Copilot Plugin Integration** | Did Friday's app install a Copilot plugin or integration? Is Copilot configured to search the app? | If app is searchable via Copilot, what's its permission model? | 10–20 min |
| **App Service Account** | What service account does the app run as? What permissions does it have? | App service account permissions determine what app can access and expose. | 10–20 min |
| **Document Indexing Configuration** | Does the app index documents for search? Without user permission filters? | App might expose documents in search without checking user's access. | 15–30 min |
| **Installation Logs** | What errors/warnings occurred during installation? Any permission grants that failed? | Installation logs show what succeeded and what problems occurred. | 15–30 min |
| **Access Control Lists (ACLs) in App** | Does the app have its own permission system? Does it respect Windows ACLs? | If app ignores Windows permissions, everyone in app has same access. | 15–30 min |

---

## IMMEDIATE CONTAINMENT ACTIONS

### **Action 1: Preserve Forensic Evidence** (0–2 Minutes)

**Responsible:** IT Operations / Incident Response  
**Execution:** Immediate (before any other action)

**Actions:**
1. Place **forensic hold** on all systems:
   - User's device (no restarts, no updates, no Copilot cache clear)
   - Copilot tenant configuration (preserve current state)
   - Document access audit logs (prevent rotation/deletion)
   - All Intune policies (prevent changes)

2. **Capture current state** of:
   - Document ACLs (screenshot/export)
   - User's Azure AD groups (export list)
   - Copilot service configuration (export)
   - Document management app configuration (export)

3. **Request preservation** from Microsoft:
   - Copilot service logs for this user (Friday to Monday)
   - Copilot access logs for this specific document
   - M365 audit logs for these accounts (Friday to Monday)

**Why:** Evidence degrades rapidly. Copilot cache clears on restart. Logs rotate after 90 days. ACLs can be changed. Need baseline before anything changes.

---

### **Action 2: Isolate Affected Device** (2–3 Minutes)

**Responsible:** IT Operations / Security  
**Execution:** Immediately after evidence preservation

**Actions:**
1. **Restrict device access:**
   - Move device to isolated VLAN (no external network access)
   - OR disconnect from network entirely (if Copilot session still active; preserve cache)
   - Keep device powered on (do not restart or sleep)

2. **Notify user:**
   - "We are conducting a security investigation on your device. Please stop work and do not restart or update anything. We will provide a loaner device if needed. This is precautionary."

3. **Provide alternative:**
   - Offer loaner device or remote access to unaffected PC
   - Allow user to continue work on loaner while investigation proceeds

**Why:** Device is forensic evidence. Restarts destroy cache. Network isolation prevents Copilot session from clearing. Keeps evidence intact.

---

### **Action 3: Disable Copilot on Floor 6 (If Scope Is Wide)** (3–5 Minutes)

**Responsible:** IT Operations / Intune  
**Execution:** Only if investigation suggests systemic issue (see Decision Tree)

**Actions:**
1. **Check scope first** (parallel to other actions):
   - Poll 3–5 other Floor 6 users: "Can Copilot access documents you don't work with?"
   - If YES (multiple users affected) → disable Copilot
   - If NO (isolated case) → do not disable globally

2. **If disabling:**
   - Push Intune policy to disable Copilot on Floor 6 devices
   - Message to Floor 6: "Copilot temporarily disabled for security investigation. This is precautionary. More info at [time]."
   - Preserve policy state before disabling (for investigation)

3. **If not disabling:**
   - Monitor for additional reports
   - Prepare rollback plan in case scope expands

**Why:** Prevents ongoing unauthorized access if systemic. But don't disable globally without evidence (impacts productivity). Preserve evidence of what was configured before disabling.

---

### **Action 4: Disable Document Management App (Contingency)** (5–10 Minutes)

**Responsible:** Application Team  
**Execution:** Only if Friday's app is strongly suspected

**Actions:**
1. **Do NOT uninstall yet** – but prepare to do so
2. **If app is suspected cause:**
   - Temporarily disable app via Intune policy (rather than uninstall)
   - Test: Can she still access document via Copilot after app disabled?
   - If access is gone → app was the cause (prepare rollback)
   - If access persists → app is not the cause (investigate other paths)

3. **Do NOT mass-disable** without first test
   - Test on 1–2 devices only
   - Confirm it stops the unauthorized access
   - Then decide on broader action

**Why:** App might be the cause, but verify first. Disabling without verification wastes investigation time. Test first = faster determination.

---

### **Action 5: Escalate to Security & Compliance Immediately** (2 Minutes)

**Responsible:** Service Desk Lead / Incident Response Manager  
**Execution:** Immediately (in parallel with other actions)

**Escalation Targets:**
- Chief Information Security Officer (CISO)
- Compliance Officer / Data Protection Officer
- Legal Department Head
- Incident Response Team Lead

**Escalation Content:**
- What happened (unauthorized access to confidential legal document via Copilot)
- When it happened (Friday afternoon or Monday morning – TBD)
- What was accessed (confidential client matter – specific file TBD)
- Current status (device isolated, evidence preserved, investigation started)
- What we need (forensic investigation, compliance breach assessment, legal review)
- Timeline (first update at 10:00, full brief at 11:00)

**Why:** This is not a support ticket. Security team must engage immediately. Compliance clock is ticking (72-hour requirement).

---

### **Action 6: Do NOT Communicate with General Staff** (First 60 Minutes)

**Responsible:** All Incident Response Team  
**Execution:** Maintain operational security

**DO NOT:**
- ❌ Send message to Floor 6 saying "security issue on Copilot"
- ❌ Post in Slack asking everyone to check Copilot
- ❌ Tell users not to use Copilot (without investigation)
- ❌ Share details of the incident with unaffected users

**WHY:** Premature communication could:
- Trigger evidence destruction (users clearing caches, deleting files)
- Accelerate data exfiltration (if breach, users might copy data before access is blocked)
- Start rumors / panic
- Compromise investigation

**DO:**
- ✅ Keep incident knowledge to Security / Compliance / Legal / IR team
- ✅ Keep operations normal (don't raise alarms)
- ✅ Prepare communication only after investigation determines scope

---

## DECISION TREE FOR INITIAL 30-MINUTE INVESTIGATION

```
START: 09:14 – Copilot Unauthorized Access Report Received
│
├─→ [00:00–00:02] PRESERVE EVIDENCE
│   ├─ Place forensic hold on all systems
│   ├─ Export document ACLs, user groups, Copilot config
│   └─ Request Microsoft preserve Copilot logs
│
├─→ [00:02–00:05] ISOLATE AFFECTED DEVICE
│   ├─ Move device to isolated VLAN or disconnect
│   ├─ Do NOT restart device (preserve Copilot cache)
│   └─ Provide loaner device to user
│
├─→ [00:05–00:10] VERIFY UNAUTHORIZED ACCESS (Are We Sure?)
│   ├─ QUESTION: Does user actually have no access?
│   │  ├─ YES → Access was truly unauthorized → [NEXT]
│   │  └─ NO → User may have had access → Adjust investigation
│   │
│   ├─ QUESTION: Is document real (not Copilot hallucination)?
│   │  ├─ YES → Document found in system; Copilot retrieved real data → [NEXT]
│   │  └─ NO → Copilot error; different investigation path
│   │
│   └─ QUESTION: Did Copilot actually show this or did user share it?
│       ├─ YES (Copilot accessed it) → Access control failure → [NEXT]
│       └─ NO (user shared with Copilot) → User behavior issue, not system issue
│
├─→ [00:10–00:20] DETERMINE SCOPE (Is This Just Her or System-Wide?)
│   ├─ RAPID SCOPE TEST: Ask 3–5 other Floor 6 paralegal staff
│   │  ├─ QUESTION: Can you access documents you don't work on via Copilot?
│   │  ├─ 0 YES (only reported user) → [ISOLATED-CASE]
│   │  ├─ 1–2 YES → [MEDIUM-SCOPE]
│   │  └─ 3+ YES → [SYSTEMIC-BREACH]
│   │
│   ├─→ [ISOLATED-CASE] Only this one user affected
│   │  ├─ Check: Is her account/device different from peers?
│   │  ├─ Check: Is her group membership different?
│   │  ├─ Check: Was she recently added to a client access group?
│   │  └─ LIKELY CAUSE: User-specific permission misconfiguration
│   │      (e.g., accidentally added to the wrong security group)
│   │
│   ├─→ [MEDIUM-SCOPE] A few users affected (2–4 users)
│   │  ├─ Check: Do they all have same role? Same device? Same group?
│   │  ├─ Check: Did Friday's app deployment affect a specific user subset?
│   │  └─ LIKELY CAUSE: App or policy affected a specific group/role
│   │
│   └─→ [SYSTEMIC-BREACH] Many users affected (5+)
│       ├─ ACTION: ESCALATE TO INCIDENT RESPONSE IMMEDIATELY
│       ├─ ACTION: Disable Copilot on Floor 6 NOW
│       └─ LIKELY CAUSE: Document management app, Intune policy, or Copilot config issue
│
├─→ [00:15–00:25] IDENTIFY ROOT CAUSE (What Broke?)
│   ├─→ [IF ISOLATED-CASE]
│   │  ├─ BRANCH A: User's Azure AD groups
│   │  │  ├─ Check: What groups is she in?
│   │  │  ├─ Check: Were groups changed Friday?
│   │  │  └─ ACTION: If wrong group added → Remove group; verify access revoked
│   │  │
│   │  ├─ BRANCH B: Document ACL
│   │  │  ├─ Check: Does document have "Everyone" or "Floor 6" grant?
│   │  │  ├─ Check: Did Friday's app deployment change this?
│   │  │  └─ ACTION: If ACL misconfigured → Fix ACL; verify access revoked
│   │  │
│   │  └─ BRANCH C: Copilot Configuration (Less Likely for Isolated Case)
│   │     ├─ Check: Does Copilot have permission filters?
│   │     └─ ACTION: If Copilot misconfigured → Fix config; verify access revoked
│   │
│   ├─→ [IF SYSTEMIC-BREACH]
│   │  ├─ BRANCH 1: Document Management App (HIGH PROBABILITY)
│   │  │  ├─ Check: What was installed Friday? What changed?
│   │  │  ├─ Check: Does app have Copilot integration?
│   │  │  ├─ Check: Did app deployment grant excessive permissions?
│   │  │  └─ ACTION: Prepare app rollback; test on small group first
│   │  │
│   │  ├─ BRANCH 2: Intune Policy Change (MEDIUM PROBABILITY)
│   │  │  ├─ Check: What policy was applied to Floor 6 Friday?
│   │  │  ├─ Check: Did policy grant Copilot broad permissions?
│   │  │  ├─ Check: Did policy change user group memberships?
│   │  │  └─ ACTION: Prepare policy rollback; test on small group first
│   │  │
│   │  ├─ BRANCH 3: Copilot Indexing/Configuration (LOWER PROBABILITY)
│   │  │  ├─ Check: What is Copilot's search scope?
│   │  │  ├─ Check: Are there permission filters in Copilot config?
│   │  │  └─ ACTION: If Copilot misconfigured → Fix config; add user permission filters
│   │  │
│   │  └─ BRANCH 4: SharePoint Search Indexing (MEDIUM PROBABILITY)
│   │     ├─ Check: Is document indexed in SharePoint search?
│   │     ├─ Check: Does Copilot query this index without permission filters?
│   │     └─ ACTION: If indexed incorrectly → Remove from index; add permission filters
│   │
│   └─→ [IF MEDIUM-SCOPE]
│       ├─ Root cause is likely between isolated and systemic
│       ├─ Check both user-specific AND system-wide factors
│       └─ Investigation proceeds as hybrid of above paths
│
├─→ [00:25–00:30] ESCALATION DECISION
│   ├─ IF ISOLATED: Engage compliance + legal (for breach assessment) + fix user permissions
│   ├─ IF MEDIUM/SYSTEMIC: Activate Incident Response Team + disable Copilot + assess breach scope
│   └─ DECISION: Is this a reportable data breach? Does client need notification?
│       ├─ If YES → Compliance + Legal make formal breach determination
│       └─ If NO → Continue investigation under standard incident procedure
│
└─→ [00:30] FIRST BRIEFING COMPLETE
    ├─ Scope determined (isolated, medium, or systemic)
    ├─ Root cause hypothesis identified
    ├─ Containment actions in progress
    ├─ Next 60-minute plan defined
    └─ Leadership briefing ready at 10:00
```

---

## TWO-SENTENCE ESCALATION TO SECURITY OPERATIONS

---

**SECURITY INCIDENT ESCALATION – COPILOT UNAUTHORIZED ACCESS**

**TO:** Chief Information Security Officer, Compliance Officer, Legal Department Head, Incident Response Team  
**FROM:** IT Service Desk  
**DATE:** Monday, 14 August 2026, 09:14  
**CLASSIFICATION:** SEV-1 CRITICAL – Data Breach Indicator  
**ACTION REQUIRED:** Immediate Investigation

---

### Escalation Notice

> **A Floor 6 paralegal reports that Microsoft Copilot displayed a confidential client legal matter she has no authorization to access, indicating a control failure in document access permissions and requiring immediate forensic investigation to determine whether this is an isolated permission error or systemic access control breach affecting other users and documents.**

> **Incident Response must immediately preserve Copilot session cache, audit logs (M365/Copilot/document management app), document ACLs, and user permissions; simultaneously contact Microsoft for Copilot service logs; conduct parallel scope testing with 3–5 other Floor 6 users to determine if access failure is systemic; and brief CISO/Compliance within 30 minutes with root cause hypothesis and preliminary breach notification assessment.**

---

### Supporting Detail Packet

**Incident Summary:**
- **Time of Report:** 09:14, Monday, 14 August 2026
- **Reported By:** Floor 6 Paralegal (via IT Operations Lead)
- **Data Accessed:** Confidential client legal matter (specific document TBD)
- **Access Method:** Microsoft Copilot
- **Sensitivity:** Highest – Attorney-client privileged, confidential work product
- **Initial Scope:** At least 1 user; unknown if systemic

**Regulatory Trigger:**
- ✅ GDPR breach notification (72-hour assessment clock now active)
- ✅ Attorney-client privilege violation (bar association reporting potential)
- ✅ Client confidentiality breach (possible client notification required)

**Investigation Status:**
- ✅ Device isolated (forensic evidence preserved)
- ✅ Copilot logs requested from Microsoft
- ✅ Evidence placed on hold (ACLs, audit logs, service configurations)
- ⏳ Scope testing in progress (other Floor 6 users)
- ⏳ Root cause hypothesis pending (App/Policy/Config/ACL)

**Escalation Justification:**
- **Not a support ticket:** This is evidence of unauthorized access to confidential data
- **Not "AI weirdness":** Copilot retrieved real document from company systems, not hallucination
- **Not user error:** User correctly reported a security control failure
- **Requires security investigation:** Not troubleshooting; requires forensics and compliance review
- **Evidence degrading:** Copilot cache, logs, and configurations must be preserved now

**Next Steps:**
1. ✅ Preserve evidence (0–5 minutes) – IN PROGRESS
2. ✅ Isolate device (2–5 minutes) – IN PROGRESS
3. ⏳ Determine scope (10–20 minutes) – PENDING
4. ⏳ Identify root cause (20–30 minutes) – PENDING
5. ⏳ Brief leadership (by 10:00) – PENDING

**First Briefing:** 10:00 AM (scope determination + root cause hypothesis)

---

## SUMMARY

**This is a security incident, not a support ticket.**

- ✅ Unauthorized access to confidential data actually occurred
- ✅ Control failure indicated (document should not have been accessible)
- ✅ Regulatory requirement triggered (GDPR 72-hour breach assessment)
- ✅ Investigation must begin immediately (evidence preservation required)
- ✅ Security team must lead (forensics + compliance + legal)
- ✅ Service Desk role is escalation + evidence preservation only

**Severity is SEV-1 CRITICAL** due to:
1. Confidentiality of data (legal/client matters = highest sensitivity)
2. Verification of breach (user reports actual unauthorized access, not suspected)
3. Unknown scope (one report could indicate systemic issue)
4. Evidence at risk (forensic evidence degrades rapidly)

**Do not:**
- ❌ Close as "user confusion" or "AI hallucination"
- ❌ Treat as routine support issue
- ❌ Restart device or clear cache
- ❌ Investigate alone in Service Desk
- ❌ Delay escalation for "confirmation"

**Escalate immediately to Security + Compliance + Legal.**
