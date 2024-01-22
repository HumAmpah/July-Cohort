provider "aws" {
  region = var.region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "public_subnets" {
  count                = length(var.public_subnet_cidr_blocks)
  vpc_id               = aws_vpc.my_vpc.id
  cidr_block           = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone    = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Prod-pub-sub${count.index + 1}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Prod-pub-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Prod-priv-route-table"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Prod-igw"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnets[*].id)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "nginxdemos"
}

resource  "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        },
      },
    ],
  })
}
 
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "my-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "my-container",
      image = "nginx:latest",
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
        },
      ],
    },
  ])
}

resource "aws_db_instance" "my_database" {
  identifier            = "my-db-instance"
  allocated_storage     = 20
  storage_type          = "gp2"
  engine                = "mysql"
  engine_version        = "5.7"   
  instance_class        = "db.t2.micro"
  username              = "admin"  
  password              = "secretpassword" 
  parameter_group_name  = "default.mysql5.7"
  publicly_accessible   = true 
  multi_az              = false
  backup_retention_period = 7
  skip_final_snapshot   = true

  tags = {
    Name = "MyDatabase"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
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
    Name = "ALB Security Group"
  }
}

resource "aws_lb" "ecs_alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  enable_deletion_protection = false

  subnets = toset(aws_subnet.public_subnets[*].id)

  enable_http2       = true
  idle_timeout       = 60

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "ECS-ALB"
  }
}

resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}

resource "aws_lb_target_group" "ecs_alb_target_group" {
  name        = "ecs-alb-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "ip"
}

resource "aws_ecs_service" "ecs_alb_service" {
  name            = "ecs-alb-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

network_configuration {
    subnets         = toset(aws_subnet.public_subnets[*].id)
    security_groups = [aws_security_group.alb_sg.id]
  }

  depends_on = [aws_lb_listener.ecs_alb_listener,
  aws_ecs_service.ecs_alb_service]

  }
