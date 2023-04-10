resource "aws_instance" "public_instance" {
  ami           = "ami-006e00d6ac75d2ebb"
  instance_type = "t2.micro"
  key_name      = "CDIIT"
  subnet_id     = aws_subnet.zendrix_public_subnet_1.id
  security_groups = [aws_security_group.mywebserver.id]
  associate_public_ip_address = true
  tags = {
    Name = "zendrix-public-instance"
    Company = "Zendrix"
  }
}

resource "aws_instance" "private_instance" {
  ami           = "ami-006e00d6ac75d2ebb"
  instance_type = "t2.micro"
  key_name      = "CDIIT"
  subnet_id     = aws_subnet.zendrix_private_subnet_1.id
  security_groups = [aws_security_group.mywebserver.id]
  tags = {
    Name = "zendrix-private-instance"
    Company = "Zendrix"
  }
}

resource "aws_instance" "additional_instance_1" {
  ami           = "ami-006e00d6ac75d2ebb"
  instance_type = "t2.medium"
  key_name      = "CDIIT"
  subnet_id     = aws_subnet.zendrix_private_subnet_2.id
  security_groups = [aws_security_group.mywebserver.id]
  tags = {
    Name = "k8s-master"
    Company = "Zendrix"
  }
}

resource "aws_instance" "additional_instance_2" {
  ami           = "ami-006e00d6ac75d2ebb"
  instance_type = "t2.medium"
  key_name      = "CDIIT"
  subnet_id     = aws_subnet.zendrix_private_subnet_2.id
  security_groups = [aws_security_group.mywebserver.id]
  tags = {
    Name = "k8s-worker"
    Company = "Zendrix"
  }
}
