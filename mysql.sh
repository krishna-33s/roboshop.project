#/bin/bash

user_id=$(id -u)
log_folder="/var/log/roboshop.project"
log_file="$log_folder/$0.log"
mongo_ip=mongodb.krishnadev.space
mysql_ip=mysql.krishnadev.space
current_path=$PWD


if [ $user_id -ne 0 ]; then
    echo "pls run the script to root user" | tee -a $log_file
    exit 1

fi

mkdir -p $log_folder

Validate(){
    if [ $1 -ne 0 ]; then
        echo "$2...failed" | tee -a $le
        exit 1
    else
        echo "$2...success" | tee -a $log_file
    fi
}

dnf install mysql-server -y &>>$log_file
Validate $? "Install MySQL server"

systemctl enable mysqld &>>$log_file
systemctl start mysqld  
Validate $? "Enable and start mysql"

mysql_secure_installation --set-root-pass RoboShop@1
Validate $? "Setup root password"