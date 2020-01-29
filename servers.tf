# ## web servers (2)
# resource "aws_instance" "web" {
#   count                  = "${length(var.subnets_cidr_public)}"
#   subnet_id              = "${element(aws_subnet.pub-subnet.*.id, count.index)}"
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = var.instance_type
#   key_name               = var.key_name
#   vpc_security_group_ids = [aws_security_group.allow_ssh.id] # allowssh
#   associate_public_ip_address = true

#   tags = {
#     Name        = "web-${count.index + 1}"
#     owner       = "760579235815"
#     server_name = "yael"
#   }

#  connection {
#     type        = "ssh"
#     host        = self.public_ip
#     user        = "ec2-user"
#     private_key = file(var.private_key_path)
#   }

# #     provisioner "remote-exec" {
# #     inline = [
# #       "sudo yum install nginx -y",
# #       "sudo service nginx start",
# #     ]
# #   }
# }



# ## DB servers (2)
# resource "aws_instance" "DB" {
#   count                  = "${length(var.subnets_cidr_private)}"
#   subnet_id              = "${element(aws_subnet.prv-subnet.*.id, count.index)}"
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = var.instance_type
#   key_name               = var.key_name
#   vpc_security_group_ids = [aws_security_group.allow_ssh.id]
#   associate_public_ip_address = true

#   tags = {
#     Name        = "DB-${count.index + 1}"
#     owner       = "760579235815"
#     server_name = "yael"
#   }

#   connection {
#     type        = "ssh"
#     host        = self.public_ip
#     user        = "ec2-user"
#     private_key = file(var.private_key_path)

#   }

# #   provisioner "remote-exec" {
# #     inline = [
# #       "sudo yum install nginx -y",
# #       "sudo service nginx start",
# #     ]
# #   }
# }
