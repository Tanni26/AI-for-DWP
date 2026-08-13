# AVD Deployment Quick Reference Card

## DEPLOYMENT OVERVIEW

**Project:** DWP Lab - Azure Virtual Desktop  
**Date:** 2026-08-13  
**Status:** Infrastructure Ready (Awaiting AVD Agent Installation)

---

## INFRASTRUCTURE SUMMARY

| Component | Name | Details |
|-----------|------|---------|
| **Subscription** | labs30 | 6639d04c-e224-4ac7-818e-9908781a2305 |
| **Resource Group** | dwp-lab-rg | Central US |
| **Host Pool** | POOL-FIN-01 | Pooled, BreadthFirst, max 5 sessions |
| **Workspace** | FinBridge-Workspace | Desktop app group |
| **App Group** | DAG-POOL-FIN-01 | Desktop (published) |
| **Session Host** | AVD-SH-01 | Windows 11 24H2, Standard_B2ms |
| **OS** | Windows 11 AVD | 24H2 optimized |
| **Security** | Trusted Launch | Secure Boot + vTPM |
| **Tenant** | zippyops.in | M365/Entra ID |

---

## NETWORK CONFIGURATION

| Component | Value |
|-----------|-------|
| **Virtual Network** | avd-vnet (10.0.0.0/16) |
| **Subnet** | avd-subnet (10.0.1.0/24) |
| **Private IP** | 10.0.1.4 |
| **Public IP** | 20.29.54.38 |
| **NIC** | avd-nic-01 |
| **NSG** | avd-nsg |
| **RDP Rule** | AllowRDP (port 3389) |

---

## USER ACCESS

| User | Email | Roles |
|------|-------|-------|
| Training User | traininguser78@zippyops.in | VM User Login (RDP) |
| | | Desktop Virtualization User (AVD) |
| | | App Group Access |

---

## RDP CONNECTION INFO

```
Server:     20.29.54.38:3389
Username:   azureuser
Password:   AzureVM@2026!
```

---

## CRITICAL FILES IN /day9

1. **AVD-Provisioning-Guide.md**
   - Complete step-by-step provisioning documentation
   - All Azure CLI commands with explanations
   - Configuration details for each component

2. **install-avd-agent.ps1**
   - Run on session host VM (via RDP)
   - Installs AVD agent MSI
   - Registers with host pool
   - **Status:** Ready to use

3. **avd-diagnostics.ps1**
   - Verification script for entire deployment
   - Checks all resources and configurations
   - Identifies issues and next steps
   - **Run from:** Local machine with Azure CLI

4. **azure-cli-commands.sh**
   - Complete reference of all CLI commands used
   - Can be used to recreate deployment
   - Includes cleanup commands

---

## DEPLOYMENT CHECKLIST

### Infrastructure Components
- [x] Host Pool (POOL-FIN-01)
- [x] Workspace (FinBridge-Workspace)
- [x] Application Group (DAG-POOL-FIN-01)
- [x] Virtual Network (avd-vnet)
- [x] Subnet (avd-subnet)
- [x] Network Interface (avd-nic-01)
- [x] Public IP (20.29.54.38)
- [x] Network Security Group (avd-nsg)
- [x] NSG Rule - RDP (port 3389)

### Session Host VM
- [x] VM Created (AVD-SH-01)
- [x] OS: Windows 11 24H2 AVD
- [x] Size: Standard_B2ms
- [x] Security: Trusted Launch enabled
- [x] Azure AD Login Extension deployed
- [ ] AVD Agent installed (PENDING)

### Security & Access
- [x] VM admin account setup
- [x] User roles assigned (Virtual Machine User Login)
- [x] App group roles assigned (Desktop Virtualization User)
- [x] Workspace roles assigned (Desktop Virtualization User)
- [x] NSG rules configured for RDP

### Final Configuration
- [ ] AVD Agent installed on session host
- [ ] Session host registered with host pool
- [ ] User can access workspace via AVD client

---

## NEXT STEPS

### Immediate Actions
1. **Connect via RDP**
   ```
   Server: 20.29.54.38:3389
   User: azureuser
   Pass: AzureVM@2026!
   ```

