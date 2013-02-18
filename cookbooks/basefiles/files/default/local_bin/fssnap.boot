#!/bin/bash

# Placed by chef
HOST=`hostname`
ORIGVOL='/dev/sda1'             # name of the logical volume to backup
SNAPVOL='boot'                  # name of the snapshot to create
FSAOPTS='-o -j2 -e *.iso'       # Wildcards already protected
BACKDIR=${1:-/media/PATRIOT}	# where to put the archive
BACKNAM=${HOST}"-boot"          # name of the archive

# ----------------------------------------------------------------------------------------------

PATH="${PATH}:/usr/sbin:/sbin:/usr/bin:/bin"
TIMESTAMP="$(date +%Y%m%d-%H%M)"
#TIMESTAMP=""

# only run as root
if [ "$(id -u)" != '0' ]
then
        echo "this script has to be run as root"
        exit 1
fi

# make readonly first
if ! mount -o remount,ro /${SNAPVOL}
then
        echo "make /${SNAPVOL} readonly failed"
        exit 1
fi

# main command of the script that does the real stuff
if fsarchiver ${FSAOPTS} savefs ${BACKDIR}/${BACKNAM}.fsa ${ORIGVOL}
then
        RES=0
else
        echo "fsarchiver failed"
        RES=1
fi

if ! mount -o remount,rw /${SNAPVOL}
then
        echo "cannot mount /${SNAPVOL} read-write "
        RES=1
fi

exit ${RES}
