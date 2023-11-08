resource "aws_launch_template" "TF-launch-template" {
  name          = "TF-launch-template"
  key_name      = var.key_name
  instance_type = var.type
  image_id      = var.ami[var.key]

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.sg_web_id]
  }

  user_data = filebase64("./network/auto_scaling_group/user_data.sh")

  tag_specifications {
    resource_type = var.resource_type
    tags = {
      Name = "Nginx-server-ASG"
    }
  }
}

resource "aws_autoscaling_group" "TF-ASG" {

  name = "TF-ASG"

  min_size         = var.size["min"]
  desired_capacity = var.size["desired"]
  max_size         = var.size["max"]

  vpc_zone_identifier = var.public_subnets

  launch_template {
    id      = aws_launch_template.TF-launch-template.id
    version = "$Latest"
  }
}

# Scale out policy if CPU usage > 70%
resource "aws_autoscaling_policy" "scale-out" {
  name                   = "scale-out"
  scaling_adjustment     = "1" # increases instance by 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.TF-ASG.name
}

resource "aws_cloudwatch_metric_alarm" "scale-out-alarm-cpu" {
  alarm_name          = "scale-out-alarm-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.threshold_out

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.TF-ASG.name
  }

  alarm_description = "Scale out policy if CPU usage > 70%"
  alarm_actions     = [aws_autoscaling_policy.scale-out.arn]

  depends_on = [aws_autoscaling_policy.scale-out]
}

# Scale in policy if CPU usage < 15%
resource "aws_autoscaling_policy" "scale-in" {
  name                   = "scale-in"
  scaling_adjustment     = "-1" # decreases instance by 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.TF-ASG.name
}

resource "aws_cloudwatch_metric_alarm" "scale-in-alarm-cpu" {
  alarm_name          = "scale-in-alarm-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.threshold_in

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.TF-ASG.name
  }

  alarm_description = "Scale in policy if CPU usage < 15%"
  alarm_actions     = [aws_autoscaling_policy.scale-in.arn]

  depends_on = [aws_autoscaling_policy.scale-in]
}