2. **Run Installation Script** (on VM, as Administrator)
   ```powershell
   # Inside VM:
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
   
   $Uri = 'https://aka.ms/avdagent/msi/latest'
   $MsiPath = 'C:\Windows\Temp\AVDAgent.msi'
   Invoke-WebRequest -Uri $Uri -OutFile $MsiPath -UseBasicParsing
   msiexec.exe /i $MsiPath /quiet /norestart
   
   Start-Sleep -Seconds 30
   ```

3. **Wait 2-3 Minutes**
   - Session host registers with POOL-FIN-01
   - Check registration in Azure Portal

4. **Test User Access**
   - Launch Windows App
   - Sign in with traininguser78@zippyops.in
   - Verify FinBridge-Workspace appears
   - Connect to AVD desktop

### Verification Commands

```powershell
# Check session hosts registered
az rest --method get `
  --uri "/subscriptions/6639d04c-e224-4ac7-818e-9908781a2305/resourceGroups/dwp-lab-rg/providers/Microsoft.DesktopVirtualization/hostPools/POOL-FIN-01/sessionHosts?api-version=2023-09-03" `
  --query "value[].{Name:name, Status:properties.status}" -o table

# Run full diagnostics
pwsh.exe -File C:\Users\labuser\Documents\Training\day9\avd-diagnostics.ps1
```

---

## COMMON ISSUES & SOLUTIONS

| Issue | Cause | Solution |
|-------|-------|----------|
| RDP Connection Failed | VM still booting | Wait 5-10 minutes, retry |
| No Session Hosts | AVD agent not installed | Install via RDP |
| User Cannot See Workspace | User not assigned to app group | Re-run role assignment |
| Cannot Connect to RDP | Firewall/network blocking | Check port 3389 access |
| Agent Installation Fails | Download issue | Verify internet connectivity |

---

## REGISTRATION TOKEN

**Token Type:** Host Pool Registration  
**Host Pool:** POOL-FIN-01  
**Validity:** 7 days (until 2026-08-20)  
**Generated:** 2026-08-13  

Token reference stored in provisioning guide.

---

## TIMELINES

| Task | Duration | Status |
|------|----------|--------|
| Provision infrastructure | 5-10 min | ✓ Complete |
| VM deployment | 5-10 min | ✓ Complete |
| VM initialization | 5-10 min | ✓ In Progress |
| AVD agent installation | 2-3 min | ⏳ Pending |
| Session host registration | 2-3 min | ⏳ Pending |
| User first login | Immediate | ⏳ Pending |

---

## SUPPORT RESOURCES

- **AVD Documentation:** https://learn.microsoft.com/en-us/azure/virtual-desktop/
- **Azure CLI Reference:** https://learn.microsoft.com/en-us/cli/azure/
- **Troubleshooting Guide:** See AVD-Provisioning-Guide.md section 11
- **Event Viewer:** On VM: Event Viewer > Windows Logs > System (search for "Remote Desktop")

---

## IMPORTANT NOTES

1. **Password Reset:** If unable to connect via RDP, run password reset:
   ```
   az vm user update -g dwp-lab-rg -n AVD-SH-01 --username azureuser --password "NewPass@123" --update-password
   ```

2. **Token Renewal:** If token expires before agent installation:
   ```
   $expirationTime = (Get-Date).AddDays(7).ToString("o")
   az desktopvirtualization hostpool update -g dwp-lab-rg -n POOL-FIN-01 \
     --registration-info registration-token-operation=Update expiration-time=$expirationTime
   ```

3. **Extension Check:** Verify AADLoginForWindows extension:
   ```
   az vm extension list -g dwp-lab-rg -n AVD-SH-01 --query "[].name"
   ```

---

## CONTACT & ESCALATION

- **VM Issues:** Check VM Event Viewer for RD Agent errors
- **Network Issues:** Verify NSG rules and public IP reachability
- **AVD Service Issues:** Check Microsoft status page for service incidents
- **Agent Installation:** Review installation logs in C:\Windows\Temp\

---

**Document Status:** ACTIVE  
**Last Updated:** 2026-08-13  
**Next Review:** After AVD Agent Installation
