#!/bin/bash

echo "Updating the system..."
sudo apt update -y
sudo apt upgrade -y

echo "Installing Nginx..."
sudo apt install nginx -y

echo "Starting Nginx..."
sudo systemctl start nginx

echo "Enabling Nginx..."
sudo systemctl enable nginx

echo "Checking Nginx status..."
sudo systemctl status nginx
