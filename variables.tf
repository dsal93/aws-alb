# Variables

variable "region" {
  description = "AWS deployment region"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr_block" {
  description = "VPC IPv4 CIDR block"
  type        = string
  default     = "10.1.0.0/16"
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
