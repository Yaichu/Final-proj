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

sudo apt-get update --quiet
echo "[*] Installing Elastic Search"
# ELK_VERSION="7.6.0"
# sudo apt-get install --quiet -y elasticsearch=$ELK_VERSION 
# cd /etc/elasticsearch
# sudo sed -i 's/Xms1g/Xms256m/' jvm.options; sudo sed -i 's/Xmx1g/Xmx256m/' jvm.options
# cd /tmp/
sudo apt-get install -y elasticsearch
# sudo apt-get install --quiet -y filebeat
echo "[+] Done Installing Elastic Search"

# cp /vagrant/configs/elasticsearch/elasticsearch.yml /etc/elasticsearch/

# # copy over configs
sudo cp -R /tmp/vagrant-elk/configs/elasticsearch/elasticsearch.yml /etc/elasticsearch/

# cd /etc/
# sudo su
# cd elasticsearch/
sudo sed -i 's/Xms1g/Xms256m/' /etc/elasticsearch/jvm.options; sudo sed -i 's/Xmx1g/Xmx256m/' /etc/elasticsearch/jvm.options


sudo sed -i 's/SuccessExitStatus=143/SuccessExitStatus=143\nTimeoutSec=900/' /usr/lib/systemd/system/elasticsearch.service
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service

# cd /tmp/
# # Install Kibana
# echo "[*] Installing Kibana"
# # ELK_VERSION="7.6.0"
# sudo apt-get install --quiet -y kibana # =$ELK_VERSION 

# # copy over configs
# sudo cp -R /tmp/vagrant-elk/configs/kibana/kibana.yml /etc/kibana/

# sudo systemctl daemon-reload
# sudo systemctl enable kibana.service
# sudo systemctl start kibana.service
# echo "[*] Done Installing Kibana"


# # install Logstash
# echo "[*] Installing Logstash"
# sudo apt-get update && sudo apt-get install logstash
# cd /etc/logstash
# sudo sed -i 's/Xms1g/Xms256m/' jvm.options; sudo sed -i 's/Xmx1g/Xmx256m/' jvm.options
# cd /tmp/
# sudo apt-get install -y logstash
# apt-get install --quiet -y filebeat
# # copy over configs
# sudo cp -R /tmp/vagrant-elk/configs/logstash/ /etc/logstash/conf.d/
# systemctl enable logstash.service
# systemctl start logstash.service
# echo "[+] Done Installing Logstash"