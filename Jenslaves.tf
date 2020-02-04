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
  count                       = "${length(var.subnets_cidr_public)}"
  subnet_id                   = "${element(aws_subnet.pub-subnet.*.id, count.index)}"   
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  # key_name                  = aws_key_pair.jenkins_ec2_key.key_name
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  tags = {
    Name = "Project Jenkins slave-${count.index+1}"
  }
  connection {
    type                = "ssh"
    host                = "${self.public_ip}"
    user                = "ubuntu"
    private_key         = file("hw2_key.pem")
    # bastion_host        = "${aws_instance.bastion_host.public_ip}"
    # bastion_user        = "ubuntu"
    # bastion_private_key = tls_private_key.bastion_key.private_key_pem

  # data "template_file" "ansible_hosts" {
  #   template = "${file("./ansible/hosts.tpl")}"
  #   vars {
  #       project_jenkins_slave = "${join("\n", aws_instance.project_jenkins_slave.*.private_ip)}"
  #   }
  # }
  # resource "local_file" "ansible_hosts" {
  #   content = "${data.template_file.ansible_hosts.rendered}"
  #   filename = "hosts"
  # }

  }

 
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt install openjdk-11-jre-headless -y",
      "sudo apt install default-jre -y"
      # "sudo apt install apt-transport-https ca-certificates curl software-properties-common -y",
      # "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      # "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
      # "sudo apt-get install docker-ce docker-ce-cli containerd.io",
      # "sudo systemctl status docker"
    ]
  }


}

