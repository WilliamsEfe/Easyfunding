variable "db_users" {
  description = "List of database users to create"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS Region to deploy resources"
  default     = "eu-west-2"
}

variable "db_password" {
  description = "The database password"
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "AWS Account ID"
  default     = "637423297014" 
}