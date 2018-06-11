# Created By: Chris Gibson
# Date: 17/05/2018
# https://github.com/ChrisGibson1982/AzureAutomation


Param(
[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$SubscriptionID,
[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$StorageAccountRG,
[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$StorageAccountName,
[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$ContainerName,
[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$BlobName
)

$SubscriptionID = $SubscriptionID.Trim()
$StorageAccountRG= $StorageAccountRG.Trim()
$StorageAccountName = $StorageAccountName.Trim()
$ContainerName = $ContainerName.Trim()
$BlobName = $BlobName.Trim()


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

    "Getting the account storage keys"
    $StorageAccKeys =  Get-AzureRmStorageAccountKey -ResourceGroupName $StorageAccountRG -Name $StorageAccountName

    "Select the primary key"    
    $StorageAccountKey = $StorageAccKeys[0].value

    "Setting the storage context"    
    $Ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

    "Getting the blob"    
    $blob = Get-AzureStorageBlob -Context $Ctx -Container $ContainerName -Blob $BlobName 

    "Taking the snapshot"    
    $snap = $blob.ICloudBlob.CreateSnapshot() 
    if ($snap) { "SnapShot taken" }
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