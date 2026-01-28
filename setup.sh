#!/bin/bash

# GitHub Webhook Receiver Setup Script

echo "========================================="
echo "GitHub Webhook Receiver Setup"
echo "========================================="
echo ""

# Check Python version
echo "Checking Python version..."
python3 --version

# Check if MongoDB is installed
echo ""
echo "Checking MongoDB..."
if command -v mongod &> /dev/null; then
    echo "✓ MongoDB is installed"
    mongod --version | head -n 1
else
    echo "✗ MongoDB is not installed"
    echo "Please install MongoDB:"
    echo "  macOS: brew install mongodb-community"
    echo "  Ubuntu: sudo apt-get install mongodb"
    exit 1
fi

# Create virtual environment
echo ""
echo "Creating virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo ""
echo "Installing dependencies..."
pip install -r requirements.txt

# Start MongoDB
echo ""
echo "Starting MongoDB..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    brew services start mongodb-community
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    sudo systemctl start mongod
fi

echo ""
echo "========================================="
echo "Setup complete!"
echo "========================================="
echo ""
echo "To start the application:"
echo "  1. Activate virtual environment: source venv/bin/activate"
echo "  2. Run the app: python run.py"
echo "  3. Open browser: http://127.0.0.1:5000/webhook/"
echo ""
echo "To expose locally for GitHub webhooks:"
echo "  1. Install ngrok: https://ngrok.com/"
echo "  2. Run: ngrok http 5000"
echo "  3. Use the ngrok URL in GitHub webhook settings"
echo ""
