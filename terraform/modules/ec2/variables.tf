variable "allow_sg" {
  description = "Security Group ID to allow EC2 access to RDS"
  type        = string
}

variable "aws_region" {
  description = "AWS Region where the RDS instances will be created"
  type        = string
}
