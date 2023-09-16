#!/bin/bash

cat /dev/null > /mnt/nationstates/rmbcheck/rmbcheck.FULL.csv

for ((i=0; i<=70000; i+=100)); do
   python /home/nationstates/scripts/dumprmbxmltocsv.py ${i}
   cat /mnt/nationstates/rmbcheck/rmbcheck.${i}.csv >> /mnt/nationstates/rmbcheck/rmbcheck.FULL.csv
done

sort /mnt/nationstates/rmbcheck/rmbcheck.FULL.csv > /mnt/nationstates/rmbcheck/rmbcheck.FULLSORTED.csv

