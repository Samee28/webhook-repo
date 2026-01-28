#!/bin/bash

# Quick Start Guide - GitHub Webhook Receiver
# Run this after completing setup to verify everything works

clear
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     GitHub Webhook Receiver - Quick Start Checklist       ║"
echo "╔════════════════════════════════════════════════════════════╗"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_count=0
total_checks=7

# Function to check command
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $2"
        ((check_count++))
        return 0
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

# Function to check process
check_process() {
    if pgrep -x "$1" > /dev/null; then
        echo -e "${GREEN}✓${NC} $2"
        ((check_count++))
        return 0
    else
        echo -e "${RED}✗${NC} $2"
        echo -e "  ${YELLOW}→${NC} Start with: $3"
        return 1
    fi
}

echo "📋 Prerequisites Check:"
echo "────────────────────────"

# Check Python
check_command "python3" "Python 3 installed"

# Check MongoDB
check_command "mongod" "MongoDB installed"

# Check if virtual environment exists
if [ -d "venv" ]; then
    echo -e "${GREEN}✓${NC} Virtual environment created"
    ((check_count++))
else
    echo -e "${RED}✗${NC} Virtual environment created"
    echo -e "  ${YELLOW}→${NC} Run: python3 -m venv venv"
fi

# Check if requirements are installed
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    if python -c "import flask" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Dependencies installed"
        ((check_count++))
    else
        echo -e "${RED}✗${NC} Dependencies installed"
        echo -e "  ${YELLOW}→${NC} Run: pip install -r requirements.txt"
    fi
fi

echo ""
echo "🔧 Services Check:"
echo "────────────────────────"

# Check MongoDB running
check_process "mongod" "MongoDB is running" "brew services start mongodb-community"

# Check if Flask is running
if lsof -Pi :5000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Flask app is running on port 5000"
    ((check_count++))
else
    echo -e "${RED}✗${NC} Flask app is running on port 5000"
    echo -e "  ${YELLOW}→${NC} Run: python run.py"
fi

# Check ngrok (optional but recommended)
if command -v ngrok &> /dev/null; then
    echo -e "${GREEN}✓${NC} ngrok installed (for GitHub webhooks)"
    ((check_count++))
else
    echo -e "${YELLOW}!${NC} ngrok not installed (optional)"
    echo -e "  ${YELLOW}→${NC} Install from: https://ngrok.com"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "Score: ${check_count}/${total_checks} checks passed"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [ $check_count -eq $total_checks ]; then
    echo -e "${GREEN}🎉 Perfect! Everything is set up correctly!${NC}"
    echo ""
    echo "📍 Next Steps:"
    echo "  1. Open dashboard: http://127.0.0.1:5000/webhook/"
    echo "  2. Test with: python test_webhook.py"
    echo "  3. Set up ngrok: ngrok http 5000"
    echo "  4. Configure GitHub webhook (see ACTION_REPO_SETUP.md)"
    echo ""
elif [ $check_count -ge 5 ]; then
    echo -e "${YELLOW}⚠️  Almost there! Fix the issues above.${NC}"
    echo ""
else
    echo -e "${RED}❌ Several issues need attention.${NC}"
    echo ""
    echo "📖 Quick Setup Commands:"
    echo "  python3 -m venv venv"
    echo "  source venv/bin/activate"
    echo "  pip install -r requirements.txt"
    echo "  brew services start mongodb-community"
    echo "  python run.py"
    echo ""
fi

echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📚 Documentation:"
echo "  • README.md           - Full setup guide"
echo "  • TESTING.md          - Testing procedures"
echo "  • ACTION_REPO_SETUP.md - GitHub configuration"
echo "  • SUMMARY.md          - Complete overview"
echo "  • ARCHITECTURE.md     - System architecture"
echo ""
echo "🆘 Need help?"
echo "  • Check TESTING.md for troubleshooting"
echo "  • Review logs in terminal running Flask"
echo "  • Verify MongoDB: mongosh github_webhooks"
echo ""
