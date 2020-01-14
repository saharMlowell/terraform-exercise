terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "aws" {
  region = "us-west-1"

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

resource "aws_instance" "example" {
  ami           = "ami-0c0e5a396959508b0" #Find available ec2 instances from https://cloud-images.ubuntu.com/locator/ec2/
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-example"
  }
}

