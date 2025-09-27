from flask import Flask, request, jsonify
from flask_cors import CORS
import io
import base64
import os
from cnn_model import VbaiPredictor

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app to communicate

# Initialize the model
MODEL_PATH = "../DL Model/Vbai-2.1c.pt"
try:
    predictor = VbaiPredictor(MODEL_PATH, model_type='c')
    print("✅ CNN Model loaded successfully!")
except Exception as e:
    print(f"❌ Error loading model: {e}")
    predictor = None

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "model_loaded": predictor is not None,
        "service": "NeuroInsight CNN Service"
    })

@app.route('/model-info', methods=['GET'])
def get_model_info():
    """Get model information and performance metrics"""
    if predictor is None:
        return jsonify({"error": "Model not loaded"}), 500
    
    info = predictor.get_model_info()
    return jsonify(info)

@app.route('/predict', methods=['POST'])
def predict():
    """Main prediction endpoint - handles both multipart file upload and JSON base64"""
    if predictor is None:
        return jsonify({"error": "Model not loaded"}), 500
    
    try:
        image_io = None
        
        # Check if it's a multipart file upload (from Flutter)
        if 'image' in request.files:
            file = request.files['image']
            if file.filename == '':
                return jsonify({"error": "No file selected"}), 400
            
            # Read the uploaded file
            image_bytes = file.read()
            image_io = io.BytesIO(image_bytes)
            print(f"✅ Received multipart file upload: {len(image_bytes)} bytes")
            
        # Check if it's JSON with base64 data
        elif request.is_json:
            data = request.get_json()
            
            if not data or 'image' not in data:
                return jsonify({"error": "No image data provided"}), 400
            
            # Decode base64 image
            image_data = data['image']
            if image_data.startswith('data:image'):
                # Remove data:image/jpeg;base64, prefix
                image_data = image_data.split(',')[1]
            
            image_bytes = base64.b64decode(image_data)
            image_io = io.BytesIO(image_bytes)
            print(f"✅ Received JSON base64 data: {len(image_bytes)} bytes")
        
        else:
            return jsonify({"error": "No image data provided. Send either multipart file or JSON with base64."}), 400
        
        # Make prediction
        result = predictor.predict_from_image_bytes(image_io)
        
        if "error" in result:
            return jsonify(result), 500
        
        # Add additional metadata
        result["model_version"] = "Vbai-DPA 2.1c"
        result["analysis_type"] = "CNN_Prediction"
        
        return jsonify(result)
        
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

@app.route('/predict-file', methods=['POST'])
def predict_file():
    """Prediction endpoint for file upload"""
    if predictor is None:
        return jsonify({"error": "Model not loaded"}), 500
    
    try:
        if 'file' not in request.files:
            return jsonify({"error": "No file provided"}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({"error": "No file selected"}), 400
        
        # Make prediction
        result = predictor.predict_from_image_bytes(io.BytesIO(file.read()))
        
        if "error" in result:
            return jsonify(result), 500
        
        # Add additional metadata
        result["model_version"] = "Vbai-DPA 2.1c"
        result["analysis_type"] = "CNN_Prediction"
        result["filename"] = file.filename
        
        return jsonify(result)
        
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

@app.route('/classes', methods=['GET'])
def get_classes():
    """Get all available classes"""
    if predictor is None:
        return jsonify({"error": "Model not loaded"}), 500
    
    return jsonify({
        "classes": predictor.class_names,
        "num_classes": len(predictor.class_names),
        "descriptions": {
            "Alzheimer Disease": "Patient definitely has Alzheimer's disease",
            "Mild Alzheimer Risk": "Patient has a little more time to develop Alzheimer's disease",
            "Moderate Alzheimer Risk": "Patient may develop Alzheimer's disease in the near future", 
            "Very Mild Alzheimer Risk": "Patient has time to reach the level of Alzheimer's disease",
            "No Risk": "Person does not have any risk",
            "Parkinson Disease": "Person has Parkinson's disease"
        }
    })

if __name__ == '__main__':
    print("🚀 Starting NeuroInsight CNN Service...")
    print(f"📁 Model path: {MODEL_PATH}")
    print(f"🔧 Model loaded: {'✅ Yes' if predictor else '❌ No'}")
    
    # Try different ports if 5000 is in use
    import socket
    
    def is_port_in_use(port):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            return s.connect_ex(('localhost', port)) == 0
    
    # Use fixed port 5002 for consistency with Flutter app
    port = 5002
    if is_port_in_use(port):
        print(f"⚠️  Port {port} is in use, trying to start anyway...")
    
    print(f"🌟 Starting service on http://localhost:{port}")
    print("💡 Flutter app expects service on port 5002")
    
    # Run the Flask app
    app.run(
        host='0.0.0.0',  # Allow connections from Flutter app
        port=port,
        debug=True
    )