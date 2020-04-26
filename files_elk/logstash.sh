#!/usr/bin/env bash

# export DEBIAN_FRONTEND="noninteractive"

# ELK_VERSION="7.6.0"

cd /tmp/
git clone https://github.com/vbichov/vagrant-elk.git

# update apt
sudo apt-get update --quiet
sudo apt-get install -y unzip ifupdown git apt-transport-https default-jre

echo "Java version"
java -version
# [ -z $JAVA_HOME ] && echo "JAVA_HOME not set" || echo "JAVA_HOME is ${JAVA_HOME}"

# install the Elastic GPG Key and repo
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

# install Logstash
echo "[*] Installing Logstash"
sudo apt-get update && sudo apt-get install logstash
cd /etc/logstash
sudo sed -i 's/Xms1g/Xms256m/' jvm.options; sudo sed -i 's/Xmx1g/Xmx256m/' jvm.options
cd /tmp/
sudo apt-get install -y logstash
# apt-get install --quiet -y filebeat
# copy over configs
sudo cp -R /tmp/vagrant-elk/configs/logstash/ /etc/logstash/conf.d/
sudo systemctl enable logstash.service
sudo systemctl start logstash.service