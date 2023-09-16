#!/bin/bash

TODAY=$(date +%Y%m%d)
YESTERDAY=$(date -d "yesterday" +%Y%m%d)
MONTHAGO=$(date -d "30 days ago" +%Y%m%d)
UPD_TIME=$(date -d "Now")

NS_HOME=/mnt/nationstates

# This Spreadsheet has a list of the Delegate, VD, and SC members.
SPREADSHEET_ID="1aQ9EplmCzZLz7AmWQwpSXiCPo60AdyGG97PR1lD2tWM"
RANGE_NAME="Citizens!A3:E"
JSON_KEY_FILE="/home/nationstates/data/tnpstatistics-8365189f5916.json"

cit_profile_list=$(python /home/nationstates/scripts/utils/read_citizens_data.py "$SPREADSHEET_ID" "$RANGE_NAME" "$JSON_KEY_FILE")

report_file=/mnt/nationstates/citizen_forum_report/citizen_forum_report.$TODAY.html

cat /dev/null > $report_file

echo "<!DOCTYPE html>" >> $report_file
echo "<html>" >> $report_file
echo "<head>" >> $report_file
echo "<link rel=\"stylesheet\" href=\"../cittable.css\">" >> $report_file
echo "</head>" >> $report_file
echo "<body>" >> $report_file




echo "<h2>Citizenship Checks</h2>" >> $report_file
echo "Last Updated: $UPD_TIME" >> $report_file
echo "<br><br> Reminder: Check all links to ensure report accuracy. Forum Profile Posts are not counted in this sheet but do count towards maintaining citizenship" >> $report_file
echo "<br><br><br>" >> $report_file


################################################
### SECTION FOR ONLY THOSE OUT OF COMPLIANCE ###
################################################

echo "<b>CITIZENS OUT OF COMPLIANCE</b>" >> $report_file

echo "<table class=\"tg\">" >> $report_file
echo "<thead>" >> $report_file
echo "  <tr>" >> $report_file
echo "    <th class=\"tg-header\">ID</th>" >> $report_file
echo "    <th class=\"tg-header\">Forum Acct.</th>" >> $report_file
echo "    <th class=\"tg-header\">Compliance</th>" >> $report_file
echo "    <th class=\"tg-header\">In-Region</th>" >> $report_file
echo "    <th class=\"tg-header\">Forum</th>" >> $report_file
echo "    <th class=\"tg-header\">RMB</th>" >> $report_file
echo "    <th class=\"tg-header\">Nation Page</th>" >> $report_file
echo "    <th class=\"tg-header\">Forum Profile</th>" >> $report_file
echo "    <th class=\"tg-header\">RMB Search</th>" >> $report_file
echo "  </tr>" >> $report_file
echo "</thead>" >> $report_file
echo "<tbody>" >> $report_file


IFS=$'\n' read -r -d '' -a rows <<< "$cit_profile_list"
for row in "${rows[@]}"; do
   echo "$row"

   # Split the row into separate columns based on the comma delimiter
   IFS=',' read -r -a columns <<< "$row"

   # Access individual columns
   citizen_id="${columns[0]}"
   forum_account="${columns[1]}"
   typeset -l tnp_nation=$(echo "${columns[3]}" | tr " " "_")
   profile_id="${columns[4]}"

   cit_compliance=1
   fail_region=0
   fail_forum=0
   fail_rmb=0

   messages_today=$(/home/nationstates/scripts/utils/get_num_messages.sh $profile_id)
   messages_monthago=$(grep $profile_id /mnt/nationstates/citizen_forum_tracker/cit_forum_lastpost.$MONTHAGO.txt | cut -d: -f2 )
   if [ -z $messages_monthago ]; then
      messages_monthago=0
   fi

   echo "$forum_account (Cit: $citizen_id)(Profile: $profile_id) has $messages_today messages now."
   echo "$forum_account (Cit: $citizen_id)(Profile: $profile_id) had $messages_monthago messages a month ago."

   if [ ! -f /mnt/nationstates/nations_tnp_list/nations_tnp_list.$TODAY.txt ]; then
      region_check=$(grep -cw "${tnp_nation}" /mnt/nationstates/nations_tnp_list/nations_tnp_list.$YESTERDAY.txt)
   else
      region_check=$(grep -cw "${tnp_nation}" /mnt/nationstates/nations_tnp_list/nations_tnp_list.$TODAY.txt)
   fi

   rmb_check=$(grep -cw "${tnp_nation}" /mnt/nationstates/rmb_cit_check/rmb_cit_check.$YESTERDAY.txt)

   if [ $region_check -lt 1 ]; then
     cit_compliance=0
     fail_region=1
   fi

   if [ $messages_today -le $messages_monthago ]; then
     fail_forum=1
   fi

   if [ $rmb_check -lt 1 ]; then
     echo "$forum_account (Cit: $citizen_id)(Profile: $profile_id) has NOT posted on the RMB in the last 30 Days."
     fail_rmb=1
   else
     echo "$forum_account (Cit: $citizen_id)(Profile: $profile_id) has posted on the RMB in the last 30 Days."
   fi

   if [ $fail_forum -gt 0 -a $fail_rmb -gt 0 ]; then
     cit_compliance=0
   fi

   if [ $cit_compliance -gt 0 ]; then
      echo "$forum_account (Cit: $citizen_id)(Profile: $profile_id) is compliant."
   else
      echo "$forum_account (Cit: $citizen_id)(Profile: $profile_id) is OUT OF COMPLIANCE."

      if [ $fail_region -gt 0 ]; then
         echo "<br>$tnp_nation is NOT IN THE REGION."
      fi
      if [ $fail_forum -gt 0 ]; then
         echo "<br>$forum_account HAS NOT POSTED ON THE FORUM in 30 Days."
      fi
      if [ $fail_rmb -gt 0 ]; then
        echo "<br>$forum_account HAS NOT POSTED ON THE RMB in 30 Days."
      fi

