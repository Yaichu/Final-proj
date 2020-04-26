# provider "aws" {
#   version = "~> 2.0"
#   region  = "us-east-1"
# }

locals {
  jenkins_default_name = "jenkins"
  jenkins_home = "/home/ubuntu/jenkins_home"
  jenkins_home_mount = "${local.jenkins_home}:/var/jenkins_home"
  docker_sock_mount = "/var/run/docker.sock:/var/run/docker.sock"
  java_opts = "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"
}

resource "aws_security_group" "jenkins_sg" {
#   name = local.jenkins_default_name
  name        = "jenkins_sg"
  description = "Allow Jenkins inbound traffic"
  vpc_id      = "${aws_vpc.vpc-1.id}"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 2375
    to_port = 2375
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow prometheus UI access from the world"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }  

  tags = {
    name = "jenkins_sg"
  }
}

resource "aws_instance" "project_jenkins_master" {
  count                       = 1 #"${length(var.subnets_cidr_private)}"
  subnet_id                   = "${element(aws_subnet.prv-subnet.*.id, count.index)}"  
  ami                         = data.aws_ami.ubuntu.id #"ami-06020ba42f0096b0a"
  instance_type               = var.instance_type
  # key_name                  = aws_key_pair.jenkins_ec2_key.key_name
  key_name                    = var.key_name
#   associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id, aws_security_group.consul_sg.id]
#   user_data                   = file("${path.module}/files/promcol.sh.tpl") 
  iam_instance_profile        = aws_iam_instance_profile.consul-join.name
  depends_on                  = [aws_instance.project_consul_server]

  tags = {
    Name = "Project Jenkins Master"
  }

  connection {
    type                = "ssh"
    # host                = "${self.public_ip}"
    host                = "${self.private_ip}"
    user                = "ubuntu"
    private_key         = file("hw2_key.pem")
    bastion_host        = "${aws_instance.bastion_host.public_ip}"
    bastion_user        = "ubuntu"
    bastion_private_key = file("hw2_key.pem")
  }

  provisioner "file" {
    source      = "./files/consul-agent.sh"
    destination = "/home/ubuntu/consul-agent.sh"
  }

  provisioner "file" {
    source      = "./ansible/install_nodeEx.sh"
    destination = "/tmp/install_nodeEx.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt install docker.io -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      "mkdir -p ${local.jenkins_home}",
      "sudo chown -R 1000:1000 ${local.jenkins_home}"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo docker run -d --restart always -p 8080:8080 -p 50000:50000 -v ${local.jenkins_home_mount} -v ${local.docker_sock_mount} --env ${local.java_opts} jenkins/jenkins"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo sh /home/ubuntu/consul-agent.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /tmp/install_nodeEx.sh"
    ]
  }
}

# output "master_ip" {
#   value = "${aws_instance.project_jenkins_master.*.public_ip}"
# }

