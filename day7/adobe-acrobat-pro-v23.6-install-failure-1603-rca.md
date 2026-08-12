# Root Cause Analysis - Adobe Acrobat Pro v23.6 Install Failure
**Reference:** INC-2024-0315-ACROBAT-001  
**Date of Incident:** 2024-03-15  
**Prepared by:** DWP Analyst  
**Status:** Closed pending corrective action validation  

---

## 1. Incident Summary

| Field | Detail |
|---|---|
| Affected Application | Adobe Acrobat Pro v23.6 |
| Package Name | `AdobeAcrobatPro.intunewin` |
| Install Context | SYSTEM |
| Install Command | `msiexec /i AcrobatPro.msi /quiet` |
| First Install Attempt | 10:01:00 |
| First Failure Recorded | 10:01:44 |
| Retry Attempt | 11:01:47 |
| Retry Failure Recorded | 11:02:31 |
| Return Code | 1603 |
| Detection Rule | Registry check against `HKLM\SOFTWARE\Adobe\Acrobat Reader\23.0` |
| Detection Result | Not detected |
| Impact | Acrobat Pro did not install successfully and remained unavailable to the device |

---

## 2. Event / Log Reference

| Log Entry | Source | What it records |
|---|---|---|
| Install start at 10:01:00 | AgentExecutor | The Intune app installation workflow started for Adobe Acrobat Pro v23.6. |
| `Install context: SYSTEM` | AppInstaller | The install ran in system context rather than as the logged-on user. This is the expected model for managed Win32 app deployment, but it also means the package must work correctly without user interaction. |
| `Install command: msiexec /i AcrobatPro.msi /quiet` | AppInstaller | The MSI installation command used for the package. Silent install failure here points to installer execution or package content problems. |
| `Return code: 1603` | AppInstaller | MSI fatal error. This is the key evidence that installation failed at the MSI layer. |
| `Detection result: Not detected` | DetectionRule | The registry check did not find the expected key after the failed install. This confirms the app was not present in the expected location. |
| Retry scheduled: 60 minutes | AgentExecutor | The deployment engine planned a retry after the initial failure. |
| Retry attempt 1 failed with 1603 | AgentExecutor / AppInstaller | The same install command failed again one hour later, showing this was repeatable rather than a one-off transient failure. |

---

## 3. Event Log / Deployment Evidence

| Time | Component | Description |
|---|---|---|
| 10:01:00 | AgentExecutor | Starting app install: Adobe Acrobat Pro v23.6 |
| 10:01:01 | AppInstaller | Install context set to SYSTEM |
| 10:01:02 | AppInstaller | Package identified as `AdobeAcrobatPro.intunewin` |
| 10:01:03 | AppInstaller | Silent MSI install started with `msiexec /i AcrobatPro.msi /quiet` |
| 10:01:44 | AppInstaller | Install returned code `1603` |
| 10:01:45 | DetectionRule | Registry detection ran against `HKLM\SOFTWARE\Adobe\Acrobat Reader\23.0` |
| 10:01:45 | DetectionRule | Key not found |
| 10:01:46 | DetectionRule | Detection result: Not detected |
| 10:01:47 | AgentExecutor | App install result: Failed |
| 10:01:47 | AgentExecutor | Retry scheduled for 60 minutes later |
| 11:01:47 | AgentExecutor | Retry attempt 1 started |
| 11:01:48 | AppInstaller | Silent MSI install attempted again |
| 11:02:31 | AppInstaller | Return code `1603` again |
| 11:02:32 | AgentExecutor | Retry 1 failed; next retry set to 60 minutes |

---

## 4. Sequence of Events - Plain English

1. The Intune workflow started installing Adobe Acrobat Pro v23.6 in system context.
2. The install used a silent MSI command, which means it had to complete without prompts, interaction, or user input.
3. Within 44 seconds, the MSI returned error code 1603.
4. Intune then ran the detection rule, which looked for a registry key under `HKLM\SOFTWARE\Adobe\Acrobat Reader\23.0`.
5. The registry key was not found, so the app was marked as not detected.
6. The deployment engine recorded the install as failed and scheduled a retry after 60 minutes.
7. The retry used the same MSI command and failed again with the same 1603 code.
8. Because the failure repeated in the same way, the issue is not a one-off network blip or timing issue. It points to a repeatable problem with the package, installer, or machine state.

---

## 5. Most Likely Cause

**Most likely cause:** the Acrobat Pro MSI package encountered a fatal installation error during silent system-context deployment, causing Windows Installer to return error 1603 on both attempts.

