resource "aws_iam_role" "secrets_manager_role" {
  name = "secrets_manager_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com" # Or your specific service
        },
        Effect = "Allow",
        Sid = ""
      },
    ]
  })
}

resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "secrets_manager_access_policy"
  description = "Policy to allow access to specific secrets in AWS Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:db_password-*"
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy" {
  role       = aws_iam_role.secrets_manager_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}
