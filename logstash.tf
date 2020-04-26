resource "aws_security_group" "logstash_sg" {
#   name = local.jenkins_default_name
  name        = "logstash_sg"
  description = "Allow logstash inbound traffic"
  vpc_id      = "${aws_vpc.vpc-1.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5044
    to_port = 5044
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
    name = "logstash_sg"
  }
}

resource "aws_instance" "project_logstash" {
#   count                       = "${length(var.subnets_cidr_public)}"
  count                       = 1
  subnet_id                   = "${element(aws_subnet.pub-subnet.*.id, count.index)}"   
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  # key_name                  = aws_key_pair.jenkins_ec2_key.key_name
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.logstash_sg.id]
#   user_data                   = file("${path.module}/files_elk/logstash.sh")
  tags = {
    Name = "Project Logstash-${count.index+1}"
  }
  connection {
    type                = "ssh"
    host                = "${self.public_ip}"
    user                = "ubuntu"
    private_key         = file("hw2_key.pem")
  }

    provisioner "file" {
        source      = "./files_elk/logstash.sh"
        destination = "/tmp/logstash.sh"
    }

    provisioner "remote-exec" {
        inline = [
            # "cloud-init status --wait",
            "sudo chmod +x /tmp/logstash.sh",
            "sudo bash /tmp/logstash.sh"
        ]
    }

}