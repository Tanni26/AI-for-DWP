# Azure Virtual Desktop (AVD) End-to-End Provisioning Guide

**Date:** 2026-08-13  
**Environment:** Azure Subscription labs30  
**Project:** DWP Lab - Windows 11 Workplace Migration

---

## Executive Summary

This document outlines the complete provisioning process for an Azure Virtual Desktop deployment with the following architecture:
- **Host Pool:** POOL-FIN-01 (Pooled, BreadthFirst load balancing, max 5 sessions)
- **Workspace:** FinBridge-Workspace
- **Session Host:** AVD-SH-01 (Windows 11 24H2, Standard_B2ms, Trusted Launch)
- **Tenant:** zippyops.in (Entra ID)

---

## Prerequisites Verified

✓ Azure CLI authenticated  
✓ Owner role on subscription (6639d04c-e224-4ac7-818e-9908781a2305)  
✓ Resource group exists (dwp-lab-rg)  
✓ Region: Central US  
✓ M365 Account: traininguser78@zippyops.in  

---

## Step 1: Create Host Pool

**Command:**
```bash
az desktopvirtualization hostpool create \
  --resource-group dwp-lab-rg \
  --name POOL-FIN-01 \
  --location "Central US" \
  --host-pool-type Pooled \
  --load-balancer-type BreadthFirst \
  --max-session-limit 5 \
  --preferred-app-group-type Desktop
```

**Result:**
- Host Pool: `POOL-FIN-01` created
- Type: Pooled
- Load Balancing: BreadthFirst (distributes new sessions to host with least sessions)
- Max Sessions: 5 per host
- Default Desktop App Group: `DAG-POOL-FIN-01` auto-created
- Registration Token: Generated and stored

---

## Step 2: Create Workspace

**Command:**
```bash
az desktopvirtualization workspace create \
  --resource-group dwp-lab-rg \
  --name FinBridge-Workspace \
  --location "Central US"
```

**Result:**
- Workspace: `FinBridge-Workspace` created
- Application Group: `DAG-POOL-FIN-01` registered automatically
- Ready for user assignments

---

## Step 3: Setup Virtual Network & Networking

### Create Virtual Network
```bash
az network vnet create \
  --resource-group dwp-lab-rg \
  --name avd-vnet \
  --subnet-name avd-subnet \
  --address-prefix 10.0.0.0/16 \
  --subnet-prefix 10.0.1.0/24 \
  --location "Central US"
```

### Create Network Interface
```bash
az network nic create \
  --resource-group dwp-lab-rg \
  --name avd-nic-01 \
  --vnet-name avd-vnet \
  --subnet avd-subnet \
  --location "Central US"
```

### Create Public IP
```bash
az network public-ip create \
  --resource-group dwp-lab-rg \
  --name avd-pip-01 \
  --sku Standard \
  --location "Central US"
```

**Result:**
- vnet: `avd-vnet` (10.0.0.0/16)
- subnet: `avd-subnet` (10.0.1.0/24)
- NIC: `avd-nic-01` (Private IP: 10.0.1.4)
- Public IP: `20.29.54.38`

---

## Step 4: Create Network Security Group & Rules

### Create NSG
```bash
az network nsg create \
  --resource-group dwp-lab-rg \
  --name avd-nsg \
  --location "Central US"
```

### Add RDP Rule
```bash
az network nsg rule create \
  --resource-group dwp-lab-rg \
  --nsg-name avd-nsg \
  --name AllowRDP \
  --priority 100 \
  --source-address-prefixes "*" \
  --source-port-ranges "*" \
  --destination-address-prefixes "*" \
  --destination-port-ranges 3389 \
  --access Allow \
  --protocol Tcp
```

### Attach NSG to NIC
```bash
az network nic update \
  --resource-group dwp-lab-rg \
  --name avd-nic-01 \
  --network-security-group avd-nsg
```

**Result:**
- NSG: `avd-nsg` created
- RDP rule: Port 3389 allowed from any source
- NIC updated with NSG association

---

## Step 5: Create Session Host VM

