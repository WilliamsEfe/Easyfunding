resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Security group for EC2 instance to access RDS"

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "ec2_instance" {
  ami                    = "ami-090c59e6c2011c0f9"
  instance_type          = "t2.micro"
  key_name               = "EC2KeyPair"
  subnet_id              = "subnet-0f23f77dd3ca5329b"
  vpc_security_group_ids = ["sg-084f68fb203f77697"]

  tags = {
    Name = "Access-EC2-for-RDS"
  }
}
