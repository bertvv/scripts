#! /bin/bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Rsync-based backup script. Based on a script I got from someone, but the
# original author is unfortunately unknown to me.
#
# UPPER_CASE variables are user settings
# lower_case variables are local

set -o nounset # abort on unbound variable

#{{{ Functions

error_message() {
  cat <<< "$@" 1>&2
}

configuration() {
  # Determine config file and execute it
  if [ -r ./backup.conf ]; then
    # First, look in the current directory
    source ./backup.conf
    excludefile=./exclude.lst
    config_dir=.
  elif [ -r ~/.backup/backup.conf ]; then
    # Then try the user's home directory
    source ~/.backup/backup.conf
    excludefile=~/.backup/exclude.lst
    config_dir=~/.backup/
  elif [ -r /etc/backup/backup.conf ]; then
    # Finally, try a system-wide configuration
    source /etc/backup/backup.conf
    excludefile=/etc/backup/exclude.lst
    config_dir=/etc/backup/
  else
    error_message 'No config file found. Create it first!'
    error_message '  e.g. ~/.backup/backup.conf'
    exit 2
  fi

  # File contain
  timestamp=${DESTINATION}/backup-${host}.timestamp

  # Configure SSH access
  if [ "${USE_SSH}" = 'YES' ]; then
    ssh_command="ssh ${SSH_LOGIN}"
    rsync_ssh_opt='-e ssh'
    dest="${SSH_LOGIN}:${DESTINATION}"
  else
    ssh_command=''
    rsync_ssh_opt=''
    SSH_LOGIN=''
    dest="${DESTINATION}"
  fi

  # Configure keeping old backups
  if [ "${KEEP_OLD_BACKUPS}" = 'YES' ]; then
    dest="${dest}/backup-${host}-${now}"
    previous_backup=$(${ssh_command} cat "${timestamp}" 2> /dev/null)
    if [ -z "${previous_backup}" ]; then
      link=''
      echo 'Full backup' | tee --append "${log_temp}"
    else
      link="--link-dest=../backup-${host}-${previous_backup}"
      echo "Incremental backup relative to ${previous_backup}" | tee --append "${log_temp}"
    fi
  else
    link=''
    dest=${dest}/backup-${host}
    echo 'Full backup' | tee --append "${log_temp}"
  fi
}

ensure_excludefile_exists() {
  if [ ! -f "${excludefile}" ]; then
    touch "${excludefile}"
  fi
}

get_host_name() {
  host=$(hostname)
  if [ -z "${host}" -o "${host}" = 'localhost' ]; then
    host=$(ip a | grep 'link/ether' | head -1 | cut --delimiter=' ' --fields=6 | sed 's/:/-/g')
  fi
}

write_log_header() {
  cat >> "${log_temp}" << _EOF_
Starting backup ${now}.

Directories selected for backup: ${BACKUP_DIRS}
Destination: ${dest}
_EOF_

}

# Copy the temporary log to a permanent place
copy_log() {
  log="${config_dir}/backup.log"
  echo "Read the log file at ${log}" | tee --append "${log_temp}"
  cp "${log_temp}" "${log}"
}

# Write the temporary log either to a file, or send it by email
export_log() {
  if [ -n "${EMAIL}" ]; then
    mail -s "Backup report ${host} at ${now}" "${EMAIL}" < "${logfile}" | copy_log
  else
    copy_log
  fi

}

# Cleanup temporary files
cleanup_tmp() {

  rm "${log_temp}" 2> /dev/null
  rm "${cmd_file}" 2> /dev/null

}

# Remove backups older than $DAYS_TO_KEEP, but keep at least $BACKUPS_TO_KEEP
cleanup_old_backups() {
  if [ "${KEEP_OLD_BACKUPS}" == 'YES' ]; then
    mtime=$((DAYS_TO_KEEP -1))

    # Don't update the time stamp if a backup failed
    if [ "${status}" -eq 0 ]; then
      echo "echo ${now} > ${timestamp}" >> "${cmd_file}"
    fi

    cat << _EOF_ >> "${cmd_file}"
    # The following code checks that we still have ${BACKUPS_TO_KEEP} backups after deletion
    # This is to prevent deletion of all backups, for example when time on server
    # is not correct
    TODELETE=\$(find ${DESTINATION} -maxdepth 1  -type d -name "backup-${host}-*" -mtime +${mtime} | wc -l )
    CURRENTBACKUPS=\$(find ${DESTINATION} -maxdepth 1 -type d  -name "backup-${host}-*" | wc -l )
    REMAINING=\$(( CURRENTBACKUPS - TODELETE ))
    if test \$REMAINING -ge ${BACKUPS_TO_KEEP} -a \$TODELETE -gt 0
    then
      find ${DESTINATION} -maxdepth 1 -type d -name "backup-${host}-*" -mtime +${mtime} -exec rm -rf {} \;
    fi
_EOF_
  fi

  echo "Cleaning up old backups" | tee --append "${log_temp}"
  if [ "${USE_SSH}" = "YES" ]; then
    ${ssh_command} < "${cmd_file}" 2>&1 | tee --append "${log_temp}"
  else
    . "${cmd_file}" 2>&1 | tee --append "${log_temp}"
  fi
}

#}}}
#{{{ Initialize variables

now=$(date +%F-%H-%M-%S)  # e.g. 2015-09-20-22-31
log_temp=$(mktemp /tmp/backup.XXXXX)
cmd_file=$(mktemp /tmp/backup.XXXXX)
status=0

get_host_name
configuration

#}}}

# Script proper

ensure_excludefile_exists
write_log_header

trap 'export_log; cleanup_tmp; exit 1;' ERR

# Do the actual backup
for d in ${BACKUP_DIRS}; do
  rsync_cmd="rsync --verbose --archive --hard-links --xattrs --compress
    --relative --delete ${rsync_ssh_opt} --exclude-from=${excludefile}
    ${link} ${d} ${dest}"

  echo "== Backing up ${d} ==" | tee --append "${log_temp}"
  echo "${rsync_cmd}" >> "${log_temp}"
  ${rsync_cmd} 2>&1 | tee --append "${log_temp}"

  current_status=${PIPESTATUS[0]}

  # If this is the first failure, change $status
  if [ "${current_status}" -ne 0 ]; then
    echo "FAILED with status ${current_status}" | tee --append "${log_temp}"
    if [ "${status}" -eq "0" ]; then
      status=${current_status}
    fi
  fi
done
echo "Backup finished $(date +%F-%H-%M-%S) with status ${status}" | tee --append "${log_temp}"

cleanup_old_backups
export_log
cleanup_tmp
