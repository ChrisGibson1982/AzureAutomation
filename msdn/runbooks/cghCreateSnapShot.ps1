Param(
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

$StorageAccountKey = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).Primary


 $Ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

 $blob = Get-AzureStorageBlob -Context $Ctx -Container $ContainerName -Blob $BlobName 

 $snap = $blob.ICloudBlob.CreateSnapshot()

 Get-AzureStorageBlob –Context $Ctx -Prefix $BlobName -Container $ContainerName| where-Object {$_.ICloudBlob.IsSnapshot -and $_.Name -eq $BlobName -and $_.SnapshotTime -ne $null } | Format-table -autosize -wrap
