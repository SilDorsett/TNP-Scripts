#!/bin/bash

nshome=/mnt/nationstates
file=/mnt/nationstates/rmbcheck/rmbcheck.FULLSORTED.csv

for ((i=1; i<32; i+=1));do

   filedate=$(date -d "${i} days ago 00:00:00" +%Y%m%d)

   starttime=$(date -d "${i} days ago 00:00:00" +%s)
   endtime=$(date -d "$((i-1)) days ago 00:00:00" +%s)

   cat /dev/null > /mnt/nationstates/rmbcheck/rmb_daily_check.$filedate.csv

   rows=($(<"$file"))

   for row in "${rows[@]}"; do
      echo "$row"
      IFS=',' read -r -a columns <<< "$row"
      timestamp="${columns[0]}"

      if [[ "$timestamp" > "$starttime" && "$timestamp" < "$endtime" ]]; then
         echo "$row" >> /mnt/nationstates/rmbcheck/rmb_daily_check.$filedate.csv
      fi
   done
done
