#!/bin/bash

# addTrashinfo: creates trashinfo file for trashed item
# params: the trashed file and version
# return: none
addTrashinfo() {
    # build the trashinfo command
    local fullpath=`realpath $1`
    local basename=`basename $1`
    local contents="[Trash Info]\nPath=$fullpath\nDeletionDate=$DATE"
    local cmd="echo -e \"$contents\" > $TRASHDIR/info/$basename.$2.trashinfo"

    # adjust command and prepended output for verbosity level
    if [ $VERBOSITYLEVEL == 0 ]
    then
        cmd+=" > /dev/null"
    fi

    if [ $VERBOSITYLEVEL == 2 ]
    then
            printf "bash: "
            echo $cmd
    fi

    eval $cmd
}

# getTrashinfoPath: extract the path from a trashinfo file
# params: the trashinfo filename
# return: the path from that file
getTrashinfoPath() {
    echo `cat $1 | grep "^Path=" | cut -d'=' -f2`
    exit
}
