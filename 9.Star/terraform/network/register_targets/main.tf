resource "aws_lb_target_group_attachment" "example1" {  
  for_each = toset(var.instance_ids)  
  target_group_arn = var.target_group["Wordpress"].arn
  target_id        = each.value
  port = var.target_group["Wordpress"].port
}

resource "aws_lb_target_group_attachment" "example2" {  
  for_each = toset(var.instance_ids)
  target_group_arn = var.target_group["Gatsby"].arn
  target_id        = each.value
  port = var.target_group["Gatsby"].port
}



