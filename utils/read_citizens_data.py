import sys
from google.oauth2 import service_account
from googleapiclient.discovery import build

# Replace the following values with your own.
spreadsheet_id = sys.argv[1]
range_name = sys.argv[2]
json_key_file = sys.argv[3]

# Authenticate with the Google Sheets API using the service account key file.
credentials = service_account.Credentials.from_service_account_file(json_key_file)
service = build('sheets', 'v4', credentials=credentials)

# Call the Google Sheets API to get the cell values.
result = service.spreadsheets().values().get(spreadsheetId=spreadsheet_id, range=range_name).execute()

values = result.get('values', [])

if not values:
    print('No data found.')
else:
    for row in values:
        output = f"{row[0]},{row[1]},{row[2]},{row[3]},{row[4]}"
        print(output)
