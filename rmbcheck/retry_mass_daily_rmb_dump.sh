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
ts_30dago_startofday_utc=$(date -u -d "30 days ago 00:00:00" +%s)
ts_30dago_startofday_local=$(date -d "30 days ago 00:00:00" +%s)
ts_30dago_endofday_utc=$(date -u -d "30 days ago 00:00:00" +%s)
ts_30dago_endofday_local=$(date -d "30 days ago 00:00:00" +%s)



#A function for checking to see if a timestamp is older than start of yesterday.;
function is_two_days_ago() {
    local timestamp=$1
    [[ $timestamp -lt $ts_yesterday_startofday_local ]]
}

function is_30_days_ago() {
    local timestamp=$1
    [[ $timestamp -lt $ts_30dago_startofday_local ]]
}

#Sort the list of messages by timestamp
sort ${RMBCHECK_HOME}/rmbcheck.${filedate}.FULL.csv > ${RMBCHECK_HOME}/rmbcheck.${filedate}.FULLSORTED.csv
dos2unix ${RMBCHECK_HOME}/rmbcheck.${filedate}.FULLSORTED.csv

for ((i=1; i<=30; i+=1)); do

   loop_filedate=$(date -d "${i} days ago 0:00:00" +%Y%m%d)
   
   ts_loop_today_startofday_local=$(date -d "$(( ${i} - 1 )) days ago 00:00:00" +%s)
   ts_loop_yesterday_startofday_local=$(date -d "${i} days ago 00:00:00" +%s)

   #Generating the file that holds the timestamps and authors for messages for the day being checked.
   #This will remove any messages from the day before that shouldn't be there.
   cat /dev/null > ${NS_HOME}/rmb_daily_check/rmb_daily_check.${loop_filedate}.csv

   rows=($(<"${RMBCHECK_HOME}/rmbcheck.${filedate}.FULLSORTED.csv"))

   for row in "${rows[@]}"; do
      echo "$row"
      IFS=',' read -r -a columns <<< "${row}"
      timestamp="${columns[0]}"

      if [[ "$timestamp" -ge "$ts_loop_yesterday_startofday_local" && "$timestamp" -lt "$ts_loop_today_startofday_local" ]]; then
         echo "$row" >> ${NS_HOME}/rmb_daily_check/rmb_daily_check.${loop_filedate}.csv
      fi
   done

   #Generating the list of users detected in the daily aggregate file
   cat /dev/null > ${NS_HOME}/rmb_daily_users/rmb_daily_users.${loop_filedate}.txt

   while read -r line; do
      echo $line | cut -d',' -f2 >> ${NS_HOME}/rmb_daily_users/rmb_daily_users.${loop_filedate}.txt
   done < ${NS_HOME}/rmb_daily_check/rmb_daily_check.${loop_filedate}.csv

   awk -i inplace '!seen[$0]++' ${NS_HOME}/rmb_daily_users/rmb_daily_users.${loop_filedate}.txt
   dos2unix ${NS_HOME}/rmb_daily_users/rmb_daily_users.${loop_filedate}.txt


   #Create the file that counts how many messages from each user are in the daily check file.

   cat /dev/null > ${NS_HOME}/rmb_daily_counts/rmb_daily_counts.${loop_filedate}.txt

   while read line; do
      count=$(grep -c -- "${line}" ${NS_HOME}/rmb_daily_check/rmb_daily_check.${loop_filedate}.csv)
      if [ $count -gt 0 ];then
         echo "${line}:${count}" >> ${NS_HOME}/rmb_daily_counts/rmb_daily_counts.${loop_filedate}.txt
      fi
   done < ${NS_HOME}/rmb_daily_users/rmb_daily_users.${loop_filedate}.txt

done


#Remove temporary files
find ${RMBCHECK_HOME} -type f

