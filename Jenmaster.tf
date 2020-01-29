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
  subnet_id                   = "${element(aws_subnet.pub-subnet.*.id, count.index)}"  
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  # key_name                  = aws_key_pair.jenkins_ec2_key.key_name
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  tags = {
    Name = "Project Jenkins Master"
  }

  connection {
    # host = aws_instance.project_jenkins_master.public_ip
    host         = self.public_ip
    user         = "ubuntu"
    # private_key = file("jenkins_ec2_key")
    private_key = file("hw2_key.pem")
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
}

# output "master_ip" {
#   value = "${aws_instance.project_jenkins_master.*.public_ip}"
# }

