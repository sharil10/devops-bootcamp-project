terraform {
  required_version = ">= 1.15"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.9"
    }
  }
    backend "s3" {
    bucket       = "devops-bootcamp-terraform-sharil"
    key          = "terraform/terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

data "aws_caller_identity" "my_account" {}
