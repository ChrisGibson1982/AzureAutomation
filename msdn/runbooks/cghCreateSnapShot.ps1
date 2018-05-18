## Created By: Chris Gibson
## Date: 17/05/2018


Param(
[Parameter(Mandatory=$true)][string]$SubscriptionID,
[Parameter(Mandatory=$true)][string]$StorageAccountName,
[Parameter(Mandatory=$true)][string]$StorageAccountRG,
[Parameter(Mandatory=$true)][string]$ContainerName,
[Parameter(Mandatory=$true)][string]$BlobName
)

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

Set-AzureRmContext -SubscriptionId $SubscriptionID

$StorageAccKeys =  Get-AzureRmStorageAccountKey -ResourceGroupName $StorageAccountRG -Name $StorageAccountName

$StorageAccountKey = $StorageAccKeys[0].value

$Ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

$blob = Get-AzureStorageBlob -Context $Ctx -Container $ContainerName -Blob $BlobName 

$snap = $blob.ICloudBlob.CreateSnapshot()
$snap.SnapshotQualifiedUri

# Get-AzureStorageBlob –Context $Ctx -Prefix $BlobName -Container $ContainerName| where-Object {$_.ICloudBlob.IsSnapshot -and $_.Name -eq $BlobName -and $_.SnapshotTime -ne $null } | Format-table -autosize -wrap