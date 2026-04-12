#/bin/bash

user_id=$(id -u)
log_folder="/var/log/roboshop.project"
log_file="$log_folder/$0.log"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo
Validate $? "copying mongorepo"

dnf install mongodb-org -y &>>$log_file
Validate $? "installing mongodb"

systemctl enable mongod &>>$log_file
systemctl start mongod &>>$log_file
Validate $? "enabling and starting"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
Validate $? "connecting to all user"

systemctl restart mongod &>>$log_file
Validate $? "restarting "