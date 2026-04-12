#!/bin/bash

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

dnf install python3 gcc python3-devel -y &>>$log_file
Validate $? "installing python"

id roboshop &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
    Validate $? "user creating"
else
    echo "user already created"
fi

mkdir -p /app
Validate $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$log_file
Validate $? "payment code"

cd /app 
Validate $? "moving to app"

rm -rf /app/*
Validate $? "Removing existing code"

unzip /tmp/payment.zip &>>$log_file
Validate $? "unzip file"

cd /app 
pip3 install -r requirements.txt &>>$log_file
Validate $? "installing dependencies"

cp $current_path/payment.service /etc/systemd/system/payment.service &>>$log_file
Validate $? "creating payment systemctl"

systemctl daemon-reload
systemctl enable payment &>>$log_file
systemctl start payment
Validate $? "enabling and starting"

