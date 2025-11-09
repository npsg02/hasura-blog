# Prisma Integration Guide

This document explains how Prisma is integrated into the Hasura Blog project as an additional migration tool and ORM.

## Overview

This project uses both **Hasura** and **Prisma** for database management:
- **Hasura Migrations**: Primary migration tool for database schema
- **Prisma**: Type-safe ORM and alternative migration tool

## Why Both Hasura and Prisma?

1. **Hasura** provides instant GraphQL APIs and real-time subscriptions
2. **Prisma** provides type-safe database access in server-side code
3. Both can work together without conflicts

## Setup

### 1. Install Dependencies

```bash
npm install
```

This installs both `prisma` (CLI) and `@prisma/client` (runtime).

### 2. Configure Database Connection

Add to your `.env` file:

```env
DATABASE_URL=postgresql://postgres:postgrespassword@localhost:5432/hasura
```

### 3. Generate Prisma Client

```bash
npm run prisma:generate
```

This generates the type-safe Prisma Client in `lib/generated/prisma`.

## Usage

### Using Prisma Client in Your Code

Create a Prisma client instance:

```typescript
// lib/prisma.ts
import { PrismaClient } from '@/lib/generated/prisma';

const globalForPrisma = global as unknown as { prisma: PrismaClient };

export const prisma = globalForPrisma.prisma || new PrismaClient();

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

Use it in your server-side code:

```typescript
import { prisma } from '@/lib/prisma';

// Get all published posts
export async function getPosts() {
  return await prisma.post.findMany({
    where: { status: 'published' },
    include: {
      author: true,
      category: true,
      postTags: {
        include: {
          tag: true
        }
      }
    },
    orderBy: {
      publishedAt: 'desc'
    }
  });
}

// Get a single post by slug
export async function getPostBySlug(slug: string) {
  return await prisma.post.findUnique({
    where: { slug },
    include: {
      author: true,
      category: true,
      comments: {
        where: { status: 'approved' },
        include: {
          author: true
        }
      },
      postTags: {
        include: {
          tag: true
        }
      }
    }
  });
}

// Create a new post
export async function createPost(data: {
  title: string;
  slug: string;
  content: string;
  authorId: string;
  categoryId?: string;
}) {
  return await prisma.post.create({
    data: {
      ...data,
      status: 'draft'
    }
  });
}
```

## Database Migrations

### Option 1: Using Hasura Migrations (Recommended)

The primary migration tool is Hasura CLI:

```bash
cd hasura
hasura migrate create "add_new_table"
# Edit the generated SQL files
hasura migrate apply
```

After applying Hasura migrations, update Prisma schema:

```bash
npm run prisma:db:pull
npm run prisma:generate
```

### Option 2: Using Prisma Migrations

You can also use Prisma Migrate:

```bash
# Create a new migration
npm run prisma:migrate:dev

# Apply migrations in production
npm run prisma:migrate:deploy
```

⚠️ **Important**: If you use Prisma Migrate, you need to sync the changes to Hasura metadata:

```bash
cd hasura
hasura metadata reload
```

## Available Commands

| Command | Description |
|---------|-------------|
| `npm run prisma:generate` | Generate Prisma Client |
| `npm run prisma:studio` | Open Prisma Studio (GUI) |
| `npm run prisma:db:push` | Push schema to database (dev) |
| `npm run prisma:db:pull` | Pull schema from database |
| `npm run prisma:migrate:dev` | Create and apply migration (dev) |
| `npm run prisma:migrate:deploy` | Apply migrations (production) |
| `npm run prisma:migrate:reset` | Reset database (⚠️ deletes all data) |

## Best Practices

1. **Schema Sync**: Keep Prisma schema in sync with Hasura migrations
2. **Type Safety**: Use Prisma Client for all server-side database operations
3. **GraphQL API**: Use Hasura GraphQL API for client-side queries
4. **Migrations**: Prefer Hasura migrations for schema changes
5. **Generated Code**: Don't commit generated Prisma Client files

## Prisma Schema Location

- Schema file: `prisma/schema.prisma`
- Generated client: `lib/generated/prisma/` (gitignored)
- Migrations: `prisma/migrations/` (if using Prisma Migrate)

## Troubleshooting

### Client out of sync with schema

```bash
npm run prisma:generate
```

### Schema doesn't match database

```bash
npm run prisma:db:pull
npm run prisma:generate
```

### Need to reset database (development only)

```bash
npm run prisma:migrate:reset
```

## Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [Hasura Documentation](https://hasura.io/docs)
- [Using Prisma with Hasura](https://hasura.io/learn/graphql/hasura/custom-business-logic/prisma/)
