#!/bin/bash

# Script to install Jenkins and Maven on Ubuntu

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if script is run with sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Please run this script as root or with sudo privileges${NC}"
    exit 1
fi

echo -e "${GREEN}Starting Jenkins and Maven installation on Ubuntu...${NC}"

# Step 1: Update the system
echo "Updating package lists and upgrading installed packages..."
apt update && apt upgrade -y

# Step 2: Install Java (OpenJDK 11)
echo "Installing OpenJDK 11..."
if ! command -v java &> /dev/null; then
    apt install openjdk-11-jdk -y
else
    echo "Java is already installed. Verifying version..."
fi

# Verify Java installation
JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
echo "Installed Java version: $JAVA_VERSION"

# Step 3: Install Maven
echo "Installing Maven..."
if ! command -v mvn &> /dev/null; then
    apt install maven -y
else
    echo "Maven is already installed. Verifying version..."
fi

# Verify Maven installation
MAVEN_VERSION=$(mvn -version 2>&1 | grep "Apache Maven" | awk '{print $3}')
echo "Installed Maven version: $MAVEN_VERSION"

# Step 4: Add Jenkins repository key and source
echo "Adding Jenkins repository..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Step 5: Update package list and install Jenkins
echo "Installing Jenkins..."
apt update
apt install jenkins -y

# Step 6: Start and enable Jenkins service
echo "Starting Jenkins service..."
systemctl start jenkins
systemctl enable jenkins

# Step 7: Check Jenkins status
echo "Checking Jenkins service status..."
if systemctl is-active --quiet jenkins; then
    echo -e "${GREEN}Jenkins is running successfully!${NC}"
else
    echo -e "${RED}Error: Jenkins failed to start. Check 'systemctl status jenkins' for details.${NC}"
    exit 1
fi

# Step 8: Display initial admin password and access instructions
echo "Retrieving initial admin password..."
INITIAL_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Not found")
if [ "$INITIAL_PASSWORD" != "Not found" ]; then
    echo -e "${GREEN}Initial Admin Password: $INITIAL_PASSWORD${NC}"
    echo "Save this password to unlock Jenkins."
else
    echo -e "${RED}Warning: Initial password not found. Check /var/lib/jenkins/secrets/initialAdminPassword manually.${NC}"
fi

# Step 9: Get Public IP for access
echo "Fetching public IP address..."
PUBLIC_IP=$(curl -s ifconfig.me || echo "Unable to fetch public IP")
if [ "$PUBLIC_IP" != "Unable to fetch public IP" ]; then
    echo -e "${GREEN}Jenkins installation complete!${NC}"
    echo "Access Jenkins at: http://$PUBLIC_IP:8080"
else
    echo -e "${RED}Could not fetch public IP. Use your server's public IP or private IP (check with 'hostname -I').${NC}"
    PRIVATE_IP=$(hostname -I | awk '{print $1}')
    echo "Private IP (if needed): $PRIVATE_IP"
fi
echo "If you’re using a firewall (e.g., ufw), allow port 8080 with: sudo ufw allow 8080"

# Step 10: Print Java and Maven paths
JAVA_PATH=$(which java)
MAVEN_PATH=$(which mvn)
echo -e "${GREEN}Installed Tool Paths:${NC}"
echo "Java Path: $JAVA_PATH"
echo "Maven Path: $MAVEN_PATH"

exit 0
