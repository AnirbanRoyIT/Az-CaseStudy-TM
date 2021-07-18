#Get Vnet

$corp_vnet=Get-AzVirtualNetwork -Name Corp_Vnet -ResourceGroupName SEA-RG
$branch_vnet=Get-AzVirtualNetwork -Name Branch_Vnet -ResourceGroupName EUS-RG

#Peering Vnet

Add-AzVirtualNetworkPeering `
  -Name Corp_Vnet-Branch_Vnet `
  -VirtualNetwork $corp_vnet `
  -RemoteVirtualNetworkId $branch_vnet.Id


Add-AzVirtualNetworkPeering `
  -Name Branch_Vnet-Corp_Vnet `
  -VirtualNetwork $branch_vnet `
  -RemoteVirtualNetworkId $corp_vnet.Id

#Check peering state

Get-AzVirtualNetworkPeering `
  -ResourceGroupName SEA-RG `
  -VirtualNetworkName Corp_Vnet `
  | Select PeeringState