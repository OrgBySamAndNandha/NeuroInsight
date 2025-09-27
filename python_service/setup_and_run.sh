#!/bin/bash

echo "🚀 NeuroInsight CNN Service - Quick Setup"
echo "========================================="

# Navigate to the python service directory
cd "$(dirname "$0")"

# Check Python version
echo "🐍 Checking Python version..."
if command -v python3 &> /dev/null; then
    python3 --version
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    python --version  
    PYTHON_CMD="python"
else
    echo "❌ Python not found. Please install Python 3.8 or later."
    exit 1
fi

# Clean install approach
echo "🧹 Cleaning previous installation..."
rm -rf venv

echo "📦 Creating fresh virtual environment..."
$PYTHON_CMD -m venv venv

echo "⚡ Activating virtual environment..."
source venv/bin/activate

echo "🔄 Upgrading pip..."
pip install --upgrade pip

echo "📚 Installing core dependencies first..."
pip install flask flask-cors numpy Pillow requests

echo "🧠 Installing PyTorch (this may take a moment)..."
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu

echo "🔧 Installing remaining dependencies..."
pip install thop

# Verify installations
echo "✅ Verifying installations..."
python -c "import torch; print(f'PyTorch version: {torch.__version__}')" || echo "❌ PyTorch installation failed"
python -c "import flask; print(f'Flask version: {flask.__version__}')" || echo "❌ Flask installation failed"

# Check if model file exists
if [ ! -f "../DL Model/Vbai-2.1c.pt" ]; then
    echo "⚠️  Model file not found at '../DL Model/Vbai-2.1c.pt'"
    echo "📁 Please ensure the Vbai-2.1c.pt model file is in the 'DL Model' directory"
    echo "🔄 Service will start anyway (will show model not loaded)"
fi

echo ""
echo "🎯 Setup complete! Starting service..."
echo "🌐 Service URL: http://localhost:5000"
echo "🔥 Keep this terminal open while using the app"
echo "📱 In another terminal, run: flutter run"
echo ""

# Start the Flask service
python app.py