##      echo "<input type=\"checkbox\" id=\"cb${citizen_id}f\" name=\"cb${citizen_id}f\"><label for=\"cb${citizen_id}f\">Fail Forum</label> \
##            <input type=\"checkbox\" id=\"cb${citizen_id}r\" name=\"cb${citizen_id}r\"><label for=\"cb${citizen_id}r\">Fail RMB</label>" >> $report_file

##      echo "<br>$forum_account (Cit: $citizen_id)(Profile: $profile_id) is OUT OF COMPLIANCE." >> $report_file

echo "<tr>" >> $report_file
echo "<td class=\"tg-std\">${citizen_id}</td>" >> $report_file
echo "<td class=\"tg-std\">${forum_account}</td>" >> $report_file

      if [ $cit_compliance -gt 0 ]; then
         echo "<td class=\"tg-ovpass\">Pass</td>"  >> $report_file
      else
         echo "<td class=\"tg-ovfail\">FAIL</td>"  >> $report_file
      fi 

      if [ $fail_region -gt 0 ]; then
         echo "<td class=\"tg-compfail\">OUT</td>"  >> $report_file
      else
         echo "<td class=\"tg-comppass\">In</td>"  >> $report_file
      fi

      if [ $fail_forum -gt 0 ]; then
         echo "<td class=\"tg-compfail\">INACTIVE</td>" >> $report_file
      else
         echo "<td class=\"tg-comppass\">Active</td>" >> $report_file
      fi

      if [ $fail_rmb -gt 0 ]; then
        echo "<td class=\"tg-compfail\">INACTIVE</td>" >> $report_file
      else
        echo "<td class=\"tg-comppass\">Active</td>" >> $report_file
      fi

      echo "<td class=\"td-std\"><a href=\"https://www.nationstates.net/nation=${tnp_nation}\">${tnp_nation}</a></td>"  >> $report_file
      echo "<td class=\"td-std\"><a href=\"https://forum.thenorthpacific.org/profile/${profile_id}/#recent-content\">profile/${profile_id}</a></td>" >> $report_file
      echo "<td class=\"td-std\"><a href=\"https://www.nationstates.net/page=rmb_search?rmbsearch-text=&rmbsearch-author=${tnp_nation}&rmbsearch-region=The+North+Pacific&rmbsearch-sort=new\">nation=${tnp_nation}</a></td>" >> $report_file
      echo "<tr>" >> $report_file
   fi

done

echo "</tbody>" >> $report_file
echo "</table>" >> $report_file

############################
### SECTION FOR EVERYONE ###
############################

echo "<br><br><br><b>All Citizens</b>" >> $report_file

