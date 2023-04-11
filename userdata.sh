#!/bin/bash
sudo apt-get update
sudo apt-get install amazon-efs-utils
sudo mkdir /home/ubuntu/efs
# Mount EFS file system
sudo {{ efs_command }}
sudo chmod 777 /home/ubuntu/efs
cd /home/ubuntu
# Clone the source code
git clone {{ github_link }}
cd devops-pgp/
sudo apt-get install -y python3 tmux python3-pip
sudo pip3 install flask pymsql boto3
tmux new -s app
