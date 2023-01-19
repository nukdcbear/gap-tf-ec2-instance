variable "region" {
  type        = string
  default     = "us-east-2"
  description = "AWS region target"
}

variable "aws_vpc_id" {
  type        = string
  default     = "vpc-00ff65477d5748f19"
  description = "VPC ID to use for the demo"
}

variable "aws_vpc_subnet_id" {
  type        = string
  default     = "subnet-08e69f7d7dc0798e1"
  description = "Subnet ID to use for the demo"
}

variable "bastion_ingress_cidr_block" {
  type        = string
  default     = "184.59.85.55/32"
  description = "Value for the bastion ingress cidr block"
}
