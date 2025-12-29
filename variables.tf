variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR notation."
  }
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.10.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_cidr_block, 0))
    error_message = "Subnet CIDR block must be a valid IPv4 CIDR notation."
  }
}

variable "availability_zone" {
  description = "AWS availability zone for resources"
  type        = string
  default     = "me-central-1a"
}

variable "env_prefix" {
  description = "Environment prefix for resource naming"
  type        = string
  default     = "prod"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "public_key" {
  description = "Path to the public SSH key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "private_key" {
  description = "Path to the private SSH key"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "backend_servers" {
  description = "List of backend server configurations"
  type = list(object({
    name        = string
    suffix      = string
    script_path = string
  }))
  default = []
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "me-central-1"
}
