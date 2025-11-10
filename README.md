# Hasura Blog

A modern blog application built with Next.js 14, Hasura GraphQL Engine, TailwindCSS, and PostgreSQL.

## Features

- ✅ **Next.js 14** with App Router for server-side rendering and optimal performance
- ✅ **Hasura GraphQL Engine** for instant GraphQL APIs
- ✅ **PostgreSQL** database with comprehensive blog schema
- ✅ **Docker Compose** for easy deployment
- ✅ **TailwindCSS** for modern, responsive UI
- ✅ **Apollo Client** for GraphQL queries with client-side caching
- ✅ **GraphQL Code Generator** for type-safe GraphQL operations
- ✅ **NextAuth.js** for authentication
- ✅ **Redux Toolkit** for state management
- ✅ **TypeScript** for type safety
- ✅ **Database Migrations** with Hasura and Prisma
- ✅ **Prisma ORM** for type-safe database access
- ✅ **Nix** for reproducible development environment
- ✅ **SEO Optimization** with Next.js metadata API

## Architecture

```
hasura-blog/
├── app/                    # Next.js App Router pages
├── components/             # React components
├── lib/                    # Utilities and configurations
│   ├── apollo-client.ts    # Apollo Client setup
│   ├── apollo-provider.tsx # Apollo Provider wrapper
│   ├── auth.ts            # NextAuth configuration
│   ├── graphql/           # GraphQL queries and mutations
│   └── redux/             # Redux store and slices
├── hasura/                # Hasura configuration
│   ├── config.yaml        # Hasura CLI config
│   ├── metadata/          # Hasura metadata
│   ├── migrations/        # Database migrations
│   └── seeds/             # Seed data
├── types/                 # TypeScript type definitions
├── public/                # Static assets
├── docker-compose.yml     # Docker Compose configuration
└── Dockerfile             # Next.js Dockerfile

```

## Prerequisites

### Option 1: Using Nix (Recommended)
- Nix package manager with flakes enabled

### Option 2: Manual Setup
- Docker and Docker Compose
- Node.js 20+ (for local development)
- npm or yarn

## Quick Start

### Option A: Using Nix (Recommended for reproducible builds)

#### 1. Install Nix with flakes enabled

If you don't have Nix installed:

```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Or use the official installer
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Enable flakes in your Nix configuration if not already enabled:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

#### 2. Enter the development environment

```bash
# Clone the repository
git clone https://github.com/npsg02/hasura-blog.git
cd hasura-blog

# Enter Nix shell (this will download and setup all dependencies)
nix develop

# Or use direnv (recommended)
# Install direnv first: nix-env -iA nixpkgs.direnv
echo "use flake" > .envrc
direnv allow
```

#### 3. Set up environment variables

```bash
cp .env.example .env
```

Edit `.env` and update the values as needed. The default values work for local development.

#### 4. Start development

```bash
# Start Docker services
docker-compose -f docker-compose.dev.yml up -d

# Install npm dependencies
npm install

# Generate Prisma Client
npm run prisma:generate

# Start Next.js development server
npm run dev
```

### Option B: Manual Setup

### 1. Clone the repository

```bash
git clone https://github.com/npsg02/hasura-blog.git
cd hasura-blog
```

### 2. Set up environment variables

```bash
cp .env.example .env
```

Edit `.env` and update the values as needed. The default values work for local development.

### 3. Start the services with Docker Compose

```bash
docker-compose up -d
```

This will start:
- PostgreSQL on port 5432
- Hasura GraphQL Engine on port 8080
- Next.js application on port 3000

### 4. Apply database migrations

The migrations are automatically applied when Hasura starts. You can verify by accessing the Hasura Console:

```
http://localhost:8080/console
```

Admin Secret: `adminsecret` (or the value you set in `.env`)

### 5. Seed the database (optional)

To populate the database with sample data:

```bash
# Connect to the Hasura container
docker-compose exec hasura bash

# Run the seed SQL file
psql $HASURA_GRAPHQL_DATABASE_URL -f /hasura-migrations/default/1699900000001_seed_data.sql
```

### 6. Access the application

Open your browser and navigate to:

```
http://localhost:3000
```

## Local Development (Without Docker)

### 1. Install dependencies

```bash
npm install
```

### 2. Start PostgreSQL and Hasura

```bash
docker-compose up -d postgres hasura
```

### 3. Run the Next.js development server

```bash
npm run dev
```

### 4. Generate GraphQL types (optional)

After Hasura is running with your schema:

```bash
npm run codegen
```

This generates TypeScript types from your GraphQL schema.

## Database Schema

The blog includes the following tables:

- **users** - User accounts with roles
- **posts** - Blog posts with content
- **categories** - Post categories
- **tags** - Post tags
- **post_tags** - Many-to-many relationship between posts and tags
- **comments** - Post comments with threading support

## GraphQL API

Access the GraphQL playground at:

```
http://localhost:8080/v1/graphql
```

### Sample Queries

**Get all published posts:**

```graphql
query GetPosts {
  posts(where: {status: {_eq: "published"}}, order_by: {published_at: desc}) {
    id
    title
    slug
    excerpt
    author {
      name
    }
    category {
      name
    }
  }
}
```

**Get post by slug:**

```graphql
query GetPost($slug: String!) {
  posts(where: {slug: {_eq: $slug}}) {
    id
    title
    content
    author {
      name
      bio
    }
  }
}
```

## Authentication

Authentication is handled by NextAuth.js. The configuration supports:

- Credentials-based authentication
- JWT tokens
- Role-based access control

To add more providers (Google, GitHub, etc.), update `lib/auth.ts`.

## State Management

Redux Toolkit is configured with two slices:

- **userSlice** - User state management
- **uiSlice** - UI state (theme, sidebar, notifications)

## Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint
- `npm run codegen` - Generate GraphQL types
- `npm run db:backup` - Create database backup
- `npm run db:backup:compress` - Create compressed database backup

## Prisma Commands

Prisma is integrated as an alternative migration tool and ORM. You can use it alongside Hasura:

### Generate Prisma Client

```bash
npm run prisma:generate
```

### Database Management

```bash
# Push schema changes to database (without migrations)
npm run prisma:db:push

