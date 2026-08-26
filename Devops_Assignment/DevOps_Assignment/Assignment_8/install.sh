#!/bin/bash

sudo apt update -y
sudo apt install docker.io -y

sudo systemctl start docker

sudo docker pull nginx
sudo docker pull mysql

sudo docker run -d --name nginx nginx
sudo docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=root mysql
