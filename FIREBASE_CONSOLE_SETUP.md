# 🔥 Firebase Console Setup Guide
## HackTheBrain 2025 - Healthcare AI System

### 📋 **Quick Access Links**
- **Firebase Console**: https://console.firebase.google.com/project/hackthebrain-healthcare-ai
- **Project Overview**: https://console.firebase.google.com/project/hackthebrain-healthcare-ai/overview
- **Authentication**: https://console.firebase.google.com/project/hackthebrain-healthcare-ai/authentication
- **Firestore**: https://console.firebase.google.com/project/hackthebrain-healthcare-ai/firestore
- **Storage**: https://console.firebase.google.com/project/hackthebrain-healthcare-ai/storage
- **Hosting**: https://console.firebase.google.com/project/hackthebrain-healthcare-ai/hosting

---

## 🚀 **Step 1: Authentication Setup**

### Enable Authentication:
1. Go to **Authentication** → **Get started**
2. Navigate to **Sign-in method** tab
3. Enable the following providers:

#### ✅ Email/Password:
- Click **Email/Password**
- Enable **Email/Password**
- Enable **Email link (passwordless sign-in)** (optional)
- Save

#### ✅ Google Sign-In:
- Click **Google**
- Enable **Google**
- Select your project support email
- Add **Web SDK configuration**:
  - Web Client ID: `881487619712-your-actual-client-id.apps.googleusercontent.com`
- Save

#### ✅ Anonymous:
- Click **Anonymous**
- Enable **Anonymous sign-in**
- Save

---

## 🗄️ **Step 2: Firestore Database Setup**

### Create Firestore Database:
1. Go to **Firestore Database**
2. Click **Create database**
3. **Security rules**: Start in **test mode** (secure later)
4. **Location**: Choose `us-central1` (recommended)
5. Click **Done**

### Set up Collections:
```
users/
├── {userId}/
│   ├── profile/
│   ├── appointments/
│   ├── triageHistory/
│   └── preferences/
│
healthcareFacilities/
├── {facilityId}/
│   ├── details/
│   ├── availability/
│   ├── services/
│   └── waitTimes/
│
appointments/
├── {appointmentId}/
│   ├── patientId
│   ├── facilityId
│   ├── datetime
│   ├── status
│   └── triageData/
```

---

## 💾 **Step 3: Cloud Storage Setup**

### Enable Storage:
1. Go to **Storage**
2. Click **Get started**
3. **Security rules**: Start in **test mode**
4. **Location**: Use same as Firestore (`us-central1`)
5. Click **Done**

### Create Storage Structure:
```
storage/
├── profile-images/
├── medical-documents/
├── facility-images/
└── system-assets/
```

---

## 🌐 **Step 4: Hosting Setup**

### Enable Web Hosting:
1. Go to **Hosting**
2. Click **Get started**
3. **Hosting setup** is already configured via `firebase.json`
4. Your hosting URL: `https://hackthebrain-healthcare-ai.web.app`

---

## 🔑 **Step 5: Google Cloud Console Setup**

### OAuth 2.0 Configuration:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project **hackthebrain-healthcare-ai**
3. Navigate to **APIs & Services** → **Credentials**

#### Create OAuth 2.0 Client ID:
- **Application type**: Web application
- **Name**: Healthcare AI Web Client
- **Authorized JavaScript origins**:
  - `http://localhost:52840` (development)
  - `https://hackthebrain-healthcare-ai.web.app` (production)
- **Authorized redirect URIs**:
  - `http://localhost:52840/__/auth/handler` (development)
  - `https://hackthebrain-healthcare-ai.web.app/__/auth/handler` (production)

---

## 🛡️ **Step 6: Security Rules Setup**

### Firestore Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Healthcare facilities are publicly readable
    match /healthcareFacilities/{facilityId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Appointments are user-specific
    match /appointments/{appointmentId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.patientId;
    }
  }
}
```

### Storage Security Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images
    match /profile-images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Medical documents
    match /medical-documents/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public facility images
    match /facility-images/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 🔧 **Step 7: API Keys & Services**

### Enable Required APIs:
1. Go to **APIs & Services** → **Library**
2. Enable the following APIs:
   - **Firebase Authentication API**
   - **Cloud Firestore API**
   - **Firebase Storage API**
   - **Firebase Hosting API**
   - **Google Maps JavaScript API**
   - **Google Places API Web Service**
   - **Google Geocoding API**

---

## 📊 **Step 8: Analytics Setup**

### Enable Google Analytics:
1. Go to **Project Settings** → **Integrations**
2. Click **Google Analytics** → **Enable**
3. Create new Analytics account or link existing
4. **Property name**: Healthcare AI Analytics
5. **Reporting location**: Your location

---

## 🎯 **Step 9: Performance Monitoring**

### Enable Performance Monitoring:
1. Go to **Performance** (left sidebar)
2. Click **Get started**
3. Performance monitoring will track:
   - Web page load times
   - Network request performance
   - User interaction delays

---

## 📱 **Step 10: App Configuration Updates**

### Update Configuration Files:

#### Update `firebase_options.dart`:
```dart
// Update the web configuration with actual values
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyA9DUm_aNpEyuFDVuaEC8i82J9l1BmW2KU',
  appId: '1:881487619712:web:e581a828fdca49952d6865',
  messagingSenderId: '881487619712',
  projectId: 'hackthebrain-healthcare-ai',
  authDomain: 'hackthebrain-healthcare-ai.firebaseapp.com',
  databaseURL: 'https://hackthebrain-healthcare-ai-default-rtdb.firebaseio.com',
  storageBucket: 'hackthebrain-healthcare-ai.firebasestorage.app',
  measurementId: 'G-ACTUAL_MEASUREMENT_ID', // Update this
);
```

#### Update `web/index.html`:
```html
<meta name="google-signin-client_id" content="881487619712-YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com">
```

---

## ✅ **Step 11: Testing & Verification**

### Test Firebase Services:
1. **Authentication**: Test Google Sign-In and Email/Password
2. **Firestore**: Verify data read/write operations
3. **Storage**: Test file upload/download
4. **Hosting**: Deploy and test live site

### Verification Commands:
```bash
# Test Firebase CLI connection
firebase projects:list

# Test hosting deployment
firebase deploy --only hosting

# Test Firestore rules
firebase firestore:rules:list
```

---

## 🚨 **Important Notes**

### Security Checklist:
- [ ] Update measurement ID in firebase_options.dart
- [ ] Configure actual OAuth client ID
- [ ] Set up proper Firestore security rules
- [ ] Configure Storage security rules
- [ ] Enable only necessary APIs
- [ ] Set up proper CORS for web app

### Production Readiness:
- [ ] Change Firestore to production mode
- [ ] Update security rules
- [ ] Configure proper domains
- [ ] Set up monitoring alerts
- [ ] Test all authentication flows

---

## 📞 **Support & Resources**

- **Firebase Documentation**: https://firebase.google.com/docs
- **Flutter Firebase**: https://firebase.flutter.dev/
- **Google Cloud Console**: https://console.cloud.google.com/
- **Firebase Status**: https://status.firebase.google.com/

---

**🏆 Project**: HackTheBrain 2025 - Healthcare AI  
**🔥 Firebase Project**: hackthebrain-healthcare-ai  
**🌐 Web App**: https://hackthebrain-healthcare-ai.web.app