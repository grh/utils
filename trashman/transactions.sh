#!/bin/bash

# logTransaction: logs the items that were trashed
# parameters: a list of items that were trashed
# return: none
logTransaction() {
    echo -e "$TRANSACTIONID\t$(realpath $1)\t$2\t$DATE" >> $TRANSACTIONLOG
}

# getTransactionsById: retrieve a transaction by tId
# parameters: a tId
# return: all the items for that tId
getTransactionsById() {
    local IFS=$'\n'
    echo -e `grep "^$i"$'\t' $TRASHDIR/data/transactions`
}
