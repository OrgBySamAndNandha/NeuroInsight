#!/bin/bash

echo "🚀 NeuroInsight CNN Service - Simple Setup"
echo "=========================================="

# Navigate to the python service directory
cd "$(dirname "$0")"

# Check Python version and set command
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
    echo "🐍 Using Python3: $(python3 --version)"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
    echo "🐍 Using Python: $(python --version)"
else
    echo "❌ Python not found. Please install Python 3.8 or later."
    exit 1
fi

# Remove old environment completely
echo "🧹 Cleaning up old environment..."
rm -rf venv

# Create new virtual environment
echo "📦 Creating virtual environment..."
$PYTHON_CMD -m venv venv

# Check if venv was created successfully
if [ ! -d "venv" ]; then
    echo "❌ Failed to create virtual environment"
    exit 1
fi

# Activate virtual environment
echo "⚡ Activating virtual environment..."
source venv/bin/activate

# Verify activation
if [ -z "$VIRTUAL_ENV" ]; then
    echo "❌ Failed to activate virtual environment"
    exit 1
fi

echo "✅ Virtual environment activated: $VIRTUAL_ENV"

# Upgrade pip
echo "🔄 Upgrading pip..."
pip install --upgrade pip

# Install dependencies step by step
echo "📚 Installing Flask and basic dependencies..."
pip install flask flask-cors

echo "🔢 Installing NumPy and Pillow..."
pip install numpy Pillow

echo "🌐 Installing requests..."
pip install requests

echo "🧠 Installing PyTorch (CPU version for compatibility)..."
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu

echo "📊 Installing thop for model profiling..."
pip install thop

# Verify installations
echo "✅ Verifying installations..."
python -c "import torch; print(f'✅ PyTorch: {torch.__version__}')" || echo "❌ PyTorch failed"
python -c "import flask; print('✅ Flask: OK')" || echo "❌ Flask failed"
python -c "import numpy; print('✅ NumPy: OK')" || echo "❌ NumPy failed"
python -c "import PIL; print('✅ Pillow: OK')" || echo "❌ Pillow failed"

# Check model file
if [ -f "../DL Model/Vbai-2.1c.pt" ]; then
    echo "✅ Model file found: $(ls -lh '../DL Model/Vbai-2.1c.pt' | awk '{print $5}')"
else
    echo "⚠️  Model file not found at '../DL Model/Vbai-2.1c.pt'"
    echo "📁 Please ensure the model file is in the correct location"
fi

echo ""
echo "🎯 Setup complete! Starting CNN service..."
echo "🌐 Service will be available at: http://localhost:5001+ (auto port detection)"
echo "🔥 Keep this terminal open while using the app"
echo "📱 In another terminal, run: flutter run"
echo ""

# Start the service
python app.py