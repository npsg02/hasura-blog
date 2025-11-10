# Quick Start Guide - Terraform Deployment

This guide will help you deploy the Hasura Blog to AWS in under 30 minutes.

## Prerequisites Checklist

- [ ] AWS account with admin access
- [ ] AWS CLI installed and configured (`aws configure`)
- [ ] Terraform installed (v1.0+)
- [ ] Docker installed (for building Next.js image)
- [ ] Generated strong secrets

## Step-by-Step Deployment

### 1. Prepare Docker Image (5 minutes)

```bash
# From project root
cd /path/to/hasura-blog

# Get your AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="us-east-1"

# Create ECR repository
aws ecr create-repository --repository-name hasura-blog-nextjs --region $AWS_REGION

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push image
docker build -t hasura-blog-nextjs:latest .
docker tag hasura-blog-nextjs:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hasura-blog-nextjs:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hasura-blog-nextjs:latest

echo "✅ Image pushed to ECR"
echo "Image URI: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/hasura-blog-nextjs:latest"
```

### 2. Generate Secrets (2 minutes)

```bash
# Generate strong secrets
echo "DB_PASSWORD=$(openssl rand -base64 32)"
echo "HASURA_ADMIN_SECRET=$(openssl rand -base64 32)"
echo "JWT_SECRET=$(openssl rand -base64 32)"
echo "NEXTAUTH_SECRET=$(openssl rand -base64 32)"

# Save these! You'll need them in the next step
```

### 3. Configure Terraform (3 minutes)

```bash
cd terraform

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars
nano terraform.tfvars
# or
vi terraform.tfvars
```

Update these values in `terraform.tfvars`:

```hcl
# Set your ECR image URI from step 1
nextjs_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/hasura-blog-nextjs:latest"

# Optional: customize region, environment, etc.
aws_region = "us-east-1"
environment = "prod"
```

### 4. Set Environment Variables (1 minute)

```bash
# Use the secrets generated in step 2
export TF_VAR_db_password="<YOUR_DB_PASSWORD>"
export TF_VAR_hasura_admin_secret="<YOUR_HASURA_SECRET>"
export TF_VAR_jwt_secret="<YOUR_JWT_SECRET>"
export TF_VAR_nextauth_secret="<YOUR_NEXTAUTH_SECRET>"
```

### 5. Deploy Infrastructure (15-20 minutes)

```bash
# Option A: Use the deploy script (recommended)
./deploy.sh

# Option B: Manual deployment
terraform init
terraform plan
terraform apply
```

Wait for deployment to complete. This will:
- Create VPC and networking (2-3 min)
- Create RDS database (8-10 min)
- Create ECS cluster and services (3-5 min)
- Create Application Load Balancer (2-3 min)

### 6. Get Your URLs (1 minute)

```bash
# Get the application URLs
terraform output nextjs_url
terraform output hasura_graphql_url
terraform output hasura_console_url
```

Save these URLs! Example output:
```
nextjs_url = "http://hasura-blog-prod-alb-123456789.us-east-1.elb.amazonaws.com"
hasura_graphql_url = "http://hasura-blog-prod-alb-123456789.us-east-1.elb.amazonaws.com/v1/graphql"
hasura_console_url = "http://hasura-blog-prod-alb-123456789.us-east-1.elb.amazonaws.com:8080/console"
```

### 7. Apply Database Migrations (5 minutes)

```bash
# Install Hasura CLI if not already installed
curl -L https://github.com/hasura/graphql-engine/raw/stable/cli/get.sh | bash

# Go back to project root
cd ..

# Get your ALB DNS name
ALB_DNS=$(terraform -chdir=terraform output -raw alb_dns_name)

# Apply migrations
cd hasura
hasura migrate apply \
  --endpoint "http://$ALB_DNS:8080" \
  --admin-secret "$TF_VAR_hasura_admin_secret" \
  --database-name default

# Apply metadata
hasura metadata apply \
  --endpoint "http://$ALB_DNS:8080" \
  --admin-secret "$TF_VAR_hasura_admin_secret"

# (Optional) Seed database
hasura seed apply \
  --endpoint "http://$ALB_DNS:8080" \
  --admin-secret "$TF_VAR_hasura_admin_secret" \
  --database-name default
```

### 8. Verify Deployment (2 minutes)

