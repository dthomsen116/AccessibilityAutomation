#Imports custom Module
try{
    write-host "Importing Module..."
    import-Module "/home/david/Documents/AccessibilityAutomation/Capstone-Utils/PSUtils/cap-utils.psm1" -Force
} catch{
    Write-Host -ForegroundColor Red "Error: $_"
}

## Prints the link to the Google Form to submit
try{
    Write-Host
    Write-Host -NoNewline -ForegroundColor Cyan "Please submit the form at the following link: "
    Write-Host -ForegroundColor Magenta "https://forms.gle/KmjDi6ymKADZFmYV6"
    Write-Host
    Read-host "Press Enter to continue"
} catch{
    Write-Host -ForegroundColor Red "Error: $_"
}

# Grab the CSV From google Sheets
try{
    write-host "Grabbing CSV from Google Sheets..."
    python3 AccessibilityAutomation/Capstone-Utils/CollectSheets.py
} catch{
    Write-Host -ForegroundColor Red "Error: $_"
}

# Select the CSV to be used for additional configuration
try{
    write-host "Selecting CSV..."
    $csv = SelectCsv
} catch{
    write-host -ForegroundColor Red "Error: $_"
}

# Create the Configuration
try{
    write-host "Creating Script..."
    CreateScript -csv_path $csv
} catch{
    write-host -ForegroundColor Red "Error: $_"
}

# Create the clone
try{
    write-host "Creating Clone..."
    CreateClone -csv_path $csv
    $timer = 10
    while ($timer -gt 0) {
        write-host "Waiting for clone to be created... Time remaining: $timer seconds"
        Start-Sleep -Seconds 1
        $timer--
    }
} catch{
    write-host -ForegroundColor Red "Error: $_"
}

# Turn on the new clone
try{
    write-host "Turning on the new clone..."
    turnonNewClone
    
    write-host "checking powerstate"
    do{
        $vm = Get-VM | Sort-Object -Property Created -Descending | Select-Object -First 1
        Start-Sleep -Seconds 5
    } until ($vm.PowerState -eq "PoweredOn")

} catch{
    write-host -ForegroundColor Red "Error: $_"
}

# create ansible inv file
try{
    write-host "Creating Ansible Inventory File..."
    ConfCreation
} catch{
    write-host -ForegroundColor Red "Error: $_"
}


# Create the Run the ansible playbook
try{
    write-host "Running Ansible Playbook..."
    {"FILL THIS IN"}
} catch{
    write-host -ForegroundColor Red "Error: $_"
}
