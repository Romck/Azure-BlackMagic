$resGrp = 'mytestw2016'
$loc = 'westeurope' 
$vnetName = 'mynew-vnet'
$vnetPrefix = '10.0.0.0/16'
$subnetName = 'mysubnet'
$subnetPrefix = '10.0.1.0/24'
$vmsize='Standard_A2_v2'
$vmName = 'myw2016-01'
$nsgName = $vmName + '-nsg'
$pipName = $vmName + '-pip'
$avSetName = $vmName + '-avset'
$adminUserName = "User-Test"
$adminPassword = "Test12345!" | ConvertTo-SecureString -AsPlainText -Force
#$adminPassword = (Get-AzureKeyVaultSecret –VaultName 'myKeyVault' -Name myPassword).SecretValueText | `
                  #ConvertTo-SecureString -AsPlainText -Force
$adminCred = New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword)

New-AzureRmVm `
    -ResourceGroupName $resGrp `
    -Name $vmName `
    -ImageName Win2016Datacenter `
    -Location $loc `
    -VirtualNetworkName $vnetName `
    -AddressPrefix $vnetPrefix `
    -SubnetName $subnetName `
    -subnetaddressprefix $subnetPrefix `
    -SecurityGroupName $nsgName `
    -OpenPorts 80,3389 `
    -PublicIpAddressName $pipName `
    -Credential $adminCred

    $dataDiskSize = 127
$dataDiskNumber = 3
$vm = get-azurermvm -ResourceGroupName $resGrp -Name $vmName
for ($i=1; $i -le $dataDiskNumber; $i++) {
  $diskName = $vmname + '-disk' + $i
  Add-AzureRmVMDataDisk -VM $vm -Name $diskName -DiskSizeInGB $dataDiskSize -Caching ReadWrite -CreateOption Empty -Lun $i
}
Update-AzureRmVM -ResourceGroupName $resGrp -VM $vm

$baseUrl = 'https://raw.githubusercontent.com/erjosito/AzureBlackMagic/master/'
$script = 'windowsConfig.ps1'
$scriptUrl = $baseUrl + $script
set-azurermvmcustomscriptextension -resourcegroupname $resGrp `
                                   -VMName $vmName `
                                   -Location $loc `
                                   -FileUri $scriptUrl `
                                   -Run $script `
                                   -Name DemoScriptExtension
