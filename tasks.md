# Hasura Blog Implementation Tasks

This document outlines the implementation plan for setting up a Next.js blog with Hasura as the backend.

## Phase 1: Project Foundation

### 1.1 Next.js Setup
- [ ] Initialize Next.js 14 project with TypeScript
- [ ] Configure Next.js with App Router (app directory)
- [ ] Setup basic folder structure:
  - `app/` - App Router pages
  - `components/` - Reusable React components
  - `lib/` - Utility functions and configurations
  - `types/` - TypeScript type definitions
  - `public/` - Static assets

### 1.2 Tailwind CSS Setup
- [ ] Install and configure Tailwind CSS
- [ ] Setup custom Tailwind configuration
- [ ] Create base styles and theme configuration
- [ ] Add common utility classes

## Phase 2: Backend Infrastructure

### 2.1 Hasura Setup
- [ ] Create Hasura configuration directory structure
- [ ] Setup Hasura metadata
- [ ] Configure Hasura environment variables
- [ ] Setup database connection

### 2.2 Docker Compose Configuration
- [ ] Create docker-compose.yml with services:
  - PostgreSQL database
  - Hasura GraphQL Engine
  - Next.js application
- [ ] Configure service networking
- [ ] Setup volume persistence for database
- [ ] Configure environment variables

### 2.3 Hasura Migrations
- [ ] Setup Hasura CLI configuration
- [ ] Create migration structure
- [ ] Define blog data models:
  - Users table
  - Posts table
  - Categories table
  - Comments table
- [ ] Create initial migration files
- [ ] Setup seed data

## Phase 3: GraphQL Integration

### 3.1 Apollo Client Setup
- [ ] Install Apollo Client dependencies
- [ ] Configure Apollo Client with Hasura endpoint
- [ ] Setup Apollo Provider
- [ ] Configure authentication headers
- [ ] Setup cache policies

### 3.2 GraphQL Code Generation
- [ ] Install and configure GraphQL Code Generator
- [ ] Create GraphQL schema file
- [ ] Define GraphQL queries and mutations:
  - Posts queries (list, single, by category)
  - User queries
  - Mutations (create, update, delete posts)
- [ ] Generate TypeScript types from schema
- [ ] Create codegen scripts

## Phase 4: Authentication

### 4.1 NextAuth.js Setup
- [ ] Install NextAuth.js
- [ ] Configure NextAuth.js API routes
- [ ] Setup authentication providers:
  - Credentials provider
  - OAuth providers (optional)
- [ ] Create session management
- [ ] Configure JWT tokens

### 4.2 Hasura Auth Integration
- [ ] Configure Hasura JWT authentication
- [ ] Setup JWT claims for role-based access
- [ ] Configure permissions in Hasura
- [ ] Integrate auth token with Apollo Client

## Phase 5: State Management

### 5.1 Redux Toolkit Setup
- [ ] Install Redux Toolkit and React-Redux
- [ ] Setup Redux store
- [ ] Create slices for:
  - User state
  - UI state
  - Blog state
- [ ] Configure Redux Provider
- [ ] Setup Redux DevTools

## Phase 6: SEO and SSR

### 6.1 Next.js Metadata Configuration
- [ ] Setup dynamic metadata for pages
- [ ] Configure sitemap generation
- [ ] Setup robots.txt
- [ ] Configure Open Graph tags

### 6.2 Server-Side Rendering
- [ ] Implement SSR for blog posts
- [ ] Setup static generation for static pages
- [ ] Configure incremental static regeneration (ISR)
- [ ] Optimize page load performance

## Phase 7: Core Features

### 7.1 Blog Components
- [ ] Create blog post list component
- [ ] Create blog post detail component
- [ ] Create category filter component
- [ ] Create search functionality
- [ ] Create comment component

### 7.2 Pages
- [ ] Home page with latest posts
- [ ] Blog post detail page
- [ ] Category page
- [ ] User profile page
- [ ] Admin dashboard

## Phase 8: Development Tooling

### 8.1 Code Quality
- [ ] Setup ESLint configuration
- [ ] Setup Prettier
- [ ] Add pre-commit hooks with Husky
- [ ] Create development scripts

### 8.2 Documentation
- [ ] Create comprehensive README.md
- [ ] Document environment variables
- [ ] Create setup instructions
- [ ] Document API structure

## Phase 9: Testing and Deployment

### 9.1 Testing
- [ ] Setup testing infrastructure (optional)
- [ ] Verify Docker Compose deployment
- [ ] Test authentication flow
- [ ] Test GraphQL queries and mutations

### 9.2 Production Preparation
- [ ] Create production docker-compose file
- [ ] Setup environment variable templates
- [ ] Create deployment documentation
- [ ] Optimize Docker images

## Implementation Order

The recommended implementation order:
1. Start with Docker Compose and infrastructure (Phase 2)
2. Setup Next.js foundation (Phase 1)
3. Configure Hasura migrations and models (Phase 2.3)
4. Setup GraphQL integration (Phase 3)
5. Implement authentication (Phase 4)
6. Add state management (Phase 5)
7. Configure SEO/SSR (Phase 6)
8. Build core features (Phase 7)
9. Polish with tooling (Phase 8)
10. Test and document (Phase 9)
