module "ecs_cluster" {
  source       = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git//?ref=v4.1.2"
  cluster_name = local.cluster_name

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        # You can set a simple string and ECS will create the CloudWatch log group for you
        # or you can create the resource yourself as shown here to better manage retetion, tagging, etc.
        # Embedding it into the module is not trivial and therefore it is externalized
        cloud_watch_log_group_name = var.cluster_cloud_watch_log_group_name
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
}

data "aws_iam_policy_document" "execution_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "execution_role_inline_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "kms:Decrypt"
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "task_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "task_role_inline_policy" {
  statement {
    actions = [
      "kms:Decrypt"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "execution_role" {
  name               = "${local.cluster_name}-ecs-task-execution-role"
  path               = "/${local.env}/"
  assume_role_policy = data.aws_iam_policy_document.execution_role_assume_policy.json

  inline_policy {
    name   = "${local.cluster_name}-ecs-task-execution-role-inline-policy"
    policy = data.aws_iam_policy_document.execution_role_inline_policy.json
  }
}

resource "aws_iam_role" "task_role" {
  name               = "${local.cluster_name}-ecs-task-role"
  path               = "/${local.env}/"
  assume_role_policy = data.aws_iam_policy_document.task_role_assume_policy.json

  inline_policy {
    name   = "${local.cluster_name}-ecs-task-role-inline-policy"
    policy = data.aws_iam_policy_document.task_role_inline_policy.json
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name                   = "hello-world"
      image                  = "" # Replace with Image URL
      readonlyRootFilesystem = false
      cpu                    = 512
      memory                 = 1024
      essential              = true

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/hello-world"
          awslogs-stream-prefix = "ecs"
          awslogs-region        = "eu-west-1"
          awslogs-create-group  = "true"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_security_group" "this" {
  name        = "${local.cluster_name}-sg"
  description = "Allow HTTPS"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_service" "this" {
  name            = local.ecs_service_name
  cluster         = module.ecs_cluster.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.subnet_ids
    security_groups = aws_security_group.this.id
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.this.arn
    container_name = var.ecs_service_name

  }
}
