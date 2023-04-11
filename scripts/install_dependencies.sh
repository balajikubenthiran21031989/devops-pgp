#!/bin/bash

# Install the CodeDeploy agent
sudo apt-get update
sudo apt-get install -y awscli
sudo apt-get install -y ruby2.0
sudo apt-get install -y wget
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
