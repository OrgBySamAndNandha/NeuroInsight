# NeuroInsight - Dual AI Analysis System

## Overview

NeuroInsight now supports **dual AI analysis** for brain scan interpretation:

1. **Gemini AI** - General purpose medical image analysis
2. **Vbai-DPA 2.1 CNN Model** - Specialized deep learning model for Alzheimer's and Parkinson's prediction

## 🧠 Vbai-DPA 2.1 Model

### About
- **Source**: Kaggle Vbai-DPA 2.1 model by eyppler
- **Purpose**: Specialized for brain disease diagnosis from MRI/fMRI images
- **Classes**: 6 diagnostic categories
- **Accuracy**: High precision for neurological conditions

### Supported Diagnoses
1. 🔴 **Alzheimer Disease** - Definitive diagnosis
2. 🟠 **Mild Alzheimer Risk** - Early risk indicators
3. 🟡 **Moderate Alzheimer Risk** - Moderate risk level
4. 🟢 **Very Mild Alzheimer Risk** - Minimal risk factors
5. ✅ **No Risk** - No significant risk detected
6. 🟣 **Parkinson Disease** - Movement disorder diagnosis

## 🚀 Setup Instructions

### 1. Python Service Setup

```bash
# Navigate to python service directory
cd python_service

# Run the startup script (recommended)
./start_service.sh

# OR manual setup:
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py
```

### 2. Model File
Ensure `Vbai-2.1c.pt` is placed in the `DL Model/` directory

### 3. Service URL
The Python service runs on `http://localhost:5000`

## 📱 Flutter App Features

### Analysis Selection UI
- Radio button selection between Gemini AI and CNN Model
- Real-time service availability check
- Model information dialog with technical details
- Visual indicators for service status

### Enhanced Results Display
- CNN predictions show confidence percentages
- Detailed probability breakdown for all classes
- Technical metadata (processing time, model version)
- Professional medical report formatting

### Smart Fallback
- Automatic fallback to Gemini AI if CNN service is unavailable
- Service health monitoring
- User-friendly error handling

## 🔧 Technical Architecture

### Python Backend
- **Flask** REST API service
- **PyTorch** for CNN model inference
- **CORS** enabled for Flutter communication
- **Base64** image encoding support

### Flutter Frontend
- **HTTP** service integration
- **Reactive UI** with real-time status updates
- **Professional medical** report formatting
- **Firebase** integration for report storage

## 📊 API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health` | GET | Service health check |
| `/model-info` | GET | Model specifications |
| `/predict` | POST | Image analysis (base64) |
| `/predict-file` | POST | File upload analysis |
| `/classes` | GET | Available diagnostic classes |

## 🎯 Usage Workflow

1. **User** selects analysis method (Gemini or CNN)
2. **App** checks CNN service availability
3. **Image** is captured/selected by user
4. **Analysis** is performed using selected method
5. **Results** are formatted and displayed
6. **Report** is saved to Firebase with metadata

## 🔐 Security & Privacy

- Local processing option (CNN service can run locally)
- No image data stored by Python service
- Firebase security rules apply for report storage
- HIPAA-compliant architecture possible with proper deployment

## 🚀 Deployment Options

### Development
- Local Python service on `localhost:5000`
- Flutter app connects to local service

### Production
- Deploy Python service to cloud (AWS, GCP, Azure)
- Update `CNNService.baseUrl` in Flutter app
- Consider using Docker for containerization

## 📈 Performance Metrics

### Vbai-DPA 2.1c Model
- **Parameters**: ~51.48M
- **FLOPs**: ~0.56B
- **Inference Time**: ~8-20ms (depending on hardware)
- **Input Size**: 224x224 pixels
- **Memory Usage**: ~200MB model file

## 🔍 Troubleshooting

### CNN Service Issues
1. Check if Python service is running
2. Verify model file location
3. Check firewall/network connectivity
4. Review Python service logs

### Flutter App Issues
1. Ensure http package is in pubspec.yaml
2. Check network permissions
3. Verify service URL configuration
4. Monitor debug console for errors

## 🎨 UI Enhancements

### Visual Indicators
- 🟢 Green: Service available
- 🔴 Red: Service unavailable  
- 🟡 Orange: Warning states
- ⚡ Lightning: Fast processing
- 🧠 Brain: Neural network analysis

### Professional Styling
- Medical-grade color scheme
- Clear typography with Google Fonts
- Intuitive iconography
- Responsive design patterns

---

*This dual AI system provides comprehensive brain scan analysis with both general-purpose AI and specialized medical deep learning models, ensuring accurate and reliable diagnostic assistance.*