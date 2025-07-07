resource "aws_security_group" "ssh_allowed" {
  vpc_id = var.vpc_id_ec2

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.open_internet]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.open_internet]
  }

  tags = {
    Name = "ssh_allowed"
  }
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.open_internet]
  security_group_id = aws_security_group.ssh_allowed.id
}

resource "aws_security_group_rule" "jenkins" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [var.open_internet]
  security_group_id = aws_security_group.ssh_allowed.id
}

resource "aws_instance" "example" {
  ami                    = var.ami_uk
  instance_type          = var.type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.ssh_allowed.id]
  subnet_id              = var.subnet_id_ec2

  tags = {
    Name = "FlaskAppServer"
  }
}

# 1. Generate an RSA private key
resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Create a unique suffix for the key name
resource "random_id" "suffix" {
  byte_length = 4
}

# 3. Register the public key with AWS as a key pair
resource "aws_key_pair" "deployer" {
  key_name   = "ephemeral-key-${random_id.suffix.hex}"
  public_key = tls_private_key.deployer.public_key_openssh
}

# 4. Save the private key locally for SSH access
resource "local_file" "private_key" {
  content         = tls_private_key.deployer.private_key_pem
  filename        = "${path.module}/ephemeral_key.pem"
  file_permission = "0600"
}