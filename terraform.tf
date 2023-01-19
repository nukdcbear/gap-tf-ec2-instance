terraform {

  required_version = "~> 1.3"

  backend "s3" {
    bucket  = "tftest-terraformstate-bucket"
    key     = "dev/dcb-ec2-instance.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.36.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }

}
