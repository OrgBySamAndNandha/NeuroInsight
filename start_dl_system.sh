#!/bin/bash

echo "🧠 NeuroInsight Deep Learning Startup"
echo "====================================="

# Start CNN Service in background
echo "🔥 Starting CNN Deep Learning Service..."
cd /Users/samandersony/StudioProjects/projects/NeuroInsight/python_service
source venv/bin/activate
nohup python app.py > cnn_service.log 2>&1 &
CNN_PID=$!
echo "✅ CNN Service started (PID: $CNN_PID)"

# Wait for service to start
sleep 3

# Check if CNN service is running
if curl -s http://localhost:5002/health > /dev/null; then
    echo "✅ CNN Service is healthy and ready!"
else
    echo "❌ CNN Service failed to start"
    exit 1
fi

# Start Flutter App
echo "📱 Starting Flutter App..."
cd /Users/samandersony/StudioProjects/projects/NeuroInsight
flutter run

echo "🎉 NeuroInsight Deep Learning System is ready!"
echo "📝 To use DL analysis:"
echo "   1. Go to Scanner screen"
echo "   2. Select 'CNN Model' instead of 'Gemini AI'"
echo "   3. Upload brain scan image"
echo "   4. Tap 'Analyze' for Deep Learning diagnosis"