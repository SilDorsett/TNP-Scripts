#!/bin/bash

TODAY=$(date +%Y%m%d)

NS_HOME=/mnt/nationstates

# This Spreadsheet has a list of the Delegate, VD, and SC members.
SPREADSHEET_ID="1aQ9EplmCzZLz7AmWQwpSXiCPo60AdyGG97PR1lD2tWM"
RANGE_NAME="Citizens!E3:E"
JSON_KEY_FILE="/home/nationstates/data/tnpstatistics-8365189f5916.json"

cit_profile_list=$(python /home/nationstates/scripts/utils/read_citizen_sheet.py "$SPREADSHEET_ID" "$RANGE_NAME" "$JSON_KEY_FILE")

report_file=/mnt/nationstates/citizen_forum_tracker/cit_forum_lastpost.$TODAY.txt

cat /dev/null > $report_file

for profile in $cit_profile_list; do
   echo "Reading profile $profile..."
   num_messages=$(/home/nationstates/scripts/utils/get_num_messages.sh $profile)
   echo "Profile $profile has $num_messages"
   echo "$profile:$num_messages" >> $report_file
done
