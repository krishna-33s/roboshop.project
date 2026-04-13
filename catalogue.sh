#!/bin/bash

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


dnf module disable nodejs -y &>>$log_file
Validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$log_file
Validate $? "enabling nodejs:20"

dnf install nodejs -y &>>$log_file
Validate $? "installing nodejs"

id roboshop &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file 
    Validate $? "creating user"
else
    echo "roboshop already exist"
fi 

mkdir -p /app
Validate $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$log_file 
Validate $? "downloading catalogue code"

cd /app
Validate $? "moving to app directory"

rm -rf /app/*
Validate $? "removing default code"

unzip /tmp/catalogue.zip &>>$log_file
Validate $? "unzipping"

npm install &>>$log_file
Validate $? "downloading dependencies"

cp $current_path/catalogue.service /etc/systemd/system/catalogue.service
Validate $? "systemctl catalogue service"

systemctl daemon-reload
systemctl enable catalogue &>>$log_file
systemctl start catalogue
Validate $? "starting and enabling"

cp $current_path/mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
dnf install mongodb-mongosh -y &>>$log_file


INDEX=$(mongosh --host $mongo_ip --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -le 0 ]; then
    mongosh --host $mongo_ip </app/db/master-data.js
    Validate $? "Loading products"
else
    echo  "Products already loaded ... SKIPPING"
fi

systemctl restart catalogue
Validate $? "Restarting catalogue"