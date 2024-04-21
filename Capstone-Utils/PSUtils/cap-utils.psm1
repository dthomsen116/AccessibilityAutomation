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
  ,---.            ,--.                             ,--.  ,--.                 
 /  O  \ ,--.,--.,-'  '-. ,---. ,--,--,--. ,--,--.,-'  '-.`--',--,--,  ,---.   
|  .-.  ||  ||  |'-.  .-'| .-. ||        |' ,-.  |'-.  .-',--.|      \| .-. |  
|  | |  |'  ''  '  |  |  ' '-' '|  |  |  |\ '-'  |  |  |  |  ||  ||  |' '-' '  
`--' `--' `----'   `--'   `---' `--`--`--' `--`--'  `--'  `--'`--''--'.`-  /   
                                                                      `---'    
  ,---.                                   ,--.,--.   ,--.,--.,--.  ,--.            
 /  O  \  ,---. ,---. ,---.  ,---.  ,---. `--'|  |-. `--'|  |`--',-'  '-.,--. ,--. 
|  .-.  || .--'| .--'| .-. :(  .-' (  .-' ,--.| .-. ',--.|  |,--.'-.  .-' \  '  /  
|  | |  |\ `--.\ `--.\   --..-'  `).-'  `)|  || `-' ||  ||  ||  |  |  |    \   '   
`--' `--' `---' `---' `----'`----' `----' `--' `---' `--'`--'`--'  `--'  .-'  /    
                                                                          `---'      
'@
Write-host -ForegroundColor Cyan $banner
Write-host -ForegroundColor Green "https://github.com/dthomsen116/AccessibilityAutomation"
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
    
    $credUser = Read-Host "Enter the username for the VM"
    $credPass = Read-Host "Enter the password for the VM" -AsSecureString    
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
        $darkmode = $individuals[6]
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
                
            if ($narrator -eq "yes") {
                
                $script = Get-Content -Path 'AccessibilityAutomation/Capstone-Utils/narrator.ps1' -Raw
                Invoke-VMScript -VM $newVM -ScriptText $script -GuestUser $credUser -GuestPassword $credPass
                Write-Host -ForegroundColor Green "Narrator enabled"
            }
        
            if ($magnifier -eq "yes") {

                $script = Get-Content -Path 'AccessibilityAutomation/Capstone-Utils/magnifier.ps1' -Raw
                Invoke-VMScript -VM $newVM -ScriptText $script -GuestUser $credUser -GuestPassword $credPass
                Write-Host -ForegroundColor Green "Magnifier enabled"
            }
            if ($larger -eq "yes") {
                #tenforums.com/tutorials/5990-change-text-size-windows-10-a.html
                $script = Get-Content -Path 'AccessibilityAutomation/Capstone-Utils/scaling.ps1' -Raw
                Invoke-VMScript -VM $newVM -ScriptText $script -GuestUser $credUser -GuestPassword $credPass
                Write-Host -ForegroundColor Green "Display Scaling increased"
            }
            if ($osk -eq "yes") {
                $script = Get-Content -Path 'AccessibilityAutomation/Capstone-Utils/osk.ps1' -Raw
                Invoke-VMScript -VM $newVM -ScriptText $script -GuestUser $credUser -GuestPassword $credPass
                Write-Host -ForegroundColor Green "On-Screen Keyboard enabled"
            }
            if ($visualalerts -eq "yes") {
                $script = Get-Content -Path 'AccessibilityAutomation/Capstone-Utils/visualAlerts.ps1' -Raw
                Invoke-VMScript -VM $newVM -ScriptText $script -GuestUser $credUser -GuestPassword $credPass
                Write-Host -ForegroundColor Green "Visual Alerts enabled"
            }
            if ($darkmode -eq "yes") {
                $script = Get-Content -Path 'AccessibilityAutomation/Capstone-Utils/darkmode.ps1' -Raw
                Invoke-VMScript -VM $newVM -ScriptText $script -GuestUser $credUser -GuestPassword $credPass
                Write-Host -ForegroundColor Green "Dark Mode enabled"
            }
            $lang = @()
            if ($en -eq 'English') { 
                $lang += "en-US"
                Write-Host -ForegroundColor Green "English Added"
            }
            if ($sp -eq 'Spanish') { 
                $lang += "es-ES"
                Write-Host -ForegroundColor Green "Spanish Added"
            }
            if ($fr -eq 'French') { 
                $lang += "fr-FR"
                Write-Host -ForegroundColor Green "French Added"
            }
            if ($ge -eq 'German') { 
                $lang += "de-DE"
                Write-Host -ForegroundColor Green "German Added"
            }
            if ($chS -eq 'Chinese (Simplified)') { 
                $lang += "zh-CN"
                Write-Host -ForegroundColor Green "Chinese (Simplified) Added"
            }
            if ($chT -eq 'Chinese (Traditional)') { 
                $lang += "zh-TW"
                Write-Host -ForegroundColor Green "Chinese (Traditional) Added"
            }
            if ($ja -eq 'Japanese') { 
                $lang += "ja-JP"
                Write-Host -ForegroundColor Green "Japanese Added"
            }
            if ($ko -eq 'Korean') { 
                $lang += "ko-KR"
                Write-Host -ForegroundColor Green "Korean Added"
            }
            if ($ru -eq 'Russian') { 
                $lang += "ru-RU"
                Write-Host -ForegroundColor Green "Russian Added"
            }
            $lang = $lang -join ',' 
            $filePath = "AccessibilityAutomation/Capstone-Utils/Lang/$fn-$ln-lang.ps1"
            $script = "Set-WinUserLanguageList $lang -Force" | Out-File -FilePath $filePath -Force
            $script = Get-Content -Path $filePath -Raw
            Invoke-VMScript -VM $newVM -ScriptText $script -GuestUser $credUser -GuestPassword $credPass
            Invoke-VMScript -VM $newVM -ScriptText "Restart-Computer -Force" -GuestUser $credUser -GuestPassword $credPass
            Write-Host -ForegroundColor Green "Language settings applied. Restarting VM"
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

