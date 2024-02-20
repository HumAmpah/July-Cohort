resource "aws_security_group" "drupal_sg" {
name = "drupal-sg"
description = "security group for drupal instance"

ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    }
  
}

resource "aws_security_group" "alb_sg" {
name= "alb_sg"
description = "Security group for ALB"
vpc_id= aws_vpc.ecommerce_vpc.id

ingress {
from_port= 80
to_port= 80
protocol= "tcp"
cidr_blocks = ["0.0.0.0/0"]
ipv6_cidr_blocks = ["::/0"]
}


egress {
from_port= 0
to_port= 0
protocol= "-1"
cidr_blocks = ["0.0.0.0/0"]
ipv6_cidr_blocks = ["::/0"]
}

tags = {
Name = "alb-sg"
}
 }

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.ecommerce_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_alb" "ecs_alb" {
 name= "ecs-alb"
 internal= false
 load_balancer_type = "application"
 security_groups= [aws_security_group.alb_sg.id]

 enable_deletion_protection = false

 subnets = (aws_subnet.public_subnet.*.id)

 enable_http2= true
 idle_timeout= 60

 enable_cross_zone_load_balancing = true

 tags = {
 Name = "ecs-abl"
 }
 }
