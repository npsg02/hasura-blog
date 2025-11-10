# Hasura Blog - AWS Infrastructure Architecture

This document describes the AWS infrastructure architecture for the Hasura Blog application deployed using Terraform.

## High-Level Architecture

```
                                    ┌─────────────────┐
                                    │   Internet      │
                                    └────────┬────────┘
                                             │
                                             │ HTTPS/HTTP
                                             │
                                    ┌────────▼────────┐
                                    │ Application     │
                                    │ Load Balancer   │
                                    │  (Public)       │
                                    └────────┬────────┘
                                             │
                        ┌────────────────────┼────────────────────┐
                        │                    │                    │
                        │ Port 80            │ Port 8080          │
                        │ (Next.js)          │ (Hasura)           │
                        │                    │                    │
            ┌───────────▼────────┐  ┌────────▼───────────┐       │
            │  Target Group      │  │  Target Group      │       │
            │  (Next.js)         │  │  (Hasura)          │       │
            └───────────┬────────┘  └────────┬───────────┘       │
                        │                    │                    │
        ┌───────────────┴────────────────────┴───────────────────┴───────┐
        │                      VPC (10.0.0.0/16)                          │
        │                                                                  │
        │  ┌────────────────────────────────────────────────────────┐    │
        │  │              Public Subnets                             │    │
        │  │  ┌──────────────────┐      ┌──────────────────┐        │    │
        │  │  │  10.0.0.0/24     │      │  10.0.1.0/24     │        │    │
        │  │  │  us-east-1a      │      │  us-east-1b      │        │    │
        │  │  │  ┌────────────┐  │      │  ┌────────────┐  │        │    │
        │  │  │  │ NAT Gateway│  │      │  │ NAT Gateway│  │        │    │
        │  │  │  └────────────┘  │      │  └────────────┘  │        │    │
        │  │  └──────────────────┘      └──────────────────┘        │    │
        │  └────────────────────────────────────────────────────────┘    │
        │                              │                                  │
        │  ┌───────────────────────────┴──────────────────────────┐     │
        │  │              Private Subnets                          │     │
        │  │  ┌──────────────────┐      ┌──────────────────┐      │     │
        │  │  │  10.0.10.0/24    │      │  10.0.11.0/24    │      │     │
        │  │  │  us-east-1a      │      │  us-east-1b      │      │     │
        │  │  │                  │      │                  │      │     │
        │  │  │  ┌────────────┐  │      │  ┌────────────┐  │      │     │
        │  │  │  │ECS Fargate │  │      │  │ECS Fargate │  │      │     │
        │  │  │  │            │  │      │  │            │  │      │     │
        │  │  │  │ ┌────────┐ │  │      │  │ ┌────────┐ │  │      │     │
        │  │  │  │ │Next.js │ │  │      │  │ │Next.js │ │  │      │     │
        │  │  │  │ └────────┘ │  │      │  │ └────────┘ │  │      │     │
        │  │  │  │            │  │      │  │            │  │      │     │
        │  │  │  │ ┌────────┐ │  │      │  │ ┌────────┐ │  │      │     │
        │  │  │  │ │ Hasura │ │  │      │  │ │ Hasura │ │  │      │     │
        │  │  │  │ └────────┘ │  │      │  │ └────────┘ │  │      │     │
        │  │  │  └────────────┘  │      │  └────────────┘  │      │     │
        │  │  │                  │      │                  │      │     │
        │  │  │  ┌────────────┐  │      │  ┌────────────┐  │      │     │
        │  │  │  │RDS Postgres│  │      │  │RDS Postgres│  │      │     │
        │  │  │  │  (Primary) │  │      │  │  (Standby) │  │      │     │
        │  │  │  └────────────┘  │      │  └────────────┘  │      │     │
        │  │  └──────────────────┘      └──────────────────┘      │     │
        │  └─────────────────────────────────────────────────────┘     │
        └──────────────────────────────────────────────────────────────┘

                     ┌──────────────────────────────┐
                     │  CloudWatch Log Groups       │
                     │  - /ecs/hasura-blog/hasura   │
                     │  - /ecs/hasura-blog/nextjs   │
                     └──────────────────────────────┘
```

