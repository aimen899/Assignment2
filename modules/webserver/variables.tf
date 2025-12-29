variable "env_prefix" {
  description = "Environment prefix for resource naming"
  type        = string
}

variable "instance_name" {
  description = "Name of the instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the instance"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "public_key" {
  description = "Path to the public SSH key"
  type        = string
}

variable "script_path" {
  description = "Path to the user data script"
  type        = string
}

variable "instance_suffix" {
  description = "Unique suffix for the key pair name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}
