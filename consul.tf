resource "aws_security_group" "consul_sg" {
  name        = "project_consul_sg"
  description = "Allow ssh & consul inbound traffic"
  vpc_id      = "${aws_vpc.vpc-1.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh from the world"
  }

   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow http from the world"
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow consul UI access from the world"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow all outside security group"
  }
}

## Create Consul Cluster:
# Create the consul server
resource "aws_instance" "project_consul_server" {
  count                       = 3
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = "${element(aws_subnet.pub-subnet.*.id, count.index)}"
  iam_instance_profile        = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids      = [aws_security_group.consul_sg.id]
  key_name                    = var.key_name # aws_key_pair.consul_key.key_name 
  user_data                   = file("${path.module}/files/consul-server.sh")
  
  
  tags = {
    Name        = "project-consul-${count.index + 1}"
    consul_server = "true"
  }
}

# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "opsschool-consul-join1"
  assume_role_policy = file("${path.module}/templates/policies/assume-role.json")
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "opsschool-consul-join1"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("${path.module}/templates/policies/describe-instances.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "opsschool-consul-join1"
  roles      = ["${aws_iam_role.consul-join.name}"]
  policy_arn = aws_iam_policy.consul-join.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name  = "opsschool-consul-join1"
  role = aws_iam_role.consul-join.name
}

output "aws_instance_public_ip" {
  value = aws_instance.project_consul_server[*].public_ip
}