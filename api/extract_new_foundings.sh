#!/bin/bash

days_ago=$1

NS_HOME=/mnt/nationstates/

if [ -z ${days_ago} ]; then
   days_ago=0
fi

days_ago_plus_one=$(($days_ago + 1))

TIMESTAMP=$(date -d "00:00:00 ${days_ago} Days Ago" +%s)
TIMELIMIT=$(date -d "00:00:00 ${days_ago_plus_one} Days Ago" +%s)

FILE_DATE=$(date -d "${days_ago_plus_one} Days Ago" +%Y%m%d)
FILE_TIMESTAMP=$TIMESTAMP

echo "Now: $TIMESTAMP"
echo "Limit: $TIMELIMIT"

url="https://www.nationstates.net/cgi-bin/api.cgi"
curl_data="q=happenings;view=region.the_north_pacific;filter=founding"
curl_timestamp="beforetime="

cat /dev/null > ${NS_HOME}/new_foundings/new_foundings.${FILE_DATE}.txt

while [ $TIMESTAMP -gt $TIMELIMIT ]; do
   curl_prepare="${curl_data};${curl_timestamp}${TIMESTAMP}"

   echo "Calling ${url}?${curl_prepare}"

   response=$(curl -A "Sil Dorsett" "$url" --data "$curl_prepare" --http1.1)

   echo $response | xmllint --format - > /${NS_HOME}/new_foundings/new_foundings.${FILE_TIMESTAMP}.xml

   set_break=0
   while read -r line; do
      if [[ $line =~ \<EVENT\ id=\"[0-9]+\"\> ]]; then
         event_id=$(echo "$line" | grep -oP '(?<=id=")[0-9]+')
      elif [[ $line =~ \<TIMESTAMP\>[0-9]+\<\/TIMESTAMP\> ]]; then
         new_timestamp=$(echo "$line" | grep -oP '(?<=<TIMESTAMP>)[0-9]+')
         echo -e "$new_timestamp"
         if (( $new_timestamp < $TIMESTAMP )); then
            TIMESTAMP=$new_timestamp
         fi
      elif [[ $line =~ \<TEXT\>\<\!\[CDATA\[.*the_north_pacific.*\]\]\>\<\/TEXT\> ]]; then
         echo -e $line
         event_data=$(echo "$line" | grep -oP '@@(.+)@@' | sed 's/@@//g')
         echo "Found: $event_data"
         echo $event_data >> ${NS_HOME}/new_foundings/new_foundings.${FILE_DATE}.txt
      elif [[ $line =~ \<HAPPENINGS\/\> ]]; then
         set_break=1
      fi
   done < ${NS_HOME}/new_foundings/new_foundings.${FILE_TIMESTAMP}.xml
   rm ${NS_HOME}/new_foundings/new_foundings.${FILE_TIMESTAMP}.xml

   if [ $set_break -eq 1 ]; then
      echo "No data found."
      break
   fi

   echo "Dumped foundings after ${TIMESTAMP}"

   sleep 3
done
