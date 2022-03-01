resource "aws_lb" "application-lb" {
  provider           = aws.region-master
  name               = "ghost-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id]
  tags = {
    Name = "ghostapp-LB"
  }
}

resource "aws_lb_target_group" "ghost-ec2" {
  provider = aws.region-master
  name     = "ghost-ec2"
  port     = 2368
  vpc_id   = aws_vpc.cloudx.id
  protocol = "HTTP"
}



resource "aws_lb_target_group" "ghost-fargate" {
  provider = aws.region-master
  name     = "ghost-fargate"
  port     = 2368
  vpc_id   = aws_vpc.cloudx.id
  protocol = "HTTP"
}




resource "aws_lb_listener" "ghost-listener" {
  provider          = aws.region-master
  load_balancer_arn = aws_lb.application-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.ghost-ec2.arn
        weight = 50
      }

      target_group {
        arn    = aws_lb_target_group.ghost-fargate.arn
        weight = 50
      }
    }
  }
}




resource "aws_lb_target_group_attachment" "asg-attach" {
  provider         = aws.region-master
  target_group_arn = aws_lb_target_group.ghost-ec2.arn
  target_id        = aws_autoscaling_group.ghost_ec2_pool.id
  port             = 2368
}




resource "aws_launch_template" "ghost" {
  name_prefix    = "ghost-ec2-pool"
  image_id       = "ami-033b95fb8079dc481"
  instance_type  = "t2.micro"
  security_group = aws_security_group.ec2_pool.id
  #user_data = filebase64("${path.module}/example.sh")
  #user_data = data.template_file.userdata_ubuntu.rendered
  user_data = filebase64("${path.module}/userdata_ubuntu.rendered")

}

resource "aws_autoscaling_group" "ghost_ec2_pool" {
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id]

  launch_template {
    id      = aws_launch_template.ghost.id
    version = "$Latest"
  }
}