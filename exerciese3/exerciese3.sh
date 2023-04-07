#!/bin/sh

log_name='custom'
conf_path="/etc/logwatch/conf/services/$log_name.conf"
logfile_path="/etc/logwatch/conf/logfiles/$log_name.conf"
script_path="/etc/logwatch/scripts/services/$log_name"

touch $conf_path
touch $logfile_path

touch $script_path
chmod +x $script_path

echo '#!/bin/bash' >> $script_path
echo 'cat' >> $script_path

echo "LogFile = $log_name" >> $conf_path

echo 'LogFile = auth.log' >> $logfile_path
echo 'LogFile = vsftpd.log' >> $logfile_path
echo 'LogFile = xrdp-sesman.log' >> $logfile_path

logwatch --detail Med --mailto root --service $log_name --range today