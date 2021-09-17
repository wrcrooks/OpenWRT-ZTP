#!/bin/bash
# Dependencies: curl, jq, wget

# Global Variables
ZTP_URL="0.0.0.0:5000"
SECRET="jBqenDkRHd4ztdTeVeG2hYkM"
CLIENT_ID="undefined"

# Application Variables
LOOP=true

# Get Parameters
while getopts ":u:s:c:" OPT; do
    case $OPT in
        u) ZTP_URL="$OPTARG"
        ;;
        s) SECRET="$OPTARG"
        ;;
        c) CLIENT_ID="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
        ;;
    esac
done
# Try to Set CLIENT_ID
# USER --> [Exists] --> CLIENT_ID=$USER
#      --> [DNE]    --> CLIENT_ID=$SYST
# SYST --> [Exists] --> CLIENT_ID=$SYST
#      --> [DNE]    --> CLIENT_ID=$DEFA
CLIENT_ID_SYS=$(cat /sys/devices/platform/10100000.ethernet/net/eth0/address 2>/dev/null)
if [ "$CLIENT_ID" == "undefined" ]; then
    if [ "$CLIENT_ID_SYS" != "" ]; then
        CLIENT_ID="$CLIENT_ID_SYS"
    fi
fi
# Main Loop
while $LOOP; do
    RESPONSE=`curl -X POST -H "Content-Type: application/json" -d "{\"CLIENT_ID\": \"$CLIENT_ID\", \"SECRET\": \"$SECRET\"}" http://$ZTP_URL/query`
    if [ "$RESPONSE" == "INVALID_SECRET" ]; then
        LOOP=false
        /etc/init.d/ztp disable
    fi
    if [ "$RESPONSE" == "CLIENT_NOT_IN_TABLE" ]; then
        # End Script and Leave ZTP Check on Startup in place
        sleep 30
    fi
    if [ "$RESPONSE" == "ZTP_DISABLE" ]; then
        # End Script and Disable ZTP Check on Startup    
        LOOP=false
        /etc/init.d/ztp disable
    fi
    if [ "$RESPONSE" == "PASS" ]; then
        # Break Loop
        LOOP=false
        RESPONSE=`curl -X POST -H "Content-Type: application/json" -d "{\"CLIENT_ID\": \"$CLIENT_ID\", \"SECRET\": \"$SECRET\"}" http://$ZTP_URL/settings`
        BIN_FILENAME=`echo $RESPONSE | jq -r '.BIN_FILENAME'`
        FLASH_ENABLED=`echo $RESPONSE | jq -r '.FLASH_ENABLED'`
        echo $RESPONSE
        # echo $BIN_FILENAME
        if [ "$BIN_FILENAME" != "null" ]; then
            wget "http://$ZTP_URL/bin/$BIN_FILENAME.bin" -O "/tmp/$BIN_FILENAME.bin"
            SHA256=`sha256sum "/tmp/$BIN_FILENAME.bin" | cut -c 1-64`
            RESPONSE=`curl -X POST -H "Content-Type: application/json" -d "{\"CLIENT_ID\": \"$CLIENT_ID\", \"SECRET\": \"$SECRET\", \"DOWNLOADED\": \"True\"}" http://$ZTP_URL/update`
            RESPONSE=`curl -X POST -H "Content-Type: application/json" -d "{\"CLIENT_ID\": \"$CLIENT_ID\", \"SECRET\": \"$SECRET\", \"BIN_FILENAME\": \"$BIN_FILENAME\", \"SHA256\": \"$SHA256\"}" http://$ZTP_URL/verify`
            if [ "$FLASH_ENABLED" == "true" ]; then
                if [ "$RESPONSE" == "VALID" ]; then
                    echo "FLASHING..."
                    sysupgrade -v "/tmp/$BIN_FILENAME.bin"
                else
                    echo "Invalid Checksum"
                fi
            else
                echo "Not authorized to FLASH"
            fi
        else
            echo "No idea what to do here" #No bin filename returned
        fi
    fi
    if [ "$RESPONSE" == "HOLD" ]; then
        sleep 10
    fi
done