#!/bin/bash

# Hasura Blog Terraform Destroy Script
# This script helps destroy the infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}=== Hasura Blog Infrastructure Destruction ===${NC}\n"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed${NC}"
    exit 1
fi

# Warning message
echo -e "${RED}WARNING: This will destroy ALL infrastructure resources!${NC}"
echo -e "${RED}This action cannot be undone.${NC}\n"
echo -e "${YELLOW}The following resources will be destroyed:${NC}"
echo "  - ECS Cluster and Services"
echo "  - Application Load Balancer"
echo "  - RDS PostgreSQL Database (and all data)"
echo "  - VPC and all networking components"
echo "  - CloudWatch Log Groups"
echo "  - IAM Roles and Policies"
echo ""
echo -e "${RED}Make sure you have backed up any important data!${NC}\n"

# Ask for confirmation
echo -e "${YELLOW}Type 'destroy' to confirm destruction:${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "destroy" ]; then
    echo -e "${GREEN}Destruction cancelled. Your infrastructure is safe.${NC}"
    exit 0
fi

# Double confirmation
echo -e "\n${RED}Are you absolutely sure? This cannot be undone. (yes/no)${NC}"
read -r DOUBLE_CONFIRM

if [ "$DOUBLE_CONFIRM" != "yes" ]; then
    echo -e "${GREEN}Destruction cancelled. Your infrastructure is safe.${NC}"
    exit 0
fi

# Run destroy
echo -e "\n${RED}Destroying infrastructure...${NC}"
terraform destroy

echo -e "\n${GREEN}Infrastructure has been destroyed.${NC}"
