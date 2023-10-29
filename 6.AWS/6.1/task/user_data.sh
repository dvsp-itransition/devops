#!/bin/bash
apt-get update
apt install nginx -y
apt install stress s-tui -y
cat > index.html <<EOF
<html>
<body>
<h1>demo-nginx-ASG</h1>
</body>
</html>
EOF
rm -rf /var/www/html/*
cp ./index.html /var/www/html/index.html
systemctl enable nginx
systemctl restart nginx


