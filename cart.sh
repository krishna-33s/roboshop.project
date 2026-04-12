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

mkdir -p /app &>>$log_file
Validate $? "creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$log_file
Validate $? "downloading cart code"

cd /app
Validate $? "moving to app directory"

rm -rf /app/*
Validate $? "removing default content"

unzip /tmp/cart.zip &>>$log_file
Validate $? "unzip cart code"

npm install &>>$log_file
Validate $? "installing dependicies"

cp $current_path/cart.service /etc/systemd/system/cart.service &>>$log_file
Validate $? "cart systemctl"

systemctl daemon-reload
systemctl enable cart 
systemctl start cart
Validate $? "enabling and starting"
