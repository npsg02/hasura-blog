#!/bin/bash

# Hasura Blog Setup Script

echo "🚀 Setting up Hasura Blog..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
    echo "✅ .env file created. Please update it with your values."
else
    echo "✅ .env file already exists."
fi

# Start Docker services
echo "🐳 Starting Docker services..."
docker-compose -f docker-compose.dev.yml up -d

# Wait for Hasura to be ready
echo "⏳ Waiting for Hasura to be ready..."
sleep 10

# Check if Hasura is running
if curl -s http://localhost:8080/healthz > /dev/null; then
    echo "✅ Hasura is running!"
else
    echo "❌ Hasura is not running. Please check Docker logs."
    exit 1
fi

# Install npm dependencies
echo "📦 Installing npm dependencies..."
npm install

echo ""
echo "✅ Setup complete!"
echo ""
echo "📖 Next steps:"
echo "  1. Update .env file with your configuration"
echo "  2. Access Hasura Console: http://localhost:8080/console"
echo "     Admin Secret: adminsecret (or your custom value)"
echo "  3. Run 'npm run dev' to start the Next.js development server"
echo "  4. Access the app: http://localhost:3000"
echo ""
echo "💡 To seed the database with sample data:"
echo "   docker-compose -f docker-compose.dev.yml exec postgres psql -U postgres -d hasura -f /hasura-migrations/default/1699900000001_seed_data.sql"
echo ""
