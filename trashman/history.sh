#!/bin/bash

# listHistory: print out a formatted list of trash history
# params: none
# return: none
listHistory() {
    . $BASEDIR/trashman/transactions.sh

    # Calculate field widths
    local maxWidth=78
    local scrWidth=`tput cols`
    local tIdFw=14
    local tDateFw=19
    local totalWidth=$([ $scrWidth -ge $maxWidth ] && echo $maxWidth || echo $scrWidth)
    local tItemFw=$(expr $(expr $totalWidth - $(expr $tIdFw + $tDateFw)) - 7)

    # Format field headers
    local tIdFh="TRANSACTION ID"
    local tItemFh="ITEM"
    local tDateFh="DATE"
    local hdrFmt=" %${tIdFw}s | %-${tItemFw}s | %-${tDateFw}s\n"
    printf "$hdrFmt" "$tIdFh" "$tItemFh" "$tDateFh"
    printf "%0.s-" $(seq 1 $totalWidth); echo

    # loop through each tId
    for i in `cut -f 1 $TRASHDIR/data/transactions | uniq`
    do
        # we've encountered a new Id so print it
        local newId=1
        printf " %${tIdFw}s |" "$i"

        # grab all transactions with that Id
        local ts=$(getTransactionsById $i)

        # count the number of transactions for id
        local numTs=0
        for t in ${ts[@]}
        do
            numTs=$(expr $numTs + 1)
        done

        # loop through each transaction and print it
        local count=0;
        for t in ${ts[@]}
        do
            count=$(expr $count + 1)

            # grab the item and date
            IFS=$'\t'
            local arr=($t)
            local item=${arr[1]}
            local date=${arr[3]}

            # if strlen for item is longer than tItemFw,
            # truncate it (probably somewhere in the middle)
            if [ ${#item} -gt $tItemFw ]
            then
                local extChars=$(expr $(expr ${#item} - $tItemFw) + 3)
                local startIdx=$(expr $(expr ${#item} / 2) - $(expr $extChars / 2))
                item=`sed -r "s/^(.{$startIdx})(.{$extChars})(.*)/\1...\3/" <<< $item`
            fi

            # if there are many items print out an additional
            # items message and break out of loop
            if [ $count -eq 2 ]
            then
                printf " %${tIdFw}s |" " "
                printf " %-${tItemFw}s |\n" "+ $(expr $numTs - 1) more items"
                break
            fi

            # if this is a new Id, print out the item and date
            # otherwise just print out the item
            if [ $newId -eq 1 ]
            then
                printf " %-${tItemFw}s |" "$item"
                printf " %-${tDateFw}s\n" "$date"
            else
                printf " %${tIdFw}s |" " "
                printf " %-${tItemFw}s |\n" "$item"
            fi

            newId=0
        done
    done
}
