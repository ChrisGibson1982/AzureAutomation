# Azure Automation Runbooks

Azure Automation runbooks and scripts

## Runbooks
1. runbooks\cghCreateSnapShot.ps1 - Creates a snapshot of Blob held in an Azure storage account.

## Scripts
1. scripts\start-cghCreateSnapShot.ps1 - Starts an Azure Runbook and retrieves the output

---

## cghCreateSnapShot.ps1 prerequisites

1. Azure Automation Run As Account needs to have elevated rights (Owner on Sub), details of which can be found [Here](https://blogs.msdn.microsoft.com/hsirtl/2018/02/28/use-azure-automation-for-creating-resource-groups-despite-having-limited-permissions-only/)
2. The end user that will call the Runbook, must have the roles **Automation Operator** and **Reader** on the Automation Account
