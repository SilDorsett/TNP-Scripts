#!/bin/bash

set -x

TODAY=$(date +%Y%m%d)
YESTERDAY=$(date -d "yesterday" +%Y%m%d)

# This needs to change based on which server runs this code.
NS_HOME=/mnt/nationstates

# For XML starlet to make everything lower case for security council tasks.
COMMAND="translate(NAME,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"


###########################
# NationStates Daily Dump #
###########################

# Get the NationStates daily dump.
curl https://www.nationstates.net/pages/nations.xml.gz --output $NS_HOME/nations/nations.xml.gz.tmp

# A protection measure. If there's a problem with the daily data dump,
# like if the download failed or the site returned bad data, then don't
# clobber the existing nations.xml.gz file. We'll just run stats off
# the old one. I expect good data to be at least 10 MB in size, compressed.

if [ $(stat -c%s $NS_HOME/nations/nations.xml.gz.tmp) -gt 1000000 ]; then
   cat $NS_HOME/nations/nations.xml.gz.tmp > $NS_HOME/nations/nations.xml.gz
fi
rm $NS_HOME/nations/nations.xml.gz.tmp


# Compress yesterday's files.
gzip $NS_HOME/nations/nations.$YESTERDAY.xml
gzip $NS_HOME/nations_tnp/nations_tnp.$YESTERDAY.xml
gzip $NS_HOME/nations_tnp_wa/nations_tnp_wa.$YESTERDAY.xml

# Uncompress today's file.
gunzip -c $NS_HOME/nations/nations.xml.gz > $NS_HOME/nations/nations.$TODAY.xml

# Remove all data from nations that aren't in The North Pacific.
#xmlstarlet ed -d "//NATIONS/NATION[not(REGION='The North Pacific')]" $NS_HOME/nations/nations.$TODAY.xml > $NS_HOME/nations_tnp/nations_tnp.$TODAY.xml
python /home/nationstates/scripts/dailydump/delete_all_non_tnp.py $TODAY

# Remove all data from nations (in The North Pacific) that aren't WA nations.
#xmlstarlet ed -d "//NATIONS/NATION[not(UNSTATUS='WA Member' or UNSTATUS='WA Delegate')]" $NS_HOME/nations_tnp/nations_tnp.$TODAY.xml > $NS_HOME/nations_tnp_wa/nations_tnp_wa.$TODAY.xml
python /home/nationstates/scripts/dailydump/delete_all_tnp_nonwa.py $TODAY

# Using the $NS_HOME/nations_tnp.$TODAY.xml, parse it to generate a list of all TNP nations, one nation per line
xmlstarlet sel -t -m "//NATIONS/NATION[REGION='The North Pacific']" \
          -v "NAME" -n $NS_HOME/nations_tnp/nations_tnp.$TODAY.xml | awk '{print tolower($0)}' | sed 's/[[:space:]]/_/g' \
          | sort > $NS_HOME/nations_tnp_list/nations_tnp_list.$TODAY.txt

# Using the $NS_HOME/nations_tnp_wa.$TODAY.xml, parse it to generate a list of all World Assembly nations in TNP, one nation per line
xmlstarlet sel -t -m "//NATIONS/NATION[UNSTATUS='WA Member' or UNSTATUS='WA Delegate'][REGION='The North Pacific']" \
          -v "NAME" -n $NS_HOME/nations_tnp_wa/nations_tnp_wa.$TODAY.xml | awk '{print tolower($0)}' | sed 's/[[:space:]]/_/g' \
          | sort > $NS_HOME/nations_tnp_wa_list/nations_tnp_wa_list.$TODAY.txt

# Compare the list of All TNP Nations with the list of TNP WA Nations to generate a list of all TNP nations that are not WA.

### A NOTE ABOUT COMM ###
# `comm` returns a list in three columns, 1. lines unique to the first file passed,
# 2. lines unique to the second file passed, 3. lines in both files.
# `comm -23` means to omit columns 2 and 3, meaning I only want to see what's in column 1,
# which is entries only present in the first file.
# So, for this next line, look at 1. All TNP nations, and 2. TNP WA nations,
# and exclude anything unique to file 2 (which in this case should be nothing) and
# whatever's in both files, leaving only nations that are only in the first file,
# which is the list of TNP nations that are not WAs.

comm -23 $NS_HOME/nations_tnp_list/nations_tnp_list.$TODAY.txt $NS_HOME/nations_tnp_wa_list/nations_tnp_wa_list.$TODAY.txt > $NS_HOME/nations_tnp_nonwa_list/nations_tnp_nonwa_list.$TODAY.txt
