# 🚀 Complete Android App Setup Guide

## 📋 Prerequisites

Before starting, make sure you have:
- ✅ Android Studio installed
- ✅ Node.js & pnpm installed
- ✅ Your VYAAS AI project working

---

## 🎯 Step-by-Step Setup

### **STEP 1: Install Capacitor** ✅ DONE

Capacitor packages have been installed in your Frontend folder:
- `@capacitor/core`
- `@capacitor/cli`
- `@capacitor/android`

### **STEP 2: Configure Next.js** ✅ DONE

Your `Frontend/next.config.js` has been updated with:
- `output: 'export'` - Enables static export
- `images: { unoptimized: true }` - Required for static builds

### **STEP 3: Build Next.js App**

```bash
cd c:\Users\mahes\OneDrive\Desktop\vyaasaiupdated\Frontend
pnpm build
```

This creates the `out` folder with your static website.

### **STEP 4: Initialize Capacitor**

```bash
npx cap init "VYAAS AI" "com.vyaasai.app" --web-dir=out
```

This creates `capacitor.config.ts` in your Frontend folder.

### **STEP 5: Add Android Platform**

```bash
npx cap add android
```

This creates the `android` folder inside `Frontend/`.

### **STEP 6: Sync Web Assets to Android**

```bash
npx cap sync android
```

This copies your built website to the Android project.

### **STEP 7: Open in Android Studio**

```bash
npx cap open android
```

Android Studio will open with your project.

---

## 🔧 Android Studio Configuration

### **1. Update App Name**

File: `Frontend/android/app/src/main/res/values/strings.xml`

```xml
<resources>
    <string name="app_name">VYAAS AI</string>
    <string name="title_activity_main">VYAAS AI</string>
    <string name="package_name">com.vyaasai.app</string>
</resources>
```

### **2. Set App Icon**

1. Right-click `app` folder → New → Image Asset
2. Choose your logo image
3. Generate icons for all sizes
4. Icons will be placed in `mipmap-*` folders

### **3. Configure Permissions**

File: `Frontend/android/app/src/main/AndroidManifest.xml`

Add these permissions inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

### **4. Update Package Name (Optional)**

File: `Frontend/android/app/build.gradle`

```gradle
android {
    namespace "com.vyaasai.app"
    defaultConfig {
        applicationId "com.vyaasai.app"
        // ... other settings
    }
}
```

---

## 📱 Building APK

### **Debug APK (For Testing)**

**Option A: Using Android Studio**
1. Click **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)**
2. Wait for build to complete
3. Click "locate" to find APK

**Option B: Command Line**
```bash
cd Frontend/android
./gradlew assembleDebug
```

APK Location: `Frontend/android/app/build/outputs/apk/debug/app-debug.apk`

### **Release APK (For Publishing)**

```bash
cd Frontend/android
./gradlew bundleRelease
```

AAB Location: `Frontend/android/app/build/outputs/bundle/release/app-release.aab`

---

## 🧪 Testing Your App

### **On Emulator**

1. In Android Studio: **Tools** → **Device Manager**
2. Create Virtual Device (Pixel 5, Android 13)
3. Click **Run** (green play button)

### **On Real Device**

1. Enable Developer Options on your phone:
   - Settings → About Phone
   - Tap "Build Number" 7 times
2. Enable USB Debugging:
   - Settings → Developer Options → USB Debugging ON
3. Connect phone via USB
4. Click **Run** in Android Studio

### **Manual APK Install**

1. Copy `app-debug.apk` to your phone
2. Open the APK file
3. Allow "Install from Unknown Sources"
4. Install!

---

## 🔄 Updating Your App

When you make changes to your Next.js code:

```bash
# 1. Navigate to Frontend
cd c:\Users\mahes\OneDrive\Desktop\vyaasaiupdated\Frontend

# 2. Build Next.js
pnpm build

# 3. Sync to Android
npx cap sync android

# 4. Rebuild in Android Studio
# Click Build → Rebuild Project
```

---

## 🎨 Customization

### **App Colors**

File: `Frontend/android/app/src/main/res/values/colors.xml`

```xml
<resources>
    <color name="colorPrimary">#7e22ce</color>
    <color name="colorPrimaryDark">#5b21b6</color>
    <color name="colorAccent">#8b5cf6</color>
</resources>
```

### **Splash Screen**

1. Create `splash.png` (2732x2732 px)
2. Place in `Frontend/android/app/src/main/res/drawable/`
3. Update `capacitor.config.json` (already configured!)

### **App Theme**

File: `Frontend/android/app/src/main/res/values/styles.xml`

```xml
<style name="AppTheme" parent="Theme.AppCompat.DayNight.DarkActionBar">
    <item name="colorPrimary">@color/colorPrimary</item>
    <item name="colorPrimaryDark">@color/colorPrimaryDark</item>
    <item name="colorAccent">@color/colorAccent</item>
</style>
```

---

## 🐛 Troubleshooting

### **Build Failed**

```bash
# Clean build
cd Frontend/android
./gradlew clean
./gradlew assembleDebug
```

### **"Cleartext HTTP traffic not permitted"**

Add to `AndroidManifest.xml`:
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

### **Firebase Auth Not Working**

1. Go to Firebase Console
2. Add Android app
3. Download `google-services.json`
4. Place in `Frontend/android/app/`

### **LiveKit Connection Issues**

- Ensure LiveKit URL is HTTPS
- Check network permissions in manifest
- Test on real device (emulator may have network issues)

---

## 🚀 Publishing to Play Store

### **1. Create Signing Key**

```bash
keytool -genkey -v -keystore vyaas-release-key.keystore -alias vyaas -keyalg RSA -keysize 2048 -validity 10000
```

### **2. Configure Signing**

Create `Frontend/android/key.properties`:
```
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=vyaas
storeFile=../vyaas-release-key.keystore
```

Update `Frontend/android/app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### **3. Build Release**

```bash
cd Frontend/android
./gradlew bundleRelease
```

### **4. Upload to Play Console**

1. Go to https://play.google.com/console
2. Create new app
3. Upload AAB from `Frontend/android/app/build/outputs/bundle/release/`
4. Fill in app details
5. Submit for review!

---

## 📁 File Structure After Setup

```
vyaasaiupdated/
├── Android/
│   ├── README.md
│   ├── SETUP_GUIDE.md (this file)
│   └── capacitor.config.json
│
└── Frontend/
    ├── android/                    ← Android project (created by Capacitor)
    │   ├── app/
    │   │   ├── src/
    │   │   │   └── main/
    │   │   │       ├── AndroidManifest.xml
    │   │   │       ├── res/
    │   │   │       └── java/
    │   │   └── build.gradle
    │   ├── gradle/
    │   └── build.gradle
    │
    ├── out/                        ← Built Next.js app
    ├── capacitor.config.ts         ← Capacitor config (auto-generated)
    └── (rest of Next.js files)
```

---

## ✅ Quick Command Reference

```bash
# Build Next.js
cd Frontend
pnpm build

# Sync to Android
npx cap sync android

# Open Android Studio
npx cap open android

# Build Debug APK
cd Frontend/android
./gradlew assembleDebug

# Build Release AAB
./gradlew bundleRelease
```

---

## 📞 Next Steps

1. ✅ Capacitor installed
2. ✅ Next.js configured for export
3. ⏳ Run `pnpm build` in Frontend folder
4. ⏳ Run `npx cap init` to initialize
5. ⏳ Run `npx cap add android` to create Android project
6. ⏳ Open in Android Studio
7. ⏳ Build APK
8. ⏳ Test on device

**Ready to proceed? Run the commands in Step 3!** 🚀
