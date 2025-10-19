#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create basic web page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>SGSI Web Server - ${environment}</title>
</head>
<body>
    <h1>SGSI Implementation</h1>
    <p>Environment: ${environment}</p>
    <p>Server started at: $(date)</p>
</body>
</html>
EOF

# Configure firewall
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload

# Configure httpd to listen on port 8080
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
systemctl restart httpd