function create_report([string] $csv_path) {
    $Report = @()
    $file = Get-Content -Path $csv_path
    foreach ($item in $file) {
        $individuals = $item -split ',' | ForEach-Object {
            $_.Trim()
        }
        $fn = $individuals[0]
        $ln = $individuals[1]
        $filename = "$fn-$ln"
        $settingsNames = @("Narrator", "Magnifier", "Scaled Display", "On-Screen Keyboard", "Dark Mode", "Visual Audio Alerts")
        $comment = $individuals[-1]

        $requestedSettings = @()
        $appliedSettings = @()

        for ($i = 2; $i -le 7; $i++) {
            if ($individuals[$i] -eq "yes") {
                $requestedSettings += "- $($settingsNames[$i - 2])"
                $appliedSettings += "- $($settingsNames[$i - 2]) : $($individuals[$i])"
            }
        }

        for ($i = 8; $i -le 16; $i++) {
            if ($individuals[$i] -eq "yes") {
                $requestedSettings += "- $($settingsNames[$i - 1])"
                $appliedSettings += "- $($settingsNames[$i - 1]) : $($individuals[$i])"
            }
        }

        # Define a list of known languages
        $knownLanguages = @("English", "Spanish", "French", "German", "Chinese (Simplified)", "Chinese (Traditional)", "Japanese", "Korean", "Russian")

        # Filter out languages that are not in the known languages list
        $enabledLanguages = $individuals[8..16] | Where-Object { $_ -in $knownLanguages }

        $reportContent = @"
Accessibility Report for $fn $ln
-----------------------------------
Requested Settings:
------------------
$($requestedSettings -join "`n")

Applied Settings:
-----------------
$($appliedSettings -join "`n")

Languages Enabled:
----------
$($enabledLanguages -join "`n")

Additional Comments/Needs:
-------------------
$comment

-----------------------------------
EOF
"@

        try {
            $path = Join-Path -Path "AccessibilityAutomation/Capstone-Utils/Reports" -ChildPath "$filename.txt"
            if (Test-Path (Split-Path $path -Parent) -PathType Container) {
                if (Test-Path $path) {
                    Write-Host -ForegroundColor Red "File already exists at $path"
                } else {
                    $reportContent | Out-File -FilePath $path
                    Write-Host -ForegroundColor Green "Report saved to $path"
                }
            } else {
                Write-Host -ForegroundColor Red "Directory does not exist: $(Split-Path $path -Parent)"
            }
        } catch {
            Write-Host -ForegroundColor Red "Error creating file"
            Write-Host $_.Exception.Message
        }
    }
    return $Report
}

function CheckInv(){
    #indexes all the CSV files in the CSVs directory and allows the user to select one to view
    $files = Get-ChildItem '/home/david/Documents/AccessibilityAutomation/Capstone-Utils/CSVs' -Filter *.csv
    $i = 0
    foreach($file in $files){
        Write-Host -ForegroundColor Cyan "[$i] $($file.Name)"
        $i++
    }
    $selection = Read-Host "Select a file by number"
    $selectedFile = $files[$selection]
    $fileContent = Get-Content -Path $selectedFile.FullName
    Write-Host -ForegroundColor Green "Content of $($selectedFile.Name):"
    Write-Host $fileContent
}

function CheckRep(){
    #indexes all the CSV files in the CSVs directory and allows the user to select one to view
    $files = Get-ChildItem '/home/david/Documents/AccessibilityAutomation/Capstone-Utils/Reports' -Filter *.txt
    $i = 0
    foreach($file in $files){
        Write-Host -ForegroundColor Cyan "[$i] $($file.Name)"
        $i++
    }
    $selection = Read-Host "Select a file by number"
    $selectedFile = $files[$selection]
    $fileContent = Get-Content -Path $selectedFile.FullName
    Write-Host -ForegroundColor Cyan "Content of $($selectedFile.Name):"
    Write-Host -ForegroundColor Green $fileContent -Separator "`n"
}
