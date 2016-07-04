#!/bin/bash

set -x

# Check if superuser is running this script
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Install MySQL client
apt-get install -y mysql-client

#exit 0

#sudo service mysql stop

# Install Docker
echo "deb http://get.docker.io/ubuntu docker main" > /etc/apt/sources.list.d/docker.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
sudo apt-get update -y
sudo apt-get install -y lxc-docker

sudo service docker start

# Get TiDB source code
git clone https://github.com/pingcap/tidb.git
pushd tidb
docker build .
popd


# Kill existing tidb container (if it exists)
EXISTING_TIDB_ID=$(docker ps --all | grep tidb | awk '{print $1}')
if [ "${EXISTING_TIDB_ID}" != "" ]; then
    docker stop $EXISTING_TIDB_ID
    docker rm $EXISTING_TIDB_ID
fi

# Kill existing tidb image (if it exists)
EXISTING_TIDB_IMAGE_ID=$(docker images --all | grep tidb | awk '{print $1}')
if [ "${EXISTING_TIDB_IMAGE_ID}" != "" ]; then
    docker rmi $EXISTING_TIDB_IMAGE_ID
fi

MYSQL_PORT=4000

docker pull pingcap/tidb:latest
docker run -it -d --name tidb-server -p 127.0.0.1:$MYSQL_PORT:4000 pingcap/tidb:latest

DB_USER="root"
PASSWD="badock"
PASSWD_HASH=$(echo -n "$PASSWD" | sha1sum | awk '{print $1}')

sleep 10

mysql -h 127.0.0.1 -P $MYSQL_PORT -u root -D test --password="" --execute="CREATE USER '${DB_USER}'@'localhost' identified by '123';"
mysql -h 127.0.0.1 -P $MYSQL_PORT -u root -D test --password="" --execute="update mysql.user set password=\"${PASSWD_HASH}\" where user=\"${DB_USER}\";"
mysql -h 127.0.0.1 -P $MYSQL_PORT -u root -D test --password="$PASSWD" --execute="update mysql.user set host=\"%\" where user=\"${DB_USER}\";"
mysql -h 127.0.0.1 -P $MYSQL_PORT -u root -D test --password="$PASSWD" --execute="GRANT ALL ON *.* TO '${DB_USER}'@'%';"

exit 0
