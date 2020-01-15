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

## General Concepts:
**VPC** ( Virtual Private Cloud) is an isolated area of your AWS account that has its own virtual network and IP address space. Just about every AWS resource deploys into a VPC. If you don’t explicitly specify a VPC, the resource will be deployed into the Default VPC.

A VPC is partitioned into one or more **subnets**, each with its own IP addresses. The subnets in the Default VPC are all public subnets. Production systems should deploy all servers, and certainly all data stores, in private subnets, which have IP addresses that can be accessed only from within the VPC and not from the public internet.

Load balancer to distribute traffic across your servers, Amazon’s Elastic Load Balancer (ELB) service offers three different types of load balancers:
* Application Load Balancer (ALB): load balancing of HTTP and HTTPS traffic
* Network Load Balancer (NLB): load balancing of TCP, UDP, and TLS traffic
* Classic Load Balancer (CLB): can handle HTTP, HTTPS, TCP, and TLS traffic, but with far fewer features than either the ALB or NLB

## Terraform common components:
```
provider "aws" {
  region = "us-west-1"
}
```
Use terraform doc to see config setting for each resource, e.g: https://www.terraform.io/docs/providers/aws/r/eks_cluster.html
```
resource "< PROVIDER>_< TYPE>" "< NAME>" { 
  [CONFIG ...]
}
```
reference: 
```
< PROVIDER>_< TYPE>.< NAME>.< ATTRIBUTE>
```

```
variable "NAME" {
  [CONFIG ...] # description, default and type
}
```

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
```
var.<VARIABLE_NAME>
```
To use a reference inside of a string literal: "${...}"

**output** variables:
```
output "< NAME>" {
  value = < VALUE>
  [CONFIG ...] # description and sensitive 
}
```
The syntax for using a data source is very similar to the syntax of a resource:
```
data "<PROVIDER>_<TYPE>" "<NAME>" {
  [CONFIG ...]
}
```
To get the data out of a data source:
```
data.<PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>
```

## Steps for different infrastraucture:
Allow EC2 Instance to receive traffic need to - [one-webserver](one-webserver/main.tf) :
1. create a **security group**. 
2. tell the EC2 Instance to use it by passing the ID of the security group into the vpc_security_group_ids argument.

**ASG** (Auto Scaling Group) - [alb-webserver-cluster](alb-webserver-cluster/main.tf) :
1. launch configuration: specifies how to configure each EC2 Instance in the ASG.
2. subnet_ids: specifies to ASG into which VPC subnets the EC2 Instances should be deployed. Use data sources to get the list of subnets in your AWS account.
3. deploying a load balancer (steps provided below)

**ALB** (Application Load Balancer):
1. create the ALB itself using the aws_lb resource
2. Listener: Listens on a specific port (e.g., 80) and protocol (e.g., HTTP)
3. security group to allow incoming requests. Tell the aws_lb resource to use this security group via the security_groups argument
4. Target groups: One or more servers that receive requests from the load balancer. The target group also performs health checks on these servers and only sends requests to healthy nodes.
5. Listener rule: sends requests that match specific paths or hostnames to specific target groups