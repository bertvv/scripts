#! /bin/bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
SERVER="tin2fbo.hogent.be"
USER="bert"

DB_NAME="testdb"
DB_USER="${DB_NAME}_usr"
DB_PASS="testpw"

SQL=$( cat << _END_
DROP USER ${DB_USER};
DROP DATABASE ${DB_NAME};
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
GRANT ALL ON ${DB_NAME} TO '${DB_USER}'@'*' IDENTIFIED BY '${DB_PASS}';
FLUSH PRIVILEGES;
_END_
)

echo $SQL
ssh ${USER}@${SERVER} "mysql -u root -p ${SQL}"

