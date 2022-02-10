



# Install Java 11 to run Keycloak

apt install openjdk-11-jdk -y

# Create folder structure

mkdir -p /opt/keycloak

cd /opt/keycloak

# Download Keycloak.tar.gz

wget https://github.com/keycloak/keycloak/releases/download/16.1.1/keycloak-16.1.1.tar.gz

# Extract archive into current directory

tar --strip-components=1 -zxf file.tar.gz



# Get MySQL connector 

mkdir -p /opt/keycloak/modules/system/layers/keycloak/com/mysql/main

wget -O /opt/keycloak/modules/system/layers/keycloak/com/mysql/main/mysql-connector-java-8.0.23.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.23/mysql-connector-java-8.0.23.jar



./KEYCLOAK_HOME/bin/jboss-cli.sh

module add --name=com.mysql --resources=/opt/keycloak/modules/system/layers/keycloak/com/mysql/main/mysql-connector-java-8.0.23.jar --dependencies=javax.api,javax.transaction.api

/opt/keycloak/bin/standalone.sh --server-config=standalone-ha.xml