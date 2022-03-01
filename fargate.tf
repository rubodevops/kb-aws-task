resource "aws_ecs_cluster" "ghost_cluster" {
  name = "ghost"
}

resource "aws_ecr_repository" "private_ghostrepo" {
  name                 = "ghost-ecr"
  image_tag_mutability = "MUTABLE"
}





resource "aws_ecs_task_definition" "main" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 1024


  container_definitions = jsonencode([
    {
      name      = "second"
      image     = "${var.container_image}:latest"
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 8080
          hostPort      = 2368
        }
      ]
    }
  ])

  volume {
    name      = "ghost-storage"
    host_path = "/var/lib/ghost/content"
  }
}



resource "aws_ecs_service" "main" {
  name                               = "ghost-test"
  cluster                            = aws_ecs_cluster.ghost_cluster.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id, aws_subnet.private_c.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ghost-fargate.arn
    container_name   = "ghost-container"
    container_port   = 2368
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}



