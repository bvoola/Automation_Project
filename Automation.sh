#!/bin/bash
#update the package information
sudo apt update -y

# Install Apache if its not installed yet
if dpkg -s apache2 &> /dev/null; then
{
echo "****Apache is installed****"
}
else
sudo apt-get update
sudo apt-get install apache2 -y
fi

#Enable Apache if its not enabled

if systemctl is-enabled --quiet apache2; then
       echo "****Apache is enabled****"
else	
sudo systemctl enable apache
fi

#Start Apache if its not running
if systemctl is-active --quiet apache2; then
        echo "****Apache is running****"
    else
        sudo systemctl start apache2
    fi

#Creating Tar file for logs
timestamp=$(date '+%d%m%Y-%H%M%S')
myname="Blessy"
s3_bucket="upgrad-blessy"
tar cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log
fileName=/tmp/${myname}-httpd-logs-${timestamp}.tar

#Archiving logs to S3
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

#Book keeping in inventory.html
size=$(find "$fileName" -printf "%s")
bookkeeping_file_path="/var/www/html/inventory.html"
if [ ! -f "$bookkeeping_file_path" ]; then
touch "$bookkeeping_file_path"
echo "<pre>Log Type		Time Created	 Type		Size</pre>" >> /var/www/html/inventory.html
echo "<pre>httpd-logs		${timestamp}	  tar		${size}</pre>" >> /var/www/html/inventory.html
else
echo "<pre>httpd-logs		${timestamp}	  tar		${size}</pre>" >> /var/www/html/inventory.html
fi

#schedule a cron job if not present already to run this script
cron_file_path="/etc/cron.d/automation"
if [ ! -f "$cron_file_path" ]; then
touch "$cron_file_path"
echo "* * * * * root /root/Automation_Project/automation.sh" >> /etc/cron.d/automation
fi


