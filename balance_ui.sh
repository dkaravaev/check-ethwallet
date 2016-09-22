#!/bin/bash

BALANCE="./balance.sh"
OUTFILE=/tmp/obalance-$$

# check ability to display
# ret - return value of DIALOG variable
set_dialog() {
    DIALOG=dialog
    if [ ! -z $DISPLAY ]
    then
        which gdialog > /dev/null && DIALOG=gdialog || DIALOG=dialog
    fi

    echo $DIALOG
}

# MUST BE IN THE END OF MAIN!!!
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

# help's you to get everything you need
help () {
    echo "Usage: $0 [ host port | -h]."
}

# main function
ui_main() {
    NAME="EtherChecker 1.0"
    DIALOG=$(set_dialog)


    if [ $STATUS !=  ];
    then
        $DIALOG --title "Error!" --msgbox "$STATUS" 6 20
        exit
    fi

    while true
    do
        OPTIONS=()
        INDEX=1
        for ACCOUNT in ${ACCOUNTS[@]}:
        do
            OPTIONS+=($INDEX "$ACCOUNT")
            INDEX=$(($INDEX+1))
        done

        $DIALOG --keep-tite --title "$NAME" --menu "Select account:" 12 76 16 ${OPTIONS[@]} 2> $OUTFILE || end $ETH_PID

        INDEX=$(cat $OUTFILE)
        INDEX=$(($INDEX-1))
        BALANCE=$(get_balance ${ACCOUNTS[$INDEX]} $SERVER_URL)

        MSG="The balance of ${ACCOUNTS[$INDEX]}: $BALANCE eth.\nDo you want to check another wallet?"
        $DIALOG --title "$NAME" --yesno "$MSG" 10 50 || end $ETH_PID
    done
}

ui_main

