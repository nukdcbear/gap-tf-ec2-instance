provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = "dev"
      Env-region  = "US"
      Terraform   = "True"
      Name        = ""
    }
  }
}

resource "random_pet" "server" {
  length = 2
  keepers = {
    # Generate a new pet name each time we switch to a new AMI id
    ami_id = data.aws_ami.ubuntu.id
  }
}

# -----------------------------------------------------------------------------
# AMI
# -----------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Official Canonical https://help.ubuntu.com/community/EC2StartersGuide

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "bastion" {
  name        = "dcb-vpc-bastion"
  description = "Rules for demo vpc bastion host"
  vpc_id      = var.aws_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_ingress_cidr_block] # Specific cidr to limit access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dcb-vpc-bastion"
  }
}

resource "aws_security_group" "private_ssh_ingress" {
  name        = "dcb-vpc-private-ssh"
  description = "Rules to allow SSH access to instances on private subnets"
  vpc_id      = var.aws_vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  tags = {
    Name = "deb-vpc-private-ssh"
  }
}

resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# resource "local_file" "bastion" {
#   content  = tls_private_key.bastion.private_key_pem
#   filename = ".bastion_id_rsa"
# }

resource "aws_key_pair" "bastion" {
  key_name   = "demo-vpc-bastion"
  public_key = tls_private_key.bastion.public_key_openssh
}

module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                   = random_pet.server.id
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.bastion.key_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = var.aws_vpc_subnet_id

  tags = {
    Name = random_pet.server.id
  }
}

locals {
  instructions = "ssh ubuntu@${module.bastion.public_ip} -i .bastion_id_rsa"
}
