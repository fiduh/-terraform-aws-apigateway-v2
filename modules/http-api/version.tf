
terraform {
  # Require Terraform Core at exactly version 1.9.1
  required_version = "1.8.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

