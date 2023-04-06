#!/bin/bash

repo_lists_path='/etc/apt/sources.list'
repo_list_path_test='/home/abyssal/Skillfactory/linux_lesson_admin/sources.list'
backport_repo_comments='#\s*deb http://ru.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse'
backport_repo='deb http://ru.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse'

authorized_keys='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhqEC30RFE/sOnWs67EZ0As65CWEPMb6E8SWntq6Inqgn1HScg1cIhfucnDaFBj/qoJX0EjVfLXsGAdCI6r6QlgLJ4Tw34yIKMdKPqgi/yJ/b/NuvjpocnhX5qf+U5F5pdcFavBr5yGqUvKKgTj8JotWPs5RU1PK8tjLGnw0mYbINXUoqjB43WC1TFp+8dxP8eP3mq69bRBzosFcfcwF6KzIAmCaDDhpb7CKus5Fp+SKi+7rU6YoaRPv5JCVHEdx7i/NL54nKLcIwMS0R0C4X/3r2q5cgTV7jKviVJ0n1y0AtKQNsXhUXSwKPUwHSOXH/PtGafm73o1Ifblm7iSZRT rsa-key-20230406'

private_key='-----BEGIN OPENSSH PRIVATE KEY-----
AAABAHO0lhqqtLQv/ZqeUUpSabKmbz/NilYVFxOWgR5A11CHO7vXSuznLjeGnnfD
4V+AuAHn1waygsXgvE9lPPfif8RLDTfrMTrTdT0XwcTJJFSCcX/DZYjBJqP5Kyzo
j1yK4bfvlkMArj5Ls09PBX+iQwj1mVsqy4kUqK4uahmfZOkmJF/JNhYJhAQiYM8t
VhU6OAg9HuTxZs/bQT/uimnwvgbYkwFxDB+E4J3Up6hD141i0cYa1pfPhGM4GoYp
1iMlt9kxgYHU8TF/6h3P0Hth23YJMMG2YTkR4cSo/Op6YWxb05XNv0oi4yQecS59
WuAnaz4tR9oJWKqFUyQooKPojCEAAACBAPQBXIGiB3nozCHHWd8E1nWScD5i6Hzh
9vxN87fRNAG8JHVcaOD/eGcuC4rhCi9aCblxC/xqiumNh+ATwlB0kDKTblr/rIym
Yn2AdZOtbWBkMcEluvqyqPREe5FLSWGCDjfK6yB1DqloGMHOIK4VLDhvTzbDJ3HS
PwxRn2IoSxDdAAAAgQDsv/5XBPb7Oz0HSKwPprfj8IM1iWerOZ0zBpJd3k2PD0TW
/9aVCft5vK0gVQsjqpydJKbOu2ELB7QWgwKXiMugmED01BnmsutKYZXFp9pmZMJb
W/HEBts8aiSz9s0IgjFylQ05+vgzeghJxyFlKbqoyQDqsZH8xOb76JWIC3/O7wAA
AIAokbMaODjKRzoEuss1vvGXTrYezAGvBg94E6Se5rdw7bdVI+BmP5vPmpjaVQNi
QcbGqS1c1XD7HRFQE6+OBM0IWIdWLes5vPlmEIRYDcb/Zy8S3Qd6t9dFiTyeedsQ
sLGjx6q6oB4KNMYlaHP6kcO7+Atl7v8DL+SpfG1C9FDA+Q==
-----END OPENSSH PRIVATE KEY-----'

ssh_config_path='/etc/ssh/sshd_config'
username='operator'
user_password='p12wne3r'

ftp_config_user_list_path='/etc/vsftpd.userlist'
ftp_config_path='/etc/vsftpd.conf'

create_user() {
    echo "Creating user..."
    useradd -m -g sudo $username
    echo "$username:$user_password" | chpasswd
    echo "Creation user complete"
}

setting_ssh() {
    echo "install ssh"
     apt update

     apt -y install ssh
     apt -y install openssh-server

    echo "Setting ssh"
    systemctl enable sshd

    if grep -q "#PasswordAuthentication yes" $ssh_config_path; then
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' $ssh_config_path
        echo "Password authentication has been uncommented"
    elif grep -q "PasswordAuthentication yes" $ssh_config_path; then
        sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/" $ssh_config_path
        echo "Password authentication has been changed to 'no'"
    elif ! grep -q "PasswordAuthentication no" $ssh_config_path; then
        echo "Password authentication var not found"
        echo "PasswordAuthentication no" >> $ssh_config_path
        echo "Password authentication has been added with valie 'no'"
    fi

    mkdir /home/$username/.ssh
    echo "$authorized_keys" > /home/$username/.ssh/authorized_keys
    echo "Setting ssh complete"
    systemctl restart sshd

    echo "$private_key" > /home/$username/id_rsa #for test
}

setting_ftp() {
    echo "Install ftp"
    apt -y install vsftpd
    systemctl enable vsftpd

    echo "Setting ftp"
    touch $ftp_config_user_list_path
    echo "$username" >> $ftp_config_user_list_path

    if grep -q "write_enable" $ftp_config_path; then
    sed -i 's/write_enable.*/write_enable=YES/' $ftp_config_path
    else
    echo "write_enable=YES" >> $ftp_config_path
    fi

    if grep -q "anonymous_enable" $ftp_config_path; then
    sed -i 's/anonymous_enable.*/anonymous_enable=NO/' $ftp_config_path
    else
    echo "anonymous_enable=NO" >> $ftp_config_path
    fi

    if grep -q "userlist_enable" $ftp_config_path; then
    sed -i 's/userlist_enable.*/userlist_enable=YES/' $ftp_config_path
    else
    echo "userlist_enable=YES" >> $ftp_config_path
    fi

    if grep -q "userlist_file" $ftp_config_path; then
    sed -i 's/userlist_file.*/userlist_file=\/etc\/vsftpd.userlist/' $ftp_config_path
    else
    echo "userlist_file=\/etc\/vsftpd.userlist" >> $ftp_config_path
    fi

    if grep -q "userlist_deny" $ftp_config_path; then
    sed -i 's/userlist_deny.*/userlist_deny=NO/' $ftp_config_path
    else
    echo "userlist_deny=NO" >> $ftp_config_path
    fi
    systemctl restart vsftpd
}

check_backport_repo () {
    if grep -q "$backport_repo_comments" $repo_list_path_test; then
        sed -i 's,'"$backport_repo_comments"','"$backport_repo"',' $repo_list_path_test
        echo 'Backport repo uncommented in repository list'
    elif grep -q "$backport_repo" $repo_list_path_test; then
        echo 'Backport repo available in repository list'
    else
        echo "$backport_repo" >> $repo_list_path_test
        echo 'Backport repo added to the store'
    fi
}

install_apache() {
    apt update
    apt -y install ufw
    apt -y install apache2
    ufw allow 'Apache'
    if systemctl status apache2 | grep -q 'running'; then
        echo 'Apache is running'
    else
        echo 'Apache is not running. Starting apache...'
        systemctl start apache2
        if systemctl status apache2 | grep -q 'running'; then
            echo 'Apache is running'
        fi
    fi
}

check_backport_repo
install_apache
apt-get -y install python3
create_user
setting_ssh
setting_ftp
