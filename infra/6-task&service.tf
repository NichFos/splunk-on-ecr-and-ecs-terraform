resource "aws_cloudwatch_log_group" "splunkapp_logs" {
  name              = "/ecs/splunkapp"
  retention_in_days = 7
}


resource "aws_ecs_task_definition" "splunk-task-df" {
  family                   = "splunk-task-df"
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "3024"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.splunk_ecs_taskrole.arn
  task_role_arn            = aws_iam_role.splunk_ecs_taskrole.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([
    {
      name              = "splunkapp"
      image             = "082258817095.dkr.ecr.eu-west-1.amazonaws.com/class6/splunk:latest"
      cpu               = 1024
      memory            = 3024
      memoryReservation = 2048
      gpu               = 1024
      essential         = true
      portMappings = [
        {
          appProtocol   = "http"
          containerPort = 8000
          hostPort      = 8000
          portName      = "splunk"
          protocol      = "tcp"
        },
        {
          appProtocol   = "http"
          containerPort = 8089
          hostPort      = 8089
          portName      = "splunk-hec"
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "SPLUNK_PASSWORD"
          value = "what_lies_below"
        },
        {
          name  = "SPLUNK_START_ARGS"
          value = "--accept-license"
        },
        {
          name  = "SPLUNK_GENERAL_TERMS"
          value = "--accept-sgt-current-at-splunk-com"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.splunkapp_logs.name
          awslogs-region        = "eu-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "splunkapp_service" {
  name                   = "splunk-service"
  cluster                = aws_ecs_cluster.splunkapp_cluster.id
  task_definition        = aws_ecs_task_definition.splunk-task-df.arn
  desired_count          = 1
  enable_execute_command = true
  force_new_deployment   = true
  force_delete           = true

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.splunk_capacity_provider.name
    weight            = 1
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = [for i in aws_subnet.splunkapp_subnet : i.id]
    security_groups  = [aws_security_group.splunkapp_tg01_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.splunkapp_tg01.arn
    container_name   = "splunkapp"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]
}
