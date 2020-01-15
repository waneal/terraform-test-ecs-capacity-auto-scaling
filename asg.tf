data "aws_ssm_parameter" "ecs_optimized_ami" {
  # Get latest ecs optimized ami
  # https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_autoscaling_group" "tmp-asg" {
  name = "tmp-asg"

  max_size = 10
  min_size = 0

  vpc_zone_identifier = [aws_subnet.tmp-a.id, aws_subnet.tmp-c.id]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.tmp-template.id
        version            = "$Latest" # https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#version
      }
      override {
        instance_type     = "t3.large"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "t3.xlarge"
        weighted_capacity = "2"
      }
    }
    instances_distribution {
      # Use spot instance only.
      on_demand_percentage_above_base_capacity = 0
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity, tag]
  }

  # Interval of scale in/out
  default_cooldown = 60

  # If you enable managedTerminationProtection on capacity provider, you have to enable this.
  # protect_from_scale_in = true
}

resource "aws_launch_template" "tmp-template" {
  name                   = "tmp-template"
  image_id               = data.aws_ssm_parameter.ecs_optimized_ami.value
  vpc_security_group_ids = [aws_security_group.tmp.id]

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 60
      volume_type = "gp2"
    }
  }

  ebs_optimized = true
  user_data = base64encode(templatefile("./userdata.sh",
    {
      CLUSTER_NAME = var.ecs_cluster_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "tmp-ecs-instance"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name    = "tmp-ecs-instance"
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecsInstanceRole_tmp.arn
  }
}