**Command:**
```bash
az vm create \
  --resource-group dwp-lab-rg \
  --name AVD-SH-01 \
  --nics avd-nic-01 \
  --size Standard_B2ms \
  --image "MicrosoftWindowsDesktop:windows-11:win11-24h2-avd:latest" \
  --admin-username azureuser \
  --admin-password "P@ssw0rd123!Azure" \
  --os-disk-size-gb 128 \
  --security-type TrustedLaunch \
  --enable-secure-boot \
  --enable-vtpm \
  --location "Central US" \
  --assign-identity
```

**Configuration:**
- OS: Windows 11 24H2 AVD-optimized
- Size: Standard_B2ms (2 vCPU, 4 GiB RAM)
- Disk: 128 GB
- Security: Trusted Launch ✓ (Secure Boot + vTPM)
- Identity: System-assigned managed identity enabled
- Admin: azureuser / P@ssw0rd123!Azure

**Result:**
- VM: `AVD-SH-01` created
- Status: Running
- Public IP: 20.29.54.38 (via avd-pip-01)
- Private IP: 10.0.1.4

---

## Step 6: Associate Public IP with NIC

**Command:**
```bash
az network nic ip-config update \
  --resource-group dwp-lab-rg \
  --nic-name avd-nic-01 \
  --name ipconfig1 \
  --public-ip-address avd-pip-01
```

**Result:**
- Public IP attached to NIC
- VM accessible via RDP at 20.29.54.38:3389

---

## Step 7: Deploy Azure AD Login Extension

**Command:**
```bash
az vm extension set \
  --resource-group dwp-lab-rg \
  --vm-name AVD-SH-01 \
  --name AADLoginForWindows \
  --publisher Microsoft.Azure.ActiveDirectory \
  --version 1.0
```

**Result:**
- Extension: `AADLoginForWindows` deployed
- VM now supports Entra ID authentication
- Users can login with M365 credentials

---

## Step 8: Generate Registration Token

**Command:**
```bash
$expirationTime = (Get-Date).AddDays(7).ToString("o")
az desktopvirtualization hostpool update \
  --resource-group dwp-lab-rg \
  --name POOL-FIN-01 \
  --registration-info registration-token-operation=Update expiration-time=$expirationTime \
  --query "registrationInfo.token" -o tsv
```

**Token Details:**
- Valid: 7 days (until 2026-08-20T11:28:01Z)
- Used by: AVD agents to register with host pool
- Scope: POOL-FIN-01 only

---

## Step 9: Assign Roles to User

### Virtual Machine User Login (RDP Access)
```bash
az role assignment create \
  --assignee "traininguser78@zippyops.in" \
  --role "Virtual Machine User Login" \
  --scope "/subscriptions/6639d04c-e224-4ac7-818e-9908781a2305/resourceGroups/dwp-lab-rg/providers/Microsoft.Compute/virtualMachines/AVD-SH-01"
```

### Desktop Virtualization User (AVD Client Access)
```bash
az role assignment create \
  --assignee "traininguser78@zippyops.in" \
  --role "Desktop Virtualization User" \
  --scope "/subscriptions/6639d04c-e224-4ac7-818e-9908781a2305/resourcegroups/dwp-lab-rg/providers/Microsoft.DesktopVirtualization/workspaces/FinBridge-Workspace"
```

### Desktop Virtualization User (Application Group)
```bash
az role assignment create \
  --assignee "traininguser78@zippyops.in" \
  --role "Desktop Virtualization User" \
  --scope "/subscriptions/6639d04c-e224-4ac7-818e-9908781a2305/resourcegroups/dwp-lab-rg/providers/Microsoft.DesktopVirtualization/applicationgroups/DAG-POOL-FIN-01"
```

**Result:**
- User: traininguser78@zippyops.in
- Permissions: RDP direct access + AVD client access
- Resources: VM + Workspace + App Group

---

## Step 10: Install AVD Agent (Manual Process)

### Prerequisites
- RDP connection to 20.29.54.38 established
- Logged in as azureuser
- Administrator access

### Installation Script

See: `install-avd-agent.ps1` in this folder

