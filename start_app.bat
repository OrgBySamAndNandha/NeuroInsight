@echo off
echo 🚀 Starting NeuroInsight Dual AI System...
echo ==========================================

echo 🧠 Starting CNN Service...
echo 💡 CNN service will run on port 5002

cd python_service
start /B start_simple.sh

echo ⏳ Waiting for CNN service to initialize...
timeout /t 8 /nobreak > nul

echo 📱 Starting Flutter App...
cd ..

echo 🔥 Launching Flutter app...
echo 📱 Choose your device when prompted
echo.
echo ===============================================
echo   NeuroInsight Dual AI System Ready!         
echo   - CNN Service: http://localhost:5002       
echo   - ChatGPT AI: Integrated                   
echo ===============================================
echo.

flutter run

pause