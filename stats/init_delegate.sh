#!/bin/bash

set -x

TODAY=$(date +%Y%m%d)
YESTERDAY=$(date -d "yesterday" +%Y%m%d)

NS_HOME=/mnt/nationstates

#################
# Delegate Init #
#################

SPREADSHEET_ID="1G9aqm9JVlr447Rg5A4G3zjhpkEf92qRZRR5oE7p8_Fc"
RANGE_NAME="Sheet1!C1"
JSON_KEY_FILE="/home/nationstates/data/tnpstatistics-0bad485533ef.json"

# Call the Python script to retrieve the Delegate
cell_value=$(python /home/nationstates/scripts/utils/read_sc_sheet.py $SPREADSHEET_ID $RANGE_NAME $JSON_KEY_FILE)
cell_value=$(echo "$cell_value" | awk '!seen[$0]++')
echo "[DEBUG]Cell Value: $cell_value"

# In case there's a problem reading the spreadsheet, don't clobber the Delegate file.
if [ -z "${cell_value}" ]; then
   echo "The returned delegate NULL and will not overwrite the previous setup."
   cp -p $NS_HOME/delegate/delegate.${YESTERDAY}.txt $NS_HOME/delegate/delegate.${TODAY}.txt
else
   > $NS_HOME/delegate/delegate.${TODAY}.txt
   while read name; do
      echo "$name" >> $NS_HOME/delegate/delegate.${TODAY}.txt
   done <<< "$cell_value"
fi
