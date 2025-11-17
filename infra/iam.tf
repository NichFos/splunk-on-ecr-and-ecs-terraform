# Splunk ECS role /profile
data "aws_iam_policy_document" "task_exec_assume" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    principals { 
      type = "Service" 
      identifiers = ["ecs-tasks.amazonaws.com"] 
      }
  }
}

resource "aws_iam_role" "splunk_ecs_taskrole" {
  name               = "splunk-ecs-taskrole"
  assume_role_policy = data.aws_iam_policy_document.task_exec_assume.json
}

resource "aws_iam_role_policy_attachment" "task_exec_attach" {
  role       = aws_iam_role.splunk_ecs_taskrole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# EC2 instance template role/profile

data "aws_iam_policy_document" "ecs_instance_assume" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    principals { 
      type = "Service" 
      identifiers = ["ec2.amazonaws.com"] 
      }
  }
}


resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecsInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_for_ec2" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_role_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}