#/bin/bash

user_id=$(id -u)
log_folder="/var/log/roboshop.project"
log_file="$log_folder/$0.log"
mongo_ip=mongodb.krishnadev.space
current_path=$PWD


if [ $user_id -ne 0 ]; then
    echo "pls run the script to root user" | tee -a $log_file
    exit 1

fi

mkdir -p $log_folder

Validate(){
    if [ $1 -ne 0 ]; then
        echo "$2...failed" | tee -a $log_file
        exit 1
    else
        echo "$2...success" | tee -a $log_file
    fi
}

dnf module disable redis -y &>>$log_file
dnf module enable redis:7 -y &>>$log_file
Validate $? "disabling and enabling"

dnf install redis -y  &>>$log_file
Validate $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
Validate $? "allowing connections"

systemctl enable redis &>>$log_file  
systemctl start redis 
Validate $? "enabling and starting"


