#!/bin/bash
set -e

# set global variable
setup_env() {
        MYSQLDATA="/usr/local/mysql/data"
        MYSQLBASE="/usr/local/mysql"
}

# init database
init__database_dir() {
        echo "Change rights ..."
        ls -la  "$MYSQLDATA"
        chown -R mysql "$MYSQLDATA"
        chgrp -R mysql "$MYSQLDATA"
        echo "Initializing database..."
        cd $MYSQLBASE
        scripts/mysql_install_db --user=mysql
}

temp_server_start() {
        mysqld_safe --user=mysql  &
}

temp_server_stop() {
        mysqladmin shutdown -uroot -p$MYSQL_ROOT_PASSWORD
        sleep 30
}

setup_db() {
        sleep 20
        if [ "$MYSQL_ROOT_PASSWORD" == "" ]; then
                MYSQL_ROOT_PASSWORD="$(pwgen -A -B -1 8)"
        fi
	echo "mysql root password is: " $MYSQL_ROOT_PASSWORD
        echo "start password setting"
        mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION"
	mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION"
        echo "password ready"        
}

# start mysql if it is exist.
main() {
        setup_env
        if [ -z "$(ls -A "$MYSQLDATA/mysql/")" ]; then
                init__database_dir
                temp_server_start
                setup_db
                temp_server_stop
        fi
        exec "$@"
}

main "$@"
