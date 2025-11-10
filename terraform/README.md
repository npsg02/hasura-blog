# Hasura Blog - Terraform Infrastructure

This directory contains Terraform configuration to deploy the Hasura Blog application to AWS using:
- ECS Fargate for container orchestration
- RDS PostgreSQL for the database
- Application Load Balancer for traffic routing
- VPC with public and private subnets
- CloudWatch for logging

## Architecture

The infrastructure creates the following resources:

- **VPC**: Custom VPC with public and private subnets across multiple availability zones
- **RDS PostgreSQL**: Managed PostgreSQL database in private subnets
- **ECS Cluster**: Fargate cluster for running containerized applications
- **ECS Services**: 
  - Hasura GraphQL Engine service
  - Next.js application service
- **Application Load Balancer**: Routes traffic to services
- **Security Groups**: Network security rules
- **CloudWatch**: Log groups for application logs
- **IAM Roles**: For ECS task execution and tasks

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** installed (version >= 1.0)
   ```bash
   # Install Terraform
   # macOS
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

3. **AWS CLI** configured with credentials
   ```bash
   aws configure
   ```

4. **Docker image** for Next.js pushed to AWS ECR
   ```bash
   # Create ECR repository
   aws ecr create-repository --repository-name hasura-blog-nextjs
   
   # Build and push Docker image
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
   docker build -t hasura-blog-nextjs:latest .
   docker tag hasura-blog-nextjs:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/hasura-blog-nextjs:latest
   docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/hasura-blog-nextjs:latest
   ```

## Quick Start

### 1. Set Up Terraform Variables

Create a `terraform.tfvars` file from the example:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update the values, especially:
- `nextjs_image`: Your ECR image URL
- `nextauth_url`: Your application URL (can be updated after deployment)

### 2. Set Sensitive Variables via Environment Variables

```bash
# Database password (generate a strong password)
export TF_VAR_db_password="your-strong-database-password"

# Hasura admin secret (generate a strong secret)
export TF_VAR_hasura_admin_secret="your-strong-admin-secret"

# JWT secret (must be at least 32 characters)
export TF_VAR_jwt_secret="your-256-bit-secret-min-32-characters-long"

# NextAuth secret (generate with: openssl rand -base64 32)
export TF_VAR_nextauth_secret="your-nextauth-secret"
```

### 3. Initialize Terraform

```bash
terraform init
```

This downloads the required providers and modules.

### 4. Plan the Deployment

```bash
terraform plan
```

Review the planned changes to ensure everything looks correct.

### 5. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to create the resources.

This will take approximately 10-15 minutes to complete.

### 6. Get the Application URL

After successful deployment, Terraform will output the ALB DNS name:

```bash
terraform output nextjs_url
terraform output hasura_graphql_url
terraform output hasura_console_url
```

### 7. Update NextAuth URL (if needed)

If you didn't set the correct URL initially, update it:

1. Update `nextauth_url` in `terraform.tfvars`
2. Run `terraform apply` again

## Accessing the Application

Once deployed, you can access:

- **Next.js Application**: `http://<alb-dns-name>`
- **Hasura GraphQL API**: `http://<alb-dns-name>/v1/graphql`
- **Hasura Console**: `http://<alb-dns-name>:8080/console`

## Database Migrations

After the infrastructure is deployed, you need to apply Hasura migrations:

```bash
# Install Hasura CLI if not already installed
curl -L https://github.com/hasura/graphql-engine/raw/stable/cli/get.sh | bash

# From the project root directory
cd hasura

# Update the endpoint in config.yaml or use command line flag
hasura migrate apply --endpoint http://<alb-dns-name>:8080 --admin-secret <your-admin-secret> --database-name default

# Apply metadata
hasura metadata apply --endpoint http://<alb-dns-name>:8080 --admin-secret <your-admin-secret>
```

## Custom Domain and HTTPS

To use a custom domain with HTTPS:

1. **Request an ACM Certificate** in AWS Certificate Manager for your domain
2. **Add HTTPS listener** to the ALB:
   ```hcl
   # Add to modules/alb/main.tf
   resource "aws_lb_listener" "https" {
     load_balancer_arn = aws_lb.main.arn
     port              = "443"
     protocol          = "HTTPS"
     ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
     certificate_arn   = "arn:aws:acm:region:account:certificate/certificate-id"

     default_action {
       type             = "forward"
       target_group_arn = aws_lb_target_group.nextjs.arn
     }
   }
   ```
3. **Create Route53 record** pointing to the ALB
4. **Update security group** to allow HTTPS (port 443)

