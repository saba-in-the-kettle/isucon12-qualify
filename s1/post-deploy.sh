set -x

sudo chmod 777 /var/log/nginx
sudo chmod 777 /var/log/nginx/*
sudo chmod 777 /var/log/mysql
sudo chmod 777 /var/log/mysql/*

set -e

truncate -s 0 /var/log/mysql/mysql-slow.log
truncate -s 0 /var/log/nginx/access.log

sudo systemctl restart nginx
sudo systemctl disable --now mysql
sudo systemctl disable --now netdata

QUERY="CREATE USER IF NOT EXISTS 'isucon'@'%' identified by 'isucon';
GRANT ALL privileges on *.* to isucon@'%';
ALTER USER isucon@'%' IDENTIFIED WITH mysql_native_password BY 'isucon';
flush privileges;
"

# echo "$QUERY" | sudo mysql -uroot

sudo ufw disable
sudo service apparmor stop
sudo systemctl disable apparmor 
