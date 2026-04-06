variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the dedicated VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for the public subnets"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for instances"
  type        = string
  default     = "web1"
}

variable "ssh_ingress_cidrs" {
  description = "CIDR blocks allowed to SSH to the instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ebs_volume_type" {
  description = "EBS volume type for instance root disks"
  type        = string
  default     = "gp3"
}
