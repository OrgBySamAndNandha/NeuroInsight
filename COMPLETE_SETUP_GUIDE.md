# 🚀 NeuroInsight - Complete Setup Guide

## 📋 Prerequisites

Before you begin, make sure you have:

- **Flutter SDK** installed ([flutter.dev](https://flutter.dev/docs/get-started/install))
- **Python 3.8+** installed
- **Git** installed
- **Android Studio** or **Xcode** (for mobile development)
- **OpenAI API Key** (get from [platform.openai.com](https://platform.openai.com))

## 🔧 Step-by-Step Setup

### 1. Clone the Repository
```bash
git clone https://github.com/OrgBySamAndNandha/NeuroInsight.git
cd NeuroInsight
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Set Up Your OpenAI API Key

#### Option A - Quick Setup (Replace Placeholder):
1. Open `lib/screens/users/views/user_report_scanner.dart`
2. Find line: `final String _openaiApiKey = 'YOUR_OPENAI_API_KEY_HERE';`
3. Replace `YOUR_OPENAI_API_KEY_HERE` with your actual OpenAI API key

4. Open `lib/screens/users/views/task_detail_view.dart`
5. Find line: `final String _openaiApiKey = 'YOUR_OPENAI_API_KEY_HERE';`
6. Replace `YOUR_OPENAI_API_KEY_HERE` with your actual OpenAI API key

#### Option B - Environment File (Recommended):
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Edit `.env` and add your API key:
   ```
   OPENAI_API_KEY=your_actual_api_key_here
   ```

### 4. Download the CNN Model

The CNN model file was too large for GitHub. You have two options:

#### Option A - Use Your Own Model:
1. Create the directory: `mkdir "DL Model"`
2. Place your PyTorch model file as: `DL Model/Vbai-2.1c.pt`

#### Option B - Contact the Developer:
- The original model can be shared separately
- Contact the repository owner for the trained model file

### 5. Set Up Python Environment
```bash
cd python_service
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cd ..
```

### 6. Configure Firebase (Optional)
If you want the full app experience:
1. Create a Firebase project at [firebase.google.com](https://firebase.google.com)
2. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Update Firebase configuration in the app

## 🚀 Running the Application

### Easy Way - One Command:
```bash
./start_app.sh
```

### Manual Way:
1. **Start CNN Service:**
   ```bash
   cd python_service
   ./start_simple.sh
   ```

2. **In a new terminal, start Flutter:**
   ```bash
   flutter run
   ```

## 🧪 Testing the Setup

### 1. Check CNN Service:
```bash
curl http://localhost:5002/health
```
Expected response:
```json
{
  "model_loaded": true,
  "service": "NeuroInsight CNN Service", 
  "status": "healthy"
}
```

### 2. Test OpenAI API:
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" https://api.openai.com/v1/models | head -5
```

### 3. Run Flutter App:
- Choose your device (Android emulator, iOS simulator, etc.)
- Upload a brain scan image
- Test both AI analysis options

## 📱 Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11.0+)
- ✅ **macOS** (Desktop)
- ✅ **Windows** (Desktop)
- ✅ **Web** (Chrome, Safari, Firefox)

## 🔍 Troubleshooting

### Flutter Issues:
```bash
flutter doctor
flutter clean
flutter pub get
```

### Python Service Issues:
```bash
cd python_service
pip install --upgrade pip
pip install -r requirements.txt
```

### Port Already in Use:
```bash
# Kill process on port 5002
lsof -ti:5002 | xargs kill -9
```

### Model Not Found:
- Ensure `DL Model/Vbai-2.1c.pt` exists and is ~196MB
- Check file permissions

## 🏗️ Project Structure

```
NeuroInsight/
├── lib/                    # Flutter app source
│   ├── screens/           # App screens
│   ├── services/          # CNN service integration
│   └── widgets/           # Custom widgets
├── python_service/        # CNN AI backend
│   ├── app.py            # Flask server
│   ├── cnn_model.py      # PyTorch model
│   └── requirements.txt  # Python dependencies
├── DL Model/             # CNN model file (not in git)
└── start_app.sh          # One-command startup
```

## ⚡ Features

- 🧠 **Dual AI Analysis**:
  - **CNN Model**: Specialized Alzheimer's/Parkinson's prediction
  - **ChatGPT**: General medical image analysis using GPT-4o
- 📱 **Cross-platform**: Android, iOS, Web, Desktop
- 🔒 **Secure**: API keys not stored in repository
- 🚀 **Easy startup**: Single command to run everything

## 💡 Development Tips

1. **Hot Reload**: Use `flutter run` with hot reload for faster development
2. **Debugging**: Check `python_service/cnn_service.log` for CNN issues
3. **API Testing**: Test APIs independently before integration
4. **Model Updates**: Replace model in `DL Model/` directory

## 🆘 Need Help?

1. **Check the logs**: `python_service/cnn_service.log`
2. **Run flutter doctor**: Ensure Flutter setup is correct
3. **Verify API keys**: Test OpenAI API independently
4. **Check model file**: Ensure it's the correct size and format

## 📞 Support

For issues or questions:
- Create an issue on GitHub
- Check existing documentation files
- Verify all prerequisites are met

---

**🎉 You're all set! Enjoy analyzing brain scans with dual AI power!**