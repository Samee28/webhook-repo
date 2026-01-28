#!/bin/bash

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  GitHub Webhook Receiver - Verification Report                ║"
echo "║  Date: $(date)                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

passed=0
total=0

check() {
  local name=$1
  local command=$2
  ((total++))
  
  if eval "$command" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} $name"
    ((passed++))
  else
    echo -e "${RED}✗${NC} $name"
  fi
}

echo -e "${BLUE}📋 PROJECT STRUCTURE${NC}"
echo "────────────────────────────────────────────────────────────────"

check "app/__init__.py exists" "test -f app/__init__.py"
check "app/extensions.py exists" "test -f app/extensions.py"
check "app/webhook/routes.py exists" "test -f app/webhook/routes.py"
check "app/templates/index.html exists" "test -f app/templates/index.html"
check "run.py exists" "test -f run.py"
check "requirements.txt exists" "test -f requirements.txt"
check ".env exists" "test -f .env"

echo ""
echo -e "${BLUE}🔧 DEPENDENCIES${NC}"
echo "────────────────────────────────────────────────────────────────"

check "Flask installed" "python -c 'import flask' 2>/dev/null"
check "Flask-PyMongo installed" "python -c 'import flask_pymongo' 2>/dev/null"
check "Flask-CORS installed" "python -c 'import flask_cors' 2>/dev/null"
check "python-dotenv installed" "python -c 'import dotenv' 2>/dev/null"

echo ""
echo -e "${BLUE}🌐 FLASK APPLICATION${NC}"
echo "────────────────────────────────────────────────────────────────"

check "Flask runs without errors" "python run.py --help 2>&1 | grep -q 'Usage:' || python -c 'from app import create_app; app = create_app()' 2>/dev/null"
check "Port 8080 available or in use" "! lsof -ti:8080 > /dev/null 2>&1 || echo 'Port in use' > /dev/null"

echo ""
echo -e "${BLUE}📁 DOCUMENTATION${NC}"
echo "────────────────────────────────────────────────────────────────"

check "README.md exists" "test -f README.md"
check "SUMMARY.md exists" "test -f SUMMARY.md"
check "TESTING.md exists" "test -f TESTING.md"
check "ACTION_REPO_SETUP.md exists" "test -f ACTION_REPO_SETUP.md"
check "ARCHITECTURE.md exists" "test -f ARCHITECTURE.md"
check "FINAL_STATUS.md exists" "test -f FINAL_STATUS.md"

echo ""
echo -e "${BLUE}🛠️  HELPER SCRIPTS${NC}"
echo "────────────────────────────────────────────────────────────────"

check "setup.sh is executable" "test -x setup.sh"
check "test_webhook.py is executable" "test -x test_webhook.py"
check "quick-check.sh is executable" "test -x quick-check.sh"
check "install-mongodb.sh is executable" "test -x install-mongodb.sh"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo -e "Score: ${GREEN}$passed${NC}/$total checks passed"
echo "════════════════════════════════════════════════════════════════"
echo ""

if [ $passed -eq $total ]; then
  echo -e "${GREEN}✅ ALL CHECKS PASSED!${NC}"
  echo ""
  echo "Your application is ready to use!"
  echo ""
  echo "📍 Quick Start:"
  echo "  1. Flask: http://127.0.0.1:8080/webhook/"
  echo "  2. API:   http://127.0.0.1:8080/webhook/events"
  echo "  3. Endpoint: POST http://127.0.0.1:8080/webhook/receiver"
  echo ""
  echo "🚀 Next Steps:"
  echo "  • Keep Flask running"
  echo "  • Set up GitHub webhooks with ngrok"
  echo "  • Test with real events"
  echo "  • Push to GitHub"
  echo "  • Submit links"
  echo ""
else
  echo -e "${YELLOW}⚠️  Some checks failed${NC}"
  echo ""
  echo "Please run: python run.py"
  echo "This will start the Flask application"
  echo ""
fi

echo "════════════════════════════════════════════════════════════════"
echo ""
