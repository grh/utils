#!/bin/bash

# usage: display usage info
# parameters: none
# return value: none
function usage {
    echo "backup.sh version 1.1.0
    
usage: backup.sh [-l | --local] [-r | --remote]
  -l, --local       local backup
  -r, --remote      remote backup

  Type of backup (local or remote) must be
  must be specified. Local and remote backup
  sources are specfied in this script; change
  them as appropriate."
}

# initialize src, dest, log, and date variables
SRC=$HOME
LOCALDEST=$HOME/Backup/`basename $HOME`
REMOTEDEST=$HOME/Dropbox/Backup/`basename $HOME`
LOGDIR=$HOME/tmp/log
DATEVAR=`date +%Y%m%d%H%M%S`

# check the command line options
case $1 in
    "-l" | "--local")
        DEST=$LOCALDEST
        LOGFILE=$LOGDIR/rsync.daily.log-$DATEVAR
        if [ ! "`mount -l -t nfs | grep $(dirname $DEST)`" ]
        then
            echo "Error: local backup $DEST not found"
            exit
        fi
        ;;
    "-r" | "--remote")
        DEST=$REMOTEDEST
        LOGFILE=$LOGDIR/rsync.weekly.log-$DATEVAR
        `dropbox running`
        if [ $? -eq 0 ]
        then
            echo "Error: remote backup $DEST not found"
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

rsync -ahimvvz --no-W --delete --log-file=$LOGFILE $SRC/Documents $DEST
rsync -ahimvvz --no-W --delete --log-file=$LOGFILE $SRC/Media $DEST
rsync -ahimvvz --no-W --delete --log-file=$LOGFILE $SRC/.bashrc $DEST
rsync -ahimvvz --no-W --delete --log-file=$LOGFILE $SRC/.vimrc $DEST
rsync -ahimvvz --no-W --delete --log-file=$LOGFILE $SRC/bin/cd2mp3 $DEST/bin
rsync -ahimvvz --no-W --delete --log-file=$LOGFILE $SRC/bin/git-prompt.sh $DEST/bin
rsync -ahimvvz --no-W --delete --log-file=$LOGFILE $SRC/bin/backup.sh $DEST/bin
rsync -ahimvvz --no-W --delete --log-file=$LOGFILE $SRC/bin/clamscan.sh $DEST/bin
rsync -ahimvvz --no-W --delete --log-file=$LOGFILE $SRC/bin/restore.sh $DEST/bin
