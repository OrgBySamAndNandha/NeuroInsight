# 🔧 Manual Setup Guide - CNN Service

If the automatic scripts aren't working, follow these manual steps:

## Step 1: Check Python Installation

```bash
# Check if Python 3 is installed
python3 --version
# Should show Python 3.8 or later

# If not installed, install Python 3:
# macOS: brew install python3
# or download from python.org
```

## Step 2: Manual Virtual Environment Setup

```bash
# Navigate to python service directory
cd python_service

# Remove any existing virtual environment
rm -rf venv

# Create new virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate

# You should see (venv) in your terminal prompt
```

## Step 3: Install Dependencies Manually

```bash
# Make sure virtual environment is activated (venv) should be in prompt
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies one by one
pip install flask==2.3.3
pip install flask-cors==4.0.0
pip install numpy
pip install Pillow
pip install requests

# Install PyTorch (CPU version for compatibility)
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu

# Install thop (for model profiling)
pip install thop
```

## Step 4: Verify Installation

```bash
# Test imports
python3 -c "import torch; print('PyTorch:', torch.__version__)"
python3 -c "import flask; print('Flask:', flask.__version__)"
python3 -c "import PIL; print('Pillow: OK')"
python3 -c "import requests; print('Requests: OK')"
```

## Step 5: Check Model File

```bash
# Check if model file exists
ls -la "../DL Model/Vbai-2.1c.pt"

# Should show a file around 200MB
# If not found, make sure the model file is in the correct location
```

## Step 6: Start Service Manually

```bash
# Make sure virtual environment is activated
source venv/bin/activate

# Start the service
python3 app.py
```

You should see:
```
✅ CNN Model loaded successfully!
🚀 Starting NeuroInsight CNN Service...
📁 Model path: ../DL Model/Vbai-2.1c.pt
🔧 Model loaded: ✅ Yes
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://[your-ip]:5000
```

## Step 7: Test the Service

In another terminal:
```bash
# Test with curl
curl http://localhost:5000/health

# Should return:
# {"model_loaded":true,"service":"NeuroInsight CNN Service","status":"healthy"}
```

Or run the test script:
```bash
cd python_service
source venv/bin/activate  # Make sure venv is activated
python3 test_service.py
```

## 🎯 Troubleshooting Common Issues

### "ModuleNotFoundError: No module named 'torch'"
- Virtual environment not activated
- Run: `source venv/bin/activate`

### "Could not find a version that satisfies the requirement torch==2.0.1"
- Use newer PyTorch: `pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu`

### "python: command not found"
- Use `python3` instead of `python`
- macOS typically requires `python3`

### "Model file not found"
- Check path: `ls -la "../DL Model/Vbai-2.1c.pt"`
- Ensure model file is exactly named `Vbai-2.1c.pt`
- File should be ~206MB

### Port 5000 already in use
- Kill existing process: `lsof -ti:5000 | xargs kill -9`
- Or use different port in app.py

## ✅ Success Indicators

- Virtual environment shows `(venv)` in terminal prompt
- All import tests pass without errors
- Service starts with "CNN Model loaded successfully!"
- Health check returns `"model_loaded": true`
- Test script shows all tests passing

## 🚀 Quick Commands Summary

```bash
# Full manual setup
cd python_service
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install flask flask-cors numpy Pillow requests
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
pip install thop
python3 app.py

# In another terminal:
python3 test_service.py
```