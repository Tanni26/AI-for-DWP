# Root Cause Analysis — Microsoft Outlook Repeated Crash
**Reference:** INC-2024-0315-OUTLOOK-001  
**Date of Incident:** 2024-03-15  
**Prepared by:** DWP Analyst  
**Status:** Closed pending confirmatory remediation  

---

## 1. Incident Summary

| Field | Detail |
|---|---|
| Affected Application | Microsoft Outlook (`OUTLOOK.EXE`) |
| Affected Version | 16.0.17126.20132 |
| First Recorded Crash | 09:14:22 |
| Second Recorded Crash | 09:17:45 |
| WER Record Logged | 09:18:01 |
| .NET Runtime Record Logged | 09:18:05 |
| Impact | Outlook repeatedly terminated and could not remain open reliably |
| User Impact Window | At least 3 minutes 43 seconds based on supplied events |

---

## 2. Event ID Reference

| Event ID | Source | What it records |
|---|---|---|
| **1000** | Application Error | A process crashed. Records the faulting application, faulting module, exception code, offset, process ID, and file paths. This is the primary evidence that `OUTLOOK.EXE` terminated unexpectedly. |
| **1001** | Windows Error Reporting | Windows Error Reporting created a crash report for the failure. Records the event name such as `APPCRASH`, fault bucket, and reporting metadata used to group similar crashes. This is supporting evidence, not the crash itself. |
| **1026** | .NET Runtime | A .NET application or .NET component inside a process terminated due to an unhandled managed exception. In this case it records `System.AccessViolationException`, showing the Outlook process ended because invalid memory access was not handled. |

---

## 3. Event Log Evidence

| Time | Event ID | Description |
|---|---|---|
| 09:14:22 | 1000 | `OUTLOOK.EXE` crashed in `KERNELBASE.dll` with exception code `0xc0000005` and fault offset `0x000000000003a4b2`. |
| 09:17:45 | 1000 | `OUTLOOK.EXE` crashed again in `KERNELBASE.dll` with the same exception code `0xc0000005` and same fault offset `0x000000000003a4b2`. |
| 09:18:01 | 1001 | Windows Error Reporting logged `APPCRASH` with fault bucket `1847362910`, confirming Windows grouped the Outlook failure as an application crash. |
| 09:18:05 | 1026 | .NET Runtime logged that `OUTLOOK.EXE` was terminated due to an unhandled `System.AccessViolationException`. |

---

## 4. Sequence of Events — Plain English

1. Outlook started at 09:13:44 based on the first `1000` event's process start time.
2. Less than a minute later, at 09:14:22, Outlook crashed. Windows recorded this as Application Error `1000` and noted an access violation (`0xc0000005`) while the process was inside `KERNELBASE.dll`.
3. The user or an automated restart action opened Outlook again.
4. At 09:17:45, Outlook crashed a second time in the same way, with the same exception code and the same fault offset. That repetition shows this was not a random one-off termination.
5. At 09:18:01, Windows Error Reporting logged Event `1001`, classifying the incident as `APPCRASH` and generating a crash bucket for Microsoft or local diagnostics.
6. At 09:18:05, `.NET Runtime` Event `1026` recorded that the Outlook process terminated because of an unhandled `System.AccessViolationException`.
7. Taken together, the logs show a repeatable Outlook startup or early-runtime crash pattern rather than a system-wide Windows failure.

---

## 5. Most Likely Cause

**Most likely cause:** a repeatable invalid memory access inside the Outlook process, most likely triggered by a loaded Outlook extension or Outlook code path that uses .NET/COM components during startup or profile initialisation.

This is more precise than saying "KERNELBASE.dll is broken." `KERNELBASE.dll` is commonly listed as the faulting module because it is where Windows surfaces or handles the exception. The stronger evidence is the exception type and repetition pattern.

### Evidence

| Evidence | Significance |
|---|---|
| Two `1000` events within 3 minutes 23 seconds | Confirms repeatable application failure rather than a transient hang or user close action |
| Same exception code `0xc0000005` on both crashes | `0xc0000005` is an access violation, meaning the process attempted invalid memory access |
| Same fault offset `0x000000000003a4b2` on both crashes | Strong sign that the same code path failed both times |
| `1026` logs `System.AccessViolationException` | Indicates the crash involved an unhandled .NET exception consistent with invalid memory access |
| `1001` logs `APPCRASH` | Confirms Windows classified the event as an application crash and generated an error reporting bucket |
| No kernel, bugcheck, or system shutdown events supplied | Supports the conclusion that this was isolated to Outlook rather than a device-wide OS crash |

