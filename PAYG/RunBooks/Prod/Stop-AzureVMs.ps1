<#
.SYNOPSIS
  Connects to Azure and stops all VMs (ARM) in the specified subscription.

.DESCRIPTION
Based on script by Farouk Friha (https://gallery.technet.microsoft.com/scriptcenter/Stop-all-Azure-VMs-ARM-and-44ea6d9d)  
This runbook connects to Azure and stops all VMs (ASM and ARM) in the specified Azure subscription.
#>

param (
    [Parameter(Mandatory=$false)] 
    [String]$AzureCredentialAssetName = 'AzureCred',
	
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$SubscriptionID,

)

# Setting error and warning action preferences
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"

#Prepping inputs
$SubscriptionID = $SubscriptionID.Trim()



$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 

    "Setting Subscription"
    Set-AzureRmContext -SubscriptionId $SubscriptionID

    "Getting all resource groups"
    $ResourceGroups = (Get-AzureRmResourceGroup -ErrorAction Stop).ResourceGroupName

    if ($ResourceGroups)
{
    foreach ($ResourceGroup in $ResourceGroups)
    {
        "`n$ResourceGroup"
        
        # Getting all virtual machines
        $RmVMs = (Get-AzureRmVM -ResourceGroupName $ResourceGroup -ErrorAction $ErrorActionPreference -WarningAction $WarningPreference).Name
        
        # Managing virtual machines deployed with the Resource Manager deployment model
        if ($RmVMs)
        {
            foreach ($RmVM in $RmVMs)
            {
                $RmPState = (Get-AzureRmVM -ResourceGroupName $ResourceGroup -Name $RmVM -Status -ErrorAction $ErrorActionPreference -WarningAction $WarningPreference).Statuses.Code[1]

                if ($RmPState -eq 'PowerState/deallocated')
                {
                    "`t$RmVM is already shut down."
                }
                else
                {
                    "`t$RmVM is shutting down ..."
                    $RmSState = (Stop-AzureRmVM -ResourceGroupName $ResourceGroup -Name $RmVM -Force -ErrorAction $ErrorActionPreference -WarningAction $WarningPreference).IsSuccessStatusCode

                    if ($RmSState -eq 'True')
                    {
                        "`t$RmVM has been shut down."
                    }
                    else
                    {
                        "`t$RmVM failed to shut down."
                    }
                }
            }
        }
        else
        {  
            "`tNo VMs deployed with the Resource Manager deployment model."      
        }
       

    }
}
else
{
    "`tNo resource group found."
}


}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

#=========================================================================



# Connecting to Azure
$Cred = Get-AutomationPSCredential -Name $AzureCredentialAssetName -ErrorAction Stop
$null = Add-AzureAccount -Credential $Cred -ErrorAction Stop -ErrorVariable err
$null = Add-AzureRmAccount -Credential $Cred -ErrorAction Stop -ErrorVariable err

# Selecting the subscription to work against
$SubID = Get-AutomationVariable -Name $SubscriptionID
Select-AzureRmSubscription -SubscriptionId $SubID

# Getting all resource groups
$ResourceGroups = (Get-AzureRmResourceGroup -ErrorAction Stop).ResourceGroupName

if ($ResourceGroups)
{
    foreach ($ResourceGroup in $ResourceGroups)
    {
        "`n$ResourceGroup"
        
        # Getting all virtual machines
        $RmVMs = (Get-AzureRmVM -ResourceGroupName $ResourceGroup -ErrorAction $ErrorActionPreference -WarningAction $WarningPreference).Name
        
        # Managing virtual machines deployed with the Resource Manager deployment model
        if ($RmVMs)
        {
            foreach ($RmVM in $RmVMs)
            {
                $RmPState = (Get-AzureRmVM -ResourceGroupName $ResourceGroup -Name $RmVM -Status -ErrorAction $ErrorActionPreference -WarningAction $WarningPreference).Statuses.Code[1]

                if ($RmPState -eq 'PowerState/deallocated')
                {
                    "`t$RmVM is already shut down."
                }
                else
                {
                    "`t$RmVM is shutting down ..."
                    $RmSState = (Stop-AzureRmVM -ResourceGroupName $ResourceGroup -Name $RmVM -Force -ErrorAction $ErrorActionPreference -WarningAction $WarningPreference).IsSuccessStatusCode

                    if ($RmSState -eq 'True')
                    {
                        "`t$RmVM has been shut down."
                    }
                    else
                    {
                        "`t$RmVM failed to shut down."
                    }
                }
            }
        }
        else
        {  
            "`tNo VMs deployed with the Resource Manager deployment model."      
        }
       

    }
}
else
{
    "`tNo resource group found."
}