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
#   vpc_id = "${aws_vpc.vpc-1.id}"
# }

# Grafana Security Group
resource "aws_security_group" "grafana_sg" {
  name        = "grafana_sg"
  description = "Security group for monitoring server"
  vpc_id      = "${aws_vpc.vpc-1.id}"

  # Allow all traffic to HTTP port 3000
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allocate the EC2 monitoring instance
resource "aws_instance" "grafana" {
  count                  = var.monitor_servers
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = "${element(aws_subnet.pub-subnet.*.id, count.index)}"
  vpc_security_group_ids = [aws_security_group.prometheus_sg.id, aws_security_group.grafana_sg.id]
  key_name               = var.key_name
  # user_data              = file("${path.module}/monitoring/grafana/install_nodex.sh")
  associate_public_ip_address = true

  tags = {
    # Owner = "Monitoring"
    Name  = "Proj-Grafana-${count.index + 1}"
  }

  connection {
    host         = self.public_ip
    user         = "ubuntu"
    private_key = file("hw2_key.pem")
  }

  provisioner "file" {
      source      = "monitoring/grafana/install_grafana.sh"
      destination = "/tmp/install_grafana.sh"
  }

  provisioner "remote-exec" {
      inline = [
        # "cloud-init status --wait",
        "chmod +x /tmp/install_grafana.sh",
        "/tmp/install_grafana.sh",
      ]
  }

  # provisioner "remote-exec" {
  #     inline = [
  #       # "cloud-init status --wait",
  #       "sudo apt-get install -y apt-transport-https",
  #       "sudo apt-get install -y software-properties-common wget",
  #       "wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -",
  #       "sudo add-apt-repository 'deb https://packages.grafana.com/oss/deb stable main'",
  #       "sudo apt-get update",
  #       "sudo apt-get install -y grafana",
  #       "sudo systemctl daemon-reload",
  #       "sudo systemctl start grafana-server"
  #     ]
  # }
  depends_on = [aws_instance.prometheus]
}

provider "grafana" {
#   version = "~> 1.5"
  url  = "http://${aws_instance.grafana[0].public_ip}:3000"
  auth = "admin:admin"
}

resource "grafana_data_source" "prometheus" {
  type          = "prometheus"
  name          = "prometheus"
  url           = "http://${aws_instance.prometheus[0].public_ip}:9090"
  is_default = true
#   username      = "foo"
#   password      = "bar"
#   database_name = "mydb"
}

resource "grafana_dashboard" "metrics" {
  config_json = "${file("${path.module}/monitoring/setup/node-exporter.json")}"
  # "${file("grafana-dashboard.json")}"
  depends_on = [grafana_data_source.prometheus]
}

resource "grafana_alert_notification" "slack" {
  name = "My Slack"
  type = "slack"

  settings = {
    # "slack" = "https://myteam.slack.com/hoook"
    slack = "https://app.slack.com/client/T2BKQBENL/G010CBXLLHF/thread/GN64UPGTZ-1587104637.073700?cdn_fallback=2"
    recipient = "@Yael Frenkel"
    uploadImage = "false"
  }
}

# resource "grafana_alert_notification" "email" {
#   name = "Email that team"
#   type = "email"
#   is_default = false

#   settings = {
#     addresses = "yael346@gmail.com"
#     uploadImage = "false"
#   }
# }

output "grafana_server_public_ip" {
  value = join(",", aws_instance.grafana.*.public_ip)
}

