#!/bin/bash

set -x

TODAY=$(date +%Y%m%d)
YESTERDAY=$(date -d "yesterday" +%Y%m%d)

# This needs to change based on which server runs this code.
NS_HOME=/mnt/nationstates

# For XML starlet to make everything lower case for security council tasks.
COMMAND="translate(NAME,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"

######################################
# Security Council Endorsement Lists #
######################################

for nation in $(cat /mnt/nationstates/securitycouncil/securitycouncil.${TODAY}.txt)
do
   TARGET=$(echo $nation | tr '_' ' ')
   PROPER=$(echo $nation | tr '_' ' ' | sed 's/\b\([a-z]\)/\u\1/g')

# Generate a list of all nations not endorsed by the Del/VD/SCMember.
# This is the full endorsement To Do list for that member.
   xmlstarlet sel -t -m "//NATIONS/NATION[UNSTATUS='WA Member' or UNSTATUS='WA Delegate'][REGION='The North Pacific'][not(contains(ENDORSEMENTS, '$nation'))]" \
          -v "NAME" -n $NS_HOME/nations_tnp_wa/nations_tnp_wa.$TODAY.xml | awk '!/${PROPER}/{print tolower($0)}' | sed 's/[[:space:]]/_/g' \
          | sort > $NS_HOME/endolists/not_endorsed_by_$nation.txt

# Generate a list of all nations endorsing the Del/VD/SCMember
   xmlstarlet sel -t -m "//NATIONS/NATION[${COMMAND}='$TARGET']" -v "ENDORSEMENTS" -n $NS_HOME/nations_tnp_wa/nations_tnp_wa.$TODAY.xml | tr ',' '\n' \
          | sort > $NS_HOME/endolists/endorsing_$nation.txt

# Generate a list of all nations that are endorsing the Del/VD/SCMember, but are not being endorsed back.
   comm -12 $NS_HOME/endolists/endorsing_$nation.txt $NS_HOME/endolists/not_endorsed_by_$nation.txt > $NS_HOME/endolists/endorsing_and_not_endorsed_by_$nation.txt

# Generate a list of all nations not endorsing the Del/VD/SCMember
   comm -23 $NS_HOME/nations_tnp_wa_list/nations_tnp_wa_list.$TODAY.txt $NS_HOME/endolists/endorsing_$nation.txt > $NS_HOME/endolists/not_endorsing_$nation.txt
done
