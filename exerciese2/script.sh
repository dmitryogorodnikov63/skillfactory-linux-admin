#!/bin/bash

backup_files="/etc/ssh/sshd_config /etc/vsftpd.conf /etc/xrdp/xrdp.ini /var/log"

archive_file=configs-`date '+%d-%B-%Y'`.tar

tar cpf /tmp/$archive_file $backup_files
