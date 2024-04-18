import gspread
from oauth2client.service_account import ServiceAccountCredentials
from googleapiclient.discovery import build
import os

# Set up credentials and authentication
scope = ['https://www.googleapis.com/auth/drive']
creds = ServiceAccountCredentials.from_json_keyfile_name('AccessibilityAutomation/credentials.json', scope)
client = gspread.authorize(creds)

# Open the spreadsheet by its title
spreadsheet = client.open('Capstone Form (Responses)')
sheet = spreadsheet.sheet1

# Extract all data from the sheet
responses = sheet.get_all_records()

print (responses)
# Loop through each response and create a cleaned CSV file
for response in responses:
    #print(response)
    fn = response['First Name'].lower()
    ln = response['Last Name'].lower()
    narrator = response['Would you like to enable Narrator?']
    magnifier = response['Would you like to enable Magnifier?']
    larger = response['Would you like to enable a scaled display?']
    osk = response['Would you like to enable the On Screen Keyboard?']
    sk = response['Would you like to enable dark mode?']
    alert = response['Would you like to show audio alerts visually?']
    languages = response['Select all additional languages for keyboard layouts']
    comment = response['Do you need any additional accommodations that can be set up (additional software/hardware)? ']

    # Create a list with cleaned data 
    cleaned_data = [fn, ln, narrator, magnifier, larger, osk, sk, alert, languages, comment]

    # Create a filename
    filename = f"AccessibilityAutomation/Capstone-Utils/CSVs/{fn}-{ln}.csv"

    # Check if the file already exists
    if os.path.exists(filename):
        print(f"File '{filename}' already exists.")
    else:
        # Write data to the CSV file
        with open(filename, 'w') as f:
            f.write(','.join(map(str, cleaned_data)))
        print(f"File '{filename}' created successfully.")

 
