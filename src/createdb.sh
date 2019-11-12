#! /bin/bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
server="tin2fbo.hogent.be"
user="bert"

db_name="testdb"
db_user="${db_name}_usr"
db_pass="testpw"

sql=$( cat << _END_
DROP USER IF EXISTS ${db_user};
DROP DATABASE IF EXISTS ${db_name};
CREATE DATABASE ${db_name};
GRANT ALL ON ${db_name} TO '${db_user}'@'*' IDENTIFIED BY '${db_pass}';
FLUSH PRIVILEGES;
_END_
)

echo "${sql}"
ssh ${user}@${server} "mysql -u root -p ${sql}"