## Components

### 1. Virtual Private Cloud (VPC)

- **CIDR Block**: 10.0.0.0/16
- **DNS Hostnames**: Enabled
- **DNS Support**: Enabled
- **Availability Zones**: 2 (us-east-1a, us-east-1b)

#### Subnets

**Public Subnets** (Internet-facing):
- `10.0.0.0/24` in us-east-1a
- `10.0.1.0/24` in us-east-1b
- Connected to Internet Gateway
- Hosts NAT Gateways and ALB

**Private Subnets** (Internal):
- `10.0.10.0/24` in us-east-1a
- `10.0.11.0/24` in us-east-1b
- Connected to NAT Gateways for outbound traffic
- Hosts ECS tasks and RDS instances

### 2. Networking Components

#### Internet Gateway
- Enables communication between VPC and internet
- Attached to VPC

#### NAT Gateways
- **Count**: 2 (one per AZ for high availability)
- **Purpose**: Allow private subnet resources to access internet
- **Elastic IPs**: 2 (one per NAT Gateway)

#### Route Tables
- **Public Route Table**: Routes internet traffic to Internet Gateway
- **Private Route Tables**: Route internet traffic to NAT Gateways (one per AZ)

### 3. Security Groups

#### ALB Security Group
**Inbound Rules**:
- Port 80 (HTTP) from 0.0.0.0/0
- Port 443 (HTTPS) from 0.0.0.0/0
- Port 8080 (Hasura Console) from 0.0.0.0/0

**Outbound Rules**:
- All traffic allowed

#### ECS Security Group
**Inbound Rules**:
- Port 3000 (Next.js) from ALB Security Group
- Port 8080 (Hasura) from ALB Security Group

**Outbound Rules**:
- All traffic allowed

#### RDS Security Group
**Inbound Rules**:
- Port 5432 (PostgreSQL) from ECS Security Group

**Outbound Rules**:
- All traffic allowed

### 4. Application Load Balancer (ALB)

- **Type**: Application Load Balancer
- **Scheme**: Internet-facing
- **Subnets**: Public subnets in both AZs
- **Deletion Protection**: Enabled for production

#### Listeners

**HTTP Listener (Port 80)**:
- Default action: Forward to Next.js target group
- Rule: Forward `/v1/*`, `/v2/*`, `/healthz` to Hasura target group

**Hasura Console Listener (Port 8080)**:
- Default action: Forward to Hasura target group

#### Target Groups

**Next.js Target Group**:
- Port: 3000
- Protocol: HTTP
- Target Type: IP
- Health Check: `/` endpoint
- Deregistration Delay: 30 seconds

**Hasura Target Group**:
- Port: 8080
- Protocol: HTTP
- Target Type: IP
- Health Check: `/healthz` endpoint
- Deregistration Delay: 30 seconds

### 5. Amazon ECS (Elastic Container Service)

#### ECS Cluster
- **Launch Type**: Fargate (serverless)
- **Container Insights**: Enabled
- **Services**: 2 (Hasura and Next.js)

#### Hasura Service
- **Task Count**: 2 (configurable)
- **CPU**: 512 units (0.5 vCPU)
- **Memory**: 1024 MB (1 GB)
- **Network Mode**: awsvpc
- **Container Port**: 8080
- **Health Check**: `/healthz` endpoint

**Environment Variables**:
- `HASURA_GRAPHQL_DATABASE_URL`: RDS connection string
- `HASURA_GRAPHQL_ADMIN_SECRET`: Admin secret
- `HASURA_GRAPHQL_JWT_SECRET`: JWT configuration
- `HASURA_GRAPHQL_ENABLE_CONSOLE`: true
- `HASURA_GRAPHQL_DEV_MODE`: false

