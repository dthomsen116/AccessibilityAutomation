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
    # Check if the file exists
    if (!(Test-Path $csv_path)) {
        Write-Host -ForegroundColor Red "File not found at $csv_path"
        return $null
    }
    else {
        # Read the file as text
        $fileContent = Get-Content -Path $csv_path
    
        # Split the file content by newlines to get rows
        $csv = $fileContent -split '\r?\n' | ForEach-Object {
            # Split each row by the appropriate delimiter 
            $_ -split ',' | ForEach-Object {
                # Trim any whitespace
                $_.Trim()
            }
        }
    
        Write-Host -ForegroundColor Green "CSV file loaded from $csv_path"
            
    }
    try {
        $newName = $csv[0] + '-' + $csv[1]
        New-VM -Name $newname -VM 'Win10Temp' -Datastore 'datastore2' -VMHost "192.168.7.24" -Location 'WorkEnv' -LinkedClone -ReferenceSnapshot '(Base(DJ(Login)))'
        Write-Host -ForegroundColor Green "Full Clone created: $clone_name"
    }
    catch {
        Write-Host -ForegroundColor Red "Error creating clone"
        write-host $_.Exception.Message
    }
}

function turnOnNewClone(){
    $newVM = Get-VM | Sort-Object -Property Created -Descending | Select-Object -First 1
    try{
        Start-VM -VM $NewVM -Confirm:$false
        Write-Host -ForegroundColor Green "VM $($NewVM.Name) powered on"
    }
    catch{
        Write-Host -ForegroundColor Red "Error powering on VM"
        write-host $_.Exception.Message
    }
}

function ConfCreation(){
    $newVM = Get-VM | Sort-Object -Property Created -Descending | Select-Object -First 1
    $ip = $newVM.Guest.IPAddress[0]
    $hostname = "hostname=" + $newVM.Name + "_WorkEnv"
    #$mac = "mac=$($newVM.NetworkAdapters.MACAddress)"
    $dns = "name_server=10.0.17.4"
    $gateway = "gateway=10.0.17.2"
    $confip = "ip=$ip"
    $conf = 
    @"
[$($newVM.Name)]
$ip $confip $hostname $dns $gateway
"@

    try{
        $path = "/home/david/Documents/AccessibilityAutomation/Capstone-Utils/Ansible/Confs/$($newVM.Name).txt"
        #check if the file exists
        if (Test-Path $path){
            Write-Host -ForegroundColor Red "File already exists at $path"
            return $null
        }
        else{
            try{
                $conf | Out-File -FilePath $path
            } catch {
                Write-Host -ForegroundColor Red "Error creating file"
                write-host $_.Exception.Message
            }
        }
    } catch {
        Write-Host -ForegroundColor Red "Error creating configuration"
        write-host $_.Exception.Message
    }
}

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
    $vm = Get-VM | Sort-Object -Property Created -Descending | Select-Object -First 1
    $hostname = $vm.Name + "-WorkEnv"
    Invoke-VMScript -ScriptType Powershell -ScriptText "Add-Computer -DomainName capstone.local -Restart" -VM $vm -GuestCredential (Get-Credential)
    }
function ChangeHostname(){
    $vm = Get-VM | Sort-Object -Property Created -Descending | Select-Object -First 1
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
    $newVM = Get-VM | Sort-Object -Property Created -Descending | Select-Object -First 1
    $filename = $newVM.Name 
    $path = "AccessibilityAutomation/Capstone-Utils/CSVs/$filename.csv"
    $file = Get-Content -Path $csv_path
    $powershellScript = @()
    foreach($item in $file) {
        $individuals = $item -split ',' | ForEach-Object {
            $_.Trim()
        }
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
        $comment = $individuals[17]

        try {
            if ($narrator -eq "yes") {
                $powershellScript += 'New-ItemProperty -Path "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name "WinEnterLaunchEnabled" -Value 1 -PropertyType DWORD -Force'
            }
            if ($magnifier -eq "yes") {
                $powershellScript += 'New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Accessibility" -Name "Magnifier" -Value 1 -PropertyType DWORD -Force'
            }
            if ($larger -eq "yes") {
                $powershellScript += 'Set-ItemProperty -Path "HKCU:\Control Panel\Desktop"  -Name "LogPixels" -Value 150'
                $powershellScript += 'Set-ItemProperty -Path "HKCU:\Control Panel\Desktop"  -Name "DpiScalingVer" -Value 1'
                $powershellScript += 'Set-ItemProperty -Path "HKCU:\Control Panel\Desktop"  -Name "Win8DpiScaling" -Value 0'
            }
            if ($osk -eq "yes") {
                $powershellScript += 'New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Value 1 -PropertyType DWORD -Force'
            }
            if ($stickykeys -eq "yes") {
                $powershellScript += 'New-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value 506 -PropertyType DWORD -Force'
            }
            if ($visualalerts -eq "yes") {
                $powershellScript += 'Set-ItemProperty -Path "HKCU:\AppEvents\Schemes\Apps\.Default\SystemNotification\.Current" -Name "(Default)" -Value "C:\WINDOWS\Media\Windows Notify System Generic.wav"'
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

            $powershellScript += '$languages = @()'
            foreach( $language in $languages) {
                $powershellScript += '$languages += "' + $language + '"'
            }

            # Apply the new keyboard layout based on the selected languages
            $powershellScript += 'Set-WinUserLanguageList -LanguageList $languages -Force'
            
            try {
                $scriptPath = "AccessibilityAutomation/Capstone-Utils/Scripts/$filename-conf.ps1"
                # Check if the file already exists
                if (Test-Path $scriptPath) {
                    Write-Host -ForegroundColor Red "File already exists at $scriptPath"
                    Write-Host "Continuing..."
                    $powershellScript | Out-File -FilePath $scriptPath
                    Write-host -ForegroundColor Green "Script created at $scriptPath"
                } else {
                    New-Item -Path $scriptPath -ItemType File
                    $powershellScript | Out-File -FilePath $scriptPath
                }
            } catch {
                Write-Host -ForegroundColor Red "Error creating script"
                Write-Host $_.Exception.Message
            }
        } catch {
            Write-Host -ForegroundColor Red "Error creating script"
            Write-Host $_.Exception.Message
        }
    }
}
