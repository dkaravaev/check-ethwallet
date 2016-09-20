#!/bin/bash
ETH=geth

# execute eth and redirect all output to /dev/null
if ! $ETH --testnet --exec 'console.log("OK")' attach 2&>/dev/null  
then
    # run eth webserver 
    $ETH --testnet --ws --fast 2&>/tmp/$ETH.log & 
    # get server process PID
    GETH_PID=`jobs -p`
    # until webserver is not created look for it
    until grep -q 'WebSocket endpoint opened:' /tmp/$ETH.log
    do
        sleep 3
    done
    # save the URL of server for future requests
    SERVER_URL=`grep 'WebSocket endpoint opened:' /tmp/$ETH.log | sed 's/^.*WebSocket endpoint opened: //'`
fi

# get the accounts from server 
STRACC=`$ETH --testnet --exec 'eth.accounts' attach $SERVER_URL | tr -d ',[]'`
ACCOUNTS=($STRACC)

# show all accounts for selection
INDEX=0 # index of account
for ACCOUNT in ${ACCOUNTS[@]}
do
	echo $INDEX: $ACCOUNT
	INDEX=$(($INDEX+1))
done

printf "Please, type the index of any account:\n"
read INDEX

# get balance by using JavaScript Web3 API
BALANCE=`$ETH --testnet --exec "web3.fromWei(eth.getBalance(${ACCOUNTS[$INDEX]}), 'ether');" attach $SERVER_URL`

printf "Balance of ${ACCOUNTS[$INDEX]}: $BALANCE eth.\n"

# close server
kill $GETH_PID