This is stronger than saying only “the app did not install.” The logs show the installer itself failed twice with the same return code and the same command. That repeatability makes the deployment package or MSI execution path the most likely problem area.

### Evidence

| Evidence | Significance |
|---|---|
| Same install command failed twice | Shows the failure is repeatable and tied to the package or machine state, not a one-time transient event |
| Return code `1603` on both attempts | `1603` is a fatal MSI error, which usually means the installer hit a blocking condition |
| Failure occurred during `msiexec /i AcrobatPro.msi /quiet` | Silent MSI execution failed during the install stage itself |
| Detection rule reported not detected | Confirms the app never reached a successfully installed state on the machine |
| Retry after 60 minutes failed in the same way | Lowers the chance that the issue was caused by a short-lived background condition |

### What the logs prove

- The install failed.
- The failure was inside the MSI install flow.
- The same package and command failed again.
- The app was not present in the expected registry location.

### What the logs do not prove by themselves

- Whether the fatal MSI error was caused by a pre-existing Acrobat install, a missing prerequisite, a corrupted MSI, a reboot requirement, or another machine-specific block.
- Whether the registry detection rule is correctly targeted for Acrobat Pro v23.6, because the current key points to an Acrobat Reader path rather than an Acrobat Pro path.

The strongest evidence-based conclusion is that the package failed at install time, with a separate concern that the detection rule should be reviewed for product-path accuracy.

---

## 6. Five Why Analysis

### Why 1 — Why did Acrobat Pro fail to install?
Because `msiexec` returned error code `1603`, which is a fatal Windows Installer failure.

---

### Why 2 — Why did Windows Installer return 1603?
Because the MSI hit a blocking condition during silent installation in system context.

---

### Why 3 — Why did the same blocking condition happen again on retry?
Because the retry used the same package and same install command, and the underlying condition was still present one hour later.

---

### Why 4 — Why was the condition not cleared before retry?
Because the deployment engine only retried the install; there is no evidence in the supplied log of a cleanup step, prerequisite check, repair action, or alternate install path before the second attempt.

---

### Why 5 — Why did the package continue to be treated as installable without a successful detection state?
Because the deployment relied on a fixed retry cycle and a registry-based detection check, but the install never completed successfully enough to create the expected registry state. In addition, the detection rule appears to point to an Acrobat Reader registry branch, which should be reviewed for correctness if the package is intended for Acrobat Pro.

---

## 7. Root Cause Statement

Adobe Acrobat Pro v23.6 failed to deploy because the MSI package returned fatal Windows Installer error `1603` during silent system-context installation on both the initial attempt and the retry. The exact subcause is not proven by the supplied logs, but the behaviour is consistent with a blocking MSI condition such as a conflicting pre-existing state, missing prerequisite, corrupted package content, or another machine-level installer restriction. The detection rule also requires review because it checks an Acrobat Reader registry path rather than an Acrobat Pro path.

---

## 8. Immediate Containment and Next Checks

| Action | Purpose |
|---|---|
| Check whether Acrobat or Reader is already installed on the device | Confirms whether a product conflict is blocking MSI install |
| Review `msiexec` verbose logs for the failing install | Identifies the specific MSI action that returned `1603` |
| Validate the `.intunewin` package contents and source MSI integrity | Rules out packaging or file corruption issues |
| Test the installer manually in a controlled admin session | Confirms whether the issue reproduces outside Intune |
| Review the detection rule path and version target | Ensures the app is checking the correct registry location for Acrobat Pro |

---

## 9. Recommendations

| Priority | Recommendation | Rationale |
|---|---|---|
| High | Capture and review a verbose MSI log for the failure | Fastest way to identify the exact step returning `1603` |
| High | Check for existing Adobe Acrobat/Reader installs or conflicting versions | Common cause of fatal MSI failures |
| High | Validate the detection rule against the correct Acrobat Pro registry path | Prevents a future success from being missed by detection |
| Medium | Rebuild or repackage the Win32 app if source media or command line is suspect | Addresses package corruption or packaging error |
| Medium | Test the install on a clean reference device before re-deploying | Confirms whether the issue is device-specific or package-wide |
| Low | Add a preinstall prerequisite check for Adobe conflicts | Reduces repeat failures and unnecessary retries |

---

## 10. Confidence and Limits

**Confidence level:** Medium.

The logs are sufficient to prove that Acrobat Pro v23.6 failed twice with MSI error `1603` and was not detected afterward. They are not sufficient to prove the exact blocking condition behind the MSI failure. A verbose installer log and a quick conflict check against existing Adobe installs would narrow the final root cause.

---

*Document end - RCA-INC-2024-0315-ACROBAT-001*