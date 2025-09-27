#!/bin/bash

# NeuroInsight - One Command Startup Script
# This script starts both the CNN service and Flutter app

echo "🚀 Starting NeuroInsight Dual AI System..."
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SERVICE_DIR="$SCRIPT_DIR/python_service"

echo -e "${BLUE}📁 Project Directory: $SCRIPT_DIR${NC}"

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}🛑 Shutting down services...${NC}"
    # Kill any background processes we started
    jobs -p | xargs -r kill
    exit 0
}

# Set up cleanup trap
trap cleanup SIGINT SIGTERM

# Check if CNN service directory exists
if [ ! -d "$PYTHON_SERVICE_DIR" ]; then
    echo -e "${YELLOW}❌ Python service directory not found at: $PYTHON_SERVICE_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}🧠 Starting CNN Service...${NC}"
echo "💡 CNN service will run on port 5002"

# Start CNN service in background
cd "$PYTHON_SERVICE_DIR"
./start_simple.sh > cnn_service.log 2>&1 &
CNN_PID=$!

# Wait a few seconds for CNN service to start
echo "⏳ Waiting for CNN service to initialize..."
sleep 8

# Check if CNN service is running
if curl -s http://localhost:5002/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ CNN Service is running on port 5002${NC}"
else
    echo -e "${YELLOW}⚠️  CNN Service may still be starting... continuing anyway${NC}"
fi

echo -e "${GREEN}📱 Starting Flutter App...${NC}"

# Go back to project root
cd "$SCRIPT_DIR"

# Start Flutter app
echo "🔥 Launching Flutter app..."
echo "📱 Choose your device when prompted"
echo ""
echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}  NeuroInsight Dual AI System Ready!         ${NC}"
echo -e "${BLUE}  - CNN Service: http://localhost:5002       ${NC}"
echo -e "${BLUE}  - ChatGPT AI: Integrated                   ${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""

# Start Flutter (this will block and show device selection)
flutter run

# If flutter run exits, cleanup
cleanup