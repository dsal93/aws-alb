data "aws_availability_zones" "available" {}


#VPC Variables

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public Subnet cidr block"
  type        = list(string)
  default     = ["10.1.0.0/24", "10.1.1.0/24"]
}

variable "private_subnet_cidr" {
  description = "Private Subnet cidr block"
  type        = list(string)
  default     = ["10.1.2.0/24", "10.1.3.0/24"]
}

variable "AZ" {
  description = "Availability Zones of Resources"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}



#EC2 Variables If you want to specify specific AMI
#variable "ami" {
#  description = "ami of ec2 instance"
#  type        = string
#  default     = "ami-09cd747c78a9add63"
#}


variable "instance_type" {
  description = "Size of EC2 Instances"
  type        = string
  default     = "t2.micro"
}

variable "user_data" {
  description = "boostrap script for Apache"
  type        = string
  default     = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo “Hello World from $(hostname -f)” > /var/www/html/index.html
EOF
}
