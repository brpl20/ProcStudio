#!/bin/bash

# ProcStudio Test Router Setup Script
# This script sets up the complete testing environment

set -e  # Exit on any error

echo "🚀 Setting up ProcStudio Test Router..."
echo "════════════════════════════════════════"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "test_router.js" ]; then
    print_error "Please run this script from the tests directory"
    exit 1
fi

# 1. Install Node.js dependencies
print_info "Installing Node.js dependencies..."
if npm install; then
    print_status "Node.js dependencies installed"
else
    print_error "Failed to install Node.js dependencies"
    exit 1
fi

# 2. Install Playwright browsers
print_info "Installing Playwright browsers..."
if npx playwright install; then
    print_status "Playwright browsers installed"
else
    print_warning "Playwright installation failed - E2E tests may not work"
fi

# 3. Install Playwright system dependencies (Linux only)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    print_info "Installing Playwright system dependencies..."
    if npx playwright install-deps; then
        print_status "Playwright system dependencies installed"
    else
        print_warning "System dependencies installation failed"
    fi
fi

# 4. Check if Rails server is available
print_info "Checking Rails server..."
if curl -s "http://localhost:3000/health" > /dev/null 2>&1; then
    print_status "Rails server is running"
elif curl -s "http://localhost:3000" > /dev/null 2>&1; then
    print_status "Rails server is running (no health endpoint)"
else
    print_warning "Rails server not detected on port 3000"
    print_info "Start Rails server with: bundle exec rails server"
fi

# 5. Check if Svelte frontend is available
print_info "Checking Svelte frontend..."
if curl -s "http://localhost:5173" > /dev/null 2>&1; then
    print_status "Svelte frontend is running"
else
    print_warning "Svelte frontend not detected on port 5173"
    print_info "Start Svelte frontend with: cd frontend && npm run dev"
fi

# 6. Generate API tests from collection.json
print_info "Generating API tests from collection.json..."
if [ -f "../collection.json" ]; then
    if node api/generate_tests.js; then
        print_status "API tests generated successfully"
    else
        print_warning "API test generation failed"
    fi
else
    print_warning "collection.json not found in project root"
    print_info "Export your Postman collection to collection.json to enable API tests"
fi

# 7. Setup test database (if Rails is available)
print_info "Setting up test database..."
cd ..
if command -v bundle > /dev/null && [ -f "Gemfile" ]; then
    if RAILS_ENV=test bundle exec rails db:create db:migrate db:seed 2>/dev/null; then
        print_status "Test database setup completed"
    else
        print_warning "Test database setup failed or already exists"
    fi
else
    print_warning "Rails not available - skipping database setup"
fi
cd tests

# 8. Create reports directory
print_info "Creating reports directory..."
mkdir -p reports
print_status "Reports directory created"

# 9. Display setup summary
echo ""
echo "🎉 Setup Complete!"
echo "══════════════════"
echo ""
echo "Next steps:"
echo ""

if ! curl -s "http://localhost:3000" > /dev/null 2>&1; then
    echo "1. Start Rails server:"
    echo "   ${BLUE}bundle exec rails server${NC}"
    echo ""
fi

if ! curl -s "http://localhost:5173" > /dev/null 2>&1; then
    echo "2. Start Svelte frontend:"
    echo "   ${BLUE}cd frontend && npm run dev${NC}"
    echo ""
fi

echo "3. Run tests:"
echo "   ${GREEN}node test_router.js${NC}          # Interactive mode"
echo "   ${GREEN}npm run test:all${NC}            # Run all tests"
echo "   ${GREEN}npm run test:api${NC}            # Run API tests only"
echo "   ${GREEN}npm run test:e2e${NC}            # Run E2E tests only"
echo ""

echo "4. View test reports:"
echo "   ${BLUE}open reports/rspec_report.html${NC}         # Unit test results"
echo "   ${BLUE}open reports/e2e-html-report/index.html${NC} # E2E test results"
echo ""

print_status "Test Router is ready to use! 🚀"

# Optional: Run a quick smoke test
echo ""
read -p "Would you like to run a quick smoke test? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Running smoke test..."

    # Test the test router itself
    if node test_router.js --help > /dev/null 2>&1; then
        print_status "Test router is working correctly"
    else
        print_error "Test router has issues"
    fi

    # Test API connectivity if servers are running
    if curl -s "http://localhost:3000" > /dev/null 2>&1 && curl -s "http://localhost:5173" > /dev/null 2>&1; then
        print_info "Both servers are running - ready for full testing!"
    else
        print_warning "Start both servers to enable all test types"
    fi
fi

echo ""
print_status "Setup complete! Happy testing! 🧪"
