#!/bin/bash

NS_HOME=/mnt/nationstates

days_ago=$1

if [ -z ${days_ago} ]; then
   days_ago=0
fi

FILE_DATE_1=$(date -d "$((days_ago + 1)) Days Ago" +%Y%m%d)
FILE_DATE_2=$(date -d "$((days_ago + 2)) Days Ago" +%Y%m%d)
FILE_DATE_3=$(date -d "$((days_ago + 3)) Days Ago" +%Y%m%d)
FILE_DATE_4=$(date -d "$((days_ago + 4)) Days Ago" +%Y%m%d)
FILE_DATE_5=$(date -d "$((days_ago + 5)) Days Ago" +%Y%m%d)
FILE_DATE_6=$(date -d "$((days_ago + 6)) Days Ago" +%Y%m%d)
FILE_DATE_7=$(date -d "$((days_ago + 7)) Days Ago" +%Y%m%d)

cat /dev/null > /stor/hda/nationstates/new_foundings/new_foundings_list.tmp

for file in $FILE_DATE_1 $FILE_DATE_2 $FILE_DATE_3 $FILE_DATE_4 $FILE_DATE_5 $FILE_DATE_6 $FILE_DATE_7; do
   echo $file
   if [ -e ${NS_HOME}/new_foundings/new_foundings.$file.txt ]; then
      cat ${NS_HOME}/new_foundings/new_foundings.$file.txt >> ${NS_HOME}/new_foundings/new_foundings_list.tmp
   fi
done

cat ${NS_HOME}/new_foundings/new_foundings_list.tmp | sort | uniq > ${NS_HOME}/new_foundings/new_foundings_list.tmp2

cat /dev/null > ${NS_HOME}/new_foundings/new_foundings_list.txt

python /home/nationstates/scripts/stats/compile_new_foundings_weekly.py
