#!/bin/bash

set -x

#Where files are being stored
NS_HOME=/mnt/nationstates

#Timestamps
filedate=$(date -d "yesterday 00:00:00" +%Y%m%d)


cat /dev/null > ${NS_HOME}/rmb_cit_check/rmb_cit_check.${filedate}.tmp


for ((i=1; i<=30; i+=1)); do
   loop_filedate=$(date -d "${i} days ago 0:00:00" +%Y%m%d)
   cat ${NS_HOME}/rmb_daily_users/rmb_daily_users.${loop_filedate}.txt >> ${NS_HOME}/rmb_cit_check/rmb_cit_check.${filedate}.tmp
done

cat ${NS_HOME}/rmb_cit_check/rmb_cit_check.${filedate}.tmp | sort | uniq > ${NS_HOME}/rmb_cit_check/rmb_cit_check.${filedate}.txt

#rm ${NS_HOME}/rmb_cit_check/rmb_cit_check.${filedate}.tmp

