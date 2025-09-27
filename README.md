# 🧠 NeuroInsight - Dual AI Brain Analysis System

A powerful Flutter application that combines **CNN deep learning** and **ChatGPT AI** for comprehensive brain scan analysis, specializing in Alzheimer's and Parkinson's disease prediction.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![PyTorch](https://img.shields.io/badge/PyTorch-EE4C2C?style=for-the-badge&logo=pytorch&logoColor=white)
![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)

## ✨ Features

### 🎯 Dual AI Analysis
- **🧠 CNN Model**: Specialized neurological disease prediction (Alzheimer's & Parkinson's)
- **💬 ChatGPT Integration**: General medical image analysis using GPT-4o vision
- **📊 Professional Results**: Medical-grade reporting and recommendations

### 📱 Cross-Platform Support
- **Android** & **iOS** mobile apps
- **Web** application
- **Desktop** (macOS, Windows, Linux)

### 🚀 Easy Deployment
- **One-command startup**: `./start_app.sh`
- **Automated setup**: Python environment and Flask server
- **Docker ready**: Containerized CNN service

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  Python Service  │    │   OpenAI API    │
│                 │    │                  │    │                 │
│  • Image Upload │◄──►│  • CNN Model     │    │  • GPT-4o       │
│  • UI/UX        │    │  • Flask Server  │    │  • Vision API   │
│  • Results      │    │  • Port 5002     │    │  • Medical AI   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Flutter SDK
- Python 3.8+
- OpenAI API Key

### Installation
```bash
# Clone the repository
git clone https://github.com/OrgBySamAndNandha/NeuroInsight.git
cd NeuroInsight

# Install dependencies
flutter pub get

# Set up your API key (see COMPLETE_SETUP_GUIDE.md)
# Add your OpenAI API key to the source files

# Start the application
./start_app.sh
```oInsight

**AI-powered Alzheimer’s MRI Analysis and Doctor-Patient Collaboration Platform**

---

## 📖 Abstract

**NeuroInsight** is an innovative healthcare application that harnesses deep learning for early detection and monitoring of Alzheimer’s disease from brain MRI scans. The app analyzes uploaded MRI images using a deep learning model to provide an initial prediction report. This report, along with the original MRI scan, is sent to a connected neurologist for further analysis, recommendations, or appointment scheduling. Both the AI and doctor’s reports are then processed and formatted by an integrated AI assistant, which stores and organizes all results for easy access. Patients can interact with the AI bot to ask questions, receive insights, and track their health journey. Monthly analytics and visualizations help patients understand changes and progress over time.

---

## 💡 Problem Statement

Early diagnosis and continuous monitoring are critical in managing Alzheimer’s disease, but access to expert analysis and organized medical records remains a challenge for many patients. Traditional methods rely heavily on in-person appointments, manual reporting, and lack digital tracking, leading to delayed interventions, confusion over medical records, and limited patient engagement in their own care.

---

## 📝 Objective

NeuroInsight addresses these limitations by combining automated deep learning-based MRI analysis, doctor collaboration, intelligent report formatting, and interactive AI-driven patient support. The platform simplifies the diagnosis process, improves record-keeping, and empowers patients to track and understand their neurological health using clear analytics and easy-to-use conversational interfaces.

---

## 💻 Hardware Requirements

- Android/iOS smartphone (with camera or file upload capability)
- Internet connectivity (Wi-Fi or Mobile Data)
- (Optional) Desktop or tablet for broader access

---

## 🖥️ Software Requirements

- Android/iOS device or web browser
- **Flutter** (for cross-platform mobile development)
- **Dart** (Flutter programming language)
- **Firebase** (Authentication, Firestore, Storage, Cloud Functions, Messaging)
- **Python** (for deep learning model serving and AI bot, e.g., using FastAPI/Flask)
- Deep Learning Libraries: TensorFlow or PyTorch (for MRI analysis)
- Charting library (e.g., [fl_chart](https://pub.dev/packages/fl_chart) for Flutter graphs)
- Cloud Hosting Platform (for model and backend APIs)

---

## 🏛️ Existing System

- Manual MRI review and Alzheimer’s diagnosis, often delayed and dependent on physical appointments.
- Lack of automation in generating diagnostic or summary reports.
- No integrated channel for patient-doctor-AI communication.
- No digital, visualized record-keeping or long-term analytics for patients.

---

## 🚀 Proposed System

- Automated MRI scan analysis using a pre-trained deep learning model.
- Generation of AI-powered preliminary reports on Alzheimer’s prediction.
- Secure report delivery to connected neurologists for confirmation, advice, and appointment scheduling.
- All doctor and AI reports are processed by an AI bot, formatted for easy comprehension, and securely stored.
- Patients can interact with the AI assistant for doubts, clarifications, and personalized insights.
- Monthly visual analytics to help users understand health trends and improvements.

---

## 📦 Modules and Module Description

1. **User Authentication & Profile**
    - Secure login and user management (Firebase Auth).
2. **MRI Scan Upload Module**
    - Upload MRI brain scans for automated deep learning analysis.
3. **Alzheimer’s Prediction Module**
    - Analyze images using a deployed DL model; generate prediction reports.
4. **Doctor Review & Collaboration Module**
    - Send AI-generated reports and images to doctors for further review and recommendations.
    - Appointment management if needed.
5. **AI Bot Assistant Module**
    - Processes, formats, and stores both AI and doctor reports.
    - Conversational support for user queries related to reports, Alzheimer’s, and general health.
6. **Report Management & Analytics Module**
    - Stores all reports securely, accessible by both patients and doctors.
    - Generates monthly analytics with graphs for user health tracking.
7. **Notification & Communication Module**
    - Notifies users of new reports, doctor feedback, and upcoming appointments (using Firebase Messaging).

---

## 📝 Conclusion

NeuroInsight reimagines Alzheimer’s care by integrating deep learning diagnostics, seamless doctor collaboration, and AI-powered patient engagement into a unified platform. With real-time predictions, transparent records, and interactive analytics, the app empowers patients and doctors to work together for better, data-driven neurological care.

---

