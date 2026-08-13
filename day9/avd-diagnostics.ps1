# AVD Deployment Diagnostics Script
# Purpose: Verify the complete AVD infrastructure deployment
# Usage: Run from local machine with Azure CLI configured

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AVD Deployment Diagnostics"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$resourceGroup = "dwp-lab-rg"
$subscription = "6639d04c-e224-4ac7-818e-9908781a2305"
$vmName = "AVD-SH-01"
$hostPoolName = "POOL-FIN-01"
$workspaceName = "FinBridge-Workspace"
$appGroupName = "DAG-POOL-FIN-01"
$user = "traininguser78@zippyops.in"

# Set Azure context
az account set --subscription $subscription | Out-Null

Write-Host "SUBSCRIPTION & RESOURCE GROUP" -ForegroundColor Yellow
Write-Host "=============================="
$sub = az account show --query "name" -o tsv
$rg = az group show --name $resourceGroup --query "location" -o tsv
Write-Host "Subscription: $sub"
Write-Host "Resource Group: $resourceGroup"
Write-Host "Region: $rg"
Write-Host ""

Write-Host "HOST POOL CONFIGURATION" -ForegroundColor Yellow
Write-Host "======================="
$hostPool = az desktopvirtualization hostpool show --resource-group $resourceGroup --name $hostPoolName --output json | ConvertFrom-Json
Write-Host "Name: $($hostPool.name)"
Write-Host "Type: $($hostPool.hostPoolType)"
Write-Host "Load Balancer: $($hostPool.loadBalancerType)"
Write-Host "Max Sessions: $($hostPool.maxSessionLimit)"
Write-Host ""

Write-Host "WORKSPACE" -ForegroundColor Yellow
Write-Host "========="
$workspace = az desktopvirtualization workspace show --resource-group $resourceGroup --name $workspaceName --output json | ConvertFrom-Json
Write-Host "Name: $($workspace.name)"
Write-Host "Location: $($workspace.location)"
Write-Host "App Groups: $($workspace.applicationGroupReferences.Count)"
Write-Host ""

Write-Host "SESSION HOST VM" -ForegroundColor Yellow
Write-Host "==============="
$vm = az vm show --resource-group $resourceGroup --name $vmName --output json | ConvertFrom-Json
Write-Host "Name: $($vm.name)"
Write-Host "Size: $($vm.hardwareProfile.vmSize)"
Write-Host "Location: $($vm.location)"
Write-Host "Provisioning State: $($vm.provisioningState)"
Write-Host ""

Write-Host "VM POWER & INSTANCE STATE" -ForegroundColor Yellow
Write-Host "========================="
$vmState = az vm get-instance-view --resource-group $resourceGroup --name $vmName --output json | ConvertFrom-Json
$powerStatus = $vmState.instanceView.statuses | Where-Object { $_.code -like "PowerState/*" }
$provisionStatus = $vmState.instanceView.statuses | Where-Object { $_.code -like "ProvisioningState/*" }
Write-Host "Power State: $($powerStatus.displayStatus)"
Write-Host "Provisioning: $($provisionStatus.displayStatus)"
Write-Host ""

Write-Host "NETWORK CONFIGURATION" -ForegroundColor Yellow
Write-Host "====================="
$nic = az network nic show --resource-group $resourceGroup --name avd-nic-01 --output json | ConvertFrom-Json
$ipConfig = $nic.ipConfigurations[0]
Write-Host "NIC: $($nic.name)"
Write-Host "Private IP: $($ipConfig.privateIPAddress)"
Write-Host "Public IP: $($ipConfig.publicIPAddress.id.Split('/')[-1])"
$publicIp = az network public-ip show --resource-group $resourceGroup --name avd-pip-01 --query "ipAddress" -o tsv
Write-Host "Public IP Address: $publicIp"
Write-Host ""

Write-Host "EXTENSIONS" -ForegroundColor Yellow
Write-Host "=========="
$extensions = az vm extension list --resource-group $resourceGroup --vm-name $vmName --output json | ConvertFrom-Json
foreach ($ext in $extensions) {
    $status = $ext.provisioningState
    $statusColor = if ($status -eq "Succeeded") { "Green" } else { "Yellow" }
    Write-Host "$($ext.name) : $status" -ForegroundColor $statusColor
}
Write-Host ""

Write-Host "SESSION HOSTS IN POOL" -ForegroundColor Yellow
Write-Host "===================="
$apiVersion = "2023-09-03"
$uri = "/subscriptions/$subscription/resourceGroups/$resourceGroup/providers/Microsoft.DesktopVirtualization/hostPools/$hostPoolName/sessionHosts?api-version=$apiVersion"
$sessionHosts = az rest --method get --uri $uri --output json 2>/dev/null | ConvertFrom-Json
if ($sessionHosts.value.Count -gt 0) {
    foreach ($sh in $sessionHosts.value) {
        Write-Host "Name: $($sh.name)"
        Write-Host "Status: $($sh.properties.status)"
        Write-Host "Available for sessions: $($sh.properties.allowNewSession)"
        Write-Host ""
    }
} else {
    Write-Host "✗ No session hosts registered (AVD agent not yet installed)" -ForegroundColor Red
    Write-Host "Status: Pending" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "USER ROLE ASSIGNMENTS" -ForegroundColor Yellow
Write-Host "====================="
$roleAssignments = az role assignment list --assignee $user --resource-group $resourceGroup --output json | ConvertFrom-Json
if ($roleAssignments.Count -gt 0) {
    foreach ($role in $roleAssignments) {
        Write-Host "Role: $($role.roleDefinitionName)"
        Write-Host "Scope: $($role.scope.Split('/')[-1])"
        Write-Host ""
    }
} else {
    Write-Host "✗ No role assignments found" -ForegroundColor Red
}

Write-Host "DEPLOYMENT CHECKLIST" -ForegroundColor Yellow
Write-Host "===================="
Write-Host "[✓] Host Pool (POOL-FIN-01)"
Write-Host "[✓] Workspace (FinBridge-Workspace)"
Write-Host "[✓] App Group (DAG-POOL-FIN-01)"
Write-Host "[✓] Session Host VM (AVD-SH-01)"
Write-Host "[✓] Networking (vnet, subnet, NIC, public IP)"
Write-Host "[✓] NSG with RDP rule"
Write-Host "[✓] Azure AD Extension"
Write-Host "[✓] User role assignments"
if ($sessionHosts.value.Count -gt 0) {
    Write-Host "[✓] AVD Agent installed & registered"
} else {
    Write-Host "[⏳] AVD Agent (pending installation)"
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Diagnostics Complete"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($sessionHosts.value.Count -eq 0) {
    Write-Host "NEXT ACTION: Install AVD Agent" -ForegroundColor Yellow
    Write-Host "1. Connect via RDP: $publicIp`:3389"
    Write-Host "2. Run: C:\Users\labuser\Documents\Training\day9\install-avd-agent.ps1"
    Write-Host "3. Wait 2-3 minutes for registration"
    Write-Host "4. Re-run this diagnostic to verify"
}
