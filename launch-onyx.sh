#!/bin/bash

# Onyx Quick Launch Script
# This script provides easy access to the Onyx platform

set -e

echo "🚀 Onyx - AI Search Platform Launcher"
echo "======================================"

# Function to check if port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Function to start simple frontend
start_simple_frontend() {
    echo "📱 Starting Simple Frontend..."
    cd simple-frontend
    python3 server.py &
    FRONTEND_PID=$!
    echo "✅ Simple frontend started (PID: $FRONTEND_PID)"
    echo "🌐 Access at: https://work-1-gqvpkgutqrgfvhqq.prod-runtime.all-hands.dev"
    echo "📱 Local: http://localhost:12000"
}

# Function to start full development server
start_dev_server() {
    echo "🔧 Starting Full Development Server..."
    ./start-dev-server.sh &
    DEV_PID=$!
    echo "✅ Development server started (PID: $DEV_PID)"
}

# Function to show status
show_status() {
    echo ""
    echo "📊 Current Status:"
    echo "=================="
    
    if check_port 12000; then
        echo "✅ Frontend: Running on port 12000"
        echo "   🌐 https://work-1-gqvpkgutqrgfvhqq.prod-runtime.all-hands.dev"
    else
        echo "❌ Frontend: Not running"
    fi
    
    if check_port 8080; then
        echo "✅ Backend API: Running on port 8080"
    else
        echo "❌ Backend API: Not running"
    fi
    
    if check_port 5432; then
        echo "✅ Database: Running on port 5432"
    else
        echo "❌ Database: Not running"
    fi
}

# Function to stop services
stop_services() {
    echo "🛑 Stopping services..."
    
    # Kill processes on specific ports
    for port in 12000 3000 8080; do
        if check_port $port; then
            echo "🔄 Stopping service on port $port..."
            lsof -ti:$port | xargs kill -9 2>/dev/null || true
        fi
    done
    
    # Kill background processes
    pkill -f "python3 server.py" 2>/dev/null || true
    pkill -f "npm run dev" 2>/dev/null || true
    pkill -f "next dev" 2>/dev/null || true
    
    echo "✅ Services stopped"
}

# Main menu
show_menu() {
    echo ""
    echo "🎯 Choose an option:"
    echo "==================="
    echo "1) 🚀 Quick Start (Simple Frontend)"
    echo "2) 🔧 Full Development Server"
    echo "3) 📊 Show Status"
    echo "4) 🛑 Stop All Services"
    echo "5) 📚 View Documentation"
    echo "6) 🔧 Run Setup Scripts"
    echo "7) ❌ Exit"
    echo ""
    read -p "Enter your choice (1-7): " choice
}

# Handle user choice
handle_choice() {
    case $choice in
        1)
            echo "🚀 Starting Quick Frontend..."
            stop_services
            sleep 2
            start_simple_frontend
            echo ""
            echo "✅ Quick start complete!"
            echo "🌐 Open: https://work-1-gqvpkgutqrgfvhqq.prod-runtime.all-hands.dev"
            ;;
        2)
            echo "🔧 Starting Full Development Environment..."
            stop_services
            sleep 2
            start_dev_server
            echo ""
            echo "✅ Development server starting..."
            echo "⏳ Please wait for services to initialize..."
            ;;
        3)
            show_status
            ;;
        4)
            stop_services
            ;;
        5)
            echo "📚 Opening documentation..."
            echo "🌐 Documentation: https://docs.onyx.app/"
            echo "💻 GitHub: https://github.com/nexa-re/danswer"
            echo "📋 Enhanced README: ./ENHANCED_README.md"
            echo "📊 Deployment Summary: ./DEPLOYMENT_SUMMARY.md"
            ;;
        6)
            echo "🔧 Available setup scripts:"
            echo "   ./scripts/setup_and_deploy.sh setup"
            echo "   ./scripts/setup_and_deploy.sh deploy dev"
            echo "   python scripts/cleanup_and_improve.py"
            read -p "Run full setup? (y/N): " run_setup
            if [[ $run_setup =~ ^[Yy]$ ]]; then
                ./scripts/setup_and_deploy.sh setup
            fi
            ;;
        7)
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid choice. Please try again."
            ;;
    esac
}

# Main execution
main() {
    # Check if we're in the right directory
    if [[ ! -f "ENHANCED_README.md" ]]; then
        echo "❌ Please run this script from the danswer repository root"
        exit 1
    fi
    
    # Show initial status
    show_status
    
    # Interactive mode
    while true; do
        show_menu
        handle_choice
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Handle Ctrl+C
trap 'echo -e "\n🛑 Interrupted by user"; stop_services; exit 0' INT

# Run main function
main