# Pull schema from database to Prisma schema
npm run prisma:db:pull

# Open Prisma Studio (database GUI)
npm run prisma:studio
```

### Migrations with Prisma

```bash
# Create and apply a new migration in development
npm run prisma:migrate:dev

# Apply migrations in production
npm run prisma:migrate:deploy

# Reset database (WARNING: This will delete all data)
npm run prisma:migrate:reset
```

### Using Prisma Client in your code

The Prisma Client is generated in `lib/generated/prisma` and can be imported:

```typescript
import { PrismaClient } from '@/lib/generated/prisma';

const prisma = new PrismaClient();

// Example: Get all published posts
const posts = await prisma.post.findMany({
  where: { status: 'published' },
  include: { author: true, category: true }
});
```

## Hasura CLI Commands

Install Hasura CLI:

```bash
curl -L https://github.com/hasura/graphql-engine/raw/stable/cli/get.sh | bash
```

Or if using Nix, it's already installed in the development environment.

Create a new migration:

```bash
cd hasura
hasura migrate create "migration_name" --database-name default
```

Apply migrations:

```bash
hasura migrate apply --database-name default
```

Export metadata:

```bash
hasura metadata export
```

## Database Backups

The project includes a comprehensive database backup script (`backup-db.sh`) that supports both Docker and direct PostgreSQL connections.

### Quick Backup

Using npm scripts:

```bash
# Create a backup using Docker (default)
npm run db:backup

# Create a compressed backup
npm run db:backup:compress
```

### Advanced Usage

```bash
# Basic backup (Docker)
./backup-db.sh

# Backup with compression
./backup-db.sh --compress

# Backup to custom directory
./backup-db.sh --output /path/to/backups

# Backup using direct connection
./backup-db.sh --no-docker --host localhost --port 5432

# Backup specific database
./backup-db.sh --database mydb --user myuser

# Show all options
./backup-db.sh --help
```

### Backup Features

- **Timestamp-based filenames** for easy organization
- **Compression support** with gzip
- **Docker and direct connection modes**
- **Custom backup directories**
- **Automatic backup directory creation**
- **Restore instructions** after backup
- **Error handling and validation**

### Restoring a Backup

After creating a backup, the script provides restore instructions. For example:

```bash
# Restore uncompressed backup (Docker)
docker-compose exec -T postgres psql -U postgres -d hasura < backups/hasura_backup_20231110_120000.sql

# Restore compressed backup (Docker)
gunzip -c backups/hasura_backup_20231110_120000.sql.gz | docker-compose exec -T postgres psql -U postgres -d hasura
```

### Automated Backups

For production environments, consider setting up automated backups using cron:

```bash
# Add to crontab (run daily at 2 AM)
0 2 * * * cd /path/to/hasura-blog && ./backup-db.sh --compress --output /backups/daily
```

## Production Deployment

### Option 1: AWS with Terraform (Recommended)

Deploy to AWS with automated infrastructure provisioning using Terraform:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration

# Set sensitive variables
export TF_VAR_db_password="your-password"
export TF_VAR_hasura_admin_secret="your-secret"
export TF_VAR_jwt_secret="your-jwt-secret"
export TF_VAR_nextauth_secret="your-nextauth-secret"

# Deploy
./deploy.sh
```

For detailed instructions, see [terraform/README.md](terraform/README.md) and [terraform/ARCHITECTURE.md](terraform/ARCHITECTURE.md).

### Option 2: Docker Compose

Build the production image:

```bash
docker-compose -f docker-compose.yml build
```

### Environment Variables

Make sure to set strong values for production:

- `POSTGRES_PASSWORD` - Strong database password
- `HASURA_GRAPHQL_ADMIN_SECRET` - Strong admin secret
- `NEXTAUTH_SECRET` - Strong NextAuth secret
- `JWT_SECRET` - Strong JWT secret (min 32 characters)

### Security Considerations

1. Change all default passwords and secrets
2. Use environment-specific configuration
3. Enable HTTPS in production
4. Configure CORS properly
5. Set up proper database backups
6. Use Hasura Cloud or self-hosted with proper security

## Hasura Permissions

Configure role-based permissions in Hasura Console:

- **anonymous** - Can read published posts
- **user** - Can create comments, read all posts
- **author** - Can create and edit their own posts
- **admin** - Full access to all operations

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the ISC License.

## Additional Documentation

- [PRISMA.md](./PRISMA.md) - Detailed Prisma integration guide
- [NIX.md](./NIX.md) - Nix development environment guide
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Production deployment guide
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Contribution guidelines

## Support

For issues and questions:
- Open an issue on GitHub
- Check Hasura documentation: https://hasura.io/docs
- Check Next.js documentation: https://nextjs.org/docs
- Check Prisma documentation: https://www.prisma.io/docs

## Acknowledgments

- [Next.js](https://nextjs.org/)
- [Hasura](https://hasura.io/)
- [Prisma](https://www.prisma.io/)
- [TailwindCSS](https://tailwindcss.com/)
- [Apollo Client](https://www.apollographql.com/docs/react/)
- [NextAuth.js](https://next-auth.js.org/)
- [Redux Toolkit](https://redux-toolkit.js.org/)
- [Nix](https://nixos.org/)