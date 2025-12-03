# 📱 Phone Mein VYAAS AI Kaise Kholein

## 🚀 Sabse Easy Method - Ngrok

### Step 1: Ngrok Install Karo
```bash
npm install -g ngrok
```

### Step 2: Ngrok Start Karo
```bash
ngrok http 3000
```

### Step 3: URL Copy Karo
Terminal mein ek URL dikhega jaise:
```
https://abc123-def456.ngrok-free.app
```

### Step 4: Phone Mein Kholo
- Wo URL phone browser mein paste karo
- Kahi se bhi access kar sakte ho!
- Internet se koi bhi access kar sakta hai (testing ke liye perfect)

---

## 🔧 Alternative: Firewall Fix (Manual)

### Windows Firewall Allow Karna:

1. **Windows Key + R** press karo
2. Type karo: `wf.msc` aur Enter
3. Left side mein "**Inbound Rules**" click karo
4. Right side mein "**New Rule**" click karo
5. "**Port**" select karo → Next
6. "**TCP**" select karo
7. "**Specific local ports**" mein type karo: `3000`
8. Next → "**Allow the connection**" → Next
9. **Domain, Private, Public** sab check karo → Next
10. Name: "Next.js Dev Server" → Finish

### Ab Phone Mein Try Karo:
```
http://YOUR_WIFI_IP:3000
```

---

## 💡 Quick Test

### Apna WiFi IP Nikalo:
```bash
ipconfig
```

"Wireless LAN adapter Wi-Fi" ke neeche "IPv4 Address" dekho.

### Phone Mein URL:
```
http://192.168.X.X:3000
```
(Apna actual IP use karo)

---

## ✅ Recommended: Ngrok Use Karo

Sabse easy aur reliable hai! 🚀
