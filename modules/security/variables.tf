variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "env_prefix" {
  description = "Environment prefix for resource naming"
  type        = string
}

variable "my_ip" {
  description = "IP address allowed for SSH access"
  type        = string
}
