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
- ✅ **Database Migrations** with Hasura
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

- Docker and Docker Compose
- Node.js 20+ (for local development)
- npm or yarn

## Quick Start

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

## Hasura CLI Commands

Install Hasura CLI:

```bash
curl -L https://github.com/hasura/graphql-engine/raw/stable/cli/get.sh | bash
```

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

## Production Deployment

### Build the production image

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

## Support

For issues and questions:
- Open an issue on GitHub
- Check Hasura documentation: https://hasura.io/docs
- Check Next.js documentation: https://nextjs.org/docs

## Acknowledgments

- [Next.js](https://nextjs.org/)
- [Hasura](https://hasura.io/)
- [TailwindCSS](https://tailwindcss.com/)
- [Apollo Client](https://www.apollographql.com/docs/react/)
- [NextAuth.js](https://next-auth.js.org/)
- [Redux Toolkit](https://redux-toolkit.js.org/)