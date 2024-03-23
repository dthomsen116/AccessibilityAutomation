try{
    import-Module "/home/david/Documents/AccessibilityAutomation/Capstone-Utils/PSUtils/cap-utils.psm1" -Force 
    python3 AccessibilityAutomation/Capstone-Utils/CollectSheets.py
    $csv = read-host("Enter the File directory for the CSV file")
    try{
        CreateClone -csv_path $csv
    }
    catch{
        Write-Host -ForegroundColor Red "Error creating clone"
        write-host $_.Exception.Message
        exit
    }

    $vm = Get-VM | Sort-Object -Property Created -Descending | Select-Object -First 1
    
    turnonNewClone

    do{
        $vm = Get-VM | Sort-Object -Property Created -Descending | Select-Object -First 1
        Start-Sleep -Seconds 5

    } until ($vm.Guest.IPAddress[0] -ne $null)

    try{
        Start-Sleep -Seconds 5
        ChangeHostname
    }
    catch{
        Write-Host -ForegroundColor Red "Error changing hostname"
        write-host $_.Exception.Message
        exit
    }

    try{
        ConfCreation
    }
    catch{
        Write-Host -ForegroundColor Red "Error creating configuration"
        write-host $_.Exception.Message
        exit
    }

}
catch{
    Write-Host -ForegroundColor Red "Error running clone"
    write-host $_.Exception.Message
}



