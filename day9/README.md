# AVD Provisioning Project - Day 9

**Project Date:** August 13, 2026  
**Status:** Infrastructure Ready | Agent Installation Pending

---

## Project Overview

This folder contains the complete Azure Virtual Desktop (AVD) end-to-end provisioning project for the DWP (Desktop Workplace) Lab migration initiative.

**Objective:** Deploy a production-ready AVD infrastructure with:
- Pooled host pool with BreadthFirst load balancing
- Session host running Windows 11 multi-session (Trusted Launch)
- Entra ID integration for user authentication
- Complete role-based access control

---

## Files in This Folder

### 📋 Documentation

**1. AVD-Provisioning-Guide.md** (MAIN REFERENCE)
   - Complete step-by-step provisioning process
   - Explains each Azure CLI command
   - Configuration details for every component
   - Troubleshooting guide
   - **Use this to:** Understand what was deployed and why

**2. AVD-Quick-Reference.md** (QUICK LOOKUP)
   - One-page summary of deployment
   - Critical resource details
   - Connection information
   - Deployment checklist
   - Common issues & solutions
   - **Use this to:** Quickly reference infrastructure details

**3. azure-cli-commands.sh** (COMMAND REFERENCE)
   - Complete list of all Azure CLI commands used
   - Organized by deployment phase
   - Can be used to recreate deployment
   - Includes cleanup commands
   - **Use this to:** Replay deployment or create similar environments

### 🔧 Scripts

**4. install-avd-agent.ps1** (INSTALLATION SCRIPT)
   - Installs AVD agent on session host VM
   - Downloads from Microsoft's official MSI
   - Configures TLS and registry settings
   - Validates installation success
   - **Run on:** Session host VM (AVD-SH-01) via RDP
   - **When:** After successful RDP connection
   - **How:** `pwsh.exe -File install-avd-agent.ps1` (as Administrator)

**5. avd-diagnostics.ps1** (VERIFICATION SCRIPT)
   - Comprehensive deployment verification
   - Checks all resource configurations
   - Verifies role assignments
   - Detects AVD agent installation status
   - Provides clear next steps
   - **Run on:** Local machine with Azure CLI
   - **When:** After infrastructure deployment or for troubleshooting
   - **How:** `pwsh.exe -File avd-diagnostics.ps1`

---

## Deployment Timeline

| Phase | Duration | Status | Notes |
|-------|----------|--------|-------|
| **Infrastructure Setup** | 5-10 min | ✅ Complete | All resources created |
| **VM Provisioning** | 5-10 min | ✅ Complete | Windows 11, Trusted Launch |
| **VM Initialization** | 5-10 min | 🔄 In Progress | OS boot, extensions loading |
| **AVD Agent Install** | 2-3 min | ⏳ Pending | Manual via RDP required |
| **Host Registration** | 2-3 min | ⏳ Pending | After agent install |
| **User First Login** | Immediate | ⏳ Pending | Via Windows App |

---

## Quick Start Guide

### Step 1: Verify Infrastructure (Optional)
```powershell
pwsh.exe -File avd-diagnostics.ps1
```

### Step 2: Connect via RDP
```
Server:     20.29.54.38:3389
Username:   azureuser
Password:   AzureVM@2026!
```

### Step 3: Install AVD Agent (Inside VM, as Administrator)
```powershell
pwsh.exe -File C:\Users\labuser\Documents\Training\day9\install-avd-agent.ps1
```

### Step 4: Wait & Verify
- Wait 2-3 minutes for registration
- Session host will appear in POOL-FIN-01
- Status should change to "Available"

### Step 5: Test User Access
- Launch Windows App
- Sign in: traininguser78@zippyops.in
- Access FinBridge-Workspace
- Connect to published desktop

---

## Infrastructure Summary

### Host Pool
- **Name:** POOL-FIN-01
- **Type:** Pooled (multi-user)
- **Load Balancing:** BreadthFirst
- **Max Sessions:** 5 per host

### Workspace
- **Name:** FinBridge-Workspace
- **Type:** Regular (not personal)
- **App Groups:** DAG-POOL-FIN-01 (Desktop)