#### Next.js Service
- **Task Count**: 2 (configurable)
- **CPU**: 512 units (0.5 vCPU)
- **Memory**: 1024 MB (1 GB)
- **Network Mode**: awsvpc
- **Container Port**: 3000
- **Health Check**: `/` endpoint

**Environment Variables**:
- `NEXT_PUBLIC_HASURA_GRAPHQL_URL`: Hasura GraphQL endpoint
- `HASURA_GRAPHQL_ADMIN_SECRET`: Admin secret
- `NEXTAUTH_SECRET`: NextAuth secret
- `NEXTAUTH_URL`: Application URL
- `JWT_SECRET`: JWT secret

### 6. Amazon RDS (Relational Database Service)

- **Engine**: PostgreSQL 15.4
- **Instance Class**: db.t3.micro (configurable)
- **Storage**: 20 GB GP3 with auto-scaling to 40 GB
- **Multi-AZ**: Single-AZ deployment (can be upgraded to Multi-AZ)
- **Storage Encryption**: Enabled
- **Automated Backups**: Enabled (7 days retention)
- **Backup Window**: 03:00-04:00 UTC
- **Maintenance Window**: Monday 04:00-05:00 UTC

**CloudWatch Logs**:
- PostgreSQL logs
- Upgrade logs

### 7. IAM Roles and Policies

#### ECS Task Execution Role
- **Purpose**: Allows ECS to pull images and write logs
- **Managed Policy**: AmazonECSTaskExecutionRolePolicy
- **Permissions**:
  - ECR image pull
  - CloudWatch Logs write
  - Secrets Manager access (if needed)

#### ECS Task Role
- **Purpose**: Allows running tasks to access AWS services
- **Use Case**: Currently minimal, can be extended for S3, DynamoDB, etc.

### 8. CloudWatch Logs

#### Log Groups
- `/ecs/hasura-blog-prod/hasura`: Hasura container logs
- `/ecs/hasura-blog-prod/nextjs`: Next.js container logs

**Configuration**:
- Retention: 7 days (configurable)
- Log Driver: awslogs
- Stream Prefix: ecs

## Data Flow

### User Request Flow

1. **Client** sends HTTP request to ALB DNS name
2. **ALB** receives request and performs health check on targets
3. **ALB** routes request based on path:
   - `/` → Next.js target group
   - `/v1/graphql` → Hasura target group
   - `/console` (port 8080) → Hasura target group
4. **Target Group** forwards request to healthy ECS task
5. **ECS Task** (Next.js or Hasura) processes request
6. **Hasura** queries RDS PostgreSQL if needed
7. **Response** flows back through the same path

### Database Access Flow

1. **Hasura ECS Task** initiates connection to RDS
2. **ECS Security Group** allows outbound connection to RDS
3. **RDS Security Group** allows inbound connection from ECS
4. **RDS** authenticates and processes query
5. **Response** returns to Hasura task

### Outbound Internet Access Flow

1. **ECS Task** in private subnet needs internet access
2. **Route Table** directs traffic to NAT Gateway
3. **NAT Gateway** translates private IP to public Elastic IP
4. **Internet Gateway** routes traffic to internet
5. **Response** flows back through NAT Gateway to ECS task

## High Availability

### Redundancy
- **Multi-AZ Deployment**: Resources distributed across 2 availability zones
- **Multiple Tasks**: 2 tasks per service for redundancy
- **NAT Gateways**: One per AZ for HA
- **RDS**: Can be upgraded to Multi-AZ for automatic failover

### Health Checks
- **ALB Health Checks**: Monitor container health
- **ECS Health Checks**: Container-level health monitoring
- **RDS**: Automated monitoring and recovery

### Auto-Recovery
- **ECS Service**: Automatically replaces unhealthy tasks
- **ALB**: Automatically routes traffic to healthy targets
- **RDS**: Automated backup and point-in-time recovery

