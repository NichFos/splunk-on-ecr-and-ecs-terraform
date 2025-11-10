resource "aws_security_group" "splunkapp_tg01_sg" {
  name        = "splunkapp_tg01_sg"
  description = "Allow Port 80"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    security_groups = [aws_security_group.splunkapp_lb01_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "splunkapp_tg01_sg"
    Service = "terraform"
  }
}



resource "aws_security_group" "splunkapp_lb01_sg" {
  name        = "splunkapp_lb01_sg"
  description = "Allow Port 80"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "splunkapp_lb01_sg"
    Service = "terraform"
  }
}