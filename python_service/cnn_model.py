import torch
import torch.nn as nn
from torchvision import transforms
from PIL import Image
import time
from thop import profile

class SimpleCNN(nn.Module):
    def __init__(self, model_type='c', num_classes=6):
        """
        SimpleCNN model for Vbai-DPA 2.1
        model_type: 'f', 'c', or 'q' based on model variant
        num_classes: 6 classes for brain disease prediction
        """
        super(SimpleCNN, self).__init__()
        self.num_classes = num_classes
        self.model_type = model_type
        
        if model_type == 'f':
            self.conv1 = nn.Conv2d(3, 16, kernel_size=3, stride=1, padding=1)
            self.conv2 = nn.Conv2d(16, 32, kernel_size=3, stride=1, padding=1)
            self.conv3 = nn.Conv2d(32, 64, kernel_size=3, stride=1, padding=1)
            self.fc1 = nn.Linear(64 * 28 * 28, 256)
            self.dropout = nn.Dropout(0.5)
        elif model_type == 'c':
            self.conv1 = nn.Conv2d(3, 32, kernel_size=3, stride=1, padding=1)
            self.conv2 = nn.Conv2d(32, 64, kernel_size=3, stride=1, padding=1)
            self.conv3 = nn.Conv2d(64, 128, kernel_size=3, stride=1, padding=1)
            self.fc1 = nn.Linear(128 * 28 * 28, 512)
            self.dropout = nn.Dropout(0.5)
        elif model_type == 'q':
            self.conv1 = nn.Conv2d(3, 64, kernel_size=3, stride=1, padding=1)
            self.conv2 = nn.Conv2d(64, 128, kernel_size=3, stride=1, padding=1)
            self.conv3 = nn.Conv2d(128, 256, kernel_size=3, stride=1, padding=1)
            self.conv4 = nn.Conv2d(256, 512, kernel_size=3, stride=1, padding=1)
            self.fc1 = nn.Linear(512 * 14 * 14, 1024)
            self.dropout = nn.Dropout(0.3)
        
        self.fc2 = nn.Linear(self.fc1.out_features, num_classes)
        self.relu = nn.ReLU()
        self.pool = nn.MaxPool2d(kernel_size=2, stride=2, padding=0)

    def forward(self, x):
        x = self.pool(self.relu(self.conv1(x)))
        x = self.pool(self.relu(self.conv2(x)))
        x = self.pool(self.relu(self.conv3(x)))
        if hasattr(self, 'conv4'):
            x = self.pool(self.relu(self.conv4(x)))
        x = x.view(x.size(0), -1)
        x = self.relu(self.fc1(x))
        x = self.dropout(x)
        x = self.fc2(x)
        return x

class VbaiPredictor:
    def __init__(self, model_path, model_type='c'):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model = SimpleCNN(model_type=model_type, num_classes=6).to(self.device)
        
        # Load the trained model
        try:
            self.model.load_state_dict(
                torch.load(model_path, map_location=self.device, weights_only=True)
            )
            print(f"Model loaded successfully from {model_path}")
        except Exception as e:
            print(f"Error loading model: {e}")
            raise
        
        self.model.eval()
        
        # Define transforms
        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])
        
        # Class names matching the Vbai-DPA 2.1 model
        self.class_names = [
            'Alzheimer Disease',
            'Mild Alzheimer Risk', 
            'Moderate Alzheimer Risk',
            'Very Mild Alzheimer Risk',
            'No Risk',
            'Parkinson Disease'
        ]
    
    def predict_from_image_path(self, image_path):
        """Predict from image file path"""
        try:
            image = Image.open(image_path).convert('RGB')
            return self._predict_from_image(image)
        except Exception as e:
            return {"error": f"Error processing image: {str(e)}"}
    
    def predict_from_image_bytes(self, image_bytes):
        """Predict from image bytes"""
        try:
            image = Image.open(image_bytes).convert('RGB')
            return self._predict_from_image(image)
        except Exception as e:
            return {"error": f"Error processing image: {str(e)}"}
    
    def _predict_from_image(self, image):
        """Internal method to predict from PIL Image"""
        try:
            # Preprocess image
            image_tensor = self.transform(image).unsqueeze(0).to(self.device)
            
            with torch.no_grad():
                start_time = time.time()
                outputs = self.model(image_tensor)
                inference_time = (time.time() - start_time) * 1000  # Convert to ms
                
                # Get prediction
                _, predicted = torch.max(outputs, 1)
                probabilities = torch.nn.functional.softmax(outputs, dim=1)
                confidence = probabilities[0, predicted].item()
                
                # Get all class probabilities
                all_probabilities = probabilities[0].cpu().numpy()
                
                result = {
                    "predicted_class": self.class_names[predicted.item()],
                    "predicted_class_index": predicted.item(),
                    "confidence": confidence,
                    "confidence_percentage": confidence * 100,
                    "inference_time_ms": inference_time,
                    "all_class_probabilities": {
                        class_name: float(prob) for class_name, prob in zip(self.class_names, all_probabilities)
                    }
                }
                
                return result
                
        except Exception as e:
            return {"error": f"Prediction error: {str(e)}"}
    
    def get_model_info(self):
        """Get model performance metrics"""
        try:
            input_size = (1, 3, 224, 224)
            inputs = torch.randn(input_size).to(self.device)
            
            flops, params = profile(self.model, inputs=(inputs,), verbose=False)
            params_million = params / 1e6
            flops_billion = flops / 1e9
            
            # Simple benchmark
            with torch.no_grad():
                start_time = time.time()
                _ = self.model(inputs)
                end_time = time.time()
                inference_time = (end_time - start_time) * 1000
            
            return {
                "model_type": self.model_type,
                "parameters_million": round(params_million, 2),
                "flops_billion": round(flops_billion, 2),
                "inference_time_ms": round(inference_time, 2),
                "input_size": "224x224",
                "num_classes": len(self.class_names),
                "device": str(self.device)
            }
        except Exception as e:
            return {"error": f"Error getting model info: {str(e)}"}