echo "<table class=\"tg\">" >> $report_file
echo "<thead>" >> $report_file
echo "  <tr>" >> $report_file
echo "    <th class=\"tg-header\">ID</th>" >> $report_file
echo "    <th class=\"tg-header\">Forum Acct.</th>" >> $report_file
echo "    <th class=\"tg-header\">Compliance</th>" >> $report_file
echo "    <th class=\"tg-header\">In-Region</th>" >> $report_file
echo "    <th class=\"tg-header\">Forum</th>" >> $report_file
echo "    <th class=\"tg-header\">RMB</th>" >> $report_file
echo "    <th class=\"tg-header\">Nation Page</th>" >> $report_file
echo "    <th class=\"tg-header\">Forum Profile</th>" >> $report_file
echo "    <th class=\"tg-header\">RMB Search</th>" >> $report_file
echo "  </tr>" >> $report_file
echo "</thead>" >> $report_file
echo "<tbody>" >> $report_file


IFS=$'\n' read -r -d '' -a rows <<< "$cit_profile_list"
for row in "${rows[@]}"; do
   echo "$row"

   # Split the row into separate columns based on the comma delimiter
   IFS=',' read -r -a columns <<< "$row"

   # Access individual columns
   citizen_id="${columns[0]}"
   forum_account="${columns[1]}"
   typeset -l tnp_nation=$(echo "${columns[3]}" | tr " " "_")
   profile_id="${columns[4]}"

   cit_compliance=1
   fail_region=0
   fail_forum=0
   fail_rmb=0

   messages_today=$(/home/nationstates/scripts/utils/get_num_messages.sh $profile_id)
   messages_monthago=$(grep $profile_id /mnt/nationstates/citizen_forum_tracker/cit_forum_lastpost.$MONTHAGO.txt | cut -d: -f2 )
   if [ -z $messages_monthago ]; then
      messages_monthago=0
   fi

   if [ ! -f /mnt/nationstates/nations_tnp_list/nations_tnp_list.$TODAY.txt ]; then
      region_check=$(grep -cw "${tnp_nation}" /mnt/nationstates/nations_tnp_list/nations_tnp_list.$YESTERDAY.txt)
   else
      region_check=$(grep -cw "${tnp_nation}" /mnt/nationstates/nations_tnp_list/nations_tnp_list.$TODAY.txt)
   fi

   rmb_check=$(grep -cw "${tnp_nation}" /mnt/nationstates/rmb_cit_check/rmb_cit_check.$YESTERDAY.txt)

   if [ $region_check -lt 1 ]; then
     cit_compliance=0
     fail_region=1
   fi

   if [ $messages_today -le $messages_monthago ]; then
     fail_forum=1
   fi

   if [ $rmb_check -lt 1 ]; then
     fail_rmb=1
   fi

   if [ $fail_forum -gt 0 -a $fail_rmb -gt 0 ]; then
     cit_compliance=0
   fi

   echo "<tr>" >> $report_file
   echo "<td class=\"tg-std\">${citizen_id}</td>" >> $report_file
   echo "<td class=\"tg-std\">${forum_account}</td>" >> $report_file

      if [ $cit_compliance -gt 0 ]; then
         echo "<td class=\"tg-ovpass\">Pass</td>"  >> $report_file
      else
         echo "<td class=\"tg-ovfail\">FAIL</td>"  >> $report_file
      fi

      if [ $fail_region -gt 0 ]; then
         echo "<td class=\"tg-compfail\">OUT</td>"  >> $report_file
      else
         echo "<td class=\"tg-comppass\">In</td>"  >> $report_file
      fi

      if [ $fail_forum -gt 0 ]; then
         echo "<td class=\"tg-compfail\">INACTIVE</td>" >> $report_file
      else
         echo "<td class=\"tg-comppass\">Active</td>" >> $report_file
      fi

      if [ $fail_rmb -gt 0 ]; then
        echo "<td class=\"tg-compfail\">INACTIVE</td>" >> $report_file
      else
        echo "<td class=\"tg-comppass\">Active</td>" >> $report_file
      fi

      echo "<td class=\"td-std\"><a href=\"https://www.nationstates.net/nation=${tnp_nation}\">${tnp_nation}</a></td>"  >> $report_file
      echo "<td class=\"td-std\"><a href=\"https://forum.thenorthpacific.org/profile/${profile_id}/#recent-content\">profile/${profile_id}</a></td>" >> $report_file
      echo "<td class=\"td-std\"><a href=\"https://www.nationstates.net/page=rmb_search?rmbsearch-text=&rmbsearch-author=${tnp_nation}&rmbsearch-region=The+North+Pacific&rmbsearch-sort=new\">nation=${tnp_nation}</a></td>" >> $report_file
      echo "</tr>" >> $report_file

done

echo "</tbody>" >> $report_file
echo "</table>" >> $report_file

cp -p $report_file /var/www/stanpit/speakersoffice/citizen_forum_report.html
