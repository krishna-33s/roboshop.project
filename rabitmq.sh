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

cp $current_path/rabitmq.repo /etc/yum.repos.d/rabbitmq.repo
Validate $? "creating repo"

dnf install rabbitmq-server -y &>>$log_file
Validate $? "installing rabitmq"

systemctl enable rabbitmq-server &>>$log_file
systemctl start rabbitmq-server
Validate $? "enabling starting"

rabbitmqctl add_user roboshop roboshop123 &>>$log_file
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$log_file
Validate $? "created user and given permissions"