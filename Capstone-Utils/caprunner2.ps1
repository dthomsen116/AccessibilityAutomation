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
# Create the Configuration
write-host "Selecting CSV..."
$csv = SelectCsv


# debug 
write-host "CSV: $csv"

#create clone 
try{
    write-host "Creating Clone..."
    createClone -csv_path $csv
    sleep 5
}
catch{
    write-host -ForegroundColor Red "Error: $_"
}

#turn on clone
turnOnNewClone

#prep clone
CreateScript -csv_path $csv