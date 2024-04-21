#import Module
import-Module "/home/david/Documents/AccessibilityAutomation/Capstone-Utils/PSUtils/cap-utils.psm1" -Force

#Banner
CapBanner

#connect to the server
    
    Connect-Cap -server 'vcenter.capstone.local'
    
    if ($global:DefaultVIServer){
        #Menu
        Write-Host -ForegroundColor Blue "1. Create a New Environment"
        Write-Host -ForegroundColor Blue "2. Check CSV Inventory"
        Write-Host -ForegroundColor Blue "3. Read Report from Post Provisioning"
        Write-Host -ForegroundColor Red "4. Exit"


        $ans = Read-Host "Select an option:"

        if($ans -eq 1){
            Invoke-Expression "/home/david/Documents/AccessibilityAutomation/Capstone-Utils/caprunner2.ps1"
        }
        if($ans -eq 2){
            CheckInv
        }
        if($ans -eq 3){
            CheckRep
        }
        if($ans -eq "exit" -or $ans -eq "4"){
            Disconnect-Cap
            exit
        }
        else{
            continue
        }

    }
    else {
        Write-Host -ForegroundColor Red "Not connected to a server"
        Read-Host "Would you like to connect to a server? (y/n)"
        if($ans -eq "y"){
            Connect-Cap -server 'vcenter.capstone.local'
        }
        else{
            exit
        }
    }



