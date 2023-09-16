import csv
import xml.etree.ElementTree as ET
import argparse

# Parse command-line arguments
parser = argparse.ArgumentParser(description='XML to CSV conversion')
parser.add_argument('num', type=int, help='Number for file name derivation')
parser.add_argument('filedate', type=int, help='Timestamp for the day')
args = parser.parse_args()

xml_file = f'/mnt/nationstates/rmbcheck/rmbcheck.{args.filedate}.{args.num}.txt'
csv_file = f'/mnt/nationstates/rmbcheck/rmbcheck.{args.filedate}.{args.num}.csv'

# Open the XML file
tree = ET.parse(xml_file)
root = tree.getroot()

# Create a list to store the extracted data
data = []

# Iterate over each POST element
for post in root.findall('.//POST'):
    timestamp = post.find('TIMESTAMP').text
    nation = post.find('NATION').text

    # Append the extracted data to the list
    data.append([timestamp, nation])

# Write the data to the CSV file
with open(csv_file, 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(data)  # Write the data rows

print(f'CSV file "{csv_file}" has been created.')
