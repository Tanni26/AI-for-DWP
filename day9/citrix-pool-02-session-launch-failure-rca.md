# RCA: Citrix Pool-02 Session Launch Failure (FinBridge)

Date of RCA: 2026-08-14
Incident Type: VDI session launch failure
Environment: FinBridge Citrix site

## Executive Summary
A high-impact session launch incident affected users assigned to `FinBridge-VDI-Pool-02`. The immediate technical fault was loss of broker availability on `dc-vdi-02` (`Citrix Broker Service` stopped), resulting in widespread VDA unregistration in Pool-02 and launch failures (`error 1030: "No machines available in the desktop group"`).

## Business/Service Impact
- Affected population: `22 of 30` users in Pool-02
- Unaffected comparator: `FinBridge-VDI-Pool-01`
- User-visible symptom: Session launch failures from broker path
- Operational impact: Elevated incident volume, degraded workforce productivity

## Scope and Systems Involved
- Affected pool: `FinBridge-VDI-Pool-02`
- Unaffected pool: `FinBridge-VDI-Pool-01`
- Delivery Controllers:
  - `dc-vdi-02` (associated with failing registration path)
  - `dc-vdi-01` (healthy path serving Pool-01)

## Supporting Evidence
### 1) Broker log evidence
- `08:58:04 Broker: Querying available machines in Pool-02`
- `08:58:34 Broker: Timeout waiting for machine registration response (30000ms exceeded)`
- `08:58:34 Session launch FAILED: error 1030 'No machines available in the desktop group'`

### 2) Machine catalog registration evidence
- Pool-02 catalog:
  - `25 provisioned`
  - `3 registered`
  - `22 unregistered`
  - `0 maintenance mode`
- Pool-01 catalog:
  - `20 provisioned`
  - `19 registered`
  - `1 unregistered`

### 3) Unregistered machine sample evidence (Pool-02)
- `VDI-P02-014`: unable to contact DC; `dc-vdi-02.finbridge.local:80 - connection refused`
- `VDI-P02-017`: unable to contact DC; `dc-vdi-02.finbridge.local:80 - connection refused`

### 4) Delivery Controller health evidence
- `dc-vdi-02`:
  - `Citrix Broker Service: STOPPED`
  - `Last known running: yesterday 23:40`
  - `Windows Update installed: today 00:15`
  - `Reboot required flag set; host not rebooted`
- `dc-vdi-01`:
  - `Citrix Broker Service: RUNNING`
  - `Uptime: 14 days`

## Timeline (from available data)
- `Yesterday 23:40`: `dc-vdi-02` Broker Service last known running
- `Today 00:15`: Windows Update installed on `dc-vdi-02`; reboot-required flagged; reboot not completed
- `06:15:22`: Sample Pool-02 VDA (`VDI-P02-014`) registration attempt failed
- `06:16:01`: Sample Pool-02 VDA (`VDI-P02-017`) registration attempt failed
- `08:58:03`: User session launch requested (Pool-02)
- `08:58:34`: Broker timeout and launch failure with `error 1030`

## Root Cause Statement
Primary root cause: `Citrix Broker Service` on `dc-vdi-02` was not running, causing Pool-02 VDA registration failure at scale (22 unregistered) and resulting in broker inability to assign desktops for user session launch.

Contributing conditions:
- Post-update reboot-required state not completed on `dc-vdi-02`
- Insufficient early alerting/automatic detection before user-impact threshold was reached
- Potential controller path concentration for Pool-02 registration behavior

## 5 Whys Analysis
1. Why did users fail to launch sessions in Pool-02?
- Because broker could not find available registered machines (`error 1030`, no machines available).

2. Why were there no available registered machines for many users?
- Because most Pool-02 machines were unregistered (`22/25` unregistered).

3. Why were Pool-02 machines unregistered?
- Because VDAs could not register via their controller path and saw `connection refused` to `dc-vdi-02:80`.

4. Why was `connection refused` occurring on `dc-vdi-02`?
- Because `Citrix Broker Service` on `dc-vdi-02` was stopped.

5. Why was broker service down without timely recovery?
- Post-update/reboot-required operational gap and insufficient controller health/registration-threshold alerting allowed the state to persist into business hours.

## Remediation Executed / Required (Technical)
1. Restore `Citrix Broker Service` on `dc-vdi-02` to running state.
2. Validate service listener availability and service stability.
3. Trigger/confirm Pool-02 VDA re-registration.
4. Re-test session launches with pilot users.
5. Observe steady-state metrics until normal baseline restored.

## Resolution Verification Plan
- Controller level:
  - `dc-vdi-02` Broker Service remains `RUNNING`
  - No repeated service failures in event logs
- Pool level:
  - Registered count in Pool-02 recovers from `3` toward expected norm
  - Unregistered count materially decreases from `22`
- User level:
  - No fresh broker timeouts/1030 failures for Pool-02 test launches
  - Stable launches during defined observation window (15-30 minutes minimum)

## Preventive and Corrective Actions (CAPA)
1. Monitoring and alerting
- Add critical alert for Broker Service stopped state on Delivery Controllers
- Add threshold alert for rapid drop in registration ratio per pool

2. Patch governance
- Enforce mandatory reboot completion after controller patching in approved windows
- Add patch-exit checklist requiring broker/service and registration health checks

3. Resilience validation
- Validate controller mapping/failover behavior for all pools
- Conduct quarterly controller failover and registration recovery drills

4. Operational runbooks and ownership
- Publish and train on controller outage runbook
- Define clear ownership and on-call response SLA for Citrix control plane health

## Confidence and Constraints
- Confidence in root cause: High, based on direct service-state evidence and matching registration/connectivity symptoms.
- Constraint: This RCA is based on provided logs and health snapshots only; no additional live telemetry or historical trend data was supplied in this packet.

## Appendix: Key Facts Snapshot
- Impacted: `22/30 users`, Pool-02
- Error: `1030 'No machines available in the desktop group'`
- Pool-02: `3 registered / 22 unregistered`
- Pool-01: `19 registered / 1 unregistered`
- `dc-vdi-02`: Broker Service stopped
- `dc-vdi-01`: Broker Service running
