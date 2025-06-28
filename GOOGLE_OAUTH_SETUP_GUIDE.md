# Google OAuth Setup Guide for Healthcare AI App

## 🔐 Step 1: Google Cloud Console Setup

1. **Go to Google Cloud Console**: https://console.cloud.google.com/
2. **Create or Select Project**: 
   - Project name: `healthcare-ai-hackthebrain-2025`
3. **Enable APIs**:
   - Go to "APIs & Services" > "Library"
   - Enable: "Google+ API" and "Google Identity Services"

## 🔧 Step 2: Create OAuth 2.0 Credentials

1. **Navigate to Credentials**:
   - Go to "APIs & Services" > "Credentials"
   - Click "+ CREATE CREDENTIALS" > "OAuth 2.0 Client IDs"

2. **Configure OAuth Consent Screen** (if prompted):
   - User Type: "External"
   - App name: "Healthcare AI - HackTheBrain 2025"
   - User support email: your-email@domain.com
   - Developer contact: your-email@domain.com

3. **Create Web Application Credentials**:
   - Application type: "Web application"
   - Name: "Healthcare AI Web Client"

## 🌐 Step 3: Configure URIs

### **Authorized JavaScript Origins:**
```
http://localhost:64520
http://localhost:3000
http://127.0.0.1:64520
http://127.0.0.1:3000
https://your-production-domain.com
```

### **Authorized Redirect URIs:**
```
http://localhost:64520/
http://localhost:64520/__/auth/handler
http://localhost:3000/
http://localhost:3000/__/auth/handler
https://your-production-domain.com/__/auth/handler
```

## 📋 Step 4: Copy Credentials

After creating, you'll get:
- **Client ID**: `123456789-abcdef.apps.googleusercontent.com`
- **Client Secret**: `GOCSPX-xxxxxxxxxxxx` (keep this secure!)

## 🔄 Step 5: Update Your App

### Update `auth_provider.dart`:
```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: 'YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com',
  scopes: ['email', 'profile'],
);
```

### Update `web/index.html`:
```html
<meta name="google-signin-client_id" content="YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com">
```

## 🚀 Step 6: Test Configuration

1. Run your app: `flutter run --web-port=64520`
2. Try Google Sign-In
3. Should work without "invalid_client" error

## 🛡️ Security Notes

- **Never commit Client Secret** to version control
- **Use environment variables** for production
- **Verify domain ownership** for production URLs
- **Limit scopes** to only what you need

## 📱 For Mobile (Future):

### Android (`android/app/google-services.json`):
- Download from Firebase Console
- Place in `android/app/` directory

### iOS (`ios/Runner/GoogleService-Info.plist`):
- Download from Firebase Console  
- Add to iOS project in Xcode

## 🔍 Troubleshooting

### Common Issues:
1. **"invalid_client"**: Wrong Client ID or missing origins
2. **"redirect_uri_mismatch"**: Add exact URL to redirect URIs
3. **"access_blocked"**: Check OAuth consent screen configuration

### Testing URLs:
- Development: `http://localhost:64520`
- Alternative: `http://localhost:3000`
- Production: Your actual domain

## ✅ Verification Checklist

- [ ] Google Cloud project created
- [ ] OAuth 2.0 credentials generated
- [ ] JavaScript origins added
- [ ] Redirect URIs configured
- [ ] Client ID updated in code
- [ ] Firebase project linked (if using)
- [ ] Test sign-in successful

---

**Need Help?** 
- Check Google Cloud Console documentation
- Verify all URLs match exactly (no trailing slashes where not needed)
- Ensure OAuth consent screen is properly configured 