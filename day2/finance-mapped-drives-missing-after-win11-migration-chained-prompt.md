# Finance Mapped Drives Missing After Win11 Migration - Chained Prompt

## Source Ticket
After Win11 migration, a Finance user's mapped drives (S: and P:) are missing every morning and must be remapped by hand. Logon script exists but seems not to run reliably post-upgrade.

## Chained Prompt

### Step 1 - Triage Summary
You are a DWP service-desk analyst writing structured triage summaries.
For the ticket below produce: Summary; Impact; Known facts; Missing info to gather; Likely category; First diagnostic step.
Do not invent facts - mark anything uncertain as "to confirm".
Return only the triage summary.

Ticket:
After Win11 migration, a Finance user's mapped drives (S: and P:) are missing every morning and must be remapped by hand. Logon script exists but seems not to run reliably post-upgrade.

### Step 2 - Ranked Fixes
Based on the triage summary you just produced, give a ranked list of likely fixes for the missing mapped drives, most probable first.
For each fix give:
- why it is likely, given what we know
- the specific check to confirm it is the right fix
- action to take if confirmed
Do not write scripts yet. Mark anything uncertain as "to confirm".

### Step 3 - Closure Note
The issue is now resolved.
Fix used: Ensure mapping runs only after network is ready at sign-in worked; policy behavior was modified to wait for network and processes. User confirmed working.

Using the triage summary and fix steps as context, write a closure note in this structure:
Resolved. Cause: {cause}. Action: {action taken}. Preventive: {preventive step}. User confirmed working.
Return only the closure note.

## Closure Note Output
Resolved. Cause: Post-Win11 sign-in timing caused mapped drive processing to occur before network/domain connectivity was fully ready, so S: and P: were not consistently mapped at morning logon. Action: Updated policy behavior to wait for network and complete logon processing synchronously before drive mapping execution at sign-in. Preventive: Standardize this network-wait/synchronous logon policy for the relevant Win11 user/device scope and monitor morning logon mapping success. User confirmed working.