```bash
# Test Next.js application
curl http://$ALB_DNS/

# Test Hasura health
curl http://$ALB_DNS/healthz

# Test GraphQL API
curl -X POST http://$ALB_DNS/v1/graphql \
  -H "Content-Type: application/json" \
  -H "x-hasura-admin-secret: $TF_VAR_hasura_admin_secret" \
  -d '{"query": "{ __schema { queryType { name } } }"}'

# Open in browser
echo "Next.js: http://$ALB_DNS"
echo "Hasura Console: http://$ALB_DNS:8080/console"
```

## Post-Deployment Steps

### Update NextAuth URL

If you didn't set it initially, update the NextAuth URL:

```bash
cd terraform

# Update terraform.tfvars
# Change: nextauth_url = "http://<your-alb-dns-name>"

# Apply changes
terraform apply
```

### (Optional) Set Up Custom Domain

1. Create a Route53 hosted zone for your domain
2. Create an ACM certificate
3. Update ALB to use HTTPS listener
4. Create Route53 A record pointing to ALB

See [README.md](README.md#custom-domain-and-https) for detailed instructions.

### (Optional) Enable Auto Scaling

Add auto-scaling configuration to scale services based on CPU/memory:

```hcl
# In modules/ecs/main.tf
resource "aws_appautoscaling_target" "hasura" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.hasura.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "hasura_cpu" {
  name               = "hasura-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.hasura.resource_id
  scalable_dimension = aws_appautoscaling_target.hasura.scalable_dimension
  service_namespace  = aws_appautoscaling_target.hasura.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
```

## Common Issues

### Issue: "Error creating RDS instance: InvalidParameterValue"

**Solution**: Check that your DB password meets AWS requirements:
- At least 8 characters
- No slash (/) or special characters like @, ", '

### Issue: "ECS tasks failing health checks"

**Solution**: 
1. Check CloudWatch logs: `aws logs tail /ecs/hasura-blog-prod/hasura --follow`
2. Verify environment variables are set correctly
3. Check security group rules allow ALB → ECS traffic

### Issue: "Can't connect to database"

**Solution**:
1. Verify RDS is running: `aws rds describe-db-instances`
2. Check ECS → RDS security group rules
3. Verify database URL in ECS task environment

### Issue: "502 Bad Gateway from ALB"

**Solution**:
1. Check ECS service status: `aws ecs describe-services`
2. Verify target health: `aws elbv2 describe-target-health`
3. Check container logs in CloudWatch

## Cleanup

To destroy all resources and stop incurring charges:

```bash
cd terraform
./destroy.sh

# Or manually
terraform destroy
```

**Warning**: This will delete all data including the database. Backup first!

## Estimated Costs

- **Setup**: Free (one-time)
- **Monthly Running**: ~$125-150/month
  - RDS: $15-20
  - ECS Fargate: $30-40
  - ALB: $20
  - NAT Gateway: $60-70
  - Data Transfer: Variable

## Next Steps

- [ ] Set up custom domain with Route53
- [ ] Enable HTTPS with ACM certificate
- [ ] Configure auto-scaling
- [ ] Set up CloudWatch alarms
- [ ] Enable AWS Backup for RDS
- [ ] Set up CI/CD pipeline
- [ ] Configure monitoring and alerting

## Support

- Main README: [../README.md](../README.md)
- Architecture Guide: [ARCHITECTURE.md](ARCHITECTURE.md)
- Deployment Guide: [../DEPLOYMENT.md](../DEPLOYMENT.md)
- Open an issue: https://github.com/npsg02/hasura-blog/issues

## Useful Commands

```bash
# View infrastructure state
terraform show

# List all resources
terraform state list

# Get specific output
terraform output nextjs_url

# View logs
aws logs tail /ecs/hasura-blog-prod/hasura --follow
aws logs tail /ecs/hasura-blog-prod/nextjs --follow

# Check ECS tasks
aws ecs list-tasks --cluster hasura-blog-prod-cluster
aws ecs describe-tasks --cluster hasura-blog-prod-cluster --tasks <task-id>

# Check RDS status
aws rds describe-db-instances --db-instance-identifier hasura-blog-prod-postgres

# Check ALB health
aws elbv2 describe-target-health --target-group-arn <arn>
```
