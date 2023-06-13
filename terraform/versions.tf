provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner       = "Todd"
      Provisioner = "Terraform"
    }
  }
}

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}