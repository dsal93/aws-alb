


#If no AMI found for RHEL then we can use default Amazon linux ami
data "aws_ami" "az" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-ebs"]
  }
}
