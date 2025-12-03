# 📱 Quick Start - Build Android App

## 🚀 Run These Commands

Open PowerShell and run these commands one by one:

### **1. Build Next.js App**
```powershell
cd c:\Users\mahes\OneDrive\Desktop\vyaasaiupdated\Frontend
pnpm build
```

### **2. Initialize Capacitor**
```powershell
npx cap init "VYAAS AI" "com.vyaasai.app" --web-dir=out
```

### **3. Add Android Platform**
```powershell
npx cap add android
```

### **4. Sync Assets**
```powershell
npx cap sync android
```

### **5. Open in Android Studio**
```powershell
npx cap open android
```

---

## 📱 In Android Studio

1. Wait for Gradle sync to complete
2. Click **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)**
3. Wait for build (2-5 minutes)
4. Click "locate" to find your APK
5. Copy APK to your phone and install!

---

## 🎯 APK Location

After building, your APK will be at:
```
Frontend\android\app\build\outputs\apk\debug\app-debug.apk
```

---

## 🔄 Update App After Changes

```powershell
cd c:\Users\mahes\OneDrive\Desktop\vyaasaiupdated\Frontend
pnpm build
npx cap sync android
# Then rebuild in Android Studio
```

---

## 📞 Need Help?

- See `SETUP_GUIDE.md` for detailed instructions
- Check troubleshooting section for common issues

**Let's build your Android app! 🚀**
