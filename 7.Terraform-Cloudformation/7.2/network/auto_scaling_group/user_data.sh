#!/bin/bash
apt update
apt install nginx postgresql-client redis-tools -y    
cat > index.html <<HTML
<html>
<body>
<h1>TF-Nginx-ASG</h1>
</body>
</html>
HTML
rm -rf /var/www/html/*
cp ./index.html /var/www/html/index.html
systemctl enable nginx
systemctl restart nginx
