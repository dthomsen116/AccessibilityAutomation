import-Module "/home/david/Documents/AccessibilityAutomation/Capstone-Utils/PSUtils/cap-utils.psm1" -Force 
python AccessibilityAutomation/Capstone-Utils/CollectSheets.py
$csv = read-host("Enter the File directory for the CSV file")
CreateClone -csv_path $csv
ChangeHostname