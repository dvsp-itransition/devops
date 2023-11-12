#!/bin/bash

db_root_password="admin123"

# Installs LAMP stack on Amazon Linux 2023
sudo dnf update -y
sudo dnf install httpd wget php-fpm php-mysqli php-gd php-json php php-devel php-mysqlnd mariadb105-server -y

sudo systemctl start httpd
sudo systemctl enable httpd

sudo systemctl start mariadb            
sudo systemctl enable mariadb

sudo usermod -a -G apache $USER 
sudo chown -R $USER:apache /var/www 
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \; 
find /var/www -type f -exec sudo chmod 0664 {} \;

# Secures the database server
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${db_root_password}'"; # update root password
sudo mysql -u root -p${db_root_password} -e "DELETE FROM mysql.global_priv WHERE User='';" # remove_anonymous_users
sudo mysql -u root -p${db_root_password} -e "DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" # remove_remote_root
sudo mysql -u root -p${db_root_password} -e "DROP DATABASE IF EXISTS test;" # remove_test_database
sudo mysql -u root -p${db_root_password} -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
sudo mysql -u root -p${db_root_password} -e "FLUSH PRIVILEGES;" # Make our changes take effect

# Installs npm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash 
. ~/.nvm/nvm.sh 
nvm install 20 