#!/bin/bash

set -x

##########################
# Variables / Init Stuff #
##########################

TODAY=$(date +%Y%m%d)

# This needs to change based on which server runs this code.
NS_HOME=/mnt/nationstates
DELEGATE=$(cat $NS_HOME/delegate/delegate.${TODAY}.txt)

##############
# Statistics #
##############

# Generating three statistics here
# 1. The number of TNP nations
# 2. The number of WA nations in TNP
# 3. The number of Keepers of the North

cat $NS_HOME/nations_tnp_list/nations_tnp_list.$TODAY.txt | wc -l > $NS_HOME/nations_tnp_count/nations_tnp_count.$TODAY.txt
cat $NS_HOME/nations_tnp_wa_list/nations_tnp_wa_list.$TODAY.txt | wc -l > $NS_HOME/nations_tnp_wa_count/nations_tnp_wa_count.$TODAY.txt
cat $NS_HOME/keepers/keepers_of_the_north.$TODAY.txt | wc -l > $NS_HOME/keepers_count/keepers_of_the_north_count.$TODAY.txt
cat $NS_HOME/endolists/endorsing_${DELEGATE}.txt | wc -l > $NS_HOME/delegate_endo_count/delegate_endo_count.${TODAY}.txt
