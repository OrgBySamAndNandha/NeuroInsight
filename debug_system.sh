#!/bin/bash

echo "🔍 NeuroInsight System Diagnostics"
echo "=================================="

echo "1. Testing CNN Service..."
curl -s http://localhost:5002/health && echo " ✅ CNN Service OK" || echo " ❌ CNN Service Failed"

echo "2. Testing Gemini API..."
curl -s "https://generativelanguage.googleapis.com/v1beta/models?key=AIzaSyCcYtHpJ_R4t64USIX862ZZWG8edzUgNlk" | grep -q "models" && echo " ✅ Gemini API OK" || echo " ❌ Gemini API Failed"

echo "3. Testing Network from Flutter..."
echo "   → Run flutter app and try analysis to see detailed logs"

echo ""
echo "📱 Next Steps:"
echo "   1. flutter run"
echo "   2. Try small image with Gemini first"
echo "   3. Check terminal for detailed error messages"