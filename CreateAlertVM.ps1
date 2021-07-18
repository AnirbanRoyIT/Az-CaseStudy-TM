$Criteria=New-AzMetricAlertRuleV2Criteria -MetricName "Percentage CPU" -MetricNameSpace "Microsoft.Compute/virtualMachines" -TimeAggregation Average -Operator GreaterThan -Threshold 80
Add-AzMetricAlertRuleV2 -Name CorpVMAlert -ResourceGroupName SEA-RG `
-WindowSize 00:05:00 -Frequency 00:05:00 `
-TargetResourceScope '/subscriptions/ea090fd4-85b2-4ac7-bdde-480b9c95be42/resourceGroups/SEA-RG/providers/Microsoft.Compute/virtualMachines/Server1','/subscriptions/ea090fd4-85b2-4ac7-bdde-480b9c95be42/resourceGroups/SEA-RG/providers/Microsoft.Compute/virtualMachines/Server2' `
-TargetResourceType 'Microsoft.Compute/virtualMachines' `
-TargetResourceRegion 'southeastasia' `
-Condition $Criteria -Severity 2