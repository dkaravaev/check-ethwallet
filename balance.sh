#!/bin/bash

source utils.sh

# MUST BE IN THE END OF THE MAIN!!!
# ret - ret of kill
# params:
#   $1 - PID
end() {
    # close server
    kill $1
    exit
}

# main function
cli_main() {
    STATUS=$(check_eth)
    if [ $STATUS != "OK" ];
    then
        echo $STATUS
        exit
    fi

    RET=$(run_server)
    SERVER_URL=$(echo $RET | awk -F',' '{print $1}')
    ETH_PID=$(echo $RET | awk -F',' '{print $2}')

    STRACC=$(get_accounts $SERVER_URL)
    ACCOUNTS=($STRACC)

    printf "$(accounts2str ${ACCOUNTS[@]})"
    printf "Please, type the index of any account:\n"
    read INDEX

    # check if index is a correct integer
    if [[ $INDEX =~ ^[0-9]+$ ]] && [[ $INDEX < ${#ACCOUNTS[@]} ]];
    then
        BALANCE=$(get_balance ${ACCOUNTS[$INDEX]} $SERVER_URL)
        printf "Balance of ${ACCOUNTS[$INDEX]}: $BALANCE eth.\n"
    else
        printf "Unknown index!\n"
    fi

    end $ETH_PID
}


cli_main
