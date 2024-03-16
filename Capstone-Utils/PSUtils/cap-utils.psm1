function test(){
    write-host "test"
}

function CapBanner(){
    $banner = @'
                                                                                                                 
    ,------.                    ,--.   ,--.    ,--------.,--.                                                        
    |  .-.  \  ,--,--.,--.  ,--.`--' ,-|  |    '--.  .--'|  ,---.  ,---. ,--,--,--. ,---.  ,---. ,--,--,             
    |  |  \  :' ,-.  | \  `'  / ,--.' .-. |       |  |   |  .-.  || .-. ||        |(  .-' | .-. :|      \            
    |  '--'  /\ '-'  |  \    /  |  |\ `-' |       |  |   |  | |  |' '-' '|  |  |  |.-'  `)\   --.|  ||  |            
    `-------'  `--`--'   `--'   `--' `---'        `--'   `--' `--' `---' `--`--`--'`----'  `----'`--''--'            
     ,-----.                       ,--.                            ,------.                ,--.               ,--.   
    '  .--./ ,--,--. ,---.  ,---.,-'  '-. ,---. ,--,--,  ,---.     |  .--. ',--.--. ,---.  `--' ,---.  ,---.,-'  '-. 
    |  |    ' ,-.  || .-. |(  .-''-.  .-'| .-. ||      \| .-. :    |  '--' ||  .--'| .-. | ,--.| .-. :| .--''-.  .-' 
    '  '--'\\ '-'  || '-' '.-'  `) |  |  ' '-' '|  ||  |\   --.    |  | --' |  |   ' '-' ' |  |\   --.\ `--.  |  |   
     `-----' `--`--'|  |-' `----'  `--'   `---' `--''--' `----'    `--'     `--'    `---'.-'  / `----' `---'  `--'   
                    `--'                                                                 '---'                          

                    https://Github.com/DTHOMSEN116/SYS-Cap 
'@
Write-host -ForegroundColor Cyan $banner
}

function Connect-Cap([string] $server){
    #are we already connected?
    if ($global:DefaultVIServer){
        Write-Host -ForegroundColor Cyan "Already connected to $($global:DefaultVIServer.Name)"
        return
    }
    else {
        #connect to the server
        Connect-VIServer -Server $server
        Write-Host -ForegroundColor Green "Connected to $server"
    }
}

function Disconnect-Cap(){
    #are we already connected?
    if ($global:DefaultVIServer){
        Disconnect-VIServer -Server $global:DefaultVIServer -Confirm:$false
        Write-Host -ForegroundColor Green "Disconnected from vcenter.david.local"
    }
    else {
        Write-Host -ForegroundColor Red "Not connected to a server"
    }
}

function ParseCSV([string] $csv_path){
    # Check if the file exists
    if (!(Test-Path $csv_path)){
        Write-Host -ForegroundColor Red "File not found at $csv_path"
        return $null
    } else {
        # Read the file as text
        $fileContent = Get-Content -Path $csv_path

        # Split the file content by newlines to get rows
        $csv = $fileContent -split '\r?\n' | ForEach-Object {
            # Split each row by the appropriate delimiter (e.g., comma)
            $_ -split ',' | ForEach-Object {
                # Trim any leading/trailing whitespace
                $_.Trim()
            }
        }

        Write-Host -ForegroundColor Green "CSV file loaded from $csv_path"
        return $csv
    }
}

#Determining settings based on the configuration file



# function CreateClone([string] $){
#     New-VM -Name $clone_name -VM $vm -Datastore $ds -VMHost "192.168.7.28" -Location $folder -RunAsync
#     Write-Host -ForegroundColor Green "Full Clone created: $clone_name"
# }

# function Get-CapConfig([string] $config_path){
#     $conf = $null
#     if(test-path $config_path){
#         $conf= Get-Content -Raw -Path $config_path | ConvertFrom-Json
#         $msg = "Configuration file loaded from $config_path"
#         Write-Host -ForegroundColor Green $msg
#     }
#     else {
#         $msg = "Configuration file not found at $config_path"
#         Write-Host -ForegroundColor Red $msg
#     }
#     return $conf
# }

# function Select-Folder(){
#     try{
#         $folder = $null
#         $folders = Get-Folder | Where-Object { $_.Name -in @("BaseVMS", "ProdEnv") }
#         $index = 1
#         Write-Host ""
#         Write-Host "Select a Folder" 
#         foreach ($folder in $folders){
#             Write-Host -ForegroundColor DarkCyan [$index] $folder.Name
#             $index++
#         }
#         Write-Host ""
#         $selection = Read-Host "Select a Folder by number"
#         $folder = $folders[$selection-1]
#         Write-Host ""
#         Write-Host -ForegroundColor Green "Selected Folder: $($folder.Name)"
#         return $folder
#     }
#     catch{
#         Write-Host -ForegroundColor Red "Error selecting Folder"
#         return $null
#     }
# }
# function Select-VM(){
#     try{
#         $vm=$null
#         $vms = Get-VM -Location $folder
#         $index = 1
#         Write-Host ""
#         Write-Host "Select a VM" 
#         foreach ($vm in $vms){
#             Write-Host -ForegroundColor Cyan [$index] $vm.Name 
#             if ($vm.PowerState -eq "PoweredOn") {
#                 Write-Host -ForegroundColor Green "Powered On"
#                 }   
#             else {
#                 Write-Host -ForegroundColor Red "Powered Off"
#                 }

#             Write-Host ""
#             $index++
#             }
#         Write-Host ""
#         $selection = Read-Host "Select a VM by number"
#         $vm = $vms[$selection-1]
#         Write-Host ""
#         Write-Host -ForegroundColor Green "Selected VM: $($vm.Name)"
#         return $vm
#         }
#     catch{
#         Write-Host -ForegroundColor Red "Error selecting VM"
#         return $null
#     }
# }

# function Terminate-VM(){
#     $folder = Select-Folder
#     if ($folder -eq "ProdEnv"){
#         Write-Host -ForegroundColor Red "You cannot delete VMs from the ProdEnv folder"
#         exit
#     }
#     else{
#         $vm = Select-VM
#         if($vm.PowerState -eq "PoweredOn"){
#             write-host -ForegroundColor Red "VM $($vm.Name) is powered on"
#             $ans = Read-Host "Would you like to power off the VM? (y/n)"
#             if($ans -eq "y" -or $ans -eq "yes"){
#                 Stop-VM -VM $vm -Confirm:$false
#                 Write-Host -ForegroundColor Green "VM $($vm.Name) powered off"
#             }
#             else{
#                 Write-Host -ForegroundColor Red "VM $($vm.Name) not powered off"
#             }
#         }
#         $confirmation = Read-Host "Are you sure you want to delete $($vm.Name)? (yes/no)"
#         if ($confirmation -eq "yes" -or $confirmation -eq "y"){
#             Remove-VM -VM $vm -DeleteFromDisk -Confirm:$false
#             Write-Host -ForegroundColor Green "VM $($vm.Name) deleted"
#         }
#         else{
#             Write-Host -ForegroundColor Red "VM $($vm.Name) not deleted"
#         }
#     }
# }

# function CreateClone(){
#     Write-Host -ForegroundColor Cyan "Clone Type:"
#     Write-Host -ForegroundColor DarkCyan "1 - Full Clone"
#     Write-Host -ForegroundColor DarkCyan "2 - Linked Clone"
#     $clone_type= Read-Host "Select a Clone Type by number"
#     if ($clone_type -eq "1"){
#         $clone_name = Read-Host "Enter the name of the new clone"
#         $folder=Select-Folder
#         $vm=Select-VM
#         $ds=Select-Datastore
#         if ($clone_type -eq "1"){
#             New-VM -Name $clone_name -VM $vm -Datastore $ds -VMHost "192.168.7.28" -Location $folder -RunAsync
#             Write-Host -ForegroundColor Green "Full Clone created: $clone_name"
#         }
#     }
#     elseif ($clone_type -eq "2"){
#         $clone_name = Read-Host "Enter the name of the new clone"
#         $folder=Select-Folder
#         $vm=Select-VM
#         $ds=Select-Datastore
#         $snap=Select-Snapshot
#         New-VM -Name $clone_name -VM $vm -Datastore $ds -VMHost "192.168.7.28" -Location $folder -LinkedClone -ReferenceSnapshot $snap
#     }
#     else{
#         continue
#     }
# }


# function Select-Datastore(){
#     try{
#         $ds=$null
#         $ds = Get-Datastore | Sort-Object Name
#         $index = 1
#         Write-Host ""
#         Write-Host "Select a Datastore" 
#         foreach ($d in $ds){
#             $free = [math]::Round($d.FreeSpaceGB, 2)
#             Write-Host -ForegroundColor Cyan [$index] $($d.Name) " -- Free Space: $free GB"
#             $index++
#             }
#             Write-Host ""
#         $selection = Read-Host "Select a Datastore by number"
#         $ds = $ds[$selection-1]
#         Write-Host ""
#         Write-Host -ForegroundColor Green "Selected Datastore: $($ds.Name)"
#         return $ds
#         }
#     catch{
#         Write-Host -ForegroundColor Red "Error selecting Datastore"
#         return $null
#     }
# }

# function Select-Snapshot(){
#     try{
#         $snap=$null
#         $snap = Get-Snapshot -VM $vm
#         $snap = $snap | Sort-Object Created
#         $index = 1
#         Write-Host ""
#         Write-Host "Select a Snapshot" 
#         foreach ($s in $snap){
#             Write-Host -ForegroundColor DarkCyan [$index] $s.Name " -- Created: $($s.Created)"
#             $index++
#             }
#         Write-Host ""
#         $selection = Read-Host "Select a Snapshot by number"
#         $snap = $snap[$selection-1]
#         Write-Host ""
#         Write-Host -ForegroundColor Green "Selected Snapshot: $($snap.Name)"
#         return $snap
#         }
#             catch{
#                 Write-Host -ForegroundColor Red "Error selecting Snapshot"
#                 return $null
#             }
#         }
        
# function changeNetwork(){
#     $vm = Select-VM
        
#     Write-Host -ForegroundColor Cyan "Listing all networks:"
#     $allnw = Get-VirtualNetwork
#     $index = 1
#     Write-Host ""
#     Write-Host "Select a Network"
#     foreach ($n in $allnw){
#         Write-Host -ForegroundColor Cyan [$index] $n.Name
#         $index++
#     }
#     $newNetwork = Read-Host "Enter the number of the new network for the VM"
#     if ($newNetwork -eq "1"){
#         $newNetwork = $allnw[0].Name
#     }
#     else{
#         $newNetwork = $allnw[$newNetwork-1].Name
#     }
    
#     $networkAdapter = $vm | Get-NetworkAdapter
#     Set-NetworkAdapter -NetworkAdapter $networkAdapter -NetworkName $newNetwork
# }  

# function editPower(){
#     try{
#         $vm=Select-VM
#         if ($vm.PowerState -eq "PoweredOn") {
#             Write-Host -ForegroundColor Green "$($vm.name) - Powered On"
#             }   
#         else {
#             Write-Host -ForegroundColor Red "$($vm.name) - Powered Off"
#             }

#         Write-Host -ForegroundColor DarkCyan "1 - Power On"
#         Write-Host -ForegroundColor DarkCyan "2 - Power Off"
#         $power_state= Read-Host "Select a Power State by number"
#             if ($power_state -eq "1"){
#                 Start-VM -VM $vm -Confirm:$false
#                 Write-Host -ForegroundColor Green "VM $($vm.Name) powered on"
#             }
#             elseif ($power_state -eq "2"){
#                 Stop-VM -VM $vm -Confirm:$false
#                 Write-Host -ForegroundColor Green "VM $($vm.Name) powered off"
#             }
#             else{
#                 continue
#             }
#         }catch{
#             Write-Host -ForegroundColor Red "Error editing Power State"
#         }
# }

# function Get-NetworkInfo(){
#     $vm = Select-VM
#     $guest = Get-VMGuest -VM $vm
#     $network = Get-NetworkAdapter -VM $vm
    

#     $i = 0
#     foreach($adapter in $network){
#         $name = $adapter.Name
#         $ip = $guest.IPAddress[$i] | Where-Object { $_ -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' }
#         $mac = $adapter.MACAddress
#         $subnet = "255.255.255.0"

#         Write-Host -ForegroundColor Cyan "Network Information for $($name)"
#         Write-Host -ForegroundColor DarkCyan "Hostname: " $guest.Hostname
#         Write-Host -ForegroundColor DarkCyan "IP Address: $ip"
#         Write-Host -ForegroundColor DarkCyan "MAC Address: $mac"
#         Write-Host -ForegroundColor DarkCyan "Subnet: $subnet"
#         $i=$i+2
#     }
# }

# function New-Network(){
# # creates a new virtual Switch and port group
#     $vswitch = Read-Host "Enter the name of the new vSwitch: "
#     $vmHost = (Get-VMHost).Name
#     $switch = New-VirtualSwitch -VMHost $vmHost -Name $vswitch -ErrorAction Stop
#     Write-Host -ForegroundColor Green "New vSwitch $vswitch created on $vmHost"

#     $portName = Read-Host "Enter the name of the new port group name:"
#     New-VirtualPortGroup -VirtualSwitch $vswitch -Name $portName -ErrorAction Stop
#     Write-Host -ForegroundColor Green "New port group $portName created on $vswitch"
# }

# function selectCSV(){
# #index the .csv files within AccessibilityAutomation/Capstone-Utils/CSVs and return the selected file
#     $csvs = Get-ChildItem -Path "/home/david/Documents/AccessibilityAutomation/Capstone-Utils/CSVs" -Filter *.csv
#     $index = 1
#     Write-Host ""
#     Write-Host "Select a .csv file" 
#     foreach ($csv in $csvs){
#         Write-Host -ForegroundColor DarkCyan [$index] $csv.Name
#         $index++
#     }
#     Write-Host ""
#     $selection = Read-Host "Select a .csv file by number"
#     $csv = $csvs[$selection-1]
#     Write-Host ""
#     Write-Host -ForegroundColor Green "Selected .csv file: " $csv.Name
#     return $csv
# }