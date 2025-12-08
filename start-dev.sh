#!/bin/bash

echo "🚀 Starting Today's Eats Development Environment"
echo "================================================"

# Màu sắc cho output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if backend server is running
check_backend() {
    if curl -s http://localhost:5000/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Backend is running on http://localhost:5000"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} Backend is not running"
        return 1
    fi
}

# Start backend in new terminal
start_backend() {
    echo -e "${BLUE}▶${NC} Starting MongoDB backend..."
    cd backend
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}⚠${NC} Installing backend dependencies..."
        npm install
    fi
    
    # Start server
    npm run mongo &
    BACKEND_PID=$!
    
    # Wait for server to start
    echo "Waiting for backend to start..."
    for i in {1..10}; do
        if curl -s http://localhost:5000/api/health > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Backend started successfully!"
            break
        fi
        sleep 1
    done
    
    cd ..
}

# Start Flutter app
start_flutter() {
    echo -e "${BLUE}▶${NC} Starting Flutter app..."
    
    # Check if pubspec dependencies are installed
    if [ ! -d ".dart_tool" ]; then
        echo -e "${YELLOW}⚠${NC} Installing Flutter dependencies..."
        flutter pub get
    fi
    
    # Run app
    flutter run -d linux
}

# Main flow
echo ""
echo "Checking backend status..."
if ! check_backend; then
    start_backend
fi

echo ""
echo "================================================"
echo -e "${GREEN}✓${NC} All systems ready!"
echo ""
echo "📱 To test MongoDB API:"
echo "   1. Open the app"
echo "   2. Go to 'Quản lý' tab (Admin)"
echo "   3. Click 'Test API' button"
echo ""
echo "🛑 To stop: Press Ctrl+C or run: pkill -f 'npm run mongo'"
echo "================================================"
echo ""

# Ask if user wants to start Flutter
read -p "Start Flutter app now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    start_flutter
else
    echo -e "${BLUE}ℹ${NC} You can start Flutter manually with: flutter run"
fi
