# resource "tls_private_key" "bastion_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "bastion_key" {
#   key_name   = "bastion_key"
#   public_key = "${tls_private_key.bastion_key.public_key_openssh}"
# }

# # Bastion host security group 
# resource "aws_security_group" "bastion" {
#   name        = "bastion"
#   description = "bastion security group"
#   vpc_id = "${aws_vpc.vpc-1.id}"

#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     cidr_blocks = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }  

#   tags = {
#     name = "bastion_sg"
#   }
# }

# resource "aws_instance" "bastion_host" {
# #    count                  = 1
#    ami                    = "${data.aws_ami.ubuntu.id}"
#    instance_type          = "${var.instance_type}"
#    subnet_id              = "${element(aws_subnet.pub-subnet.*.id, 1)}"
#    vpc_security_group_ids = [aws_security_group.bastion.id]
# #    availability_zone      = "${data.aws_availability_zones.available.names[count.index]}"
#    key_name               = "${aws_key_pair.bastion_key.key_name}"
#    associate_public_ip_address = true

#    tags = {
#         Name = "bastion"
#     }
# }
# resource "local_file" "private_key" {
#   sensitive_content  = "${tls_private_key.bastion_key.private_key_pem}"
#   filename           = "${var.bas_key_name}"
# }
# output "bastion_ip" {
# #   value = "${aws_instance.bastion_host[0].public_ip}"
# # value = aws_instance.bastion_host[count.index]
#     value = "${aws_instance.bastion_host[*].public_ip}"
# }