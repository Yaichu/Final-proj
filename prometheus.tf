# # Get Ubuntu AMI information 
# data "aws_ami" "ubuntu" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#   owners = ["099720109477"] # Canonical
# }

# # Get Subnet Id for the VPC
# data "aws_subnet_ids" "subnets" {
#   vpc_id = var.vpc_id
# }

#Monitoring Security Group
resource "aws_security_group" "prometheus_sg" {
  name        = "prometheus_sg"
  description = "Security group for monitoring server"
  vpc_id      = "${aws_vpc.vpc-1.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP from control host IP
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all SSH External
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

#   # Allow all traffic to HTTP port 3000
#   ingress {
#     from_port   = 3000
#     to_port     = 3000
#     protocol    = "TCP"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

  # Allow all traffic to HTTP port 9090
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# data "template_file" "consul-agent" {
#   template = file("${path.module}/files/consul-agent.sh")
# }

# data "template_file" "promcol" {
#   template = file("${path.module}/files/promcol.sh.tpl")
# }

# # Create the user-data for the Consul agent
# data "template_cloudinit_config" "agent-prom" {
#   part {
#     content = data.template_file.consul-agent.rendered

#   }
#   part {
#     content = data.template_file.promcol.rendered
#   }
# }

# Allocate the EC2 monitoring instance
resource "aws_instance" "prometheus" {
  count                       = var.monitor_servers
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
#   subnet_id              = element(tolist(data.aws_subnet_ids.subnets.ids), count.index)
  subnet_id                   = "${element(aws_subnet.prv-subnet.*.id, count.index)}"
  vpc_security_group_ids      = [aws_security_group.prometheus_sg.id, aws_security_group.consul_sg.id]
  key_name                    = var.key_name
  user_data                   = file("${path.module}/monitoring/prometheus/install_prom.sh")
  iam_instance_profile        = aws_iam_instance_profile.consul-join.name
  depends_on                  = [aws_instance.project_consul_server]
#   associate_public_ip_address = true

  tags = {
    # Owner = "Monitoring"
    Name  = "Proj-Prometheus-${count.index + 1}"
  }

  connection {
    # host         = self.public_ip
    # user         = "ubuntu"
    # private_key = file("hw2_key.pem")
    host                = self.private_ip
    user                = "ubuntu"
    private_key         = file("hw2_key.pem")
    bastion_host        = "${aws_instance.bastion_host.public_ip}"
    bastion_user        = "ubuntu"
    bastion_private_key = file("hw2_key.pem")
  }


  # provisioner "file" {
  #     source      = "monitoring/prometheus/docker-compose.yml"
  #     destination = "/tmp/docker-compose.yml"
  # }

  provisioner "file" {
      source      = "./files/promcol.sh.tpl"
      destination = "/tmp/promcol.sh.tpl"
  }

  # provisioner "remote-exec" {
  #     inline = [
  #       # "cloud-init status --wait",
  #       "sudo mkdir /etc/prometheus",
  #       "cd /etc/prometheus",
  #       "wget https://raw.githubusercontent.com/Yaichu/FilesForProject/master/prometheus.yml"
  #     ]
  # }

  # provisioner "remote-exec" {
  #     inline = [
  #       "cloud-init status --wait",
  #       "cd /tmp",
  #       "sudo docker-compose up -d"
  #     ]
  # }

  provisioner "remote-exec" {
      inline = [
        "cloud-init status --wait",
        "sudo chmod +x /tmp/promcol.sh.tpl",
        "sudo bash /tmp/promcol.sh.tpl"
      ]
  }

  

  # provisioner "file" {
  #   source      = "monitoring/setup/script.sh"
  #   destination = "/tmp/script.sh"
  # }
  #  provisioner "remote-exec" {
  #     inline = [
  #     "cd /tmp",
  #     "PROMETHEUS_TAG=v2.11.2",
  #     "sudo docker-compose up -d"
  #     ]
  #  }
}

output "prometheus_server_public_ip" {
  value = join(",", aws_instance.prometheus.*.public_ip)
}