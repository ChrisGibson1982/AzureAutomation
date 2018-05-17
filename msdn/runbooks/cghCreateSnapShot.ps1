Param(
[string]$StorageAccountName,
[string]$ContainerName,
[string]$BlobName
)

$StorageAccountKey = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).Primary

$Ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$blob = Get-AzureStorageBlob -Context $Ctx -Container $ContainerName -Blob $BlobName 
$snap = $blob.ICloudBlob.CreateSnapshot()

Get-AzureStorageBlob –Context $Ctx -Prefix $BlobName -Container $ContainerName| where-Object {$_.ICloudBlob.IsSnapshot -and $_.Name -eq $BlobName -and $_.SnapshotTime -ne $null } | Format-table -autosize -wrap
# 