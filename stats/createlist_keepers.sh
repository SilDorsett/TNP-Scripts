#!/bin/bash

set -x

##########################
# Variables / Init Stuff #
##########################

TODAY=$(date +%Y%m%d)
YESTERDAY=$(date -d "yesterday" +%Y%m%d)

# This needs to change based on which server runs this code.
NS_HOME=/mnt/nationstates

#############################
# Keepers of the North List #
#############################

# For every WA nation, check to see if they are endorsing each Del/VD/SCer.
# If they're endorsing a Del/VD/SCer, or if they are the Del/VD/SCer being
# checked against, increment the ENDOCOUNT by 1. At the end of all Del/VD/SCers,
# if they have an ENDOCOUNT equal to the number of Del/VD/SCers, they're a
# Keeper of the North and get added to the list.

SC_MEMBERS=$(< ${NS_HOME}/securitycouncil/securitycouncil.$TODAY.txt)
SC_COUNT=$(cat ${NS_HOME}/securitycouncil/securitycouncil.$TODAY.txt | wc -l)
KEEPERS=0

for wanation in $(cat ${NS_HOME}/nations_tnp_wa_list/nations_tnp_wa_list.$TODAY.txt); do
   echo "Processing $wanation"
   ENDOCOUNT=0
   for scer in $SC_MEMBERS; do
     if [ "${wanation}" == "${scer}" ]; then
        ((ENDOCOUNT++))
        continue
     fi
     for nation in $(grep -w "$wanation" ${NS_HOME}/endolists/endorsing_${scer}.txt); do
        if [ "${nation}" == "${wanation}" ]; then
           ((ENDOCOUNT++))
        fi
     done
   done
   if [ $ENDOCOUNT -eq $SC_COUNT ]; then
      echo "$wanation" >> $NS_HOME/keepers/keepers_of_the_north.${TODAY}.txt
      ((KEEPERS++))
   fi
done

# Compare the list of WA nations against the list of Keepers to determine who are WAs that are not keepers.
comm -23 $NS_HOME/nations_tnp_wa_list/nations_tnp_wa_list.$TODAY.txt $NS_HOME/keepers/keepers_of_the_north.$TODAY.txt > $NS_HOME/not_keepers/not_keepers.$TODAY.txt

