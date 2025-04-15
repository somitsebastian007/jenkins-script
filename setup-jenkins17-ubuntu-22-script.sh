#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing OpenJDK 17..."
sudo apt install openjdk-21-jdk -y

echo "Verifying Java installation..."
java -version

echo "Adding Jenkins GPG key..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "Adding Jenkins repository..."
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Updating package list..."
sudo apt update

echo "Installing Jenkins..."
sudo apt install jenkins -y

echo "Starting and enabling Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "Checking Jenkins status..."
sudo systemctl status jenkins

echo "Jenkins installation and setup complete."
