#!/bin/bash

# logTransaction: logs the items that were trashed
# params: a list of items that were trashed
# return: none
logTransaction() {
    echo -e "$TRANSACTIONID\t$(realpath $1)\t$2\t$DATE" >> $TRANSACTIONLOG
}

# getTransactionsById: retrieve a transaction by tId
# params: a tId
# return: all the items for that tId
getTransactionsById() {
    local IFS=$'\n'
    echo -e `grep "^$i"$'\t' $TRASHDIR/data/transactions`
}

# removeTransactionById: delete a transaction from the log
# params: a tId
# return: none
removeTransactionById() {
    local tmpLog="$TRANSACTIONLOG.tmp"
    local counter=1

    mv $OPTIONSLIST $TRANSACTIONLOG $tmpLog

    for line in `cat $tmpLog`
    do
        for i in `grep -n ^$1$'\t' $tmpLog | cut -d':' -f1`
        do
            if [ $i -ne $counter ]
            then
                echo $line >> $TRANSACTIONLOG
            fi
        done

        counter=$(expr $counter + 1)
    done

    rm $OPTIONSLIST $tmpLog
}
