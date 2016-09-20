#!/bin/bash

ETH=geth

OUTFILE=/tmp/obalance-$$
ERROR=/tmp/ebalance-$$

end () {
    # kill server
    kill $GETH_PID
    exit
}

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
    URL=`grep 'WebSocket endpoint opened:' /tmp/$ETH.log | sed 's/^.*WebSocket endpoint opened: //'`
fi

# get the accounts from server 
STRACC=`$ETH --testnet --exec 'eth.accounts' attach $URL | tr -d ',[]'`
ACCOUNTS=($STRACC)

# concat all accounts for selection
INDEX=0 # index of account
TEXT=""
for ACCOUNT in ${ACCOUNTS[@]}
do
	TEXT+=$INDEX:" "$ACCOUNT"\n"
	INDEX=$(($INDEX+1))
done

TEXT+="\nPlease, type the index of any account:"
while true
do
	gdialog --inputbox "$TEXT" 2> $OUTFILE || end

    INDEX=$(cat $OUTFILE)
    BALANCE=`$ETH --testnet --exec "web3.fromWei(eth.getBalance(${ACCOUNTS[$INDEX]}), 'ether');" attach $URL`

    MSG="The balance of ${ACCOUNTS[$INDEX]}: $BALANCE eth.\nDo you want to check another wallet?"
    gdialog --yesno "$MSG" || end
done

