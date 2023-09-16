#!/bin/bash

SCRIPT_HOME=/home/nationstates/scripts

# Initialize Security Council Data File
${SCRIPT_HOME}/stats/init_securitycouncil.sh

# Initialize Delegate Data File
${SCRIPT_HOME}/stats/init_delegate.sh

# Initialize Keepers List File
${SCRIPT_HOME}/stats/init_keepers.sh

# Download and Parse daily nations data file from nationstates.net
# MOST IMPORTANT
${SCRIPT_HOME}/dailydump/dailydump.sh

# Create endorsement lists for the WAD/VD/SCers
${SCRIPT_HOME}/stats/createlist_securitycouncil.sh

# Generate the list of Keepers of the North
${SCRIPT_HOME}/stats/createlist_keepers.sh

# Generate other statistics, including:
#    Number of Nations in TNP
#    Number of WA Nations in TNP
#    Number of Keepers of the North
#    Number of Endorsements the Serving Delegate has
${SCRIPT_HOME}/stats/gen_statistics.sh
