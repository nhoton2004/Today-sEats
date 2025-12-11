#!/bin/bash
# Clean restart script for backend

echo "🔄 Cleaning and restarting backend..."
echo ""

# Kill existing node processes
echo "1️⃣ Stopping existing processes..."
pkill -f "node server.js" 2>/dev/null || echo "   No existing processes found"

# Clear Node cache
echo "2️⃣ Clearing Node.js cache..."
rm -rf node_modules/.cache 2>/dev/null || true

# Verify .env file
echo "3️⃣ Verifying .env configuration..."
if [ -f .env ]; then
    echo "   ✅ .env file exists"
    grep -q "MONGODB_URI=mongodb+srv" .env && echo "   ✅ MongoDB URI found" || echo "   ⚠️  MongoDB URI missing"
    grep -q "AWS_ACCESS_KEY_ID=AKIA" .env && echo "   ✅ AWS credentials found" || echo "   ⚠️  AWS credentials missing"
else
    echo "   ❌ .env file not found!"
    exit 1
fi

# Verify Firebase service account
echo "4️⃣ Verifying Firebase service account..."
if [ -L serviceAccountKey.json ]; then
    target=$(readlink serviceAccountKey.json)
    if [ -f "$target" ]; then
        echo "   ✅ Firebase service account: $target"
    else
        echo "   ❌ Symlink broken: $target not found"
        exit 1
    fi
else
    echo "   ❌ serviceAccountKey.json symlink not found"
    exit 1
fi

echo ""
echo "5️⃣ Starting backend server..."
echo "=========================================="
npm start
