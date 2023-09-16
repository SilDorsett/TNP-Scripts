#!/bin/bash

set -x

#Where files are being stored
NS_HOME=/mnt/nationstates
RMBCHECK_HOME=${NS_HOME}/rmbcheck

#Timestamps
filedate=$(date -d "yesterday 00:00:00" +%Y%m%d)

ts_yesterday_startofday_utc=$(date -u -d "yesterday 00:00:00" +%s)
ts_yesterday_startofday_local=$(date -d "yesterday 00:00:00" +%s)
ts_yesterday_endofday_utc=$(date -u -d "yesterday 23:59:59" +%s)
ts_yesterday_endofday_local=$(date -d "yesterday 23:59:59" +%s)
ts_today_startofday_utc=$(date -u -d "today 00:00:00" +%s)
ts_today_startofday_local=$(date -d "today 00:00:00" +%s)
ts_today_endofday_utc=$(date -u -d "today 23:59:59" +%s)
ts_today_endofday_local=$(date -d "today 23:59:59" +%s)

#A function for checking to see if a timestamp is older than start of yesterday.;
function is_two_days_ago() {
    local timestamp=$1
    [[ $timestamp -lt $ts_yesterday_startofday_local ]]
}

#NationStates API Call
url=https://www.nationstates.net/cgi-bin/api.cgi
curl_data="region=the_north_pacific&q=messages"
curl_limit="&limit=100"
curl_offset="&offset="

#Create the RMBCheck aggregate file
cat /dev/null > ${RMBCHECK_HOME}/rmbcheck.${filedate}.FULL.csv
break_now=0
for ((i=0; i<=70000; i+=100)); do
   #Get 100 messages from NationStates
   curl_prepare="${curl_data}${curl_offset}${i}${curl_limit}"
   echo "Calling ${url}?${curl_prepare}"
   response=$(curl -A "Sil Dorsett" "$url" --data "$curl_prepare" --http1.1)

   #Write the messages to a temporary file
   echo $response > ${RMBCHECK_HOME}/rmbcheck.$filedate.${i}.txt
   echo "Dumped messages ${i}"
   #This wait time is mandatory to ensure compliance with API limits.
   sleep 2
   #This python scriptretrieves the timestamp and author
   python /home/nationstates/scripts/rmbcheck/dumprmbxmltocsv.py ${i} ${filedate}
   cat ${RMBCHECK_HOME}/rmbcheck.${filedate}.${i}.csv >> ${RMBCHECK_HOME}/rmbcheck.${filedate}.FULL.csv

   #See if there are any messages from two days ago. If yes, then this the last
   #file that needs to be retrieved.
   while IFS= read -r line; do
      timestamp=$(echo "$line" | cut -d',' -f1)
      if is_two_days_ago "$timestamp"; then
         echo "Found a timestamp from two days ago or earlier."
         break_now=1
      fi
   done < ${RMBCHECK_HOME}/rmbcheck.${filedate}.${i}.csv

   #Remove Temporary Files
   #rm ${RMBCHECK_HOME}/rmbcheck.${filedate}.${i}.csv
   #rm /stor/hda/nationstates/rmbcheck/rmbcheck.$filedate.${i}.txt

   if [ $break_now -eq 1 ]; then
      break
   fi
done

#Sort the list of messages by timestamp
sort ${RMBCHECK_HOME}/rmbcheck.${filedate}.FULL.csv > ${RMBCHECK_HOME}/rmbcheck.${filedate}.FULLSORTED.csv
dos2unix ${RMBCHECK_HOME}/rmbcheck.${filedate}.FULLSORTED.csv


#Generating the file that holds the timestamps and authors for messages for the day being checked.
#This will remove any messages from the day before that shouldn't be there.
cat /dev/null > ${NS_HOME}/rmb_daily_check/rmb_daily_check.${filedate}.csv

rows=($(<"${RMBCHECK_HOME}/rmbcheck.${filedate}.FULLSORTED.csv"))

for row in "${rows[@]}"; do
   echo "$row"
   IFS=',' read -r -a columns <<< "${row}"
   timestamp="${columns[0]}"

   if [[ "$timestamp" -ge "$ts_yesterday_startofday_local" && "$timestamp" -lt "$ts_today_startofday_local" ]]; then
      echo "$row" >> ${NS_HOME}/rmb_daily_check/rmb_daily_check.${filedate}.csv
   fi
done

#Generating the list of users detected in the daily aggregate file
cat /dev/null > ${NS_HOME}/rmb_daily_users/rmb_daily_users.${filedate}.txt

while read -r line; do
   echo $line | cut -d',' -f2 >> ${NS_HOME}/rmb_daily_users/rmb_daily_users.${filedate}.txt
done < ${NS_HOME}/rmb_daily_check/rmb_daily_check.${filedate}.csv

awk -i inplace '!seen[$0]++' ${NS_HOME}/rmb_daily_users/rmb_daily_users.${filedate}.txt
dos2unix ${NS_HOME}/rmb_daily_users/rmb_daily_users.${filedate}.txt


#Remove temporary files
find ${RMBCHECK_HOME} -type f

#Create the file that counts how many messages from each user are in the daily check file.

cat /dev/null > ${NS_HOME}/rmb_daily_counts/rmb_daily_counts.${filedate}.txt

while read line; do
   count=$(grep -c -- "${line}" ${NS_HOME}/rmb_daily_check/rmb_daily_check.${filedate}.csv)
   if [ $count -gt 0 ];then
      echo "${line}:${count}" >> ${NS_HOME}/rmb_daily_counts/rmb_daily_counts.${filedate}.txt
   fi
done < ${NS_HOME}/rmb_daily_users/rmb_daily_users.${filedate}.txt

#Timestamps
cit_check_filedate=$(date -d "yesterday 00:00:00" +%Y%m%d)


cat /dev/null > ${NS_HOME}/rmb_cit_check/rmb_cit_check.${cit_check_filedate}.tmp


for ((i=1; i<=30; i+=1)); do
   loop_filedate=$(date -d "${i} days ago 0:00:00" +%Y%m%d)
   cat ${NS_HOME}/rmb_daily_users/rmb_daily_users.${loop_filedate}.txt >> ${NS_HOME}/rmb_cit_check/rmb_cit_check.${cit_check_filedate}.tmp
done

cat ${NS_HOME}/rmb_cit_check/rmb_cit_check.${cit_check_filedate}.tmp | sort | uniq > ${NS_HOME}/rmb_cit_check/rmb_cit_check.${cit_check_filedate}.txt

#rm ${NS_HOME}/rmb_cit_check/rmb_cit_check.${cit_check_filedate}.tmp
