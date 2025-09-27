#!/bin/bash

# Simple CNN Service Starter
echo "🚀 Starting NeuroInsight CNN Service (Simple Mode)"
echo "=========================================="

cd /Users/samandersony/StudioProjects/projects/NeuroInsight/python_service

# Activate virtual environment
source venv/bin/activate

# Start the service with production-like settings
echo "🔥 Starting Flask app..."
FLASK_ENV=production python -c "
from app import app
import sys
import socket

def is_port_in_use(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0

# Find an available port
for port in [5002, 5555, 5001, 5003, 5000, 8080, 8081]:
    if not is_port_in_use(port):
        print(f'✅ Starting on port {port}')
        app.run(host='0.0.0.0', port=port, debug=False, use_reloader=False)
        break
else:
    print('❌ No available ports found')
    sys.exit(1)
"