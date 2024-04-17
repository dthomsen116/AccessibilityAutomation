function Get-CapConfig([string] $config_path){
    $conf = $null
    if(test-path $config_path){
        $conf= Get-Content -Raw -Path $config_path | ConvertFrom-Json
        $msg = "Configuration file loaded from $config_path"
        Write-Host -ForegroundColor Green $msg
    }
    else {
        $msg = "Configuration file not found at $config_path"
        Write-Host -ForegroundColor Red $msg
    }
    return $conf
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

function Select-VM(){
    try{
        $vm=$null
        $vms = Get-VM -Location $folder
        $index = 1
        Write-Host ""
        Write-Host "Select a VM" 
        foreach ($vm in $vms){
            Write-Host -ForegroundColor Cyan [$index] $vm.Name 
            if ($vm.PowerState -eq "PoweredOn") {
                Write-Host -ForegroundColor Green "Powered On"
                }   
            else {
                Write-Host -ForegroundColor Red "Powered Off"
                }

            Write-Host ""
            $index++
            }
        Write-Host ""
        $selection = Read-Host "Select a VM by number"
        $vm = $vms[$selection-1]
        Write-Host ""
        Write-Host -ForegroundColor Green "Selected VM: $($vm.Name)"
        return $vm
        }
    catch{
        Write-Host -ForegroundColor Red "Error selecting VM"
        return $null
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

function CreateClone([string] $csv_path) {
    if (!(Test-Path $csv_path)) {
        Write-Host -ForegroundColor Red "File not found at $csv_path"
        return $null
    }
    else {
    
        $fileContent = Get-Content -Path $csv_path
    

        $csv = $fileContent -split '\r?\n' | ForEach-Object {
            $_ -split ',' | ForEach-Object {
                $_.Trim()
            }
        }
    
        Write-Host -ForegroundColor Green "CSV file loaded from $csv_path"
            
    }
    try {
        $newName = $csv[0] + '-' + $csv[1]
        New-VM -Name $newName -VM 'Win10Base' -Datastore 'datastore2' -VMHost "192.168.7.24" -Location 'WorkEnv' -LinkedClone -ReferenceSnapshot 'Base(VM)3'
        Write-Host -ForegroundColor Green "Full Clone created: $newName" # changed $clone_name to $newName
    }
    catch {
        Write-Host -ForegroundColor Red "Error creating clone"
        write-host $_.Exception.Message
    }
}

function turnOnNewClone([string] $csv_path){
    $file = Get-Content -Path $csv_path
    
    foreach($item in $file) {
        $individuals = $item -split ',' | ForEach-Object {
            $_.Trim()
        }
        $fn = $individuals[0]
        $ln = $individuals[1]   
    $newVM = Get-VM -Name "$fn-$ln"
    try{
        Start-VM -VM $newVM -Confirm:$false
        Write-Host -ForegroundColor Green "VM $($newVM.Name) powered on"
    }
    catch{
        Write-Host -ForegroundColor Red "Error powering on VM"
        write-host $_.Exception.Message
    }
}
}
# function ConfCreation(){
    
#     $newVM = Get-VM | Sort-Object -Property Created -Descending | Select-Object -First 1

#     $ip = $newVM.Guest.IPAddress[0]
#     $hostname = "hostname=" + $newVM.Name + "_WorkEnv"
#     #$mac = "mac=$($newVM.NetworkAdapters.MACAddress)"
#     $dns = "name_server=10.0.17.4"
#     $gateway = "gateway=10.0.17.2"
#     $confip = "ip=$ip"
    
#     $conf = 
#     @"
# [$($newVM.Name)]
# $ip $confip $hostname $dns $gateway
# "@

#     try{
#         $path = "/home/david/Documents/AccessibilityAutomation/Capstone-Utils/Ansible/Confs/$($newVM.Name).txt"
#         #check if the file exists
#         if (Test-Path $path){
#             Write-Host -ForegroundColor Red "File already exists at $path"
#             return $null
#         }
#         else{
#             try{
#                 $conf | Out-File -FilePath $path
#             } catch {
#                 Write-Host -ForegroundColor Red "Error creating file"
#                 write-host $_.Exception.Message
#             }
#         }
#     } catch {
#         Write-Host -ForegroundColor Red "Error creating configuration"
#         write-host $_.Exception.Message
#     }
# }

function VmStatus([String] $vm){
    $guest = Get-VMGuest -VM $vm
    $network = Get-NetworkAdapter -VM $vm
    

    $i = 0
    foreach($adapter in $network){
        $name = $adapter.Name
        $ip = $guest.IPAddress[$i] | Where-Object { $_ -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' }
        $mac = $adapter.MACAddress
        $subnet = "255.255.255.0"

        Write-Host -ForegroundColor Cyan "Network Information for $($name)"
        Write-Host -ForegroundColor DarkCyan "Hostname: " $guest.Hostname
        Write-Host -ForegroundColor DarkCyan "IP Address: $ip"
        Write-Host -ForegroundColor DarkCyan "MAC Address: $mac"
        Write-Host -ForegroundColor DarkCyan "Subnet: $subnet"
        $i=$i+2
    }
}
function JoinDomain(){
    $vm = Select-VM
    $hostname = $vm.Name + "-WorkEnv"
    Invoke-VMScript -ScriptType Powershell -ScriptText "Add-Computer -DomainName capstone.local -Restart" -VM $vm -GuestCredential (Get-Credential)
    }
function ChangeHostname(){
    $vm = Select-VM
    $hostname = $vm.Name + "-WorkEnv"
    Invoke-VMScript -ScriptType Powershell -Verbose -ScriptText "Rename-Computer -NewName $hostname -Force -Restart" -VM $vm -GuestCredential (Get-Credential)
    }

function DNSRecord(){
    $vm = Get-VM -Name 'David-AD'
    $zoneName = "capstone.local"
    $recordName = $vm.guest.Hostname + "WorkEnv"
    $ip = $vm.guest.IPAddress[0]
    Invoke-VMScript -ScriptText "Add-DnsServerResourceRecordA -Name $recordName -ZoneName $zonename -AllowUpdateAny -IPv4Address $ip" -VM $vm -GuestCredential (Get-Credential) 
}


function CreateScript([string] $csv_path) {
    #$newVM = Select-VM
    
    $filename = $newVM.Name 
    $path = "AccessibilityAutomation/Capstone-Utils/CSVs/$filename.csv"
    $file = Get-Content -Path $csv_path
    $regScript = @()
    foreach($item in $file) {
        $individuals = $item -split ',' | ForEach-Object {
            $_.Trim()
        }
        $fn = $individuals[0]
        $ln = $individuals[1]   
        $newVM = Get-VM -Name "$fn-$ln"     
        $narrator = $individuals[2]
        $magnifier = $individuals[3]
        $larger = $individuals[4]
        $osk = $individuals[5]
        $stickykeys = $individuals[6]
        $visualalerts = $individuals[7]
        $en = $individuals[8]
        $sp = $individuals[9]
        $fr = $individuals[10]
        $ge = $individuals[11]
        $chS = $individuals[12]
        $chT = $individuals[13]
        $ja = $individuals[14]
        $ko = $individuals[15]
        $ru = $individuals[16]
        $comment = $individuals[-1]

       try {
                #debug 
                # Write-Host "First Name: $fn"
                # Write-Host "Last Name: $ln"
                # Write-Host "Narrator: $narrator"
                # Write-Host "Magnifier: $magnifier"
                # Write-Host "Larger: $larger"
                # Write-Host "OSK: $osk"
                # Write-Host "Sticky Keys: $stickykeys"
                # Write-Host "Visual Alerts: $visualalerts"
                # Write-Host "English: $en"
                # Write-Host "Spanish: $sp"
                # Write-Host "French: $fr"
                # Write-Host "German: $ge"
                # Write-Host "Chinese (Simplified): $chS"
                # Write-Host "Chinese (Traditional): $chT"
                # Write-Host "Japanese: $ja"
                # Write-Host "Korean: $ko"
                # Write-Host "Russian: $ru"
                # Write-Host "Comment: $comment"
                $regScript += "Windows Registry Editor Version 5.00"
                $regScript += ""
                $regScript += "[HKEY_CURRENT_USER\Control Panel\Accessibility\On]"
                $regScript += '"On"="1"'
                $regScript += ""
                
            if ($narrator -eq "yes") {
                $regScript += '[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility]'
                $regScript += '"Configuration"="Narrator"'
                $regScript += ""
            }
            
            if ($magnifier -eq "yes") {
                Invoke-VMScript -VM $newVM -ScriptText 'AccessibilityAutomation/Capstone-Utils/magnifier.ps1' -GuestCredential (Get-Credential)

            }
            if ($larger -eq "yes") {
                #tenforums.com/tutorials/5990-change-text-size-windows-10-a.html
                $regScript += "[HKEY_CURRENT_CONFIG\Software\Fonts]"
                $regScript += '"LogPixels"=dword:00000144'
                $regScript += ""
                $regScript += "[HKEY_CURRENT_USER\Control Panel\Desktop]"
                $regScript += '"Win8DpiScaling"=dword:1'
                $regScript += ""

            }
            if ($osk -eq "yes") {
                Invoke-VMScript -VM $newVM -ScriptText 'AccessibilityAutomation/Capstone-Utils/osk.ps1' -GuestCredential (Get-Credential)
            }
            
            if ($visualalerts -eq "yes") {
                $regScript += '[HKEY_CURRENT_USER\Control Panel\Accessibility\ShowSounds]'
                $regScript += '"On"="1"'
                $regScript += ""
            }
            # Create an array to store language tags
            $languages = @()

            # Check each language variable and add its language tag to the $languages array
            if ($en -eq 'English') { $languages += "en-US" }
            if ($sp -eq 'Spanish') { $languages += "es-ES" }
            if ($fr -eq 'French') { $languages += "fr-FR" }
            if ($ge -eq 'German') { $languages += "de-DE" }
            if ($chS -eq 'Chinese (Simplified)') { $languages += "zh-CN" }
            if ($chT -eq 'Chinese (Traditional)') { $languages += "zh-TW" }
            if ($ja -eq 'Japanese') { $languages += "ja-JP" }
            if ($ko -eq 'Korean') { $languages += "ko-KR" }
            if ($ru -eq 'Russian') { $languages += "ru-RU" }

            # Add language settings to the .reg script
            foreach ($language in $languages) {
                $regScript += "[HKEY_CURRENT_USER\Keyboard Layout\Preload]"
                $regScript += "`"`"1`"`"=`"$language`""
                $regScript += ""
                }            
            try {
                $scriptPath = "AccessibilityAutomation/Capstone-Utils/Scripts/$fn-$ln-conf.reg"
                # Check if the file already exists
                if (Test-Path $scriptPath) {
                    Write-Host -ForegroundColor Red "File already exists at $scriptPath"
                    return $null
                }
                else{
                    try{
                        $regScript | Out-File -FilePath $scriptPath
                    } catch {
                        Write-Host -ForegroundColor Red "Error creating file"
                        write-host $_.Exception.Message
                    }
                }
            } catch {
                Write-Host -ForegroundColor Red "Error creating configuration"
                write-host $_.Exception.Message
            }
        }catch {
            Write-Host -ForegroundColor Red "Error creating configuration"
            write-host $_.Exception.Message
        } 

    } 
}


function SelectCsv(){
    $files = Get-ChildItem '/home/david/Documents/AccessibilityAutomation/Capstone-Utils/CSVs' -Filter *.csv

    for ($i = 0; $i -lt $files.Count; $i++) {
        Write-Host "$($i + 1). $($files[$i].Name)" -ForegroundColor Green
    }

    $selectedIndex = Read-Host "Enter the index of the file you want to select"

    if ($selectedIndex -ge 1 -and $selectedIndex -le $files.Count) {
        $selectedFile = $files[$selectedIndex - 1]
        Write-Host "You have selected: $($selectedFile.FullName)"
        return $selectedFile.FullName -as [string]
    } else {
        Write-Host "Invalid selection. Please enter a valid index."
}
}

function invokeReg([string] $csv_path){
    #grab the newest made vm
    $file = Get-Content -Path $csv_path
    foreach($item in $file) {
        $individuals = $item -split ',' | ForEach-Object {
            $_.Trim()
        }
        $fn = $individuals[0]
        $ln = $individuals[1]
    #$vm = Select-VM
    $vm = Get-VM -Name "$fn-$ln"
   
    $scriptPath = "AccessibilityAutomation/Capstone-Utils/Scripts/$fn-$ln-conf.reg"
    Invoke-VMScript -ScriptType Powershell -ScriptText "regedit /s $scriptPath" -VM $vm -GuestCredential (Get-Credential)
}
}