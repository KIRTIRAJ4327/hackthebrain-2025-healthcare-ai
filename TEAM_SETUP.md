# Team Setup Instructions - HackTheBrain 2025 Healthcare AI

## 🎯 Quick Start for Team Members

### Prerequisites
- **Node.js:** 18+ [Download](https://nodejs.org/)
- **Flutter:** 3.32.4+ [Install Guide](https://docs.flutter.dev/get-started/install)
- **Git:** Latest version
- **Chrome Browser:** For testing Flutter web apps
- **Code Editor:** VS Code recommended with Flutter extension

### 1. Clone Repository
```bash
git clone https://github.com/your-username/hackthebrain-2025-healthcare-ai.git
cd hackthebrain-2025-healthcare-ai
```

### 2. Verify Flutter Installation
```bash
flutter --version
# Should show: Flutter 3.32.4 or higher
# Should show: Dart 3.8.1 or higher

flutter doctor
# Fix any issues shown (Android/Visual Studio warnings are OK for web development)
```

### 3. Install Dependencies
```bash
# Install Flutter dependencies
cd frontend
flutter pub get

# Install Backend dependencies (if working on backend)
cd ../backend
npm install

# Install AI service dependencies (if working on AI features)
cd ../ai-service
pip install -r requirements.txt
```

### 4. Environment Setup
```bash
# Copy environment template
cp .env.example .env

# Ask team lead for API keys and fill in .env file with:
# - Google Cloud API keys
# - Firebase configuration
# - Any other required credentials
```

### 5. Verify Setup Works
```bash
# Test Flutter web app
cd frontend
flutter run -d chrome --web-port 3000

# Should open Chrome with working Healthcare AI app
# If successful, you're ready to develop!
```

### 6. Development Workflow
```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and test locally
flutter run -d chrome

# Commit and push changes
git add .
git commit -m "feat: add your feature description"
git push origin feature/your-feature-name

# Create pull request on GitHub for code review
```

## 🚨 Common Issues & Solutions

### Issue: Flutter version too old
```bash
flutter upgrade
flutter --version
```

### Issue: Dependencies conflicts
```bash
cd frontend
flutter clean
flutter pub get
```

### Issue: Chrome not launching
```bash
flutter devices
# Make sure Chrome is listed as available device
```

### Issue: Permission errors on Windows
```bash
# Run PowerShell as Administrator if needed
# Use semicolons instead of && in PowerShell:
cd frontend; flutter pub get
```

### Issue: Missing API keys
```bash
# Contact team lead for .env file with proper API keys
# Never commit API keys to Git repository
```

## 🔧 Platform-Specific Notes

### Windows (PowerShell)
- Use semicolons `;` instead of `&&` for command chaining
- Example: `cd frontend; flutter run -d chrome`
- Run as Administrator if permission issues occur

### macOS/Linux (Bash/Zsh)
- Use `&&` for command chaining normally
- Example: `cd frontend && flutter run -d chrome`
- Use `chmod +x scripts/*.sh` for script permissions

## 🏗️ Project Structure
```
hackthebrain-2025-healthcare-ai/
├── frontend/          # Flutter web app (main development area)
├── backend/           # Node.js API server
├── ai-service/        # Python AI/ML services
├── docs/              # Project documentation
├── scripts/           # Build and deployment scripts
├── database/          # Database schemas and migrations
├── infrastructure/    # Cloud infrastructure configuration
└── credentials/       # API keys and certificates (not in Git)
```

## 🎯 Feature Development Areas

### Frontend (Flutter Web)
- **Triage Interface:** AI-powered medical assessment
- **Appointment Booking:** Real-time scheduling
- **Provider Network:** Healthcare facility management
- **Patient Dashboard:** User experience and data visualization

### Backend (Node.js)
- **API Endpoints:** RESTful services for frontend
- **Database Integration:** Firebase Firestore operations
- **Authentication:** User and provider login/security
- **Real-time Updates:** WebSocket connections

### AI Service (Python)
- **Gemini Integration:** Google AI for medical triage
- **Predictive Analytics:** Wait time and capacity optimization
- **Natural Language:** Medical symptom processing
- **Risk Assessment:** CTAS protocol implementation

## 🏆 Ready to Code!

Once these steps work without errors, you're ready to contribute to our healthcare AI system that aims to:

- **Reduce wait times** from 30 weeks to 12-18 weeks
- **Save 1,500+ lives** annually through better triage
- **Save $170M+** in healthcare costs
- **Win HackTheBrain 2025** with innovative technology

## 📞 Getting Help

### Team Communication
- **Slack/Discord:** [Add your team chat link]
- **GitHub Issues:** For bugs and feature requests
- **Team Lead:** [Add contact information]
- **Daily Standups:** [Add meeting schedule]

### Technical Support
- **Flutter Issues:** Check [Flutter documentation](https://docs.flutter.dev/)
- **Firebase Help:** See [Firebase docs](https://firebase.google.com/docs)
- **Google Cloud:** Visit [GCP documentation](https://cloud.google.com/docs)

## 🚀 Let's Build Something Amazing!

Our Healthcare AI platform will revolutionize Canadian healthcare delivery. Every line of code you write brings us closer to saving lives and improving healthcare for millions of people.

**Ready to make an impact? Start coding! 🏥💡** 