#!/bin/bash

# Hasura Blog Terraform Deployment Script
# This script helps deploy the infrastructure to AWS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Hasura Blog Terraform Deployment ===${NC}\n"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed${NC}"
    echo "Please install Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${YELLOW}Warning: AWS CLI is not installed${NC}"
    echo "It's recommended to install AWS CLI: https://aws.amazon.com/cli/"
fi

# Check if terraform.tfvars exists
if [ ! -f terraform.tfvars ]; then
    echo -e "${YELLOW}terraform.tfvars not found. Creating from example...${NC}"
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${YELLOW}Please edit terraform.tfvars with your configuration before continuing.${NC}"
    echo -e "${YELLOW}Press Enter when ready to continue...${NC}"
    read -r
fi

# Check for required environment variables
REQUIRED_VARS=("TF_VAR_db_password" "TF_VAR_hasura_admin_secret" "TF_VAR_jwt_secret" "TF_VAR_nextauth_secret")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo -e "${RED}Error: Missing required environment variables:${NC}"
    for var in "${MISSING_VARS[@]}"; do
        echo "  - $var"
    done
    echo ""
    echo "Please set these variables before running the script:"
    echo "  export TF_VAR_db_password=\"your-strong-password\""
    echo "  export TF_VAR_hasura_admin_secret=\"your-admin-secret\""
    echo "  export TF_VAR_jwt_secret=\"your-jwt-secret-min-32-chars\""
    echo "  export TF_VAR_nextauth_secret=\"your-nextauth-secret\""
    exit 1
fi

# Initialize Terraform
echo -e "\n${GREEN}Step 1: Initializing Terraform...${NC}"
terraform init

# Format Terraform files
echo -e "\n${GREEN}Step 2: Formatting Terraform files...${NC}"
terraform fmt -recursive

# Validate configuration
echo -e "\n${GREEN}Step 3: Validating configuration...${NC}"
terraform validate

# Run plan
echo -e "\n${GREEN}Step 4: Planning deployment...${NC}"
terraform plan -out=tfplan

# Ask for confirmation
echo -e "\n${YELLOW}Review the plan above. Do you want to apply these changes? (yes/no)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${RED}Deployment cancelled.${NC}"
    rm -f tfplan
    exit 0
fi

# Apply the plan
echo -e "\n${GREEN}Step 5: Applying changes...${NC}"
terraform apply tfplan
rm -f tfplan

# Display outputs
echo -e "\n${GREEN}=== Deployment Complete! ===${NC}\n"
echo -e "${GREEN}Application URLs:${NC}"
terraform output nextjs_url
terraform output hasura_graphql_url
terraform output hasura_console_url

echo -e "\n${YELLOW}Next Steps:${NC}"
echo "1. Apply database migrations:"
echo "   cd ../hasura"
echo "   hasura migrate apply --endpoint \$(terraform -chdir=../terraform output -raw hasura_console_url | sed 's/:8080.*/:8080/') --admin-secret \$TF_VAR_hasura_admin_secret --database-name default"
echo ""
echo "2. Apply Hasura metadata:"
echo "   hasura metadata apply --endpoint \$(terraform -chdir=../terraform output -raw hasura_console_url | sed 's/:8080.*/:8080/') --admin-secret \$TF_VAR_hasura_admin_secret"
echo ""
echo "3. Update your DNS (if using custom domain) to point to the ALB"
echo ""
echo -e "${GREEN}Enjoy your Hasura Blog!${NC}"
