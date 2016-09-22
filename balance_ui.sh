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
end () {
    # close server
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

    STATUS=$($BALANCE -e)
    if [ $STATUS != "OK" ];
    then
        $DIALOG --title "Error!" --msgbox "$STATUS" 6 20
        exit
    fi

    OPTIONS=($($BALANCE -a))
    
    while true
    do
        $DIALOG --keep-tite --title "$NAME" --menu "Select account:" 12 76 16 ${OPTIONS[@]} 2> $OUTFILE || end 

        INDEX=$(cat $OUTFILE)
        INDEX=$(($INDEX-1))
        VALUE=$($BALANCE -i $INDEX)

        MSG="$VALUE\nDo you want to check another wallet?"
        $DIALOG --title "$NAME" --yesno "$MSG" 10 50 || end
    done
}

ui_main

