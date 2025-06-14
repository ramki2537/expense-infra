terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }

  backend "s3" {
    bucket = "gonew-remote-state-dev"
    key    = "expense-dev-eks-eks" # you should have unique keys with in the bucket, same key should not be used in other repos or tf projects
    region = "us-east-1"
    dynamodb_table = "gonew-remote-state-dev"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

