resource "aws_security_group" "kibana_sg" {
#   name = local.jenkins_default_name
  name        = "kibana_sg"
  description = "Allow kibana inbound traffic"
  vpc_id      = "${aws_vpc.vpc-1.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5601
    to_port = 5601
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
    name = "kibana_sg"
  }
}

resource "aws_instance" "project_kibana" {
#   count                       = "${length(var.subnets_cidr_public)}"
  count                       = 1
  subnet_id                   = "${element(aws_subnet.pub-subnet.*.id, count.index)}"   
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type # "t2.medium"
  # key_name                  = aws_key_pair.jenkins_ec2_key.key_name
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.kibana_sg.id]
#   user_data                   = file("${path.module}/files_elk/kibana.sh")
  tags = {
    Name = "Project Kibana-${count.index+1}"
  }
  connection {
    type                = "ssh"
    host                = "${self.public_ip}"
    user                = "ubuntu"
    private_key         = file("hw2_key.pem")
  }

    provisioner "file" {
        source      = "./files_elk/kibana.sh"
        destination = "/tmp/kibana.sh"
    }

    provisioner "remote-exec" {
        inline = [
            # "cloud-init status --wait",
            "sudo chmod +x /tmp/kibana.sh",
            "sudo bash /tmp/kibana.sh"
        ]
    }

}