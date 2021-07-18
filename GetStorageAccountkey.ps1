$RG_name = Read-Host "Please enter Resource group name"
$Storage_name = Read-Host "Please enter storage account name"
Get-AzStorageAccountKey -ResourceGroupName $RG_name -AccountName $Storage_name |Format-List