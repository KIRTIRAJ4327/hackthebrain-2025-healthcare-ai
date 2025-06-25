#!/bin/bash

# 🏥 Healthcare AI - Team Setup Verification Script
# Run this script to verify your development environment is ready

echo "🏥 Healthcare AI Orchestration - Setup Verification"
echo "=================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check functions
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✅ $1 is installed${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 is not installed${NC}"
        return 1
    fi
}

check_flutter_version() {
    if command -v flutter &> /dev/null; then
        version=$(flutter --version | head -n 1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
        echo -e "${GREEN}✅ Flutter version: $version${NC}"
        
        # Check if version is >= 3.32.4
        if [[ "$(printf '%s\n' "3.32.4" "$version" | sort -V | head -n1)" = "3.32.4" ]]; then
            echo -e "${GREEN}✅ Flutter version is compatible${NC}"
        else
            echo -e "${YELLOW}⚠️  Flutter version may be outdated (recommended: 3.32.4+)${NC}"
        fi
    else
        echo -e "${RED}❌ Flutter not found${NC}"
        return 1
    fi
}

check_directory() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✅ Directory $1 exists${NC}"
        return 0
    else
        echo -e "${RED}❌ Directory $1 not found${NC}"
        return 1
    fi
}

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✅ File $1 exists${NC}"
        return 0
    else
        echo -e "${RED}❌ File $1 not found${NC}"
        return 1
    fi
}

echo -e "${BLUE}🔍 Checking required software...${NC}"
echo ""

# Check required software
all_good=true

check_command "flutter" || all_good=false
check_command "dart" || all_good=false
check_command "git" || all_good=false
check_command "chrome" || check_command "google-chrome" || all_good=false

echo ""
echo -e "${BLUE}🔍 Checking Flutter installation details...${NC}"
echo ""

check_flutter_version

# Run flutter doctor
echo ""
echo -e "${BLUE}🔍 Running Flutter doctor...${NC}"
echo ""
flutter doctor

echo ""
echo -e "${BLUE}🔍 Checking project structure...${NC}"
echo ""

# Check if we're in the right directory
if [ -f "pubspec.yaml" ]; then
    echo -e "${GREEN}✅ Found pubspec.yaml - you're in the Flutter project directory${NC}"
    
    # Check specific project files
    check_file "lib/main.dart"
    check_file "lib/core/theme/app_theme.dart"
    check_file "lib/core/routing/app_router.dart"
    check_directory "lib/features"
    
elif [ -d "frontend" ]; then
    echo -e "${YELLOW}⚠️  You're in the root directory. Checking frontend/...${NC}"
    cd frontend
    
    if [ -f "pubspec.yaml" ]; then
        echo -e "${GREEN}✅ Found frontend/pubspec.yaml${NC}"
        check_file "lib/main.dart"
        check_file "lib/core/theme/app_theme.dart"
    else
        echo -e "${RED}❌ frontend/pubspec.yaml not found${NC}"
        all_good=false
    fi
else
    echo -e "${RED}❌ Neither pubspec.yaml nor frontend/ directory found${NC}"
    echo -e "${YELLOW}Make sure you're in the project root or frontend/ directory${NC}"
    all_good=false
fi

echo ""
echo -e "${BLUE}🔍 Testing Flutter dependencies...${NC}"
echo ""

# Test pub get
if flutter pub get; then
    echo -e "${GREEN}✅ Dependencies installed successfully${NC}"
else
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    all_good=false
fi

echo ""
echo -e "${BLUE}🔍 Running tests...${NC}"
echo ""

# Run tests
if flutter test; then
    echo -e "${GREEN}✅ All tests passed${NC}"
else
    echo -e "${RED}❌ Some tests failed${NC}"
    all_good=false
fi

echo ""
echo -e "${BLUE}🔍 Checking for common issues...${NC}"
echo ""

# Check for common issues
if [ -d ".dart_tool" ]; then
    echo -e "${GREEN}✅ .dart_tool directory exists${NC}"
else
    echo -e "${YELLOW}⚠️  .dart_tool directory not found (run 'flutter pub get')${NC}"
fi

if [ -f ".packages" ]; then
    echo -e "${GREEN}✅ .packages file exists${NC}"
else
    echo -e "${YELLOW}⚠️  .packages file not found (run 'flutter pub get')${NC}"
fi

# Final summary
echo ""
echo "=================================================="
if [ "$all_good" = true ]; then
    echo -e "${GREEN}🎉 SETUP VERIFICATION COMPLETE!${NC}"
    echo -e "${GREEN}✅ Your environment is ready for Healthcare AI development${NC}"
    echo ""
    echo -e "${BLUE}🚀 Next steps:${NC}"
    echo "1. Run: flutter run -d chrome --web-port 3000"
    echo "2. Open browser to: http://localhost:3000"
    echo "3. Look for: Healthcare AI splash screen"
    echo "4. Check terminal for: ✅ Firebase initialized successfully"
    echo ""
    echo -e "${GREEN}Ready to save 1,500+ lives annually! 🏥${NC}"
else
    echo -e "${RED}❌ SETUP ISSUES DETECTED${NC}"
    echo -e "${YELLOW}Please fix the issues above before starting development${NC}"
    echo ""
    echo -e "${BLUE}📚 Need help?${NC}"
    echo "- Check TEAM_SETUP.md for detailed instructions"
    echo "- Check REQUIREMENTS.md for system requirements"
    echo "- Ask team members for assistance"
fi

echo "==================================================" 