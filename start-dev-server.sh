#!/bin/bash

# Onyx Development Server Startup Script
# This script starts the Onyx application in development mode without Docker

set -e

echo "🚀 Starting Onyx Development Server..."

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Installing..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

# Setup web frontend
echo "📱 Setting up web frontend..."
cd web

# Install dependencies if node_modules doesn't exist
if [[ ! -d node_modules ]]; then
    echo "📦 Installing npm dependencies..."
    npm install
fi

# Create .env.local if it doesn't exist
if [[ ! -f .env.local ]]; then
    echo "📝 Creating web/.env.local..."
    cat > .env.local << EOF
NEXT_PUBLIC_API_URL=http://localhost:8080
NEXT_PUBLIC_DISABLE_STREAMING=false
NEXT_PUBLIC_NEW_CHAT_DIRECTS_TO_SAME_PERSONA=false
NEXT_PUBLIC_POSITIVE_PREDEFINED_FEEDBACK_OPTIONS=
NEXT_PUBLIC_NEGATIVE_PREDEFINED_FEEDBACK_OPTIONS=
NEXT_PUBLIC_DISABLE_LLM_DOC_RELEVANCE=false
NEXT_PUBLIC_DEFAULT_SIDEBAR_OPEN=false
NEXT_PUBLIC_GMAIL_AUTH_IS_ADMIN_CONNECTORS=true
NEXT_PUBLIC_CLOUD_ENABLED=false
EOF
fi

# Start the development server
echo "🌐 Starting Next.js development server on port 12000..."
PORT=12000 npm run dev &
WEB_PID=$!

cd ..

# Setup backend (if Python virtual environment exists)
if [[ -d backend ]]; then
    echo "🔧 Setting up backend..."
    cd backend
    
    # Create virtual environment if it doesn't exist
    if [[ ! -d .venv ]]; then
        echo "🐍 Creating Python virtual environment..."
        python3 -m venv .venv
    fi
    
    # Activate virtual environment and install dependencies
    source .venv/bin/activate
    
    # Install dependencies if requirements exist
    if [[ -f requirements/default.txt ]]; then
        echo "📦 Installing Python dependencies..."
        pip install --upgrade pip
        pip install -r requirements/default.txt || echo "⚠️ Some dependencies may have failed to install"
    fi
    
    # Create a simple .env file for backend
    if [[ ! -f .env ]]; then
        echo "📝 Creating backend/.env..."
        cat > .env << EOF
# Development environment
POSTGRES_HOST=localhost
POSTGRES_DB=onyx_dev
POSTGRES_USER=onyx
POSTGRES_PASSWORD=password
VESPA_HOST=localhost
REDIS_HOST=localhost
SECRET_KEY=dev-secret-key-change-in-production
AUTH_TYPE=basic
LOG_LEVEL=INFO
EOF
    fi
    
    cd ..
fi

echo ""
echo "🎉 Onyx Development Environment Started!"
echo ""
echo "📱 Frontend: http://localhost:12000"
echo "   Available at: https://work-1-gqvpkgutqrgfvhqq.prod-runtime.all-hands.dev"
echo ""
echo "🔧 Backend: Not started (requires database setup)"
echo "   Would be available at: https://work-2-gqvpkgutqrgfvhqq.prod-runtime.all-hands.dev"
echo ""
echo "📝 Next Steps:"
echo "   1. Set up PostgreSQL database"
echo "   2. Set up Vespa search engine"
echo "   3. Set up Redis cache"
echo "   4. Run backend server: cd backend && source .venv/bin/activate && uvicorn onyx.main:app --host 0.0.0.0 --port 8080"
echo ""
echo "🛑 To stop the frontend server: kill $WEB_PID"

# Keep the script running
wait $WEB_PID