#!bin/bash

MYSQL_PORT=4000
DB_USER="root"
PASSWD="badock"

mysql -h 127.0.0.1 -P $MYSQL_PORT -u root --password="$PASSWD" --execute="drop database nova;"
mysql -h 127.0.0.1 -P $MYSQL_PORT -u root --password="$PASSWD" --execute="create database nova;"

mysqldump -h 127.0.0.1 -P 3306 -u root  --password="admin" nova > nova.sql

mysql -h 127.0.0.1 -P $MYSQL_PORT -u root -D nova --password="$PASSWD" < nova.sql

exit 0