## Scaling

### Adjusting Task Count

Edit `terraform.tfvars`:

```hcl
hasura_desired_count = 3  # Increase from 2 to 3
nextjs_desired_count = 3  # Increase from 2 to 3
```

Then run:
```bash
terraform apply
```

### Adjusting Resources

Edit task CPU and memory in `terraform.tfvars`:

```hcl
hasura_cpu = 1024      # Increase from 512
hasura_memory = 2048   # Increase from 1024
```

## Monitoring

### CloudWatch Logs

View logs in AWS Console:
- Hasura logs: `/ecs/hasura-blog-prod/hasura`
- Next.js logs: `/ecs/hasura-blog-prod/nextjs`

Or use AWS CLI:
```bash
# View Hasura logs
aws logs tail /ecs/hasura-blog-prod/hasura --follow

# View Next.js logs
aws logs tail /ecs/hasura-blog-prod/nextjs --follow
```

### ECS Container Insights

Container Insights is enabled by default. View metrics in CloudWatch Console.

## Backup and Recovery

### Database Backups

RDS automated backups are enabled with a retention period (default: 7 days).

To create a manual snapshot:
```bash
aws rds create-db-snapshot \
  --db-instance-identifier hasura-blog-prod-postgres \
  --db-snapshot-identifier hasura-blog-manual-snapshot-$(date +%Y%m%d)
```

To restore from a snapshot:
1. Create a new RDS instance from the snapshot
2. Update the database endpoint in Terraform variables
3. Run `terraform apply`

## Costs

Estimated monthly costs (us-east-1):
- RDS db.t3.micro: ~$15-20
- ECS Fargate (2 tasks each): ~$30-40
- ALB: ~$20
- NAT Gateway (2): ~$60-70
- **Total: ~$125-150/month**

To reduce costs:
- Use a single NAT Gateway
- Reduce task counts to 1 each
- Use smaller RDS instance (db.t3.micro is already smallest)

## Troubleshooting

### Tasks Not Starting

Check ECS service events:
```bash
aws ecs describe-services \
  --cluster hasura-blog-prod-cluster \
  --services hasura-blog-prod-hasura
```

### Database Connection Issues

Verify security group rules allow traffic from ECS to RDS:
```bash
aws ec2 describe-security-groups \
  --group-ids <ecs-security-group-id> <rds-security-group-id>
```

### Cannot Access Application

Check ALB health checks:
```bash
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources including the database. Make sure to backup any important data first.

## State Management

For production use, it's recommended to use a remote state backend:

1. Create an S3 bucket for state:
   ```bash
   aws s3 mb s3://your-terraform-state-bucket
   ```

2. Create a DynamoDB table for state locking:
   ```bash
   aws dynamodb create-table \
     --table-name terraform-state-lock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST
   ```

3. Uncomment the backend configuration in `main.tf`:
   ```hcl
   backend "s3" {
     bucket         = "your-terraform-state-bucket"
     key            = "hasura-blog/terraform.tfstate"
     region         = "us-east-1"
     encrypt        = true
     dynamodb_table = "terraform-state-lock"
   }
   ```

4. Reinitialize Terraform:
   ```bash
   terraform init -migrate-state
   ```

## Module Structure

```
terraform/
├── main.tf                 # Main configuration
├── variables.tf            # Variable definitions
├── outputs.tf              # Output definitions
├── terraform.tfvars.example # Example variables
├── README.md               # This file
└── modules/
    ├── vpc/                # VPC, subnets, NAT gateways
    ├── security/           # Security groups
    ├── rds/                # PostgreSQL database
    ├── alb/                # Application Load Balancer
    └── ecs/                # ECS cluster, services, task definitions
```

## Security Best Practices

1. **Never commit secrets** to version control
2. **Use environment variables** for sensitive values
3. **Enable encryption** at rest for RDS and EBS volumes
4. **Use HTTPS** in production with ACM certificates
5. **Restrict security groups** to minimum required access
6. **Enable CloudTrail** for audit logging
7. **Use IAM roles** with least privilege
8. **Regular updates** of Docker images
9. **Enable MFA** on AWS root and admin accounts
10. **Regular security audits** with AWS Security Hub

## Support

For issues and questions:
- Check the main [README.md](../README.md)
- Review [DEPLOYMENT.md](../DEPLOYMENT.md)
- Open an issue on GitHub

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [Hasura Cloud Deployment Guide](https://hasura.io/docs/latest/deployment/deployment-guides/)
