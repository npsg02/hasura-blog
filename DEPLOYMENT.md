# Deployment Guide

This guide covers different deployment scenarios for the Hasura Blog application.

## Table of Contents

1. [Local Development](#local-development)
2. [Docker Compose (Production)](#docker-compose-production)
3. [Cloud Deployment](#cloud-deployment)
   - [AWS with Terraform (Recommended)](#aws-with-terraform-recommended)
   - [Vercel + Hasura Cloud](#vercel--hasura-cloud)
   - [AWS Manual Deployment](#aws-manual-deployment)
   - [DigitalOcean App Platform](#digitalocean-app-platform)
4. [Environment Variables](#environment-variables)
5. [Database Management](#database-management)
6. [Troubleshooting](#troubleshooting)

## Local Development

### Quick Start

Use the provided setup script:

```bash
./setup.sh
```

Or manually:

```bash
# 1. Create environment file
cp .env.example .env

# 2. Start Hasura and PostgreSQL
docker-compose -f docker-compose.dev.yml up -d

# 3. Install dependencies
npm install

# 4. Start Next.js development server
npm run dev
```

### Access Points

- **Next.js App**: http://localhost:3000
- **Hasura Console**: http://localhost:8080/console
- **PostgreSQL**: localhost:5432
- **GraphQL Endpoint**: http://localhost:8080/v1/graphql

### Development Workflow

1. Make changes to your code
2. Next.js hot-reloads automatically
3. For GraphQL changes, run: `npm run codegen`
4. For database changes, create migrations in Hasura Console

## Docker Compose (Production)

### Prerequisites

- Docker and Docker Compose installed
- Domain name (for production)
- SSL certificate (recommended)

### Deployment Steps

1. **Clone the repository**:
```bash
git clone https://github.com/npsg02/hasura-blog.git
cd hasura-blog
```

2. **Configure environment variables**:
```bash
cp .env.example .env
# Edit .env with production values
nano .env
```

**Important**: Change these values for production:
- `POSTGRES_PASSWORD`: Use a strong password
- `HASURA_GRAPHQL_ADMIN_SECRET`: Use a strong secret
- `NEXTAUTH_SECRET`: Generate with: `openssl rand -base64 32`
- `JWT_SECRET`: Must be at least 32 characters
- `NEXTAUTH_URL`: Your production URL

3. **Build and start services**:
```bash
docker-compose -f docker-compose.prod.yml up -d --build
```

4. **Verify deployment**:
```bash
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs -f
```

5. **Apply migrations** (if not auto-applied):
```bash
docker-compose -f docker-compose.prod.yml exec hasura hasura-cli migrate apply --database-name default
```

### Production Checklist

- [ ] Update all default passwords and secrets
- [ ] Set `HASURA_GRAPHQL_ENABLE_CONSOLE` to `"false"`
- [ ] Set `HASURA_GRAPHQL_DEV_MODE` to `"false"`
- [ ] Configure proper CORS domains
- [ ] Setup SSL/TLS certificates
- [ ] Configure database backups
- [ ] Setup monitoring and logging
- [ ] Configure reverse proxy (Nginx/Traefik)
- [ ] Setup rate limiting
- [ ] Configure firewall rules

### Reverse Proxy (Nginx Example)

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    # Next.js
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Hasura GraphQL
    location /v1/graphql {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Cloud Deployment

### AWS with Terraform (Recommended)

**Automated infrastructure deployment using Terraform**

This is the recommended approach for production deployments. Terraform provides infrastructure as code with version control and reproducibility.

#### Features

- Automated AWS infrastructure provisioning
- ECS Fargate for container orchestration
- RDS PostgreSQL managed database
- Application Load Balancer with health checks
- Auto-scaling capabilities
- CloudWatch logging
- Multi-AZ deployment for high availability

#### Quick Start

```bash
# Navigate to terraform directory
cd terraform

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Set sensitive variables via environment
export TF_VAR_db_password="your-strong-password"
export TF_VAR_hasura_admin_secret="your-admin-secret"
export TF_VAR_jwt_secret="your-jwt-secret-min-32-chars"
export TF_VAR_nextauth_secret="your-nextauth-secret"

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Deploy infrastructure
terraform apply
```

#### After Deployment

1. Get the ALB DNS name from Terraform outputs:
   ```bash
   terraform output nextjs_url
   terraform output hasura_graphql_url
   ```

2. Apply database migrations:
   ```bash
   cd hasura
   hasura migrate apply --endpoint http://<alb-dns-name>:8080 --admin-secret <your-secret>
   hasura metadata apply --endpoint http://<alb-dns-name>:8080 --admin-secret <your-secret>
   ```

**For detailed instructions, see [terraform/README.md](terraform/README.md)**

### Vercel + Hasura Cloud

**Next.js on Vercel**:

1. Push code to GitHub
2. Import project to Vercel
3. Configure environment variables:
   - `NEXT_PUBLIC_HASURA_GRAPHQL_URL`: Your Hasura Cloud URL
   - `HASURA_GRAPHQL_ADMIN_SECRET`: Your admin secret
   - `NEXTAUTH_SECRET`: Generated secret
   - `JWT_SECRET`: JWT secret

**Hasura on Hasura Cloud**:

1. Create account at https://cloud.hasura.io
2. Create new project
3. Connect your PostgreSQL database
4. Apply migrations using Hasura CLI:
```bash
cd hasura
hasura migrate apply --endpoint https://your-project.hasura.app --admin-secret your-secret
```

### AWS Manual Deployment

**Using ECS/Fargate (Manual Setup)**:

1. Create ECR repositories for your images
2. Build and push Docker images:
```bash
docker build -t your-repo/hasura-blog:latest .
docker push your-repo/hasura-blog:latest
```

3. Create ECS task definitions
4. Setup RDS PostgreSQL database
5. Configure Application Load Balancer
6. Deploy ECS services

**Using EC2**:

1. Launch EC2 instance (Ubuntu recommended)
2. Install Docker and Docker Compose
3. Clone repository
4. Follow Docker Compose production steps
5. Setup Nginx reverse proxy
6. Configure security groups

### DigitalOcean App Platform

1. Create new App from GitHub repo
2. Configure services:
   - **Web Service**: Next.js (Dockerfile)
   - **Database**: PostgreSQL managed database
   - **Container**: Hasura (hasura/graphql-engine:latest)
3. Set environment variables
4. Deploy

## Environment Variables

### Required Variables

```bash
# Database
POSTGRES_PASSWORD=your-secure-password
POSTGRES_DB=hasura
POSTGRES_USER=postgres

# Hasura
HASURA_GRAPHQL_ADMIN_SECRET=your-admin-secret
NEXT_PUBLIC_HASURA_GRAPHQL_URL=http://localhost:8080/v1/graphql

# NextAuth
NEXTAUTH_SECRET=your-nextauth-secret
NEXTAUTH_URL=http://localhost:3000

# JWT (must be at least 32 characters)
JWT_SECRET=your-256-bit-secret-key-here
```

### Optional Variables

```bash
# CORS
CORS_DOMAIN=https://yourdomain.com

# Email (for authentication)
EMAIL_SERVER=smtp://username:password@smtp.example.com:587
EMAIL_FROM=noreply@yourdomain.com
```

## Database Management

### Backup Database

```bash
# Using Docker
docker-compose exec postgres pg_dump -U postgres hasura > backup.sql

# Direct connection
pg_dump -h localhost -U postgres -d hasura > backup.sql
```

### Restore Database

```bash
# Using Docker
docker-compose exec -T postgres psql -U postgres hasura < backup.sql

# Direct connection
psql -h localhost -U postgres -d hasura < backup.sql
```

### Create Migration

```bash
cd hasura
hasura migrate create "migration_name" --database-name default
# Edit the generated up.sql and down.sql files
hasura migrate apply --database-name default
```

### Seed Database

```bash
# Using Docker
docker-compose exec postgres psql -U postgres -d hasura -f /path/to/seed.sql

# Direct connection
psql -h localhost -U postgres -d hasura -f hasura/seeds/default/1699900000001_seed_data.sql
```

## Troubleshooting

### Common Issues

**1. Hasura can't connect to database**
```bash
# Check if PostgreSQL is running
docker-compose ps

# Check database logs
docker-compose logs postgres

# Verify connection string
docker-compose exec hasura env | grep DATABASE_URL
```

**2. Next.js can't connect to Hasura**
```bash
# Check if Hasura is running
curl http://localhost:8080/healthz

# Verify environment variable
echo $NEXT_PUBLIC_HASURA_GRAPHQL_URL

# Check Hasura logs
docker-compose logs hasura
```

**3. Authentication issues**
```bash
# Verify JWT secret matches between Hasura and NextAuth
# Check if NEXTAUTH_SECRET is set
# Verify NEXTAUTH_URL is correct
```

**4. Build fails**
```bash
# Clear cache and rebuild
rm -rf .next node_modules
npm install
npm run build
```

### Debug Mode

Enable verbose logging:

```bash
# Next.js
DEBUG=* npm run dev

# Hasura
docker-compose logs -f hasura
```

### Health Checks

```bash
# Check all services
docker-compose ps

# Test PostgreSQL
docker-compose exec postgres psql -U postgres -c "SELECT version();"

# Test Hasura
curl http://localhost:8080/healthz

# Test Next.js
curl http://localhost:3000
```

## Monitoring

### Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f hasura
docker-compose logs -f nextjs
docker-compose logs -f postgres
```

### Metrics

Consider using:
- **Prometheus + Grafana**: For metrics collection and visualization
- **ELK Stack**: For log aggregation
- **Sentry**: For error tracking
- **DataDog/New Relic**: For APM

## Scaling

### Horizontal Scaling

1. **Database**: Use PostgreSQL read replicas
2. **Hasura**: Run multiple Hasura instances behind a load balancer
3. **Next.js**: Deploy multiple Next.js instances

### Vertical Scaling

Adjust resource limits in docker-compose.yml:

```yaml
services:
  hasura:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```

## Security Best Practices

1. **Never commit secrets** to version control
2. **Use strong passwords** for all services
3. **Enable HTTPS** in production
4. **Configure firewall** rules
5. **Regular updates** of dependencies and images
6. **Database backups** scheduled regularly
7. **Monitor logs** for suspicious activity
8. **Use environment-specific** configurations
9. **Implement rate limiting**
10. **Regular security audits**

## Support

For issues and questions:
- Check the main [README.md](README.md)
- Open an issue on GitHub
- Consult [Hasura Documentation](https://hasura.io/docs)
- Consult [Next.js Documentation](https://nextjs.org/docs)
