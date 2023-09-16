#!/bin/bash

userUID=$1

# Fetch the webpage
page_content=$(curl -s "https://forum.thenorthpacific.org/profile/$userUID/")

# Extract the number under "Messages"
messages=$(echo "$page_content" | grep -A 3 "<dt>Messages</dt>" | sed -n '4s/[[:space:], ]//g; 4p')

# Output the extracted value
echo "${messages}"
