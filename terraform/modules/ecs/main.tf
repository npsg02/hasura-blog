# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cluster"
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "hasura" {
  name              = "/ecs/${var.project_name}-${var.environment}/hasura"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-${var.environment}-hasura-logs"
  }
}

resource "aws_cloudwatch_log_group" "nextjs" {
  name              = "/ecs/${var.project_name}-${var.environment}/nextjs"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-${var.environment}-nextjs-logs"
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-task-execution"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-${var.environment}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-task"
  }
}

# Hasura Task Definition
resource "aws_ecs_task_definition" "hasura" {
  family                   = "${var.project_name}-${var.environment}-hasura"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.hasura_cpu
  memory                   = var.hasura_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "hasura"
      image     = var.hasura_image
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "HASURA_GRAPHQL_DATABASE_URL"
          value = var.database_url
        },
        {
          name  = "HASURA_GRAPHQL_ENABLE_CONSOLE"
          value = "true"
        },
        {
          name  = "HASURA_GRAPHQL_DEV_MODE"
          value = "false"
        },
        {
          name  = "HASURA_GRAPHQL_ENABLED_LOG_TYPES"
          value = "startup, http-log, webhook-log, websocket-log, query-log"
        },
        {
          name  = "HASURA_GRAPHQL_ADMIN_SECRET"
          value = var.hasura_admin_secret
        },
        {
          name  = "HASURA_GRAPHQL_JWT_SECRET"
          value = jsonencode({ type = "HS256", key = var.jwt_secret })
        },
        {
          name  = "HASURA_GRAPHQL_UNAUTHORIZED_ROLE"
          value = "anonymous"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.hasura.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/healthz || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-${var.environment}-hasura"
  }
}

# Next.js Task Definition
resource "aws_ecs_task_definition" "nextjs" {
  family                   = "${var.project_name}-${var.environment}-nextjs"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.nextjs_cpu
  memory                   = var.nextjs_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "nextjs"
      image     = var.nextjs_image
      essential = true

      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NEXT_PUBLIC_HASURA_GRAPHQL_URL"
          value = "http://localhost:8080/v1/graphql"
        },
        {
          name  = "HASURA_GRAPHQL_ADMIN_SECRET"
          value = var.hasura_admin_secret
        },
        {
          name  = "NEXTAUTH_SECRET"
          value = var.nextauth_secret
        },
        {
          name  = "NEXTAUTH_URL"
          value = var.nextauth_url
        },
        {
          name  = "JWT_SECRET"
          value = var.jwt_secret
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.nextjs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000 || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-${var.environment}-nextjs"
  }
}

# Hasura ECS Service
resource "aws_ecs_service" "hasura" {
  name            = "${var.project_name}-${var.environment}-hasura"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hasura.arn
  desired_count   = var.hasura_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.hasura_target_group_arn
    container_name   = "hasura"
    container_port   = 8080
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution]

  tags = {
    Name = "${var.project_name}-${var.environment}-hasura-service"
  }
}

# Next.js ECS Service
resource "aws_ecs_service" "nextjs" {
  name            = "${var.project_name}-${var.environment}-nextjs"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nextjs.arn
  desired_count   = var.nextjs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "nextjs"
    container_port   = 3000
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution]

  tags = {
    Name = "${var.project_name}-${var.environment}-nextjs-service"
  }
}

data "aws_region" "current" {}
