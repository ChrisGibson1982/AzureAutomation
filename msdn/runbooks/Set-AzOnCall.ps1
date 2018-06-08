# Created By: Chris Gibson
## Date: 17/05/2018


Param(
[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$SubscriptionID,
[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$actionGroupName,
[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$smsUser,
[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$phoneNumber
)

$SubscriptionID = $SubscriptionID.Trim()
$actionGroupName = $actionGroupName.Trim()
$countryCode = '44'
$smsUser = $smsUser.Trim()
$phoneNumber = $phoneNumber.Trim()


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

    $Group = Get-AzureRmActionGroup

    $sms = New-AzureRmActionGroupReceiver -Name $smsUser -SmsReceiver -CountryCode $countryCode -PhoneNumber $phoneNumber
    
    Set-AzureRmActionGroup -Name $actionGroupName -ResourceGroup $group.ResourceGroupName -ShortName $group.GroupShortName -Receiver $sms


    
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

