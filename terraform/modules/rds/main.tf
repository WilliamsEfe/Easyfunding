resource "aws_kms_key" "mykey" {
  description = "KMS key for encrypting RDS instances"
  is_enabled  = true
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS MySQL"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "mysql_dev" {
  identifier        = "mysql-dev"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  username          = "admin"
  password          = var.db_password
  db_name           = "mydb"
  skip_final_snapshot = true
}

resource "aws_db_instance" "mysql_staging" {
  identifier        = "mysql-staging"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t2.small"
  allocated_storage = 20
  username          = "admin"
  password          = var.db_password
  db_name           = "mydb"
  multi_az          = true
  storage_encrypted = true
  kms_key_id = aws_kms_key.mykey.arn
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot = true
}

resource "null_resource" "db_user_setup" {
  triggers = {
    db_instance_endpoint = aws_db_instance.mysql_dev.endpoint
  }

  provisioner "local-exec" {
    command = "${path.module}/../../scripts/setup-db-users.sh ${aws_db_instance.mysql_dev.endpoint} ${join(" ", var.db_users)}"
    environment = {
        EC2_PUBLIC_DNS = var.ec2_public_dns
    }
  }

  depends_on = [aws_db_instance.mysql_dev, aws_db_instance.mysql_staging]
}

resource "aws_secretsmanager_secret" "db_password" {
  name        = "db_password"
  description = "Database password for RDS instances"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    password = var.db_password
  })
}