## Scaling

### Horizontal Scaling

**ECS Services**:
```hcl
hasura_desired_count = 2  # Increase to 3, 4, etc.
nextjs_desired_count = 2  # Increase to 3, 4, etc.
```

**Auto Scaling (not implemented, can be added)**:
- Target Tracking Scaling: Based on CPU/Memory utilization
- Step Scaling: Based on CloudWatch alarms
- Scheduled Scaling: Based on time patterns

### Vertical Scaling

**ECS Tasks**:
```hcl
hasura_cpu = 512      # Increase to 1024, 2048
hasura_memory = 1024  # Increase to 2048, 4096
```

**RDS**:
```hcl
db_instance_class = "db.t3.micro"  # Upgrade to db.t3.small, db.t3.medium
allocated_storage = 20              # Increase storage
```

## Security

### Network Security
- Private subnets for application and database
- Security groups with least privilege
- No direct internet access for ECS tasks

### Data Security
- RDS encryption at rest
- Secrets stored as environment variables (can be moved to Secrets Manager)
- VPC isolation

### Access Control
- IAM roles with least privilege
- No public database access
- Admin console access controlled

## Cost Optimization

### Current Costs (Estimated)
- **ECS Fargate**: ~$30-40/month (4 tasks, 0.5 vCPU, 1 GB each)
- **RDS db.t3.micro**: ~$15-20/month
- **ALB**: ~$20/month
- **NAT Gateway**: ~$60-70/month (2 gateways)
- **Data Transfer**: Variable
- **Total**: ~$125-150/month

### Cost Reduction Options
1. **Use Single NAT Gateway**: Save ~$32/month
   - Trade-off: Reduced availability if NAT Gateway fails
2. **Reduce Task Count**: Save ~$15/month per task
   - Trade-off: Reduced redundancy
3. **Use Savings Plans**: 20-30% discount on ECS and RDS
4. **Reserved Instances**: For RDS if long-term commitment possible

## Monitoring and Observability

### CloudWatch Metrics
- ECS: CPU, Memory, Network utilization
- ALB: Request count, latency, HTTP codes
- RDS: CPU, connections, storage, IOPS

### CloudWatch Logs
- Application logs from containers
- RDS logs (PostgreSQL, upgrades)

### CloudWatch Alarms (to be added)
- High CPU usage
- High memory usage
- Elevated error rates
- RDS storage threshold

## Disaster Recovery

### Backup Strategy
- **RDS Automated Backups**: 7 days retention
- **RDS Snapshots**: Manual snapshots before major changes
- **Terraform State**: Store in S3 with versioning

### Recovery Procedures

**Database Recovery**:
```bash
# Restore from automated backup
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier hasura-blog-prod-postgres \
  --target-db-instance-identifier hasura-blog-restored \
  --restore-time 2024-01-01T12:00:00Z
```

**Infrastructure Recovery**:
```bash
# Re-apply Terraform configuration
terraform apply
```

### RTO and RPO
- **RTO (Recovery Time Objective)**: ~15 minutes
- **RPO (Recovery Point Objective)**: Up to 5 minutes (RDS automated backups)

## Future Enhancements

1. **Auto Scaling**: Implement ECS auto-scaling based on metrics
2. **HTTPS/SSL**: Add ACM certificate and HTTPS listener
3. **Custom Domain**: Add Route53 DNS configuration
4. **WAF**: Add Web Application Firewall for security
5. **Secrets Manager**: Move secrets from environment variables
6. **Multi-Region**: Add replica in another region for DR
7. **CDN**: Add CloudFront for static content
8. **Monitoring**: Add X-Ray tracing and detailed monitoring
9. **CI/CD**: Add pipeline for automated deployments
10. **Cost Management**: Add budget alerts and cost optimization

## References

- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Hasura Cloud Deployment](https://hasura.io/docs/latest/deployment/deployment-guides/)
