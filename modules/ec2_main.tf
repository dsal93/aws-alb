#EC2 Instances

resource "aws_instance" "ec2" {
  ami                    = "${data.aws_ami.az.id}"
  count                  = 2
  instance_type          = var.instance_type
  availability_zone      = var.AZ[count.index]
  subnet_id              = aws_subnet.public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.webtier_sg.id]
  user_data              = var.user_data

  root_block_device {
    delete_on_termination = true
    iops = 150
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "Two-Tier-EC2"
  }
}

# ALB for Webtier

# ALB
resource "aws_lb" "external_alb" {
  name               = "external-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for i in aws_subnet.public_subnet : i.id]

  tags = {
    Name = "external-ALB"
  }
}

# ALB target group
resource "aws_lb_target_group" "external_group" {
  name     = "external-web-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}


resource "aws_lb_target_group_attachment" "ec2_target" {
  target_group_arn = aws_lb_target_group.external_group.arn
  count            = 2
  target_id        = aws_instance.ec2[count.index].id
  port             = 80
}


# Create ALB listener
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_group.arn
  }
}
