#!/bin/bash

set -x

##########################
# Variables / Init Stuff #
##########################

TODAY=$(date +%Y%m%d)
YESTERDAY=$(date -d "yesterday" +%Y%m%d)

# This needs to change based on which server runs this code.
NS_HOME=/mnt/nationstates

##############################
# Security Council File Init #
##############################

# Use Google Sheets API to get the list of nations to endorse to be a Keeper.
# You need a Google Sheets API key file.

# This Spreadsheet has a list of the Delegate, VD, and SC members.
SPREADSHEET_ID="1G9aqm9JVlr447Rg5A4G3zjhpkEf92qRZRR5oE7p8_Fc"
RANGE_NAME="Sheet1!C1:C"
JSON_KEY_FILE="/home/nationstates/data/tnpstatistics-8365189f5916.json"

# Call the Python script to retrieve the list of Security Council members
cell_value=$(python /home/nationstates/scripts/utils/read_sc_sheet.py $SPREADSHEET_ID $RANGE_NAME $JSON_KEY_FILE)
cell_value=$(echo "$cell_value" | awk '!seen[$0]++')

echo "[DEBUG]Cell Value: $cell_value"

# In case there's a problem reading the spreadsheet, don't clobber the list of SCers.
if [ -z "${cell_value}" ]; then
   echo "The range of SCers was NULL and will not overwrite the previous setup."
   cp -p $NS_HOME/securitycouncil/securitycouncil.${YESTERDAY}.txt $NS_HOME/securitycouncil/securitycouncil.${TODAY}.txt
else
   > $NS_HOME/securitycouncil/securitycouncil.${TODAY}.txt
   while read name; do
      echo "$name" >> $NS_HOME/securitycouncil/securitycouncil.${TODAY}.txt
   done <<< "$cell_value"
fi
