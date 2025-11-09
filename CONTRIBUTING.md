# Contributing to Hasura Blog

Thank you for your interest in contributing to Hasura Blog! This document provides guidelines and instructions for contributing.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Setup](#development-setup)
4. [Making Changes](#making-changes)
5. [Coding Standards](#coding-standards)
6. [Submitting Changes](#submitting-changes)
7. [Reporting Issues](#reporting-issues)

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect differing viewpoints and experiences

## Getting Started

### Prerequisites

- Node.js 20 or higher
- Docker and Docker Compose
- Git
- A GitHub account

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
```bash
git clone https://github.com/YOUR_USERNAME/hasura-blog.git
cd hasura-blog
```

3. Add upstream remote:
```bash
git remote add upstream https://github.com/npsg02/hasura-blog.git
```

## Development Setup

1. **Install dependencies**:
```bash
npm install
```

2. **Set up environment**:
```bash
cp .env.example .env
# Edit .env if needed
```

3. **Start development services**:
```bash
docker-compose -f docker-compose.dev.yml up -d
```

4. **Start Next.js dev server**:
```bash
npm run dev
```

5. **Verify setup**:
- Next.js: http://localhost:3000
- Hasura Console: http://localhost:8080/console

## Making Changes

### Workflow

1. **Create a branch**:
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

2. **Make your changes**:
- Write clean, readable code
- Follow existing code style
- Add comments where necessary
- Update documentation if needed

3. **Test your changes**:
```bash
npm run build
npm run lint
```

4. **Commit your changes**:
```bash
git add .
git commit -m "feat: add new feature"
# or
git commit -m "fix: resolve bug in component"
```

### Commit Message Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

Examples:
```
feat: add blog post pagination
fix: resolve authentication redirect loop
docs: update installation instructions
style: format code with prettier
refactor: simplify apollo client setup
```

## Coding Standards

### TypeScript

- Use TypeScript for all new code
- Define proper types and interfaces
- Avoid `any` type when possible
- Use meaningful variable and function names

```typescript
// Good
interface BlogPost {
  id: string;
  title: string;
  content: string;
}

// Avoid
const data: any = fetchData();
```

### React Components

- Use functional components with hooks
- Keep components small and focused
- Use meaningful component names
- Add PropTypes or TypeScript interfaces

```typescript
// Good
interface PostCardProps {
  title: string;
  excerpt: string;
  author: string;
}

export function PostCard({ title, excerpt, author }: PostCardProps) {
  return (
    <div>
      <h2>{title}</h2>
      <p>{excerpt}</p>
      <span>By {author}</span>
    </div>
  );
}
```

### File Organization

```
app/
  ├── (auth)/          # Auth-related pages
  ├── blog/            # Blog pages
  ├── api/             # API routes
  └── layout.tsx       # Root layout

components/
  ├── ui/              # Generic UI components
  ├── blog/            # Blog-specific components
  └── layout/          # Layout components

lib/
  ├── apollo-client.ts # Apollo setup
  ├── auth.ts          # Auth configuration
  └── utils/           # Utility functions
```

### CSS/Styling

- Use Tailwind CSS utility classes
- Keep custom CSS minimal
- Use semantic class names
- Prefer composition over custom CSS

```tsx
// Good
<div className="max-w-4xl mx-auto p-4">
  <h1 className="text-3xl font-bold mb-4">Title</h1>
</div>

// Avoid inline styles
<div style={{ maxWidth: '800px', margin: '0 auto' }}>
```

### GraphQL

- Keep queries and mutations in separate files
- Use descriptive operation names
- Request only necessary fields
- Document complex queries

```graphql
# Good
query GetPublishedPosts($limit: Int!) {
  posts(
    where: { status: { _eq: "published" } }
    limit: $limit
    order_by: { published_at: desc }
  ) {
    id
    title
    excerpt
  }
}
```

## Submitting Changes

### Pull Request Process

1. **Update your fork**:
```bash
git fetch upstream
git rebase upstream/main
```

2. **Push your branch**:
```bash
git push origin feature/your-feature-name
```

3. **Create Pull Request**:
- Go to GitHub and create a PR
- Fill in the PR template
- Link related issues
- Add screenshots for UI changes

### PR Guidelines

- **Title**: Clear and descriptive
- **Description**: Explain what and why
- **Screenshots**: For UI changes
- **Testing**: Describe how you tested
- **Breaking Changes**: Highlight any breaking changes

Example PR description:
```markdown
## Description
Adds pagination to the blog post list

## Changes
- Added pagination component
- Updated GraphQL query to support offset
- Added navigation buttons

## Testing
- Tested with 50+ posts
- Verified navigation works correctly
- Checked responsive design

## Screenshots
[Add screenshots here]
```

### Review Process

- Address reviewer feedback promptly
- Make requested changes in new commits
- Re-request review after changes
- Be patient and respectful

## Reporting Issues

### Bug Reports

Include:
- Clear description of the bug
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Node version, etc.)
- Screenshots or error messages

### Feature Requests

Include:
- Clear description of the feature
- Use case and benefits
- Possible implementation approach
- Examples from other projects (if applicable)

### Issue Template

```markdown
## Description
[Clear description of the issue]

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. See error

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- OS: [e.g., Ubuntu 22.04]
- Node: [e.g., 20.10.0]
- Docker: [e.g., 24.0.0]

## Additional Context
[Any other relevant information]
```

## Development Tips

### Hot Reloading

- Next.js: Changes reload automatically
- Hasura: Refresh console for metadata changes
- GraphQL: Run `npm run codegen` after schema changes

### Debugging

**Next.js**:
```bash
DEBUG=* npm run dev
```

**Hasura**:
```bash
docker-compose logs -f hasura
```

**Database**:
```bash
docker-compose exec postgres psql -U postgres -d hasura
```

### Common Tasks

**Create migration**:
```bash
cd hasura
hasura migrate create "add_new_column" --database-name default
```

**Generate GraphQL types**:
```bash
npm run codegen
```

**Reset database**:
```bash
docker-compose down -v
docker-compose -f docker-compose.dev.yml up -d
```

## Questions?

- Check existing [issues](https://github.com/npsg02/hasura-blog/issues)
- Ask in discussions
- Review [README.md](README.md) and [DEPLOYMENT.md](DEPLOYMENT.md)

## License

By contributing, you agree that your contributions will be licensed under the ISC License.

## Thank You!

Your contributions make this project better. Thank you for taking the time to contribute! 🎉
