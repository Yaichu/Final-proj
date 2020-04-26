#!/bin/bash

cd /tmp
# sudo apt-get install -y apt-transport-https
# sudo apt-get install -y software-properties-common wget
# wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# # sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
# echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list 

# sudo apt-get update
# sudo apt-get install -y grafana

sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/oss/release/grafana_6.7.3_amd64.deb
sudo dpkg -i grafana_6.7.3_amd64.deb
until $(curl --output /dev/null --silent --head --fail http://admin:admin@localhost:3000/api/admin/stats); do
    printf '.'
    sleep 5
done
sudo systemctl daemon-reload
sudo systemctl start grafana-server.service
sudo systemctl enable grafana-server.service