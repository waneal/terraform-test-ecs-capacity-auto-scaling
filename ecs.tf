resource "aws_ecs_cluster" "tmp-cluster" {
  name               = var.ecs_cluster_name
  capacity_providers = [aws_ecs_capacity_provider.tmp-cluster-ec2.name]
  default_capacity_provider_strategy {
    base              = 0
    capacity_provider = aws_ecs_capacity_provider.tmp-cluster-ec2.name
    weight            = 1
  }
}

resource "aws_ecs_capacity_provider" "tmp-cluster-ec2" {
  # Currentry, we cannot delete capacity provider. If you exec 'terraform destroy', you can delete resouce only on tfstate.
  name = "tmp-cluster-ec2"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.tmp-asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 100
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

################################################
## Service: tmp-task
################################################

resource "aws_ecs_service" "tmp-task" {
  name            = "test-task"
  task_definition = aws_ecs_task_definition.tmp-task.arn
  cluster         = aws_ecs_cluster.tmp-cluster.arn
  desired_count   = 0

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.tmp-cluster-ec2.name
    weight = 1
    base = 0
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_ecs_task_definition" "tmp-task" {
  container_definitions    = file("./task-definition.json")
  family                   = "test-task"
  cpu                      = "128"
  memory                   = "128"
  requires_compatibilities = ["EC2"]
}

