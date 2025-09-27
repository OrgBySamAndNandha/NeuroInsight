#!/bin/bash

echo "🚀 Starting NeuroInsight CNN Service..."

# Navigate to the python service directory
cd "$(dirname "$0")"

# Check if virtual environment exists, create if not
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Upgrade pip first
echo "Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Check if model file exists
if [ ! -f "../DL Model/Vbai-2.1c.pt" ]; then
    echo "❌ Model file not found at '../DL Model/Vbai-2.1c.pt'"
    echo "Please make sure the Vbai-2.1c.pt model file is in the 'DL Model' directory"
    exit 1
fi

echo "✅ Model file found!"
echo "🌟 Starting Flask service on http://localhost:5000"
echo "💡 Keep this terminal open while using the app"
echo "📱 Now you can run your Flutter app: flutter run"
echo ""

# Start the Flask service with the virtual environment activated
python app.py