# 🏥 Healthcare AI - Team Requirements & Setup

## 📋 System Requirements

### Minimum Hardware
- **RAM**: 8GB (16GB recommended for AI development)
- **Storage**: 10GB free space
- **CPU**: Dual-core 2.4GHz (Quad-core recommended)
- **Internet**: Stable connection for package downloads

### Operating System Support
- ✅ **Windows 10/11** (Primary development environment)
- ✅ **macOS 10.14+**
- ✅ **Linux Ubuntu 18.04+**

---

## 🛠 Required Software

### Core Development Tools
```bash
# 1. Flutter SDK (REQUIRED)
Version: 3.32.4+ (latest stable)
Download: https://flutter.dev/docs/get-started/install

# 2. Dart SDK (Included with Flutter)
Version: 3.8.1+

# 3. Git (REQUIRED)
Version: 2.30+
Download: https://git-scm.com/downloads

# 4. Node.js (REQUIRED for package management)
Version: 18.0+
Download: https://nodejs.org/
```

### Development Environment (Choose One)
```bash
# Recommended: VS Code
- Flutter extension
- Dart extension
- GitLens extension

# Alternative: Android Studio
- Flutter plugin
- Dart plugin
```

### Web Browser (REQUIRED)
- **Chrome**: Primary development browser
- **Edge**: Secondary testing (Windows)

---

## 📦 Project Dependencies

### Flutter Packages (Auto-installed)
```yaml
# Core Framework
flutter: sdk
cupertino_icons: ^1.0.8

# Navigation & State Management
go_router: ^14.8.1
flutter_riverpod: ^2.6.1

# Firebase & Backend
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.3

# HTTP & Utilities
http: ^1.2.2
uuid: ^4.5.1

# Development Tools
flutter_test: sdk
flutter_lints: ^6.0.0
```

### Firebase Services (Pre-configured)
- **Authentication**: User login/registration
- **Firestore**: Patient data storage (PIPEDA compliant)
- **Cloud Functions**: AI processing endpoints
- **Analytics**: Usage tracking

---

## ⚡ Quick Setup (5 Minutes)

### Step 1: Install Flutter
```bash
# Windows (using Git Bash or PowerShell)
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# macOS (using Homebrew)
brew install flutter

# Verify installation
flutter doctor
```

### Step 2: Clone & Setup Project
```bash
# Clone repository
git clone https://github.com/[your-username]/hackthebrain-2025-healthcare-ai.git
cd hackthebrain-2025-healthcare-ai

# Navigate to frontend (IMPORTANT!)
cd frontend

# Install dependencies
flutter pub get

# Verify setup
flutter analyze
```

### Step 3: Run Application
```bash
# Start development server
flutter run -d chrome --web-port 3000

# Expected result: Browser opens to Healthcare AI splash screen
# Terminal shows: ✅ Firebase initialized successfully
```

---

## 🎯 Development Environment Verification

### ✅ Success Checklist
Run these commands to verify your setup:

```bash
# Check Flutter installation
flutter doctor -v
# Should show: ✅ Flutter, ✅ Chrome, ✅ VS Code

# Check project dependencies
cd frontend && flutter pub deps
# Should show: All dependencies resolved

# Run tests
flutter test
# Should show: All tests passed!

# Launch app
flutter run -d chrome --web-port 3000
# Should show: Healthcare AI splash screen
```

### 🚨 Common Setup Issues

#### Issue: Flutter command not found
```bash
# Solution: Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
# Or restart terminal after installation
```

#### Issue: Chrome not detected
```bash
# Solution: Install Chrome or use different browser
flutter run -d edge  # Windows
flutter run -d safari  # macOS
```

#### Issue: pubspec.yaml not found
```bash
# Solution: Ensure you're in frontend directory
cd frontend
flutter pub get
```

---

## 🔧 IDE Configuration

### VS Code Setup (Recommended)
```json
// .vscode/settings.json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "editor.rulers": [80, 120],
  "editor.formatOnSave": true
}
```

### Recommended Extensions
- **Flutter**: Dart & Flutter support
- **GitLens**: Git integration
- **Error Lens**: Inline error display
- **Bracket Pair Colorizer**: Code readability

---

## 🏥 Healthcare-Specific Requirements

### Compliance & Security
```bash
# Environment Variables (DO NOT COMMIT)
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
GOOGLE_CLOUD_PROJECT=your_project

# Privacy Standards
PIPEDA_COMPLIANCE=enabled
PHIPA_COMPLIANCE=enabled
DATA_ENCRYPTION=AES256
```

### Medical Data Handling
- **Patient Data**: Encrypted at rest and in transit
- **Access Control**: Role-based permissions
- **Audit Logging**: All data access tracked
- **Data Retention**: Compliant with Canadian healthcare laws

---

## 🚀 Team Workflow

### Git Workflow
```bash
# Daily workflow
git pull origin main
git checkout -b feature/your-feature-name

# Make changes in frontend/ directory
cd frontend
flutter run -d chrome --web-port 3000

# Test and commit
flutter test
git add .
git commit -m "feat: add AI triage functionality"
git push origin feature/your-feature-name
```

### Feature Development Areas
1. **AI Triage** (`lib/features/triage/`) - Medical assessment algorithms
2. **Appointments** (`lib/features/appointments/`) - Smart scheduling
3. **Providers** (`lib/features/providers/`) - Healthcare directory
4. **Profile** (`lib/features/profile/`) - Patient data management

---

## 📊 Performance Requirements

### Target Metrics
- **Load Time**: < 3 seconds (first paint)
- **API Response**: < 500ms (triage assessment)
- **Memory Usage**: < 100MB (mobile)
- **Offline Support**: Core features available

### Browser Support
- **Chrome 90+**: Primary target
- **Safari 14+**: iOS compatibility
- **Edge 90+**: Windows compatibility
- **Firefox 88+**: Cross-platform testing

---

## 🆘 Getting Help

### Documentation Resources
- **Flutter Docs**: https://flutter.dev/docs
- **Firebase Setup**: https://firebase.google.com/docs/flutter
- **Project Wiki**: [GitHub Wiki Link]
- **API Documentation**: [API Docs Link]

### Team Support
- **Slack/Discord**: [Team Chat Link]
- **Code Reviews**: Required for all PRs
- **Daily Standups**: [Meeting Schedule]

---

## ✅ Final Verification

Before starting development, confirm all items:

- [ ] Flutter 3.32.4+ installed and in PATH
- [ ] Chrome browser available
- [ ] Project cloned and in `frontend/` directory
- [ ] `flutter pub get` completed successfully
- [ ] `flutter test` passes all tests
- [ ] App launches on `localhost:3000` with splash screen
- [ ] Firebase shows initialization success
- [ ] No critical errors in `flutter analyze`

**Setup Complete!** Ready to build AI that saves 1,500+ lives annually! 🏥🚀

---

*Healthcare AI Orchestration - Built for HackTheBrain 2025*
*Version: 0.3.0 - Production Ready* 