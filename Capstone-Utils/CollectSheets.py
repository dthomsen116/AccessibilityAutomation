import gspread
from oauth2client.service_account import ServiceAccountCredentials
from googleapiclient.discovery import build
import os

# Set up credentials and authentication
scope = ['https://www.googleapis.com/auth/drive']
creds = ServiceAccountCredentials.from_json_keyfile_name('AccessibilityAutomation/Capstone-Utils/CSVs/credentials.json', scope)
client = gspread.authorize(creds)

# Open the spreadsheet by its title
spreadsheet = client.open('Capstone Form (Responses)')
sheet = spreadsheet.sheet1

# Extract all data from the sheet
responses = sheet.get_all_records()

# Loop through each response and create a cleaned CSV file
for response in responses:
    timestamp = response['Timestamp']
    fn = response['First Name'].lower()
    ln = response['Last Name'].lower()
    textsize = response['How large would you like the text scaling?']
    cursor = response['How large would you like the Mouse Cursor?']
    narrator = response['Would you like to turn on Narrator?']
    magnifier = response['Would you like to turn on Magnifier?']
    voice = response['Would you like to turn on Voice Access?']
    keyboard = response['Would you like to turn on an On Screen Keyboard?']
    languages = '(' + response['Select all additional languages for keyboard loadout'] + ')'

    eyecontrol = response['Would you like to turn on Eye Control?']

    # Create a list with cleaned data
    cleaned_data = [fn, ln, textsize, cursor, narrator, magnifier, voice, keyboard, languages, eyecontrol]

    # Create a filename
    filename = f"AccessibilityAutomation/Capstone-Utils/CSVs/{fn}_{ln}.csv"

    # Check if the file already exists
    if os.path.exists(filename):
        print(f"File '{filename}' already exists.")
    else:
        # Write data to the CSV file
        with open(filename, 'w') as f:
            f.write(','.join(map(str, cleaned_data)))
        print(f"File '{filename}' created successfully.")