### Session Host
- **Name:** AVD-SH-01
- **OS:** Windows 11 24H2 (AVD-optimized)
- **Size:** Standard_B2ms (2 vCPU, 4GB RAM)
- **Security:** Trusted Launch (Secure Boot + vTPM)
- **Public IP:** 20.29.54.38
- **Private IP:** 10.0.1.4

### Network
- **vNet:** avd-vnet (10.0.0.0/16)
- **Subnet:** avd-subnet (10.0.1.0/24)
- **NSG:** avd-nsg (RDP port 3389 allowed)

### User Access
- **Account:** traininguser78@zippyops.in
- **Roles:** 
  - Virtual Machine User Login (RDP)
  - Desktop Virtualization User (AVD + App Group)

---

## Key Deployment Decisions

### Why Pooled Host Pool?
- Multiple users per host (cost-efficient)
- BreadthFirst load balancing (even distribution)
- Better resource utilization

### Why Windows 11 24H2 AVD?
- Latest Windows 11 build
- AVD-optimized for better performance
- Full Trusted Launch support
- Long-term support available

### Why Trusted Launch?
- Secure Boot prevents bootkit attacks
- vTPM provides hardware security module
- Industry best practice for sensitive workloads

### Why System-Assigned Identity?
- No credential management needed
- Automatic rotation handled by Azure
- Sufficient for session host requirements

---

## Troubleshooting Quick Links

| Issue | Solution | File |
|-------|----------|------|
| "How do I know if it worked?" | Run avd-diagnostics.ps1 | avd-diagnostics.ps1 |
| "RDP connection failed" | Wait 5 min & retry or reset password | AVD-Provisioning-Guide.md §11 |
| "No session hosts available" | Install AVD agent | install-avd-agent.ps1 |
| "User can't see workspace" | Verify role assignments | AVD-Quick-Reference.md |
| "Which commands did you run?" | Check complete CLI reference | azure-cli-commands.sh |

---

## Important Notes

### ⚠️ Session Host Must Complete Initialization
The VM needs 5-10 minutes after creation to fully initialize. If RDP connection fails immediately, this is normal—wait and retry.

### ⚠️ AVD Agent Installation is Manual
Due to Azure Run Command limitations with long-running operations, the AVD agent must be installed manually via RDP. This is a one-time operation.

### ⚠️ Registration Token is Time-Limited
The host pool registration token is valid for 7 days. If expired, regenerate using commands in azure-cli-commands.sh.

### ⚠️ Password Valid Until 2026-08-20
Session host will not auto-generate password expiration, but keep updated credentials safe.

---

## Files Reference

```
day9/
├── README.md (this file)
├── AVD-Provisioning-Guide.md       [Complete documentation]
├── AVD-Quick-Reference.md          [Quick lookup guide]
├── azure-cli-commands.sh            [CLI command reference]
├── install-avd-agent.ps1            [Agent installation script]
└── avd-diagnostics.ps1              [Deployment verification]
```

---

## Next Actions Checklist

- [ ] Review AVD-Provisioning-Guide.md
- [ ] Run avd-diagnostics.ps1 to verify infrastructure
- [ ] Connect via RDP to 20.29.54.38:3389
- [ ] Run install-avd-agent.ps1 on session host VM
- [ ] Wait 2-3 minutes for agent registration
- [ ] Verify session host status in Azure Portal
- [ ] Test user login via Windows App with traininguser78@zippyops.in
- [ ] Document any issues or customizations made

---

## Support & Resources

- **Microsoft AVD Docs:** https://learn.microsoft.com/en-us/azure/virtual-desktop/
- **Azure CLI Reference:** https://learn.microsoft.com/en-us/cli/azure/
- **Windows 11 AVD:** https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds-in-windows-server
- **Trusted Launch:** https://learn.microsoft.com/en-us/azure/virtual-machines/trusted-launch

---

## Project Metadata

- **Created:** 2026-08-13
- **Last Modified:** 2026-08-13
- **Subscription:** labs30 (6639d04c-e224-4ac7-818e-9908781a2305)
- **Resource Group:** dwp-lab-rg
- **Region:** Central US
- **Owner:** traininguser78@zippyops.in

---

**Status: READY FOR AVD AGENT INSTALLATION**

All infrastructure components are deployed and verified. The next step is to install the AVD agent on the session host VM, which will complete the setup and enable user access via AVD.
