#!/bin/bash

url="https://www.nationstates.net/cgi-bin/api.cgi"
curl_data="region=the_north_pacific&q=messages"
curl_offset="&offset="
curl_limit="&limit=100"

for ((i=0; i<=70000; i+=100)); do
   curl_prepare="${curl_data}${curl_offset}${i}${curl_limit}"
   #next=((i + 100))
   echo "Calling ${url}?${curl_prepare}"
   response=$(curl -A "Sil Dorsett" "$url" --data "$curl_prepare" --http1.1)
   echo $response > /mnt/nationstates/rmbcheck/rmbcheck.${i}.txt
   echo "Dumped messages ${i}"
   sleep 2
done
