#####################   Install Ansible     #####################

cd /tmp
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

##################### Install Node-Exporter #####################

git clone https://github.com/Yaichu/NodeExporter-Ansible.git
wget https://raw.githubusercontent.com/Yaichu/FilesForProject/master/node_exporter.service
sudo cp ./node_exporter.service /etc/systemd/system/node_exporter.service
cd NodeExporter-Ansible/project-node-exporter/
ansible-playbook -i hosts playbook.yml
sudo chmod +x /usr/local/bin/node_exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter.service