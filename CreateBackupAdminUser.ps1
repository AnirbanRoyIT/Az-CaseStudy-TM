$userid= Read-Host "Please enter the userid"
$Password= Read-host "Please enter the password" | ConvertTo-SecureString -AsPlainText -Force
New-AzADUser -DisplayName $userid -UserPrincipalName $userid@anirbanroyaz104outlook.onmicrosoft.com -Password $Password -MailNickname $userid
New-AzRoleAssignment -SignInName $userid@anirbanroyaz104outlook.onmicrosoft.com `
-RoleDefinitionName "Backup Contributor" `
-Scope "/subscriptions/ea090fd4-85b2-4ac7-bdde-480b9c95be42/resourceGroups/EUS-RG"
