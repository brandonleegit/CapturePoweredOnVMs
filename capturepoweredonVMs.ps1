import-module VMware.PowerCLI

connect-viserver vcsa.cloud.local -user administrator@vsphere.local -password <your password>

$date = Get-Date -Format "MM-dd-yyyy"
copy-item 'c:\vminventory\vms\' -destination c:\vminventory\vms-$date -recurse

$clusters = Get-Cluster | select -expandproperty Name | out-file "c:\vminventory\vms\clusters.txt"
$standalones = Get-VMHost | where{$_.Parent.Name -eq 'host'} | select -expandproperty Name | out-file "c:\vminventory\vms\standalones.txt"
$clusternames = get-content c:\vminventory\vms\clusters.txt
$standalonenames = get-content c:\vminventory\vms\standalones.txt


get-vm | where-object {$_.PowerState -eq "PoweredOn"} | select Name, PowerState, Folder, VMHost | sort Name | out-file c:\vminventory\vms\runningVMsverbose.txt

foreach ($clustername in $clusternames) {
    
    get-cluster $clustername | get-vm | where-object {$_.PowerState -eq "PoweredOn" -and $_.Name -notlike "vCLS*"} | select -expandproperty Name | sort | out-file "c:\vminventory\vms\runningVMs_$clustername.txt"

}

foreach ($standalonename in $standalonenames) {
    
    get-vm | where-object {$_.PowerState -eq "PoweredOn" -and $_.VMHost -like $standalonename -and $_.Name -notlike "vCLS*"} | select -expandproperty Name | sort | out-file c:\vminventory\vms\runningVMs_$standalonename.txt

}  
    

disconnect-viserver -confirm:$false