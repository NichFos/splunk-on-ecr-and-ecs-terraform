resource "aws_ecs_cluster" "splunkapp_cluster" {
  name = "splunkapp-cluster"
  region = "eu-west-1"

    configuration {
      execute_command_configuration {
        logging = "DEFAULT"
      }
    }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_capacity_provider" "splunk_capacity_provider" {
  name = "splunk-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.splunkapp_asg01.arn 
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "attach" {
  cluster_name       = aws_ecs_cluster.splunkapp_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.splunk_capacity_provider.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.splunk_capacity_provider.name 
    weight            = 1
    base              = 0
  }
}