**Steps:**
1. Connect via RDP to 20.29.54.38:3389
2. Open PowerShell as Administrator
3. Run the installation script
4. Wait 2-3 minutes for registration

---

## Step 11: Verify Deployment

### Check Session Host Registration
```bash
az rest --method get \
  --uri "/subscriptions/6639d04c-e224-4ac7-818e-9908781a2305/resourceGroups/dwp-lab-rg/providers/Microsoft.DesktopVirtualization/hostPools/POOL-FIN-01/sessionHosts?api-version=2023-09-03" \
  --query "value[].{Name:name, Status:properties.status}" -o table
```

### Check VM Status
```bash
az vm show --resource-group dwp-lab-rg --name AVD-SH-01 \
  --query "{Name:name, Status:provisioningState, PowerState:powerState}" -o table
```

### Check Extensions
```bash
az vm extension list --resource-group dwp-lab-rg --vm-name AVD-SH-01 \
  --query "[].{Name:name, Status:provisioningState}" -o table
```

---

## Deployment Summary

| Component | Value | Status |
|-----------|-------|--------|
| **Subscription** | labs30 (6639d04c-e224-4ac7-818e-9908781a2305) | ✓ |
| **Resource Group** | dwp-lab-rg | ✓ |
| **Region** | Central US | ✓ |
| **Host Pool** | POOL-FIN-01 (Pooled, BreadthFirst, max 5 sessions) | ✓ |
| **Workspace** | FinBridge-Workspace | ✓ |
| **App Group** | DAG-POOL-FIN-01 (Desktop) | ✓ |
| **Session Host** | AVD-SH-01 (Windows 11 24H2, Standard_B2ms) | ✓ |
| **Security** | Trusted Launch (Secure Boot + vTPM) | ✓ |
| **Network** | avd-vnet/avd-subnet, NSG with RDP rule | ✓ |
| **Public IP** | 20.29.54.38 | ✓ |
| **Azure AD Extension** | AADLoginForWindows | ✓ |
| **User Roles** | Virtual Machine User Login + Desktop Virtualization User | ✓ |
| **AVD Agent** | Pending (manual installation) | ⏳ |

---

## RDP Connection Details

```
Server:     20.29.54.38:3389
Username:   azureuser
Password:   AzureVM@2026!  (password reset performed)
```

---

## Troubleshooting

### RDP Connection Failed
- **Cause:** VM still initializing (normal after creation)
- **Fix:** Wait 5-10 minutes, then retry connection
- **Verify:** `az vm show -g dwp-lab-rg -n AVD-SH-01 --query powerState -o tsv`

### No Session Hosts Available
- **Cause:** AVD agent not installed
- **Fix:** Connect via RDP and run AVD agent installation script
- **Verify:** Check for session hosts: `az rest --method get --uri "/subscriptions/.../sessionHosts?api-version=2023-09-03"`

### User Cannot See Workspace
- **Cause:** User not assigned to application group
- **Fix:** Assign Desktop Virtualization User role to DAG-POOL-FIN-01
- **Verify:** `az role assignment list --assignee traininguser78@zippyops.in`

---

## Post-Deployment Steps

1. **Install AVD Agent** (Manual via RDP)
2. **Wait for Session Host Registration** (2-3 minutes)
3. **Test User Access** via Windows App
4. **Monitor Host Health** in Azure Portal
5. **Configure additional settings** as needed (load balancing, timeouts, etc.)

---

## Files in This Folder

- `AVD-Provisioning-Guide.md` - This file
- `install-avd-agent.ps1` - AVD agent installation script
- `avd-diagnostics.ps1` - Deployment verification script
- `azure-cli-commands.txt` - All CLI commands used

---

## References

- [Azure Virtual Desktop Documentation](https://learn.microsoft.com/en-us/azure/virtual-desktop/)
- [AVD Host Pool Configuration](https://learn.microsoft.com/en-us/azure/virtual-desktop/create-host-pools-azure-marketplace)
- [Session Host Registration](https://learn.microsoft.com/en-us/azure/virtual-desktop/agent-overview)

---

**Document Created:** 2026-08-13  
**Last Updated:** 2026-08-13  
**Status:** Ready for AVD Agent Installation
