terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
  
  backend "s3" {
    bucket = "gonew-remote-state-dev"
    key    = "expense-dev-eks-vpc"
    region = "us-east-1"
    dynamodb_table = "gonew-remote-state-dev"
  }
}

provider "aws" {
  alias  = "west"
  region = "us-east-1"
}
