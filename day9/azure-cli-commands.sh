# Azure CLI Commands - AVD Provisioning
# Complete list of all CLI commands used for end-to-end AVD deployment

## VARIABLES
SUBSCRIPTION="6639d04c-e224-4ac7-818e-9908781a2305"
RESOURCE_GROUP="dwp-lab-rg"
LOCATION="Central US"
HOST_POOL="POOL-FIN-01"
WORKSPACE="FinBridge-Workspace"
APP_GROUP="DAG-POOL-FIN-01"
VM_NAME="AVD-SH-01"
USER="traininguser78@zippyops.in"

## ========================================
## 1. VERIFY AUTHENTICATION & PERMISSIONS
## ========================================

# Check current account
az account show

# Verify Owner role on subscription
az role assignment list --assignee $USER --scope /subscriptions/$SUBSCRIPTION --query "[].roleDefinitionName" -o tsv

# Verify resource group exists
az group show --name $RESOURCE_GROUP --query "id" -o tsv


## ========================================
## 2. CREATE HOST POOL
## ========================================

az desktopvirtualization hostpool create \
  --resource-group $RESOURCE_GROUP \
  --name $HOST_POOL \
  --location "$LOCATION" \
  --host-pool-type Pooled \
  --load-balancer-type BreadthFirst \
  --max-session-limit 5 \
  --preferred-app-group-type Desktop

# Verify creation
az desktopvirtualization hostpool show --resource-group $RESOURCE_GROUP --name $HOST_POOL \
  --query "{Name:name, Type:hostPoolType, LoadBalancer:loadBalancerType, MaxSessions:maxSessionLimit}"


## ========================================
## 3. CREATE WORKSPACE
## ========================================

az desktopvirtualization workspace create \
  --resource-group $RESOURCE_GROUP \
  --name $WORKSPACE \
  --location "$LOCATION"

# Verify creation
az desktopvirtualization workspace show --resource-group $RESOURCE_GROUP --name $WORKSPACE \
  --query "name"


## ========================================
## 4. CREATE VIRTUAL NETWORK & SUBNETS
## ========================================

az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name avd-vnet \
  --subnet-name avd-subnet \
  --address-prefix 10.0.0.0/16 \
  --subnet-prefix 10.0.1.0/24 \
  --location "$LOCATION"

# Verify
az network vnet subnet list --resource-group $RESOURCE_GROUP --vnet-name avd-vnet


## ========================================
## 5. CREATE NETWORK INTERFACE
## ========================================

az network nic create \
  --resource-group $RESOURCE_GROUP \
  --name avd-nic-01 \
  --vnet-name avd-vnet \
  --subnet avd-subnet \
  --location "$LOCATION"

# Get NIC ID
NIC_ID=$(az network nic show --resource-group $RESOURCE_GROUP --name avd-nic-01 --query "id" -o tsv)


## ========================================
## 6. CREATE PUBLIC IP
## ========================================

az network public-ip create \
  --resource-group $RESOURCE_GROUP \
  --name avd-pip-01 \
  --sku Standard \
  --location "$LOCATION"

# Get Public IP address
az network public-ip show --resource-group $RESOURCE_GROUP --name avd-pip-01 --query "ipAddress" -o tsv


## ========================================
## 7. CREATE NETWORK SECURITY GROUP
## ========================================

az network nsg create \
  --resource-group $RESOURCE_GROUP \
  --name avd-nsg \
  --location "$LOCATION"


## ========================================
## 8. ADD RDP RULE TO NSG
## ========================================

az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name avd-nsg \
  --name AllowRDP \
  --priority 100 \
  --source-address-prefixes "*" \
  --source-port-ranges "*" \
  --destination-address-prefixes "*" \
  --destination-port-ranges 3389 \
  --access Allow \
  --protocol Tcp

# Verify rule
az network nsg rule show --resource-group $RESOURCE_GROUP --nsg-name avd-nsg --name AllowRDP


## ========================================
## 9. ATTACH NSG TO NIC
## ========================================

az network nic update \
  --resource-group $RESOURCE_GROUP \
  --name avd-nic-01 \
  --network-security-group avd-nsg


## ========================================
## 10. ASSOCIATE PUBLIC IP WITH NIC
## ========================================

az network nic ip-config update \
  --resource-group $RESOURCE_GROUP \
  --nic-name avd-nic-01 \
  --name ipconfig1 \
  --public-ip-address avd-pip-01


## ========================================
## 11. CREATE SESSION HOST VM
## ========================================

az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --nics avd-nic-01 \
  --size Standard_B2ms \
  --image "MicrosoftWindowsDesktop:windows-11:win11-24h2-avd:latest" \
  --admin-username azureuser \
  --admin-password "P@ssw0rd123!Azure" \
  --os-disk-size-gb 128 \
  --security-type TrustedLaunch \
  --enable-secure-boot \
  --enable-vtpm \
  --location "$LOCATION" \
  --assign-identity

# Verify creation
az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME \
  --query "{Name:name, Status:provisioningState, VMSize:hardwareProfile.vmSize}"

# Check VM power state
az vm get-instance-view --resource-group $RESOURCE_GROUP --name $VM_NAME \
  --query "instanceView.statuses[?starts_with(code, 'PowerState')].displayStatus" -o tsv


## ========================================
## 12. DEPLOY AZURE AD LOGIN EXTENSION
## ========================================

