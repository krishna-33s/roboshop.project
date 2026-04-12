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

dnf install maven -y &>>$log_file
Validate $? "installing maven"

id roboshop &>>$log_file
if [ $? -ne 0 ]; then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
    Validate $? "creating user"
else 
    echo "already user created"
fi

mkdir -p /app &>>$log_file
Validate $? "creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$log_file
Validate $? "shipping code"

cd /app
Validate $? "adding to app directory"

rm -rf /app/*
Validate $? "Removing existing code"

unzip /tmp/shipping.zip &>>$log_file
Validate $? "unzipping"

cd /app 
mvn clean package &>>$log_file
Validate $? "installing and building shipping"

mv target/shipping-1.0.jar shipping.jar 
Validate $? "moving shipping"

cp $current_path/shipping.service /etc/systemd/system/shipping.service &>>$log_file
Validate $? "systemctl shipping"

systemctl daemon-reload

dnf install mysql -y &>>$log_file
Validate $? "installing mysql"

if [ $? -ne 0 ]; then 
    mysql -h $mysql_ip -uroot -pRoboShop@1 < /app/db/schema.sql &>>$log_file
    mysql -h $mysql_ip -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$log_file
    mysql -h $mysql_ip -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$log_file
    Validate $? "loding data into mysql"
else
    echo "already mysql installed"
fi

systemctl enable shipping &>>$log_file
systemctl start shipping
Validate $? "enabing and starting"

