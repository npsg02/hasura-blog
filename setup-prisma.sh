#!/bin/bash
set -e

echo "🔧 Setting up Prisma for Hasura Blog"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
    echo "✅ Created .env file"
else
    echo "✅ .env file already exists"
fi

# Check if node_modules exists
if [ ! -d node_modules ]; then
    echo ""
    echo "📦 Installing npm dependencies..."
    npm install
    echo "✅ Dependencies installed"
else
    echo "✅ Dependencies already installed"
fi

# Generate Prisma Client
echo ""
echo "🔨 Generating Prisma Client..."
npm run prisma:generate
echo "✅ Prisma Client generated"

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Start database and Hasura:"
echo "   docker-compose -f docker-compose.dev.yml up -d"
echo ""
echo "2. Open Prisma Studio to view your database:"
echo "   npm run prisma:studio"
echo ""
echo "3. Start Next.js development server:"
echo "   npm run dev"
echo ""
