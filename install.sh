#!/usr/bin/env bash
##!####/bin/sh
#

set -ex

check_file() {
FILE=/etc/automysqlbackup/automysqlbackup.conf
if [ -f "$FILE" ]; then
    echo "$FILE found. Destroying..."
    #rm -f $FILE
    touch /etc/automysqlbackup/automysqlbackup.conf
    write_file >> /etc/automysqlbackup/automysqlbackup.conf
else
    echo "$FILE does not exist."
    mkdir -p /etc/automysqlbackup
    echo "creating file"
    touch /etc/automysqlbackup/automysqlbackup.conf
    write_file >> /etc/automysqlbackup/automysqlbackup.conf
    echo "done"
fi
}

write_file(){
    DBEXCREM=""
    IFS="," read -r -a arr <<< "${DBEXCLUDE}"
    for i in "${arr[@]}"
    do
        DBEXCREM+=" '${i}'"
    done
    echo "#version=3.0_rc2"
    echo "# Uncomment to change the default values (shown after =)"
    echo "# WARNING:"
    echo "# This is not true for UMASK, CONFIG_prebackup and CONFIG_postbackup!!!"
    echo "#"
    echo "# Default values are stored in the script itself. Declarations in"
    echo "# /etc/automysqlbackup/automysqlbackup.conf will overwrite them. The"
    echo "# declarations in here will supersede all other."
    echo ""
    echo "# Edit \$PATH if mysql and mysqldump are not located in /usr/local/bin:/usr/bin:/bin:/usr/local/mysql/bin"
    echo "#PATH=\${PATH}:FULL_PATH_TO_YOUR_DIR_CONTAINING_MYSQL:FULL_PATH_TO_YOUR_DIR_CONTAINING_MYSQLDUMP"
    echo ""
    echo "# Basic Settings"
    echo ""
    echo "# Username to access the MySQL server e.g. dbuser"
    if [[ -z "${MYSQL_USER}" ]]; then
        echo "CONFIG_mysql_dump_username='root'"
    else
        echo "CONFIG_mysql_dump_username='"$MYSQL_USER"'"
    fi
    echo ""
    echo "# Password to access the MySQL server e.g. password"
    if [[ -z "${MYSQL_PASSWORD_FILE}" ]]; then
        echo "CONFIG_mysql_dump_password='"$MYSQL_PASSWORD"'"
    else
        echo "CONFIG_mysql_dump_password='$(cat $MYSQL_PASSWORD_FILE)'"
    fi
    echo ""
    echo "# Host name (or IP address) of MySQL server e.g localhost"
    if [[ -z "${MYSQL_HOST}" ]]; then
        echo "CONFIG_mysql_dump_host='localhost'"
    else
        echo "CONFIG_mysql_dump_host='"$MYSQL_HOST"'"
    fi
    echo ""
    echo "# \"Friendly\" host name of MySQL server to be used in email log"
    echo "# if unset or empty (default) will use CONFIG_mysql_dump_host instead"
    echo "#CONFIG_mysql_dump_host_friendly=''"
    echo ""
    echo "# Backup directory location e.g /backups"
    if [[ -z "${BACKUPDIR}" ]]; then
        echo "CONFIG_backup_dir='/var/backup/db'"
    else
        echo "CONFIG_backup_dir='"$BACKUPDIR"'"
    fi
    echo ""
    echo "# This is practically a moot point, since there is a fallback to the compression"
    echo "# functions without multicore support in the case that the multicore versions aren't"
    echo "# present in the system. Of course, if you have the latter installed, but don't want"
    echo "# to use them, just choose no here."
    echo "# pigz -> gzip"
    echo "# pbzip2 -> bzip2"
    echo "#CONFIG_multicore='yes'"
    echo ""
    echo "# Number of threads (= occupied cores) you want to use. You should - for the sake"
    echo "# of the stability of your system - not choose more than (#number of cores - 1)."
    echo "# Especially if the script is run in background by cron and the rest of your system"
    echo "# has already heavy load, setting this too high, might crash your system. Assuming"
    echo "# all systems have at least some sort of HyperThreading, the default is 2 threads."
    echo "# If you wish to let pigz and pbzip2 autodetect or use their standards, set it to"
    echo "# 'auto'."
    echo "#CONFIG_multicore_threads=2"
    echo ""
    echo "# Databases to backup"
    echo ""
    echo "# List of databases for Daily/Weekly Backup e.g. ( 'DB1' 'DB2' 'DB3' ... )"
    echo "# set to (), i.e. empty, if you want to backup all databases"
    if [[ -z "${DBNAMES}" ]]; then
        echo "#CONFIG_db_names=()"
    else
        echo "CONFIG_db_names=('$DBNAMES')"
    fi
    echo "# You can use"
    echo "#declare -a MDBNAMES=( \"\${DBNAMES[@]}\" 'added entry1' 'added entry2' ... )"
    echo "# INSTEAD to copy the contents of \$DBNAMES and add further entries (optional)."
    echo ""
    echo "# List of databases for Monthly Backups."
    echo "# set to (), i.e. empty, if you want to backup all databases"
    if [[ -z "${MDBNAMES}" ]]; then
        echo "#CONFIG_db_month_names=()"
    else
        echo "CONFIG_db_month_names=('$MDBNAMES')"
    fi
    echo ""
    echo "# List of DBNAMES to EXCLUDE if DBNAMES is empty, i.e. ()."
    if [[ -z "${DBEXCLUDE}" ]]; then
        echo "#CONFIG_db_exclude=( 'information_schema' )"
    else
        echo "CONFIG_db_exclude=($DBEXCREM)"
    fi
    echo ""
    echo "# List of tables to exclude, in the form db_name.table_name"
    echo "#CONFIG_table_exclude=()"
    echo ""
    echo ""
    echo "# Advanced Settings"
    echo ""
    echo "# Rotation Settings"
    echo ""
    echo "# Which day do you want monthly backups? (01 to 31)"
    echo "# If the chosen day is greater than the last day of the month, it will be done"
    echo "# on the last day of the month."
    echo "# Set to 0 to disable monthly backups."
    echo "#CONFIG_do_monthly='01'"
    echo ""
    echo "# Which day do you want weekly backups? (1 to 7 where 1 is Monday)"
    echo "# Set to 0 to disable weekly backups."
    if [[ -z "${DOWEEKLY}" ]]; then
        echo 'CONFIG_do_weekly="5"'
    else
        echo '#CONFIG_do_weekly="'$DOWEEKLY'"'
    fi
    echo ""
    echo "# Set rotation of daily backups. VALUE*24hours"
    echo "# If you want to keep only today's backups, you could choose 1, i.e. everything older than 24hours will be removed."
    echo "CONFIG_rotation_daily=6"
    echo ""
    echo "# Set rotation for weekly backups. VALUE*24hours"
    echo "CONFIG_rotation_weekly=35"
    echo ""
    echo "# Set rotation for monthly backups. VALUE*24hours"
    echo "CONFIG_rotation_monthly=150"
    echo ""
    echo ""
    echo "# Server Connection Settings"
    echo ""
    echo "# Set the port for the mysql connection"
    echo "#CONFIG_mysql_dump_port=3306"
    echo ""
    echo "# Compress communications between backup server and MySQL server?"
    if [[ -z "${COMMCOMP}" ]]; then
        echo "#CONFIG_mysql_dump_commcomp='no'"
    else
        echo "CONFIG_mysql_dump_commcomp='"$COMMCOMP"'"
    fi
    echo ""
    echo "# Use ssl encryption with mysqldump?"
    echo "CONFIG_mysql_dump_usessl='no'"
    echo ""
    echo "# For connections to localhost. Sometimes the Unix socket file must be specified."
    if [[ -z "${SOCKET}" ]]; then
        echo "#CONFIG_mysql_dump_socket=''"
    else
        echo "CONFIG_mysql_dump_socket='"$SOCKET"'"
    fi
    echo ""
    echo "# The maximum size of the buffer for client/server communication. e.g. 16MB (maximum is 1GB)"
    if [[ -z "${MAX_ALLOWED_PACKET}" ]]; then
        echo "#CONFIG_mysql_dump_max_allowed_packet=''"
    else
        echo "CONFIG_mysql_dump_max_allowed_packet='"$MAX_ALLOWED_PACKET"'"
    fi
    echo ""
    echo "# This option sends a START TRANSACTION SQL statement to the server before dumping data. It is useful only with"
    echo "# transactional tables such as InnoDB, because then it dumps the consistent state of the database at the time"
    echo "# when BEGIN was issued without blocking any applications."
    echo "#"
    echo "# When using this option, you should keep in mind that only InnoDB tables are dumped in a consistent state. For"
    echo "# example, any MyISAM or MEMORY tables dumped while using this option may still change state."
    echo "#"
    echo "# While a --single-transaction dump is in process, to ensure a valid dump file (correct table contents and"
    echo "# binary log coordinates), no other connection should use the following statements: ALTER TABLE, CREATE TABLE,"
    echo "# DROP TABLE, RENAME TABLE, TRUNCATE TABLE. A consistent read is not isolated from those statements, so use of"
    echo "# them on a table to be dumped can cause the SELECT that is performed by mysqldump to retrieve the table"
    echo "# contents to obtain incorrect contents or fail."
    echo "#CONFIG_mysql_dump_single_transaction='no'"
    echo ""
    echo "# http://dev.mysql.com/doc/refman/5.0/en/mysqldump.html#option_mysqldump_master-data"
    echo "# --master-data[=value] "
    echo "# Use this option to dump a master replication server to produce a dump file that can be used to set up another"
    echo "# server as a slave of the master. It causes the dump output to include a CHANGE MASTER TO statement that indicates"
    echo "# the binary log coordinates (file name and position) of the dumped server. These are the master server coordinates"
    echo "# from which the slave should start replicating after you load the dump file into the slave."
    echo "#"
    echo "# If the option value is 2, the CHANGE MASTER TO statement is written as an SQL comment, and thus is informative only;"
    echo "# it has no effect when the dump file is reloaded. If the option value is 1, the statement is not written as a comment"
    echo "# and takes effect when the dump file is reloaded. If no option value is specified, the default value is 1."
    echo "#"
    echo "# This option requires the RELOAD privilege and the binary log must be enabled. "
    echo "#"
    echo "# The --master-data option automatically turns off --lock-tables. It also turns on --lock-all-tables, unless"
    echo "# --single-transaction also is specified, in which case, a global read lock is acquired only for a short time at the"
    echo "# beginning of the dump (see the description for --single-transaction). In all cases, any action on logs happens at"
    echo "# the exact moment of the dump."
    echo "# =================================================================================================================="
    echo "# possible values are 1 and 2, which correspond with the values from mysqldump"
    echo "# VARIABLE=    , i.e. no value, turns it off (default)"
    echo "#"
    echo "#CONFIG_mysql_dump_master_data="
    echo ""
    echo "# Included stored routines (procedures and functions) for the dumped databases in the output. Use of this option"
    echo "# requires the SELECT privilege for the mysql.proc table. The output generated by using --routines contains"
    echo "# CREATE PROCEDURE and CREATE FUNCTION statements to re-create the routines. However, these statements do not"
    echo "# include attributes such as the routine creation and modification timestamps. This means that when the routines"
    echo "# are reloaded, they will be created with the timestamps equal to the reload time."
    echo "#"
    echo "# If you require routines to be re-created with their original timestamp attributes, do not use --routines. Instead,"
    echo "# dump and reload the contents of the mysql.proc table directly, using a MySQL account that has appropriate privileges"
    echo "# for the mysql database. "
    echo "#"
    echo "# This option was added in MySQL 5.0.13. Before that, stored routines are not dumped. Routine DEFINER values are not"
    echo "# dumped until MySQL 5.0.20. This means that before 5.0.20, when routines are reloaded, they will be created with the"
    echo "# definer set to the reloading user. If you require routines to be re-created with their original definer, dump and"
    echo "# load the contents of the mysql.proc table directly as described earlier."
    echo "#"
    echo "#CONFIG_mysql_dump_full_schema='yes'"
    echo ""
    echo "# Backup dump settings"
    echo ""
    echo "# Include CREATE DATABASE in backup?"
    if [[ -z "${CREATE_DATABASE}" ]]; then
        echo "#CONFIG_mysql_dump_create_database='no'"
    else
        echo "CONFIG_mysql_dump_create_database='"$CREATE_DATABASE"'"
    fi
    echo ""
    echo "# Separate backup directory and file for each DB? (yes or no)"
    if [[ -z "${SEPDIR}" ]]; then
        echo "#CONFIG_mysql_dump_use_separate_dirs='yes'"
    else
        echo "#CONFIG_mysql_dump_use_separate_dirs='"$SEPDIR"'"
    fi
    echo ""
    echo "# Choose Compression type. (gzip or bzip2)"
    if [[ -z "${COMP}" ]]; then
        echo "CONFIG_mysql_dump_compression='gzip'"
    else
        echo "CONFIG_mysql_dump_compression='"$COMP"'"
    fi
    echo ""
    echo "# Store an additional copy of the latest backup to a standard"
    echo "# location so it can be downloaded by third party scripts."
    if [[ -z "${LATEST}" ]]; then
        echo "#CONFIG_mysql_dump_latest='no'"
    else
        echo "CONFIG_mysql_dump_latest='"$LATEST"'"
    fi
    echo ""
    echo "# Remove all date and time information from the filenames in the latest folder."
    echo "# Runs, if activated, once after the backups are completed. Practically it just finds all files in the latest folder"
    echo "# and removes the date and time information from the filenames (if present)."
    echo "#CONFIG_mysql_dump_latest_clean_filenames='no'"
    echo ""
    echo "# Notification setup"
    echo ""
    echo "# What would you like to be mailed to you?"
    echo "# - log   : send only log file"
    echo "# - files : send log file and sql files as attachments (see docs)"
    echo "# - stdout : will simply output the log to the screen if run manually."
    echo "# - quiet : Only send logs if an error occurs to the MAILADDR."
    echo "#CONFIG_mailcontent='stdout'"
    echo ""
    echo "# Set the maximum allowed email size in k. (4000 = approx 5MB email [see docs])"
    echo "#CONFIG_mail_maxattsize=4000"
    echo ""
    echo "# Email Address to send mail to? (user@domain.com)"
    echo "#CONFIG_mail_address='root'"
    echo ""
	echo '# Create differential backups. Master backups are created weekly at #$CONFIG_do_weekly weekday. Between master backups,'
	echo "# diff is used to create differential backups relative to the latest master backup. In the Manifest file, you find the"
	echo "# following structure"
	echo '# $filename 	md5sum	$md5sum	diff_id	$diff_id	rel_id	$rel_id'
	echo "# where each field is separated by the tabular character '\t'. The entries with $ at the beginning mean the actual values,"
	echo "# while the others are just for readability. The diff_id is the id of the differential or master backup which is also in"
	echo "# the filename after the last _ and before the suffixes begin, i.e. .diff, .sql and extensions. It is used to relate"
	echo '# differential backups to master backups. The master backups have 0 as $rel_id and are thereby identifiable. Differential'
	echo '# backups have the id of the corresponding master backup as $rel_id.'
	echo "#"
	echo '# To ensure that master backups are kept long enough, the value of $CONFIG_rotation_daily is set to a minimum of 21 days.'
	echo "#"
	echo "#CONFIG_mysql_dump_differential='no'"
    echo ""
    echo "# Encryption"
    echo ""
    echo "# Do you wish to encrypt your backups using openssl?"
    echo "#CONFIG_encrypt='no'"
    echo ""
    echo "# Choose a password to encrypt the backups."
    echo "#CONFIG_encrypt_password='password0123'"
    echo ""
    echo "# Other"
    echo ""
    echo "# Backup local files, i.e. maybe you would like to backup your my.cnf (mysql server configuration), etc."
    echo "# These files will be tar'ed, depending on your compression option CONFIG_mysql_dump_compression compressed and"
    echo "# depending on the option CONFIG_encrypt encrypted."
    echo "#"
    echo "# Note: This could also have been accomplished with CONFIG_prebackup or CONFIG_postbackup."
    echo "#CONFIG_backup_local_files=()"
    echo ""
    echo "# Command to run before backups (uncomment to use)"
    echo "#CONFIG_prebackup=\"/etc/mysql-backup-pre\""
    echo ""
    echo "# Command run after backups (uncomment to use)"
    echo "#CONFIG_postbackup=\"/etc/mysql-backup-post\""
    echo ""
    echo "# Uncomment to activate! This will give folders rwx------"
    echo "# and files rw------- permissions."
    echo "#umask 0077"
    echo ""
    echo "# dry-run, i.e. show what you are gonna do without actually doing it"
    echo "# inactive: =0 or commented out"
    echo "# active: uncommented AND =1"
    echo "#CONFIG_dryrun=1"
}


check_file
