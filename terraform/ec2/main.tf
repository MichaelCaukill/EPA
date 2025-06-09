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

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.public_key_path)
}