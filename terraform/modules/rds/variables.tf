variable "db_users" {
  description = "List of database users to create"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS Region where the RDS instances will be created"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID for IAM Role and Policy"
  default     = "637423297014" 
}

variable "db_password" {
  description = "The database password"
  type        = string
  sensitive   = true
}

variable "ec2_public_dns" {
  description = "Public DNS of the EC2 instance for SSH tunneling"
  type        = string
}
