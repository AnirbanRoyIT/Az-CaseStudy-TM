#Create Resource Group

$RGName=Read-Host "Please type Resource group name"
$location=Read-Host "Please type location name"
$rg=New-AzResourceGroup -Name $RGName -Location $location

#Create Public Ip Address

$publicip = New-AzPublicIpAddress -ResourceGroupName $RGName -Name "corplbpub-ipp" -Location $location -AllocationMethod Static -Sku Standard

#CReate Load Balancer

$frontend = New-AzLoadBalancerFrontendIpConfig -Name "CorpLBFrontEnd" `
-PublicIpAddress $publicip

$backendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name "CorpLbBpool"
$probe = New-AzLoadBalancerProbeConfig -Name "CorpLBHProbe" `
-Protocol "http" -Port 80 -IntervalInSeconds 15 -ProbeCount 2 `
-RequestPath "index.html"

$inboundNatRule1 = New-AzLoadBalancerInboundNatRuleConfig -Name "CorpLBinboundNatRule1" `
-FrontendIPConfiguration $frontend -Protocol Tcp `
-FrontendPort 5580 -BackendPort 3389 -IdleTimeoutInMinutes 4 `


$inboundNatRule2 = New-AzLoadBalancerInboundNatRuleConfig -Name "CorpLBinboundNatRule2" `
-FrontendIPConfiguration $frontend -Protocol Tcp `
-FrontendPort 5581 -BackendPort 3389 -IdleTimeoutInMinutes 4

$lbrule = New-AzLoadBalancerRuleConfig -Name "CorpLBruleName" `
-FrontendIPConfiguration $frontend -BackendAddressPool $backendAddressPool `
-Probe $probe -Protocol "Tcp" -FrontendPort 80 `
-BackendPort 80 -IdleTimeoutInMinutes 4 -LoadDistribution SourceIP -DisableOutboundSNAT

$lb = New-AzLoadBalancer -Name "CorpLoadBalancer" -ResourceGroupName $RGName `
-Location $location -FrontendIpConfiguration $frontend `
-BackendAddressPool $backendAddressPool -Probe $probe `
-InboundNatRule $inboundNatRule1,$inboundNatRule2 `
-LoadBalancingRule $lbrule -Sku Standard

#CreateVNET and Subnet

$subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name "Corp_Subnet" `
  -AddressPrefix 10.10.1.0/24
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $RGName `
  -Location $location `
  -Name "Corp_Vnet" `
  -AddressPrefix 10.10.0.0/16 `
  -Subnet $subnetConfig

#Create Network Security Group

$nsgrule1= New-AzNetworkSecurityRuleConfig -Name corprule `
-Description corpnsginboundrule `
-Protocol TCP `
-SourcePortRange * `
-DestinationPortRange 80,3389 `
-Access Allow -Priority 1000 `
-Direction Inbound `
-SourceAddressPrefix * `
-DestinationAddressPrefix 10.10.1.0/24

$nsgrule2= New-AzNetworkSecurityRuleConfig -Name jumprule `
-Description jumpnsginboundrule `
-SourceAddressPrefix 10.10.2.0/24 `
-DestinationAddressPrefix 10.10.1.0/24 `
-Protocol TCP `
-SourcePortRange * `
-DestinationPortRange 5985 `
-Access Allow -Priority 1010 `
-Direction Inbound 

$corpnsg=New-AzNetworkSecurityGroup -Name Corp_NSG -ResourceGroupName $RGName -Location $location -SecurityRules $nsgrule1,$nsgrule2

#Create Network Interface


  for ($i=0; $i -le 0; $i++)
{
for ($j=1; $j -le 2; $j++)
{
   New-AzNetworkInterface `
     -ResourceGroupName $RGName `
     -Name Server$j `
     -Location $location `
     -NetworkSecurityGroup $corpnsg `
     -Subnet $vnet.Subnets[0] `
     -LoadBalancerBackendAddressPool $lb.BackendAddressPools[0] `
     -LoadBalancerInboundNatRule $lb.InboundNatRules[$i]
$i++
}
}


#Create Availability Set

$aset=New-AzAvailabilitySet `
   -Location $location `
   -Name "CorpASet" `
   -ResourceGroupName $RGName `
   -Sku aligned `
   -PlatformFaultDomainCount 2 `
   -PlatformUpdateDomainCount 3
#Pass credentials

$cred=Get-Credential -Message "Please enter VM credential:"

#Create VM

for($i=1; $i -le 2; $i++){
$corpvm=New-AzVM -ResourceGroupName $RGName `
-Location $location `
-Name Server$i `
-Credential $cred `
-VirtualNetworkName $vnet.Name `
-SubnetName 'Corp_Subnet' `
-AvailabilitySetName $aset.Name `
-image MicrosoftWindowsServer:WindowsServer:2016-Datacenter:latest `
-Size 'Standard_DS1_v2'
}