import-Module "/home/david/Documents/AccessibilityAutomation/Capstone-Utils/PSUtils/cap-utils.psm1" -Force

#Banner
CapBanner

#set the config
$conf=Get-CapConfig -config_path "/home/david/Documents/AccessibilityAutomation/Capstone-Utils/Cap.json"

#connect to the server
    
Connect-Cap -server 'vcenter.capstone.local'
    
if ($global:DefaultVIServer){
    #Menu
    Write-Host "1. Create and Prep a Clone from a CSV"

    $choice = Read-Host "Enter the number of the action you would like to perform"

    switch ($choice) {
        1 {
            #run the caprunner.sh script
            Invoke-Expression "powershell -File AccessibilityAutomation/Capstone-Utils/caprunner.ps1"

        }
        default {
            Write-Host "Invalid Choice"
            exit

        }
    }
}