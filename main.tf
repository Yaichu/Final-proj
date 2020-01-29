provider "aws" {
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
  region     = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# data "aws_ami" "redhat" {
#   most_recent = true
#   owners      = ["309956199498"]

#   filter {
#     name   = "name"
#     values = ["RHEL-8.0.0_HVM-20190618-x86_64-1-Hourly2-GP2"]
#   }

#   # filter {
#   #   name   = "root-device-type"
#   #   values = ["ebs"]
#   # }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# data "aws_ami" "aws-linux" {
#   most_recent = true
#   owners      = ["137112412989"]

#   filter {
#     name   = "name"
#     values = ["amzn-ami-hvm-2018.03.0.20191219.0-x86_64-gp2"]
#   }

#   # filter {
#   #   name   = "root-device-type"
#   #   values = ["ebs"]
#   # }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

## security group
resource "aws_security_group" "allow_ssh" {
  name        = "nginx_demo"
  description = "Allow ports for nginx demo"
  vpc_id      = "${aws_vpc.vpc-1.id}"
  

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}





