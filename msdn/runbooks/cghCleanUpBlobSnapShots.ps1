# Created By: Chris Gibson
# Date: 24/05/2018
# https://github.com/ChrisGibson1982/AzureAutomation



Param(
[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$SubscriptionID,
[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$StorageAccountName
)

$SubscriptionID = $SubscriptionID.Trim()
$SubscriptionID = $StorageAccountName.Trim()

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

    function Get-StorageContainer
    {
    param
    (
        [string]$StorageAccountName
    )

    $StorageAccounts = Get-AzureRmStorageAccount

    $selectedStorageAccount = $StorageAccounts | where-object{$_.StorageAccountName -eq $StorageAccountName}
    $key1 = (Get-AzureRmStorageAccountKey -ResourceGroupName $selectedStorageAccount.ResourceGroupName -name $selectedStorageAccount.StorageAccountName)[0].value

    $storageContext = New-AzureStorageContext -StorageAccountName $selectedStorageAccount.StorageAccountName -StorageAccountKey $key1
    $storageContainer = Get-AzureStorageContainer -Context $storageContext
    $storageContainer
    }

    Get-StorageContainer -StorageAccountName storageaccount
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



# Get-AzureStorageBlob –Context $Ctx -Prefix $BlobName -Container $ContainerName| where-Object {$_.ICloudBlob.IsSnapshot -and $_.Name -eq $BlobName -and $_.SnapshotTime -ne $null } | Format-table -autosize -wrap