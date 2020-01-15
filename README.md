# terraform-exercise

Going through exercises from: https://www.terraformupandrunning.com/ second edition.

To run:
```
$ export AWS_ACCESS_KEY_ID=(your access key id)
$ export AWS_SECRET_ACCESS_KEY=(your secret access key)

terraform init
terraform plan
terraform apply
terraform destroy
terraform graph # dependency graph can convert to image using: http://dreampuf.github.io/GraphvizOnline 
terraform output # list all outputs without applying any changes
```

## Terraform common components:
**provider** "aws" {
  region = "us-west-1"
}

Use terraform doc to see config setting for each resource, e.g: https://www.terraform.io/docs/providers/aws/r/eks_cluster.html

**resource** "< PROVIDER>_< TYPE>" "< NAME>" { <br>
  [CONFIG ...]<br>
}

**reference**: < PROVIDER>_< TYPE>.< NAME>.< ATTRIBUTE>

**variable** "NAME" {<br>
  [CONFIG ...] # description, default and type<br>
}

Ways to provide a value for the variable:
* passing it in at the command line (using the -var option)
* via a file (using the -var-file option)
* via an environment variable (Terraform looks for environment variables of the name TF_VAR_<variable_name>). 
* If no value is passed in, the variable will fall back to default value. 
* If there is no default value, Terraform will interactively prompt the user for one.
Type: string, number, bool, list, map, set, object, tuple, and any. If not specifying a type, Terraform assumes any.
```
variable "object_example" {
  description = "An example of a structural type in Terraform"
  type        = object({
    name    = string
    age     = number
    tags    = list(string)
    enabled = bool
  })

  default = {
    name    = "value1"
    age     = 42
    tags    = ["a", "b", "c"]
    enabled = true
  }
}
```
variable reference:

var.<VARIABLE_NAME>

To use a reference inside of a string literal: "${...}"

**output** variables:

output "< NAME>" {<br>
  value = < VALUE><br>
  [CONFIG ...] # description and sensitive <br>
}

## Steps for different infrastraucture:
By default, AWS does not allow any incoming or outgoing traffic from an EC2 Instance. To allow the EC2 Instance to receive traffic need to create a **security group**. And tell the EC2 Instance to actually use it by passing the ID of the security group into the vpc_security_group_ids argument of the aws_instance resource. **Sample**: [one-webserver](one-webserver/main.tf) 

The first step in creating an **ASG** (Auto Scaling Group) is to create a launch configuration, which specifies how to configure each EC2 Instance in the ASG.
