<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.EXAMPLE
An example

.NOTES
General notes
#>
function Start-AzureRMStorageSnapShotRB {
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
                
                # Name
                [Parameter(Mandatory=$true)]
                [ValidateNotNullOrEmpty()]         
                $Name
    )
    
    begin {
    }
    
    process {

        $job = Start-AzureRmAutomationRunbook -ResourceGroupName "ResourceGroup" –AutomationAccountName "AutomationAccount" –Name "Test-Runbook"

        $doLoop = $true
        While ($doLoop) {
          $job = Get-AzureRmAutomationJob -ResourceGroupName "ResourceGroup" –AutomationAccountName "AutomationAccount" -Id $job.JobId
          $status = $job.Status
          $doLoop = (($status -ne "Completed") -and ($status -ne "Failed") -and ($status -ne "Suspended") -and ($status -ne "Stopped"))
        }
        
        Get-AzureRmAutomationJobOutput -ResourceGroupName "ResourceGroup" –AutomationAccountName "AutomationAccount" -Id $job.JobId –Stream Output
        
        # For more detailed job output, pipe the output of Get-AzureRmAutomationJobOutput to Get-AzureRmAutomationJobOutputRecord
        Get-AzureRmAutomationJobOutput -ResourceGroupName "ResourceGroup" –AutomationAccountName "AutomationAccount" -Id $job.JobId –Stream Any | Get-AzureRmAutomationJobOutputRecord
    
    }
    
    end {
    }
}


