resource "aws_alb_target_group" "ecs_alb_tg" {
 name= "ecs-alb-tg"
 port= 80
 protocol= "HTTP"
 vpc_id= aws_vpc.ecommerce_vpc.id
 target_type = "ip"

health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

 }
