#!/bin/bash

nshome=/mnt/nationstates/

cd $nshome/rmbcheck/

for file in $(ls rmb_daily_check*); do

   output=$(echo ${file} | cut -d'.' -f1,2).txt
   
   cat /dev/null > $output

   while read line; do
      count=$(grep -c -- "${line}" ${file})
      if [ $count -gt 0 ];then
         echo "${line}:${count}" >> $output
      fi
   done < rmbusers.FULLSORTED.txt
done
