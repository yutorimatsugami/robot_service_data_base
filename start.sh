#!/bin/bash
set -e

echo "🚀 Robot Service Database Setup"
echo "================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose."
    exit 1
fi

# Create .env if not exists
if [ ! -f .env ]; then
    echo "📝 Creating .env from template..."
    cp .env.example .env
    echo "   Edit .env to customize settings if needed."
fi

# Create data directory
mkdir -p db/data

# Start containers
echo "🐳 Starting Docker containers..."
if command -v docker-compose &> /dev/null; then
    docker-compose up -d
else
    docker compose up -d
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📊 Adminer (DB管理画面): http://localhost:${ADMINER_PORT:-8080}"
echo "🔗 PostgreSQL: localhost:${DB_PORT:-5432}"
echo ""
echo "Login info:"
echo "  Server: db"
echo "  User: robot_user"
echo "  Password: robot_pass"
echo "  Database: robot_service_db"
