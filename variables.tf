# variable "aws_access_key" {
#     default = ""
    
# }
# variable "aws_secret_key" {
#     default = ""
# }
# variable "private_key_path" {
#     default = ""
# }
variable "key_name" {
    default = "hw2_key"
}

variable "bas_key_name" {
    default = "bastion_key"
}

# variable "instance_count" {
#   default = "2"
# }
variable "region" {
  default = "us-east-1"
}

# variable "vpc_id" {
#   # type    = string
#   default = "${aws_vpc.vpc-1.id}"
# }

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}
# variable "subnet_count" {
#     default = 2
# }

variable "subnets_cidr_public" {
	default = ["10.0.1.0/24", "10.0.2.0/24"]
  type = "list"
}

variable "subnets_cidr_private" {
	default = ["10.0.10.0/24", "10.0.20.0/24"]
  type = "list"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
  type = "list"
}

variable "pub-subnet" {
  default = 4
}

variable "instance_type" {
  default = "t2.micro"
}
