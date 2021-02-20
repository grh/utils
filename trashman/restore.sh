#!/bin/bash

# restoreFile: restore a file/dir from trash to its original path
# params: the item to restore
# return: none
restoreFile() {
    . $BASEDIR/trashman/trashinfo.sh

    local version=1

    # what if there is more than one version in trash?
    if [ `ls $TRASHDIR/files/$1.* | wc -l` -gt 1 ]
    then
        # list transaction history
        # print and read a transaction selection
        # lookup trashinfo by transaction date
        # assign version based on the filename that
        #   contains the matched transaction date
        echo "Multiple versions of $1 in trash"; exit
    fi

    local trashFile="$TRASHDIR/files/$1.$version"
    local trashinfoFile="$TRASHDIR/info/$1.$version.trashinfo"
    local restorePath="`grep "Path=" $trashinfoFile | cut -d'=' -f2`"

    # move file from trash to original path
    mv -i $OPTIONSLIST $trashFile $restorePath

    # remove the trashinfo file
    rm -f $OPTIONSLIST $trashinfoFile
}

# doRestore: restores items in FILELIST
# params: none
# return: none
restore() {
    for i in ${FILELIST[@]}
    do
        restoreFile $i
    done
}
