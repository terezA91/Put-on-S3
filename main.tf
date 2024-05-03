resource "aws_iam_role" "for-ec2" {
  name = "role-for-ec2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "EC2AssumeRole"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "Custom-role"
  }
}

resource "aws_iam_policy" "for-s3" {
  name = "policy-for-s3"
  description = "for-access-to-s3"
  policy = jsonencode({
    "Version": "2012-10-17"
    "Statement": [
      {
        "Sid": "AllowEc2ToBucket"
        "Effect": "Allow",
        "Action": [
          "s3:Put*",
          "s3:List*",
          "s3:Describe*"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rp-attach" {
  role       = aws_iam_role.for-ec2.name
  policy_arn = aws_iam_policy.for-s3.arn
}

resource "aws_iam_instance_profile" "ip-example" {
  name = "some-instance-profile"
  role = aws_iam_role.for-ec2.name
}

resource "tls_private_key" "key-gen" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "key" {
  key_name   = var.key-file
  public_key = tls_private_key.key-gen.public_key_openssh
}

resource "local_file" "for-key" {
  content  = tls_private_key.key-gen.private_key_pem
  filename = var.key-file
}

resource "aws_security_group" "tf-sg" {
  name        = "my-sg"
  description = "desc-of-custom-sg"
  vpc_id      = "vpc-0d950414acc1afde9"

  ingress {
    description = "SSH"
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

/*
data "aws_ami" "custom-ami" {
  owners = ["767398017099"]
}
*/

data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "ec2-example" {
  #ami                  = data.aws_ami.custom-ami.id
  ami = data.aws_ami.amazon-linux-2.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ip-example.name
  key_name = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.tf-sg.name]

  tags = {
    Name = "My-EC2-instance"
  }
}

resource "aws_s3_bucket" "s3" {
  bucket = "bucket923"

  tags   = {
    Name = "My-S3"
  }
}

