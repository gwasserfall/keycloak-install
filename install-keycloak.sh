#!/bin/bash

INSTALL_DIR="/opt/keycloak"


# If /opt/keycloak exists then exit
if [ -d $INSTALL_DIR ] 
then
    echo "Remove keycloak before running this script."
    exit 1 
fi

# Grab environment variables for database
if [ ! -f .env ]; then
    echo "Missing .env file"
    exit 1
fi

# Install Java 11
apt update
apt install openjdk-11-jre -y

export $(echo $(cat .env | sed 's/#.*//g' | sed 's/\r//g' | xargs) | envsubst)

# Place to store some files
mkdir -p ./temp

# Grab keycloak installation archive
wget -O ./temp/keycloak_archive.tar.gz "https://github.com/keycloak/keycloak/releases/download/16.1.1/keycloak-16.1.1.tar.gz"

# Create keycloak directory
mkdir -p "$INSTALL_DIR"

# Extract archive to keycloak folder
tar -xf ./temp/keycloak_archive.tar.gz --strip-components=1 -C "$INSTALL_DIR"

# # Move standalone configuration to correct folder with expanded vars from env
cp ./config/keycloak-server.xml "$INSTALL_DIR/standalone/configuration/standalone-ha.xml"

perl -i -p -e 's/\@MYSQL_CONNECTION_STRING\@/$ENV{MYSQL_CONNECTION_STRING}/' "$INSTALL_DIR/standalone/configuration/standalone-ha.xml"
perl -i -p -e 's/\@MYSQL_USERNAME\@/$ENV{MYSQL_USERNAME}/' "$INSTALL_DIR/standalone/configuration/standalone-ha.xml"
perl -i -p -e 's/\@MYSQL_PASSWORD\@/$ENV{MYSQL_PASSWORD}/' "$INSTALL_DIR/standalone/configuration/standalone-ha.xml"

# Add database driver
mkdir -p "$INSTALL_DIR/modules/system/layers/keycloak/com/mysql/main"
wget -O "$INSTALL_DIR/modules/system/layers/keycloak/com/mysql/main/mysql-connector-java-8.0.22.jar" https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.22/mysql-connector-java-8.0.22.jar
cp ./config/db-connector-module.xml "$INSTALL_DIR/modules/system/layers/keycloak/com/mysql/main/module.xml"


exit 0


# Install nginx
apt update
apt install nginx -y

# Move certificate and key to system dirs
cp ./certs/certificate.crt /etc/ssl/certs/certificate.crt
cp ./certs/private.key /etc/ssl/certs/private.key

# Replace nginx config and restart
cp ./config/nginx.conf /etc/nginx/sites-enabled/default
systemctl restart nginx

# Move service file and enable service at boot
cp ./config/keycloak.service /etc/systemd/system/keycloak.service
systemctl enable keycloak
systemctl start keycloak
