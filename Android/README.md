# 📱 VYAAS AI - Android App Setup

## 📂 This Folder Contains

This `Android` folder will contain your Android app project built with Capacitor.

## 🎯 What is Capacitor?

Capacitor wraps your Next.js web app into a native Android container, allowing you to:
- ✅ Publish to Google Play Store
- ✅ Access native Android features
- ✅ Use your existing web code (no rewrite!)

## 📋 Setup Process

Follow these steps to build your Android app:

### **Step 1: Install Capacitor Dependencies**

```bash
cd c:\Users\mahes\OneDrive\Desktop\vyaasaiupdated\Frontend
pnpm add @capacitor/core @capacitor/cli @capacitor/android
```

### **Step 2: Configure Next.js for Static Export**

Update `Frontend/next.config.js` to enable static export (required for Capacitor).

### **Step 3: Initialize Capacitor**

```bash
cd c:\Users\mahes\OneDrive\Desktop\vyaasaiupdated\Frontend
npx cap init
```

When prompted:
- **App name**: `VYAAS AI`
- **App ID**: `com.vyaasai.app`
- **Web directory**: `out`

### **Step 4: Build Next.js App**

```bash
pnpm build
```

### **Step 5: Add Android Platform**

```bash
npx cap add android
```

This creates the Android project in `Frontend/android/`

### **Step 6: Sync Assets**

```bash
npx cap sync android
```

### **Step 7: Open in Android Studio**

```bash
npx cap open android
```

### **Step 8: Build APK**

In Android Studio:
1. Click **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)**
2. Wait for build to complete
3. APK location: `Frontend/android/app/build/outputs/apk/debug/app-debug.apk`

## 📁 Folder Structure (After Setup)

```
Android/
├── README.md                    ← This file
├── SETUP_GUIDE.md              ← Detailed setup instructions
├── capacitor.config.json       ← Capacitor configuration
└── (Android project files will be in Frontend/android/)
```

## 🚀 Quick Commands

```bash
# Build web app
cd ../Frontend
pnpm build

# Sync to Android
npx cap sync android

# Open Android Studio
npx cap open android
```

## 📞 Need Help?

Refer to:
- `SETUP_GUIDE.md` - Detailed step-by-step instructions
- `../INSTALLATION_GUIDE.md` - General installation guide
- Capacitor docs: https://capacitorjs.com/docs/android

---

**Status**: 🟡 Setup in progress...
