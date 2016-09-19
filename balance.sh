if ! geth --testnet --exec 'console.log("OK")' attach 2&>/dev/null  
then
    geth --testnet --ws --fast 2&>/tmp/geth.log & 
    GETH_PID=`jobs -p`
    until grep -q 'WebSocket endpoint opened:' /tmp/geth.log
    do
        sleep 3
    done
    URL=`grep 'WebSocket endpoint opened:' /tmp/geth.log | sed 's/^.*WebSocket endpoint opened: //'`
fi
 
ACCOUNTS=`geth --testnet --exec 'eth.accounts' attach $URL | tr -d ',[]'`
echo $ACCOUNTS

geth --testnet --exec "web3.fromWei(eth.getBalance($ACCOUNTS), 'ether');" attach $URL

kill $GETH_PID