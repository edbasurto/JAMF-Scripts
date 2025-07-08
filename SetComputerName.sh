#!/bin/bash

# I run this script within a polict that runs when enrollment is complete. This will ask for the Asset Tag you want to use, then name the device as "MAC-$ASSETTAG". For example, MAC-57575.
# This script only accepts numbers for the asset tag field

assetTag=""

while [ -z "$assetTag" ]; do

    assetTag=$(osascript -e 'display dialog "Please enter the Asset Tag of the device:" default answer "" buttons {"Cancel", "OK"}' -e 'text returned of result')

    # echo $assetTag

    re='^[0-9]+$'

    if [ -n "$assetTag" ]; then
        if [[ $assetTag =~ $re ]]; then
            choice=$(osascript -e "display dialog \"Use $assetTag as asset tag?\" buttons {\"No\", \"Yes\"} default button \"Yes\"" -e 'button returned of result')
            if [ "$choice" = "Yes" ]; then
                NEW_NAME="MAC-$assetTag"
                # echo $NEW_NAME
                sudo scutil --set ComputerName "$NEW_NAME"
                sudo scutil --set LocalHostName "$NEW_NAME"
                sudo scutil --set HostName "$NEW_NAME"
                sudo dscacheutil -flushcache
                sudo killall -HUP mDNSResponder
                sudo jamf recon
                osascript -e "display dialog \"Computer name is now set to $NEW_NAME\" buttons {\"OK\"}"
                # echo"<result>$assetTag</result>"
            else
                assetTag=""
            fi
        else
            osascript -e "display dialog \"Asset tag needs to be a number!\" buttons {\"OK\"}"
            assetTag=""
        fi
    fi
done

exit 0
