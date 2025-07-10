#!/bin/bash

# Onyx Runtime Startup Script
# This script starts the Onyx application in the runtime environment

set -e

echo "🚀 Starting Onyx in Runtime Environment..."

# Set environment variables for runtime
export SECRET_KEY=${SECRET_KEY:-$(openssl rand -hex 32)}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-$(openssl rand -base64 32)}

# Create .env file if it doesn't exist
if [[ ! -f .env ]]; then
    echo "📝 Creating .env file..."
    cat > .env << EOF
SECRET_KEY=$SECRET_KEY
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
AUTH_TYPE=basic
CORS_ALLOWED_ORIGINS=https://work-1-gqvpkgutqrgfvhqq.prod-runtime.all-hands.dev,https://work-2-gqvpkgutqrgfvhqq.prod-runtime.all-hands.dev
EOF
fi

# Start services
echo "🐳 Starting Docker services..."
docker-compose -f docker-compose.runtime.yml up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Health check
echo "🔍 Performing health check..."
if curl -f http://localhost:12001/health &> /dev/null; then
    echo "✅ API is healthy"
else
    echo "❌ API health check failed"
fi

if curl -f http://localhost:12000 &> /dev/null; then
    echo "✅ Web frontend is healthy"
else
    echo "❌ Web frontend health check failed"
fi

echo "🎉 Onyx is running!"
echo "📱 Frontend: https://work-1-gqvpkgutqrgfvhqq.prod-runtime.all-hands.dev"
echo "🔧 API: https://work-2-gqvpkgutqrgfvhqq.prod-runtime.all-hands.dev"
echo ""
echo "📊 To view logs: docker-compose -f docker-compose.runtime.yml logs -f"
echo "🛑 To stop: docker-compose -f docker-compose.runtime.yml down"