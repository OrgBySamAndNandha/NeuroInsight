#!/usr/bin/env python3
"""
Test script for NeuroInsight CNN Service
Tests all endpoints and functionality

Usage: 
    python3 test_service.py
    or
    ./test_service.py
"""

import requests
import base64
import json
import os
import sys

BASE_URL = 'http://localhost:5000'

def test_health():
    """Test health endpoint"""
    print("🔍 Testing health endpoint...")
    try:
        response = requests.get(f'{BASE_URL}/health', timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Health check passed")
            print(f"   Status: {data.get('status')}")
            print(f"   Model loaded: {data.get('model_loaded')}")
            return data.get('model_loaded', False)
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def test_model_info():
    """Test model info endpoint"""
    print("\n🔍 Testing model info endpoint...")
    try:
        response = requests.get(f'{BASE_URL}/model-info', timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("✅ Model info retrieved successfully")
            print(f"   Model type: {data.get('model_type')}")
            print(f"   Parameters: {data.get('parameters_million')}M")
            print(f"   Device: {data.get('device')}")
            return True
        else:
            print(f"❌ Model info failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Model info error: {e}")
        return False

def test_classes():
    """Test classes endpoint"""
    print("\n🔍 Testing classes endpoint...")
    try:
        response = requests.get(f'{BASE_URL}/classes', timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("✅ Classes retrieved successfully")
            print(f"   Number of classes: {data.get('num_classes')}")
            classes = data.get('classes', [])
            for i, class_name in enumerate(classes, 1):
                print(f"   {i}. {class_name}")
            return True
        else:
            print(f"❌ Classes failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Classes error: {e}")
        return False

def create_test_image():
    """Create a simple test image for prediction"""
    try:
        from PIL import Image
        import io
        
        # Create a simple 224x224 RGB image
        img = Image.new('RGB', (224, 224), color='gray')
        
        # Convert to bytes
        img_byte_arr = io.BytesIO()
        img.save(img_byte_arr, format='JPEG')
        img_byte_arr = img_byte_arr.getvalue()
        
        return base64.b64encode(img_byte_arr).decode('utf-8')
    except ImportError:
        print("❌ PIL not available, skipping image tests")
        return None
    except Exception as e:
        print(f"❌ Error creating test image: {e}")
        return None

def test_prediction():
    """Test prediction endpoint"""
    print("\n🔍 Testing prediction endpoint...")
    
    test_image_b64 = create_test_image()
    if not test_image_b64:
        print("⏭️  Skipping prediction test (no test image)")
        return False
    
    try:
        payload = {'image': test_image_b64}
        response = requests.post(
            f'{BASE_URL}/predict', 
            json=payload, 
            headers={'Content-Type': 'application/json'},
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            print("✅ Prediction successful")
            print(f"   Predicted class: {data.get('predicted_class')}")
            print(f"   Confidence: {data.get('confidence_percentage', 0):.1f}%")
            print(f"   Inference time: {data.get('inference_time_ms', 0):.1f}ms")
            return True
        else:
            print(f"❌ Prediction failed: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Prediction error: {e}")
        return False

def main():
    print("🧠 NeuroInsight CNN Service Test Suite")
    print("=" * 40)
    
    # Test all endpoints
    tests = [
        ("Health Check", test_health),
        ("Model Info", test_model_info),
        ("Classes Info", test_classes),
        ("Prediction", test_prediction)
    ]
    
    results = []
    for test_name, test_func in tests:
        result = test_func()
        results.append((test_name, result))
    
    # Summary
    print("\n" + "=" * 40)
    print("📊 Test Results Summary:")
    
    passed = 0
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"   {test_name}: {status}")
        if result:
            passed += 1
    
    print(f"\n🎯 Overall: {passed}/{len(tests)} tests passed")
    
    if passed == len(tests):
        print("🎉 All tests passed! Service is ready.")
        return 0
    else:
        print("⚠️  Some tests failed. Check the service setup.")
        return 1

if __name__ == '__main__':
    sys.exit(main())