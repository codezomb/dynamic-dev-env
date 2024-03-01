# ----------------------------------------------------------------------------------------------------------------------
# State & Providers
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  backend "s3" {
    key            = "cz-dev/terraform.tfstate"
    encrypt        = true
    bucket         = "cz-terraform-state"
    region         = "us-west-2"
  }

  required_providers {
    random = {
      source = "hashicorp/random"
      version = "~> 3"
    }

    aws = {
      source = "hashicorp/aws"
      version = "~> 5"
    }

    tls = {
      source = "hashicorp/tls"
      version = "~> 4"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
}

# ----------------------------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------------------------

### VPC Variables

variable "vpc_cidr_block" {
  type    = string
  default = "10.101.0.0/16"
}

variable "subnet_count" {
  type    = number
  default = 1
}

variable "zone_count" {
  type    = number
  default = 2
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "prefix" {
  type = string
}

### Users
### See secrets/default.tfvars

variable "user" {
  type    = map
  default = {
    /*
    ssh_key       = "<public key>"
    instance_type = "t2.micro"
    volume_size   = 500
    */
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# AMI Map
# ----------------------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    values = ["${var.prefix}-*"]
    name   = "name"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Outputs
# ----------------------------------------------------------------------------------------------------------------------

output "ip_address" {
  value = aws_eip.ip.public_ip
}
