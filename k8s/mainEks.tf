# terraform {
#   required_version = ">= 0.12.0"
# }

# provider "aws" {
#   version = ">= 2.28.1"
#   region  = var.region
#   #"us-east-1" 
# }

# provider "random" {
#   version = "~> 2.1"
# }

# provider "local" {
#   version = "~> 1.2"
# }

# provider "null" {
#   version = "~> 2.1"
# }

# provider "template" {
#   version = "~> 2.1"
# }

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
#   load_config_file       = false
#   version                = "~> 1.10"
# }

# data "aws_availability_zones" "available" {
# }

# # resource "aws_default_vpc" "default" {
# # }

# # resource "aws_default_subnet" "subnet" {
# #   availability_zone = "us-west-2a"
# # }

# locals {
#   cluster_name = "project-eks-${random_string.suffix.result}"
# }

# # resource "aws_vpc" "K8s-vpc" {
# #   cidr_block = var.vpc_cidr_block
# #   enable_dns_hostnames = "true"
# #   # vpc_id = "${aws_vpc.K8s-vpc.id}"

# #   tags = {
# #        Name = "K8s-vpc"
# #    }
# # }

# # resource "aws_subnet" "K8s-subnet" {
# #   count             = 2
# #   vpc_id            = "${aws_vpc.K8s-vpc.id}"
# #   cidr_block        = "${var.subnets_cidr_public[count.index]}"
# #   availability_zone = "${var.availability_zones[count.index]}"

# #   tags = {
# #     Name = "K8s-subnet-${count.index+1}"
# #   }
# # }

# resource "random_string" "suffix" {
#   length  = 8
#   special = false
# }

# # CIDR will be "My IP" \ all Ips from which you need to access the worker nodes
# resource "aws_security_group" "worker_group_mgmt_one" {
#   name_prefix = "worker_group_mgmt_one"
#   vpc_id      = "vpc-0399381e6efc5b076" #"vpc-9dee6bfa" "${aws_vpc.K8s-vpc.id}"

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = ["0.0.0.0/0"]
#     # [
#     #   "199.203.102.38/32",
#     #   "207.232.13.77/32",
#     #   "192.168.1.0/32"
#     # ]
#   }
# }


# module "eks" {
#   source       = "terraform-aws-modules/eks/aws"
#   cluster_name = local.cluster_name
#   # vpc_id = "${aws_vpc.K8s-vpc.id}"
#   #TODO Ssbnet id
#   subnets      = ["subnet-0b2b011d50a8b3cae", "subnet-0e61ef726dd1703f1"]

#   tags = {
#     Environment = "test"
#     GithubRepo  = "terraform-aws-eks"
#     GithubOrg   = "terraform-aws-modules"
#   }

#   vpc_id = "vpc-0399381e6efc5b076" #"vpc-9dee6bfa"

#   # TODO Worker group 1
#   # One Subnet
#   worker_groups = [
#     {
#       name                          = "worker-group-1"
#       instance_type                 = "t2.micro"
#       additional_userdata           = "echo foo bar"
#       asg_desired_capacity          = 2
#       additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
#       public_ip                     = true  
#     }

#   ]

# }

# # output "aws_eks_cluster_ip" {
# #  value = aws_eks_cluster.cluster.*.public_ip
# # }
