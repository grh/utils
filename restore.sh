#!/bin/bash

# usage: display usage info
# parameters: none
# return value: none
function usage {
    echo "restore.sh version 1.0.0
    
usage: restore.sh [-l | --local] [-r | --remote]
  -l, --local       restore from local backup
  -r, --remote      restore from remote backup

  A restoration from either a local or remote
  backup must be specified. Local and remote 
  backup sources are specfied in this script; 
  change them as appropriate."
}

# initialize src, dest, log, and date variables
DEST=$HOME
LOCALSRC=$HOME/Backup/`basename $HOME`
REMOTESRC=$HOME/Dropbox/Backup/`basename $HOME`
LOGDIR=$HOME/tmp/log
DATEVAR=`date +%Y%m%d%H%M%S`

# check command line options
case $1 in
    "-l" | "--local")
        SRC=$LOCALSRC
        LOGFILE=$LOGDIR/rsync.daily.log-$DATEVAR
        if [ ! "`mount -l -t nfs | grep $(dirname $SRC)`" ]
        then
            echo "Error: local backup $SRC not found"
            exit
        fi
        ;;
    "-r" | "--remote")
        SRC=$REMOTESRC
        LOGFILE=$LOGDIR/rsync.weekly.log-$DATEVAR
        `dropbox running`
        if [ $? -eq 0 ]
        then
            echo "Error: remote backup $SRC not found"
            exit
        fi
        ;;
    "-h" | "--help")
        usage
        exit
        ;;
    *)
        echo "Error: unrecognized arguments"; echo
        usage
        exit
        ;;
esac

# delete backup logs older than 30 days
find $LOGDIR -mtime +30 -name "rsync.*.log-*" -exec rm -f {} \;

rsync -ahimvvz --no-W --log-file=$LOGFILE $SRC/Documents $DEST
rsync -ahimvvz --no-W --log-file=$LOGFILE $SRC/Media $DEST
rsync -ahimvvz --no-W --log-file=$LOGFILE $SRC/.bashrc $DEST
rsync -ahimvvz --no-W --log-file=$LOGFILE $SRC/.vimrc $DEST
rsync -ahimvvz --no-W --log-file=$LOGFILE $SRC/bin/cd2mp3 $DEST/bin
rsync -ahimvvz --no-W --log-file=$LOGFILE $SRC/bin/git-prompt.sh $DEST/bin
rsync -ahimvvz --no-W --log-file=$LOGFILE $SRC/bin/backup.sh $DEST/bin
rsync -ahimvvz --no-W --log-file=$LOGFILE $SRC/bin/clamscan.sh $DEST/bin
rsync -ahimvvz --no-W --log-file=$LOGFILE $SRC/bin/restore.sh $DEST/bin
