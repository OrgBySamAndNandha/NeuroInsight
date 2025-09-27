# NeuroInsight CNN Service

This Python service provides CNN-based brain disease prediction using the Vbai-DPA 2.1 model.

## Setup

1. Install Python dependencies:
```bash
cd python_service
pip install -r requirements.txt
```

2. Make sure the model file `Vbai-2.1c.pt` is in the `DL Model/` folder

3. Run the service:
```bash
python app.py
```

The service will start on `http://localhost:5000`

## API Endpoints

- `GET /health` - Health check
- `GET /model-info` - Get model information and metrics
- `POST /predict` - Predict from base64 encoded image
- `POST /predict-file` - Predict from uploaded file
- `GET /classes` - Get all available classes and descriptions

## Model Classes

1. **Alzheimer Disease**: Patient definitely has Alzheimer's disease
2. **Mild Alzheimer Risk**: Patient has a little more time to develop Alzheimer's disease  
3. **Moderate Alzheimer Risk**: Patient may develop Alzheimer's disease in the near future
4. **Very Mild Alzheimer Risk**: Patient has time to reach the level of Alzheimer's disease
5. **No Risk**: Person does not have any risk
6. **Parkinson Disease**: Person has Parkinson's disease

## Usage from Flutter

The Flutter app communicates with this service via HTTP requests to get CNN-based predictions alongside the existing Gemini analysis.