#!/bin/bash

# MongoDB Installation Helper for macOS

echo "╔════════════════════════════════════════════════════════╗"
echo "║   MongoDB Installation Helper for macOS                ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed"
    echo "Install Homebrew from: https://brew.sh"
    exit 1
fi

echo "✓ Homebrew found"
echo ""

# Try different installation methods
echo "Attempting to install MongoDB..."
echo ""

# Method 1: Try direct installation (no tap needed in newer Homebrew)
echo "Method 1: Direct installation (newer Homebrew)..."
if brew install mongodb-community 2>/dev/null; then
    echo "✓ MongoDB installed successfully via direct method!"
    brew services start mongodb-community
    echo "✓ MongoDB service started"
    exit 0
fi

echo "Trying alternative method..."
echo ""

# Method 2: Using MongoDB's tap
echo "Method 2: Using MongoDB's official tap..."
if brew tap mongodb/brew 2>/dev/null && brew install mongodb-community 2>/dev/null; then
    echo "✓ MongoDB installed successfully via MongoDB tap!"
    brew services start mongodb-community
    echo "✓ MongoDB service started"
    exit 0
fi

echo ""
echo "⚠️  MongoDB installation via Homebrew failed"
echo ""
echo "Alternative Options:"
echo ""
echo "1. Use MongoDB Atlas (Cloud - FREE, NO installation needed):"
echo "   Go to: https://www.mongodb.com/cloud/atlas"
echo "   Create free account and cluster"
echo "   Then update your .env file with the connection string"
echo ""
echo "2. Update Command Line Tools and try again:"
echo "   sudo xcode-select --install"
echo "   Then run this script again"
echo ""
echo "3. Install MongoDB manually from:"
echo "   https://docs.mongodb.com/manual/tutorial/install-mongodb-on-os-x/"
echo ""

exit 1
