#!/bin/bash
# Read configuration file
# First we search .backup.conf in homedir, if it does not exist,
# we search backup.conf in /etc/, and if this neither exists,
# we use the one in the current directory

#set -o nounset # Abort on unbound variable

cur_dir=$(dirname "${0}")

if test -r ~/.backup/backup.conf
then
  source ~/.backup/backup.conf
  excludefile=~/.backup/exclude.lst
elif test -r /etc/backup/backup.conf
then
  source /etc/backup/backup.conf
  excludefile=/etc/backup/exclude.lst
elif test -r ./backup.conf
then
  source ./backup.conf
  excludefile="$(pwd)/exclude.lst"
elif test -r "${cur_dir}/backup.conf"
then
  source "${cur_dir}/backup.conf"
  excludefile="${cur_dir}/exclude.lst"
else
  echo "No configuration file found. Please create a backup.conf"
  echo "file based on the one included in the source tarball"
  exit 1
fi

now=$(date +%F-%H-%M-%S)
host=$(hostname)
log_temp=$(mktemp /tmp/backup.XXXXX)
cmd_file=$(mktemp /tmp/backup.XXXXX)

# Make sure "${excludefile}" exists, otherwise we'll get errors from rsync
if test ! -f "${excludefile}"
then
  touch "${excludefile}"
fi

# Actually check if we have a meaningful hostname
if test "${host}"x == 'x' -o "${host}"x == "localhost"x
then
  # if hostname is meaningless, use MAC address of first Ethernet
  # NIC, to have something unique
  host=$(ip a | grep 'link/ether' | head -1 | cut -d' ' -f 6 | sed 's/:/-/g')
fi

if test "${BWLIMIT}"x == 'x'
then
  BWLIMIT=0
fi

# backup data

if test "${USESSH}"x == "YES"x
then
  ssh_command="ssh ${SSHLOGIN}"
  rsync_ssh_opt="-e ssh"
  dest=${SSHLOGIN}:${DESTINATION}
else
  ssh_command=""
  rsync_ssh_opt=""
  SSHLOGIN=""
  dest="${DESTINATION}"
fi

cat >> "${log_temp}" << EOF
Starting backup ${now}.

Directories selected for backup: ${BACKUPDIRS}
dest: ${SSHLOGIN}:${DESTINATION}
EOF

if test "${KEEPOLDBACKUPS}"x == "YES"x
then
  dest="${dest}/backup-${host}-${now}"
  PREVIOUSBACKUP=$(${ssh_command} cat "${DESTINATION}/backup-${host}.timestamp" 2>/dev/null)
  # Only use --link-dest if it's not the first backup
  if test "${PREVIOUSBACKUP}"x != "x"
  then
    link="--link-dest=../backup-${host}-${PREVIOUSBACKUP}"
    echo "Incremental backup relative to ${PREVIOUSBACKUP}" >> "${log_temp}"
  else
    echo "Full backup" >> "${log_temp}"
  fi
else
  link=" "
  dest=${dest}/backup-${host}
  echo "Full backup" >> "${log_temp}"
fi


trap '{ cat ${log_temp} | mail -s "Backup FAILURE ${host} ${now}" $EMAIL; rm ${log_temp}; rm ${cmd_file} 2>/dev/null; exit 1; }' ERR

rsync --verbose \
  --archive --hard-links --xattrs \
  --compress \
  --relative --delete \
  ${rsync_ssh_opt} \
  --exclude-from="${excludefile}" \
  "${link}" \
  "${BACKUPDIRS}" "${dest}" \
  --bwlimit="${BWLIMIT}" | tee -a "${log_temp}"


if test "${KEEPOLDBACKUPS}"x == "YES"x
then

# -mtime option to find command ignores any fractional part
# so to match -mtime +1, a file has to have been modified at least two days ago.
# Subtract 1 from $DAYSTOKEEP for this reason
MTIME=$((DAYSTOKEEP - 1))

cat << EOF > $cmd_file
  echo $now > ${DESTINATION}/backup-${host}.timestamp
  # The following code checks that we still have $BACKUPSTOKEEP backups after deletion
  # This is to prevent deletion of all backups, for example when time on server
  # is not correct
  TODELETE=\$(find ${DESTINATION} -maxdepth 1  -type d -name "backup-${host}-*" -mtime +${MTIME} | wc -l\)
  CURRENTBACKUPS=\$(find ${DESTINATION} -maxdepth 1 -type d  -name "backup-${host}-*" | wc -l\)
  REMAINING=\$(expr \$CURRENTBACKUPS - \$TODELETE\)
  if test \$REMAINING -ge $BACKUPSTOKEEP -a \$TODELETE -gt 0
  then
    find ${DESTINATION} -maxdepth 1 -type d -name "backup-${host}-*" -mtime +${MTIME} -exec rm -rf {} \;
  fi
EOF

if test "${USESSH}"x == "NO"x
then
  .  "${cmd_file}"
else
  "${ssh_command}" < "${cmd_file}"  2>/dev/null
fi
rm "${cmd_file}"
fi

echo >> "${log_temp}"
echo "Backup finished $(date +%F-%H-%M-%S)" >> "${log_temp}"

if test "${EMAIL}"x != "x"
then
  mail -s "Backup report ${host} ${now}" "${EMAIL}" < "${log_file}"
fi
rm "${log_temp}"
