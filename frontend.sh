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
        echo "$2...failed" | tee -a $log_file
        exit 1
    else
        echo "$2...success" | tee -a $log_file
    fi
}

dnf module disable nginx -y &>>$log_file
Validate $? "disabling nginx"

dnf module enable nginx:1.24 -y &>>$log_file
Validate $? "enabling:1.24 nginx"

dnf install nginx -y &>>$log_file
Validate $? "installing nginx"

rm -rf /usr/share/nginx/html/* 
Validate $? "remove default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$log_file
cd /usr/share/nginx/html &>>$log_file
unzip /tmp/frontend.zip &>>$log_file
Validate $? "code and unzipping"

cp $current_path/nginx.conf /etc/nginx/nginx.conf &>>$log_file
Validate $? "configuration added"

systemctl restart nginx 
Validate $? "restarting"