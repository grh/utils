#!/bin/bash

# empty: permanently delete all items in trash
# params: none
# return: none
empty() {
    local confirm="n"

    printf "trash: delete all items in trash? (y/n): "
    read confirm
    parseConfirm $confirm

    if [ $confirm == "y" ]
    then
        rm -rf $OPTIONSLIST $TRASHDIR/*
    fi
}

# getNextVersion: version the item to be trashed
# params: the item to be trashed
# return: the next version number
getNextVersion() {
    if [ `ls $TRASHDIR/files/ | grep "$(basename $1).*" | wc -l` -gt 0 ]
    then
        echo $(expr `ls -r $TRASHDIR/files/$(basename $1).* | rev | cut -d'.' -f1 | head -n 1` + 1)
    else
        echo 1
    fi
}

# parseConfirm: parses interactive confirmation input
# parameters: user input from terminal
# return: 1 if users confirm trash, 0 otherwise
parseConfirm() {
    case $1 in
        "Y" | "y" | "YES" | "Yes" | "yes")
            confirm='y' 
            ;;
        "N" | "n" | "NO" | "No" | "no")
            confirm='n' 
            ;;
        "A" | "a" | "ALL" | "All" | "all")
            INTERACTIVE=0
            confirm='a' 
            ;;
        *)
            echo "Error: unrecognized confirmation '$1'"
            exit
            ;;
    esac
}

# trash: main trash handler
# params: none
# return: none
trash() {
    . $BASEDIR/trashman/trashinfo.sh
    . $BASEDIR/trashman/transactions.sh

    local confirm="a"

    for i in ${FILELIST[@]}
    do
        if [ $INTERACTIVE == 1 ]
        then
            printf "trash: move '$i' to trash? (y/n/a): "
            read confirm
            parseConfirm $confirm
        fi

        if [ $confirm = "y" ] || [ $confirm = "a" ]
        then
            local version=$(getNextVersion $i)
            moveFile $i $TRASHDIR/files/$i.$version
            addTrashinfo $i $version
            logTransaction $i $version

            if [ $VERBOSITYLEVEL == 1 ]
            then
                echo "Trashed '$1'"
            fi

            if [ $VERBOSITYLEVEL == 2 ]
            then
                echo "trash: Trashed '$1'"
            fi
        fi
    done
}
