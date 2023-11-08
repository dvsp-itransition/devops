# 1-TARGET GRUOP
resource "aws_lb_target_group" "TF-TG" {
  name        = "TF-ELB"
  port        = var.port
  protocol    = var.protocol
  vpc_id      = var.vpc_id

  health_check {
    path = var.health_check_path
  }
}

resource "aws_autoscaling_attachment" "TF-ASG-attach" { # Targets Auto Scaling Group 
  lb_target_group_arn = aws_lb_target_group.TF-TG.arn
  autoscaling_group_name = var.autoscaling_group_name
}

# 2-LOAD BALANCER
resource "aws_lb" "TF-ELB" {
  name               = "TF-ELB"
  internal           = var.elb_type
  load_balancer_type = "application"
  security_groups    = [ var.sg_elb_id ]
  subnets            = [for subnet in var.public_subnets : subnet] # A list of subnet IDs to attach to the LB

  tags = {
    Environment = "TF-ELB"
  }
}

resource "aws_lb_listener" "LB-Listener" { # Adds Listener 
  load_balancer_arn = aws_lb.TF-ELB.arn
  port              = var.port
  protocol          = var.protocol

  default_action {
    type             = var.elb_action_type
    target_group_arn = aws_lb_target_group.TF-TG.arn
  }

  depends_on = [aws_lb_target_group.TF-TG]
}


