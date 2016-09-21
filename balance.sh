#!/bin/bash

ETH=$(which geth)

# runs Ethereum server
# ret - URL,PID
run_server() {
    # execute eth and redirect all output to /dev/null
    if ! $ETH --testnet --exec 'console.log("OK")' attach 2&>/dev/null  
    then
        # run eth webserver 
        $ETH --testnet --ws --fast 2&> /tmp/wallet-server.log & 
        # get server process PID
        PID=`jobs -p`
        echo $1
        # until webserver is not created look for it
        until grep -q 'WebSocket endpoint opened:' /tmp/wallet-server.log
        do
            sleep 3
        done
        # save the URL of server for future requests
        URL=`grep 'WebSocket endpoint opened:'  /tmp/wallet-server.log | sed 's/^.*WebSocket endpoint opened: //'`
        echo $URL,$PID
    fi
}

# get the accounts from server 
# ret - string with accounts
# params: 
#   $1 - SERVER_URL
get_accounts() {
    STRACC=`$ETH --testnet --exec 'eth.accounts' attach $1 | tr -d ',[]'`
    echo $STRACC
}

# concat accounts to text with indexes
# ret - formated string
# params:
#   $1 - array with accounts
accounts2str() {
    ACCOUNTS=${1}
    # concat all accounts for selection
    INDEX=0 # index of account
    TEXT=""
    for ACCOUNT in ${ACCOUNTS[@]}
    do
        TEXT+=$INDEX:" "$ACCOUNT"\n"
        INDEX=$(($INDEX+1))
    done
    echo $TEXT
}

# get balance by account name
# ret - BALANCE
# params: 
#   $1 - account name
#   $2 - SERVER_URL
get_balance() {
    # get balance by using JavaScript Web3 API
    BALANCE=`$ETH --testnet --exec "web3.fromWei(eth.getBalance($1), 'ether');" attach $2`
    echo $BALANCE
}

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
# param:
#   $1 - option (-a, -c)
balance_main() {
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

if [ -z $ETH ];  
then
    echo "Please, install Ethereum CLI based on GoLang (geth), or if you already have it, set the directory in PATH variable."
    exit  
else 
    balance_main
fi