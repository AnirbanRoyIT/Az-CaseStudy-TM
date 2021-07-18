$location='southeastasia'
$RGName='SEA-RG'

#Get VNET from ResourceGroup

$vnet=Get-AzVirtualNetwork -Name Corp_Vnet -ResourceGroupName $RGName

#Create Subnet

$subnet= Add-AzVirtualNetworkSubnetConfig -Name 'Jump_Subnet' `
-VirtualNetwork $vnet -AddressPrefix 10.10.2.0/24
$vnet | Set-AzVirtualNetwork

#Create network security group

$nsgrule= New-AzNetworkSecurityRuleConfig -Name rdprule `
-Description rdpinboundrule `
-Protocol TCP `
-SourcePortRange * `
-DestinationPortRange 3389 `
-Access Allow -Priority 1000 `
-Direction Inbound `
-SourceAddressPrefix * `
-DestinationAddressPrefix 10.10.2.0/24

$jumpnsg=New-AzNetworkSecurityGroup -Name Jump_NSG `
-ResourceGroupName $rg.ResourceGroupName `
-Location $location -SecurityRules $nsgrule

#Create public ip address

$ip = @{
    Name = 'jumppub-ip'
    ResourceGroupName = $rg.ResourceGroupName
    Location = $location
    Sku = 'Standard'
    AllocationMethod = 'Static'
    IpAddressVersion = 'IPv4'
}

#Pass Credentials for JumpServer

$cred=Get-Credential -Message "Please enter VM credential:"

#Craete VM

$jumpvm=New-AzVM -ResourceGroupName $RGName `
-Location $location `
-Name JumpServer `
-Credential $cred `
-VirtualNetworkName $vnet.Name `
-SubnetName 'Jump_Subnet' `
-PublicIpAddressName $ip.Name `
-SecurityGroupName $jumpnsg.Name `
-image MicrosoftWindowsServer:WindowsServer:2016-Datacenter:latest `
-Size 'Standard_DS1_v2'