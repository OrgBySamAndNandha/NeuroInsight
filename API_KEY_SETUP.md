# 🔐 API Key Setup Instructions

## ⚠️ IMPORTANT SECURITY NOTICE

The API keys have been removed from the source code for security reasons. You need to add your OpenAI API key before the app will work.

## 🛠️ Setup Steps:

### 1. Add Your API Key to Both Files:

**File 1:** `lib/screens/users/views/user_report_scanner.dart`
- Find line: `final String _openaiApiKey = 'YOUR_OPENAI_API_KEY_HERE';`
- Replace `YOUR_OPENAI_API_KEY_HERE` with your actual API key

**File 2:** `lib/screens/users/views/task_detail_view.dart`
- Find line: `final String _openaiApiKey = 'YOUR_OPENAI_API_KEY_HERE';`
- Replace `YOUR_OPENAI_API_KEY_HERE` with your actual API key

### 2. Get Your Own API Key:
- Visit [platform.openai.com](https://platform.openai.com)
- Create an account and generate your API key
- Replace the placeholder in both files with your actual key

### 3. Download the ML Model:
The CNN model file was too large for GitHub. You'll need to ensure `DL Model/Vbai-2.1c.pt` exists in your project.

## 🚀 After Setup:
Run your app with:
```bash
./start_app.sh
```

## 🔒 Security Note:
- Never commit API keys to version control
- Keep your `.env` file local only
- The `.gitignore` now prevents accidental commits of sensitive data

---
**Remember to add your API key to both files before running the app!**