#!/bin/bash

# initialize: assigns script variables
# params: none
# return: none
initialize() {
    TRASHDIR=$HOME/.local/share/Trash

    ACTION="TRASH"
    DATEFORMAT="+%Y-%m-%dT%H:%M:%S"
    DATE=$(date $DATEFORMAT)
    FILELIST=()
    INTERACTIVE=0
    OPTIONSLIST=()
    OPTS=( 
        "--empty" 
        "--extra-verbose" 
        "--force" 
        "--help" 
        "--history" 
        "--interactive" 
        "--quiet" 
        "--restore" 
        "--rollback" 
        "--trash" 
        "--verbose" 
        "--version" 
    )
    TRANSACTIONLOG="$TRASHDIR/data/transactions"
    VERBOSITYLEVEL=-1
    VERSION=1.0

    # make sure TRASHDIR exists and is structured
    mkdir -p $TRASHDIR/files
    mkdir -p $TRASHDIR/info
    mkdir -p $TRASHDIR/data
    touch $TRASHDIR/data/transactions

    # get the next transaction id
    TRANSACTIONID=$(expr `tail -n 1 $TRASHDIR/data/transactions | cut -f 1` + 1)
}

# usage: prints usage info and exits
# params: none
# return: none
usage() {
    echo "trashman - a trash manager for Linux ($VERSION)
    
usage: trashman [options] [item1 ...]

  Main Options
  --empty               permanently delete all items in trash
  --history             list transaction history
  --restore             restore items from trash
  --rollback            undo a transaction from history
  --trash               move items to trash

  General Options
  --force               skip confirmation for all items
  --help                show this help
  --interactive         confirm each item (y-yes/n-no/a-all)
  --quiet               suppress any output
  --verbose             list items as they are processed
  --extra-verbose       additional verbosity
  --version             show version"
}

# isOpt: checks if a given parameter is an option
# params: any item
# return: 1 if item is in list of options, 0 otherwise
isOpt() {
    for opt in ${OPTS[@]}
    do
        if [ $1 = $opt ]
        then
            echo 1
            return
        fi
    done

    echo 0
}

# parseOpts: parses command line arguments
# parameters: the command line arguments array $@
# return: none
parseOpts() {
    if [ $# -eq 0 ]
    # must have at least 1 argument
    then
        echo "Error: no arguments provided"
        exit
    else
        while [ $# -ne 0 ]
        # loop through arguments
        do
            # make sure argument is either a file or an option
            local argIsOpt=$(isOpt $1)
            if [ $argIsOpt = 0 ] && [ ! -e $1 ] && [ -z "`ls $TRASHDIR/files/$1.*`" ]
            then
                echo "Error: unrecognized option or file '$1'"
                exit
            fi

            # we know we've got either an option or a file
            case $1 in
                "--empty")
                    ACTION="EMPTY"
                    ;;
                "--extra-verbose")
                    VERBOSITYLEVEL=2
                    OPTIONSLIST[${#OPTIONSLIST[@]}]="-v"
                    ;;
                "--force")
                    INTERACTIVE=0
                    ;;
                "--help")
                    ACTION="HELP"
                    ;;
                "--history")
                    ACTION="HISTORY"
                    ;;
                "--interactive")
                    INTERACTIVE=1
                    ;;
                "--quiet")
                    VERBOSITYLEVEL=0
                    ;;
                "--restore")
                    ACTION="RESTORE"
                    ;;
                "--rollback")
                    ACTION="ROLLBACK"
                    ;;
                "--trash")
                    ACTION="TRASH"
                    ;;
                "--verbose")
                    VERBOSITYLEVEL=1
                    ;;
                "--version")
                    ACTION="VERSION"
                    ;;
                *)
                    if [ -e $1 ] || [ ! -z "`ls $TRASHDIR/files/$1.*`" ]
                    then
                        FILELIST[${#FILELIST[@]}]=$1
                    else
                        echo "Error: unrecognized file or argument '$1'"
                        exit
                    fi
                    ;;
            esac
            shift
        done
    fi
}

# moveFile: move file to location
# params: the file and its new path
# return: none
moveFile() {
    if [ $VERBOSITYLEVEL == 0 ]
    then
        mv -f $OPTIONSLIST $1 $2 > /dev/null
    elif [ $VERBOSITYLEVEL == 2 ]
    then
        printf "mv: "
        mv -f $OPTIONSLIST $1 $2
    else
        mv -f $OPTIONSLIST $1 $2
    fi
}
