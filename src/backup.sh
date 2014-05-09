#!/bin/bash 
# Read configuration file
# First we search .backup.conf in homedir, if it does not exist,
# we search backup.conf in /etc/, and if this neither exists,
# we use the one in the current directory

if test -r ~/.backup/backup.conf
then
	source ~/.backup/backup.conf
	EXCLUDEFILE=~/.backup/exclude.lst
elif test -r /etc/backup/backup.conf
then
	source /etc/backup/backup.conf
	EXCLUDEFILE=/etc/backup/exclude.lst
elif test -r ./backup.conf
then
	source ./backup.conf
	EXCLUDEFILE=`pwd`/exclude.lst
elif test -r `dirname $0`/backup.conf
then
	source `dirname $0`/backup.conf
	EXCLUDEFILE=`dirname $0`/exclude.lst
else
	echo "No configuration file found. Please create a backup.conf"
	echo "file based on the one included in the source tarball"
	exit 1
fi

NOW=`date +%F-%H-%M-%S`
HOST=`hostname`
LOGTEMP=`mktemp /tmp/backup.XXXXX`
CMDFILE=`mktemp /tmp/backup.XXXXX`

case `uname` in
 
	"Linux") NIC="eth0"
		 ;;
	"Darwin") NIC="en0"
		  ;;
esac

# Make sure $EXCLUDEFILE exists, otherwise we'll get errors from rsync
if test ! -f $EXCLUDEFILE
then
	touch $EXCLUDEFILE
fi

# Actually check if we have a meaningful hostname
if test ${HOST}x == 'x' -o ${HOST}x == "localhost"x
then
        # if hostname is meaningless, use MAC address of eth0, to have something unique
        # Replace : by - in MAC address, as : is not supported by some file systems        
	# Make sure there are no spaces after the MAC address like seems to be the case in Linux
        HOST=$(/sbin/ifconfig $NIC | grep HWaddr | sed -e 's/^.*HWaddr \(.*\)$/\1/' -e 's/:/-/g' -e 's/ /g')
fi

if test x{BWLIMIT}x == 'x'
then	
	BWLIMIT=0
fi

# backup data

if test ${USESSH}x == "YES"x
then
	SSHCOMMAND="ssh $SSHLOGIN"
	RSYNCSSH="-e ssh"
	DST=${SSHLOGIN}:${DESTINATION}
else
	SSHCOMMAND=""
	RSYNCSSH=""
	SSHLOGIN=""
	DST=$DESTINATION
fi

cat >> $LOGTEMP << EOF
Starting backup $NOW.

Directories selected for backup: $BACKUPDIRS
Destination: ${SSHLOGIN}:${DESTINATION}
EOF

if test ${KEEPOLDBACKUPS}x == "YES"x
then
	DST=${DST}/backup-${HOST}-${NOW}
	PREVIOUSBACKUP=`${SSHCOMMAND} cat ${DESTINATION}/backup-${HOST}.timestamp 2>/dev/null`
	# Only use --link-dest if it's not the first backup
	if test ${PREVIOUSBACKUP}x != "x"
	then
		LINK="--link-dest=../backup-${HOST}-${PREVIOUSBACKUP}"
		echo "Incremental backup to ${PREVIOUSBACKUP}" >> $LOGTEMP
	fi
else
	LINK=""
	DST=$DST/backup-${HOST}
fi


trap "{ cat $LOGTEMP | mail -s 'Backup FAILURE $HOST $NOW' $EMAIL; rm $LOGTEMP; rm $CMDFILE 2>/dev/null; exit 1; }" ERR

#nice -n +19 rsync -vazHR --delete ${RSYNCSSH} --exclude-from=${EXCLUDEFILE} ${LINK} $BACKUPDIRS ${DST} --bwlimit=${BWLIMIT} 2>&1 > /dev/null | tee -a $LOGTEMP

#echo rsync -vazHR --delete ${RSYNCSSH} --exclude-from=${EXCLUDEFILE} ${LINK} $BACKUPDIRS ${DST} --bwlimit=${BWLIMIT} 2>&1 > /dev/null | tee -a $LOGTEMP

rsync -vazHR --delete ${RSYNCSSH} --exclude-from=${EXCLUDEFILE} ${LINK} $BACKUPDIRS ${DST} --bwlimit=${BWLIMIT} | tee -a $LOGTEMP


if test ${KEEPOLDBACKUPS}x == "YES"x
then

# -mtime option to find command ignores any fractional part
# so to match -mtime +1, a file has to have been modified at least two days ago.
# Subtract 1 from $DAYSTOKEEP for this reason
MTIME=`expr $DAYSTOKEEP - 1`

cat << EOF > $CMDFILE
	echo $NOW > ${DESTINATION}/backup-${HOST}.timestamp
	# The following code checks that we still have $BACKUPSTOKEEP backups after deletion
	# This is to prevent deletion of all backups, for example when time on server
	# is not correct
	TODELETE=\`find ${DESTINATION} -maxdepth 1  -type d -name "backup-${HOST}-*" -mtime +${MTIME} | wc -l\`
	CURRENTBACKUPS=\`find ${DESTINATION} -maxdepth 1 -type d  -name "backup-${HOST}-*" | wc -l\`
	REMAINING=\`expr \$CURRENTBACKUPS - \$TODELETE\`
	if test \$REMAINING -ge $BACKUPSTOKEEP -a \$TODELETE -gt 0
	then
		find ${DESTINATION} -maxdepth 1 -type d -name "backup-${HOST}-*" -mtime +${MTIME} -exec rm -rf {} \;
	fi
EOF

if test ${USESSH}x == "NO"x
then
	.  $CMDFILE
else
	cat $CMDFILE | ${SSHCOMMAND} 2>/dev/null
fi
rm $CMDFILE
fi

echo >> $LOGTEMP
echo "Backup finished `date +%F-%H-%M-%S`" >> $LOGTEMP
 
cat $LOGTEMP 
if test ${EMAIL}x != "x"
then
	cat $LOGTEMP | mail -s "Backup report $HOST $NOW" $EMAIL 
fi
rm $LOGTEMP
