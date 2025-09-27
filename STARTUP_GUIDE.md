# 🚀 NeuroInsight - One Command Startup

## Quick Start

### macOS/Linux:
```bash
./start_app.sh
```

### Windows:
```cmd
start_app.bat
```

## What it does:
1. **Starts CNN Service** (Port 5002) - Specialized brain disease prediction
2. **Launches Flutter App** - Main application with dual AI interface
3. **Manages both processes** - Clean shutdown when you exit

## Features:
- ✅ **CNN AI**: Alzheimer's & Parkinson's prediction using your trained model
- ✅ **ChatGPT AI**: General medical analysis using GPT-4o vision
- ✅ **One command startup** - No need to manage multiple terminals
- ✅ **Automatic cleanup** - Kills background processes on exit

## Manual Commands (if needed):

### Start CNN Service Only:
```bash
cd python_service
./start_simple.sh
```

### Start Flutter Only:
```bash
flutter run
```

### Check CNN Service:
```bash
curl http://localhost:5002/health
```

## Troubleshooting:
- If CNN service fails, check `python_service/cnn_service.log`
- Make sure you have Flutter installed: `flutter doctor`
- Ensure PyTorch model is in `DL Model/Vbai-2.1c.pt`

---

**Happy Analyzing! 🧠✨**