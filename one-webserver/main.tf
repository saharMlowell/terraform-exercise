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
  vpc_security_group_ids = [aws_security_group.instance.id] # The security group exports this id attribute

  # Define a dummy web server that uses busybox and run script as part of the EC2 Instance’s User Data configuration. 
  # EOF: Terraform syntax for multiline strings
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags = {
    Name = "terraform-example"
  }
}

# To allow EC2 Instance to receive traffic need to create security group
resource "aws_security_group" "instance" {

  name = "terraform-example-instance"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # CIDR blocks specify IP address ranges, 0.0.0.0/0 includes all possible IP addresses.
  }
}

# $ curl http://<EC2_INSTANCE_PUBLIC_IP>:8080
# Hello, World