# data "aws_ami" "aws-linux" {
#   # executable_users = ["self"]
#   most_recent      = true
#   # name_regex       = "^myami-\\d{3}"
#   owners           = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["ami-09d069a04349dc3cb"]
#     # values = ["amzn-ami-hvm-2018.03.0.20190826-x86_64-gp2-*"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# #   owners = ["099720109477"] # Canonical
# }

# locals {
#   jenkins_default_name = "jenkinsslave"
#   jenkins_home = "/home/ubuntu/jenkins_home"
#   jenkins_home_mount = "${local.jenkins_home}:/var/jenkins_home"
#   docker_sock_mount = "/var/run/docker.sock:/var/run/docker.sock"
#   java_opts = "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"
# }

resource "aws_security_group" "jenkins_slave_sg" {
#   name = local.jenkins_default_name
  name        = "jenkins_slave_sg"
  description = "Allow Jenkins inbound traffic"
  vpc_id      = "${aws_vpc.vpc-1.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port = 5000
    to_port = 5000
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
    name = "jenkins_slave_sg"
  }
}

resource "aws_instance" "project_jenkins_slave" {
  # count                  = "${length(var.subnets_cidr_private)}"
  # subnet_id              = "${element(aws_subnet.prv-subnet.*.id, count.index)}"
  count                  = "${length(var.subnets_cidr_public)}"
  subnet_id              = "${element(aws_subnet.pub-subnet.*.id, count.index)}"   
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  # key_name             = aws_key_pair.jenkins_ec2_key.key_name
  key_name               = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  tags = {
    Name = "Project Jenkins slave-${count.index+1}"
  }
  connection {
    type                = "ssh"
    # host              = "${aws_instance.project_jenkins_slave.*.public_ip}"
    # host              = "${element(aws_instance.project_jenkins_slave.*.public_ip, count.index)}"
    # host                = "${self.private_ip}"
    host                = "${self.public_ip}"
    user                = "ubuntu"
    # private_key         = tls_private_key.bastion_key.private_key_pem
    private_key         = file("hw2_key.pem")
    # # bastion_host        = "${aws_instance.bastion_host.*.public_ip}"
    # bastion_host        = "${aws_instance.bastion_host.public_ip}"
    # bastion_user        = "ubuntu"
    # bastion_private_key = tls_private_key.bastion_key.private_key_pem
    # # bastion_private_key = "${local_file.private_key.sensitive_content}"
  }

 
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y"
      # "sudo yum update -y",
      # "sudo yum install java-1.8.0 -y",
      # "sudo alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1",
      # "sudo alternatives --config java",
      # "sudo yum install docker git -y",
      # "sudo service docker start",
      # "sudo usermod -aG docker ec2-user"
    ]
  }
}

