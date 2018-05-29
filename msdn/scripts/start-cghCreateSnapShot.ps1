<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.EXAMPLE
$Params = @{'SubscriptionID' = '81186e29-6917-590f-a95a-49d7e8e9eaa2';'StorageAccountRG' = 'cghStorageSnapTest';'StorageAccountName' = 'storageacc001';'ContainerName' = 'container001';'BlobName' = 'bluejpeg'}
Start-AzRunBook -ResourceGroup 'AAResourceRG' -AutomationAccount 'AAutomation' -Name 'SnapShotRunBook' -Params $Params

.NOTES
Starts AA Runbooks
#>
function Start-AzRunBook {
    [CmdletBinding()]
    param (
                # Resource Group
                [Parameter(Mandatory=$true)]
                [ValidateNotNullOrEmpty()]
                $ResourceGroup,

                # Automation Account
                [Parameter(Mandatory=$true)]
                [ValidateNotNullOrEmpty()]
                $AutomationAccount,

                # Automation Account
                [Parameter(Mandatory=$true)]
                [ValidateNotNullOrEmpty()]
                $Params,
                
                # Name
                [Parameter(Mandatory=$true)]
                [ValidateNotNullOrEmpty()]         
                $Name
    )
    
    begin {
        $ResourceGroup = $ResourceGroup.Trim()
        $AutomationAccount = $AutomationAccount.Trim()
        $Name = $Name.Trim()
    }
    
    process {

        $job = Start-AzureRmAutomationRunbook -ResourceGroupName $ResourceGroup –AutomationAccountName $AutomationAccount –Name $Name

        $doLoop = $true
        While ($doLoop) {
          $job = Get-AzureRmAutomationJob -ResourceGroupName $ResourceGroup –AutomationAccountName $AutomationAccount -Id $job.JobId
          $status = $job.Status
          $doLoop = (($status -ne "Completed") -and ($status -ne "Failed") -and ($status -ne "Suspended") -and ($status -ne "Stopped"))
        }
        
        Get-AzureRmAutomationJobOutput -ResourceGroupName $ResourceGroup –AutomationAccountName $AutomationAccount -Id $job.JobId –Stream Output
        
        # For more detailed job output, pipe the output of Get-AzureRmAutomationJobOutput to Get-AzureRmAutomationJobOutputRecord
        Get-AzureRmAutomationJobOutput -ResourceGroupName $ResourceGroup –AutomationAccountName $AutomationAccount -Id $job.JobId –Stream Any | Get-AzureRmAutomationJobOutputRecord
    
    }
    
    end {
    }
}