### What the logs prove

- Outlook itself crashed repeatedly.
- The crash was caused by invalid memory access.
- The crash path was consistent across attempts.
- A .NET component was involved in the termination path.

### What the logs do not prove by themselves

- Whether the failing code was Outlook core code, a COM add-in, an antivirus/email integration module, or profile data corruption.
- Whether the trigger was a recent Office update, mailbox/profile corruption, or a third-party plug-in.

Given the `.NET Runtime` evidence, a managed Outlook add-in or integration component is the most likely suspect, but that remains an evidence-based hypothesis rather than a confirmed fact from these four events alone.

---

## 6. Five Why Analysis

### Why 1 — Why did Outlook close unexpectedly?
Because `OUTLOOK.EXE` hit an access violation (`0xc0000005`) and Windows terminated the process, as shown by Application Error Event `1000`.

---

### Why 2 — Why was the process terminated instead of recovering?
Because the exception was unhandled. `.NET Runtime` Event `1026` explicitly states the process was terminated due to an unhandled `System.AccessViolationException`.

---

### Why 3 — Why did the same unhandled exception happen repeatedly?
Because the same code path was triggered on both launches. Both `1000` events show the same faulting module, same exception code, and same fault offset, which indicates a consistent trigger rather than random instability.

---

### Why 4 — Why was that code path being triggered each time Outlook started?
Most likely because Outlook was loading the same startup dependency each time, such as:

| Probable Trigger | Why it fits the evidence |
|---|---|
| Outlook COM or .NET add-in | Repeated startup crash plus `.NET Runtime` involvement is consistent with managed add-ins or integration modules |
| Corrupt Outlook profile or mailbox initialisation state | Outlook may hit the same failing path each time it loads the same profile configuration |
| Damaged Office component or recent Office update regression | Same binary version and same crash signature across launches can indicate a reproducible product defect |

Of these, an Outlook add-in or integration component is the most likely based on the `.NET Runtime` event.

---

### Why 5 — Why was the issue able to recur without being prevented?
Because Outlook startup dependencies were allowed to load unchanged on each relaunch, and there is no evidence in the supplied logs of any isolation step having been taken first, such as Safe Mode launch, add-in suppression, or Office repair. Without removing the trigger, each new launch reproduced the same crash path.

---

## 7. Root Cause Statement

Outlook repeatedly crashed because the process encountered an unhandled access violation during the same startup or early-runtime execution path on multiple launches. The available evidence most strongly points to a faulty Outlook add-in or other .NET-integrated Outlook component, with Outlook profile initialisation or Office component corruption as secondary possibilities.

---

## 8. Immediate Containment and Next Checks

| Action | Purpose |
|---|---|
| Launch Outlook in Safe Mode (`outlook.exe /safe`) | Confirms whether add-ins are involved by suppressing them |
| Disable non-Microsoft Outlook add-ins | Identifies whether a COM/.NET add-in is the trigger |
| Create a new Outlook profile | Tests whether profile corruption triggers the same crash path |
| Run Office Quick Repair, then Online Repair if needed | Repairs damaged Outlook or Office binaries |
| Review recent Office updates and third-party email/security plug-ins | Correlates the crash onset with a version or integration change |

---

## 9. Recommendations

| Priority | Recommendation | Rationale |
|---|---|---|
| High | Test Outlook in Safe Mode and capture whether the crash stops | Fastest discriminating check for add-in involvement |
| High | Disable third-party Outlook add-ins and re-enable one by one if stability returns | Most likely root-cause area based on the `.NET Runtime` event |
| Medium | Create a fresh Outlook profile if Safe Mode is inconclusive | Isolates profile corruption from application binary issues |
| Medium | Run Office repair and validate Outlook version health | Addresses damaged Office components or known update regressions |
| Low | Capture a full crash dump on next reproduction if issue persists | Needed to prove the exact failing module beyond Event Viewer evidence |

---

## 10. Confidence and Limits

**Confidence level:** Medium.

The supplied events are sufficient to conclude that Outlook crashed repeatedly due to the same unhandled access violation. They are not sufficient on their own to prove the exact subcomponent that initiated the fault. A Safe Mode test, add-in review, and if needed a crash dump would confirm the final technical root cause.

---

*Document end — RCA-INC-2024-0315-OUTLOOK-001*