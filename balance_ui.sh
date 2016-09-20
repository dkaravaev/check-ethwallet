#!/bin/bash

ETH=geth

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
ACCOUNTS=`$ETH --testnet --exec 'eth.accounts' attach $URL | tr -d ',[]'`

# show all accounts for selection
INDEX=0 # index of account
TEXT=""
for ACCOUNT in $ACCOUNTS
do
	TEXT+=$INDEX:" "
	TEXT+=$ACCOUNT
	TEXT+="\n"
	INDEX=$(($INDEX+1))
done

#printf $LIST

TEXT+="\nPlease, type the index of any account:"
while true
do
	gdialog --inputbox "$TEXT" || end
#	$DIALOG --inputbox "Please, type the index of any account:\n" || end
#	if cat $FILE1 | $CALC > $FILE2 2>$ERROR
#	then
#		MSG="`$GETTEXT \"Result:\"` `cat $FILE2`\\n\\n`$GETTEXT \"Continue?\"`"
#		$DIALOG --yesno "$MSG" 7 20 || end
#	else
#		MSG="`$GETTEXT \"Error:\"`\\n\\n`cat $ERROR`\\n\\n`$GETTEXT \"Continue?\"`"
#		$DIALOG --yesno "$MSG" 10 35 || end
#	fi
done

#printf 
#read INDEX

# get balance by using JavaScript Web3 API
#BALANCE=`$ETH --testnet --exec "web3.fromWei(eth.getBalance(${ACCOUNTS[$INDEX]}), 'ether');" attach $URL`

#printf "Balance of ${ACCOUNTS[$INDEX]}: $BALANCE eth.\n"


