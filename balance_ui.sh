#!/bin/bash

source utils.sh

OUTFILE=/tmp/obalance-$$

# check ability to display
if [ -z $DISPLAY ]
then
    DIALOG=dialog
else
    which gdialog > /dev/null && DIALOG=gdialog || DIALOG=dialog
fi

# MUST BE IN THE END OF THE MAIN!!!
# ret - ret of kill
# params:
#   $1 - PID
end () {
    # close server
    kill $1
    clear
    rm -f $OUTFILE
    exit
}

# main function
ui_main() {
    STATUS=$(check_eth)
    if [ $STATUS != "OK" ];
    then
        $DIALOG --title "Error!" --msgbox "$STATUS" 6 20
        exit
    fi

    RET=$(run_server)
    SERVER_URL=$(echo $RET | awk -F',' '{print $1}')
    ETH_PID=$(echo $RET | awk -F',' '{print $2}')

    STRACC=$(get_accounts $SERVER_URL)
    ACCOUNTS=($STRACC)

    while true
    do
        OPTIONS=()
        INDEX=1
        for ACCOUNT in ${ACCOUNTS[@]}:
        do
            OPTIONS+=($INDEX "$ACCOUNT")
            INDEX=$(($INDEX+1))
        done

        $DIALOG --keep-tite --title "EtherChecker 1.0" --menu "Select account:" 12 76 16 ${OPTIONS[@]} 2> $OUTFILE || end $ETH_PID

        INDEX=$(cat $OUTFILE)
        INDEX=$(($INDEX-1))

        BALANCE=$(get_balance ${ACCOUNTS[$INDEX]} $SERVER_URL)
        MSG="The balance of ${ACCOUNTS[$INDEX]}: $BALANCE eth.\nDo you want to check another wallet?"
        $DIALOG --title "EtherChecker 1.0" --yesno "$MSG" 10 50 || end $ETH_PID
    done
}

ui_main