az vm extension set \
  --resource-group $RESOURCE_GROUP \
  --vm-name $VM_NAME \
  --name AADLoginForWindows \
  --publisher Microsoft.Azure.ActiveDirectory \
  --version 1.0

# Verify extension
az vm extension list --resource-group $RESOURCE_GROUP --vm-name $VM_NAME


## ========================================
## 13. GENERATE REGISTRATION TOKEN
## ========================================

# Get token with 7-day expiration
EXPIRATION_TIME=$(date -d "+7 days" -u +"%Y-%m-%dT%H:%M:%S.000Z")

az desktopvirtualization hostpool update \
  --resource-group $RESOURCE_GROUP \
  --name $HOST_POOL \
  --registration-info registration-token-operation=Update expiration-time=$EXPIRATION_TIME \
  --query "registrationInfo.token" -o tsv


## ========================================
## 14. ASSIGN ROLES - VIRTUAL MACHINE USER LOGIN
## ========================================

VM_ID="/subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/$VM_NAME"

az role assignment create \
  --assignee $USER \
  --role "Virtual Machine User Login" \
  --scope $VM_ID

# Verify
az role assignment list --assignee $USER --scope $VM_ID


## ========================================
## 15. ASSIGN ROLES - DESKTOP VIRTUALIZATION USER (WORKSPACE)
## ========================================

WORKSPACE_ID="/subscriptions/$SUBSCRIPTION/resourcegroups/$RESOURCE_GROUP/providers/Microsoft.DesktopVirtualization/workspaces/$WORKSPACE"

az role assignment create \
  --assignee $USER \
  --role "Desktop Virtualization User" \
  --scope $WORKSPACE_ID

# Verify
az role assignment list --assignee $USER --scope $WORKSPACE_ID


## ========================================
## 16. ASSIGN ROLES - DESKTOP VIRTUALIZATION USER (APP GROUP)
## ========================================

APP_GROUP_ID="/subscriptions/$SUBSCRIPTION/resourcegroups/$RESOURCE_GROUP/providers/Microsoft.DesktopVirtualization/applicationgroups/$APP_GROUP"

az role assignment create \
  --assignee $USER \
  --role "Desktop Virtualization User" \
  --scope $APP_GROUP_ID

# Verify
az role assignment list --assignee $USER --scope $APP_GROUP_ID


## ========================================
## 17. RESET ADMIN PASSWORD (IF NEEDED)
## ========================================

az vm user update \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --username azureuser \
  --password "AzureVM@2026!" \
  --update-password


## ========================================
## 18. VERIFY DEPLOYMENT
## ========================================

# List host pools
az desktopvirtualization hostpool list --resource-group $RESOURCE_GROUP \
  --query "[].{Name:name, Type:hostPoolType}" -o table

# List workspaces
az desktopvirtualization workspace list --resource-group $RESOURCE_GROUP \
  --query "[].name" -o table

# List session hosts (requires REST API)
az rest --method get \
  --uri "/subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DesktopVirtualization/hostPools/$HOST_POOL/sessionHosts?api-version=2023-09-03" \
  --query "value[].{Name:name, Status:properties.status}" -o table

# Check all role assignments for user
az role assignment list --assignee $USER --query "[].{Role:roleDefinitionName, Scope:scope}" -o table


## ========================================
## 19. INSTALL AVD AGENT (RUN ON VM)
## ========================================

# Connect via RDP to VM:
# Server: <public-ip-address>:3389
# Username: azureuser
# Password: AzureVM@2026!

# Then run PowerShell as Administrator on the VM and execute:
# See: install-avd-agent.ps1


## ========================================
## 20. VERIFY SESSION HOST REGISTRATION
## ========================================

# After agent installation, check if session host registered:
az rest --method get \
  --uri "/subscriptions/$SUBSCRIPTION/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.DesktopVirtualization/hostPools/$HOST_POOL/sessionHosts?api-version=2023-09-03" \
  --query "value[].{Name:name, Status:properties.status, HealthCheck:properties.allowNewSession}" -o table

# Run diagnostic script for complete validation:
# pwsh.exe -File avd-diagnostics.ps1


## ========================================
## USEFUL QUERIES
## ========================================

# Get all resources in resource group
az resource list --resource-group $RESOURCE_GROUP --query "[].{Name:name, Type:type}" -o table

# Get VM details
az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME --output json | jq .

# Get all extensions on VM
az vm extension list --resource-group $RESOURCE_GROUP --vm-name $VM_NAME -o table

# Get all role assignments in resource group
az role assignment list --resource-group $RESOURCE_GROUP --query "[].{Principal:principalName, Role:roleDefinitionName}" -o table

# Get public IP address
az network public-ip show --resource-group $RESOURCE_GROUP --name avd-pip-01 --query "ipAddress" -o tsv


## ========================================
## CLEANUP (IF NEEDED)
## ========================================

# Delete entire resource group (WARNING: Deletes all resources)
# az group delete --name $RESOURCE_GROUP --yes

# Delete specific VM
# az vm delete --resource-group $RESOURCE_GROUP --name $VM_NAME --yes

# Delete host pool
# az desktopvirtualization hostpool delete --resource-group $RESOURCE_GROUP --name $HOST_POOL

# Delete workspace
# az desktopvirtualization workspace delete --resource-group $RESOURCE_GROUP --name $WORKSPACE
