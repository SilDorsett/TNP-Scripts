#!/bin/bash

set -x

##########################
# Variables / Init Stuff #
##########################

TODAY=$(date +%Y%m%d)

# This needs to change based on which server runs this code.
NS_HOME=/mnt/nationstates

##########################
# Keepers List File Init #
##########################

touch $NS_HOME/keepers/keepers_of_the_north.${TODAY}.txt
cat /dev/null > $NS_HOME/keepers/keepers_of_the_north.${TODAY}.txt
