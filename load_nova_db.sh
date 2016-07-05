#!bin/bash

MYSQL_PORT=4000
DB_USER="root"
PASSWD="badock"

mysql -h 127.0.0.1 -P $MYSQL_PORT -u root --password="$PASSWD" --execute="drop database nova;"
mysql -h 127.0.0.1 -P $MYSQL_PORT -u root --password="$PASSWD" --execute="create database nova;"

if [ ! -d save ]; then
    mkdir -p save
fi

DATE=`date +%Y-%m-%d:%H:%M:%S`

mysqldump -h 127.0.0.1 -P 3306 -u root  --password="admin" nova > nova.sql
cp nova.sql save/nova_$DATE.sql

mysql -h 127.0.0.1 -P $MYSQL_PORT -u root -D nova --password="$PASSWD" < nova.sql

exit 0
