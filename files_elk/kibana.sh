#!/usr/bin/env bash

# export DEBIAN_FRONTEND="noninteractive"

cd /tmp/
git clone https://github.com/vbichov/vagrant-elk.git

# update apt
sudo apt-get update --quiet
sudo apt-get install -y unzip ifupdown git apt-transport-https default-jre --quiet

echo "Java version"
java -version # 11.0.6
# [ -z $JAVA_HOME ] && echo "JAVA_HOME not set" || echo "JAVA_HOME is ${JAVA_HOME}"

# install the Elastic PGP Key and repo
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo 'deb https://artifacts.elastic.co/packages/7.x/apt stable main' | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

cd /tmp/
# Install Kibana
echo "[*] Installing Kibana"
# ELK_VERSION="7.6.0"
sudo apt-get update --quiet
sudo apt-get install --quiet -y kibana # =$ELK_VERSION 

# copy over configs
sudo cp -R /tmp/vagrant-elk/configs/kibana/kibana.yml /etc/kibana/

sudo systemctl daemon-reload
sudo systemctl enable kibana.service
sudo systemctl start kibana.service
echo "[*] Done Installing Kibana"