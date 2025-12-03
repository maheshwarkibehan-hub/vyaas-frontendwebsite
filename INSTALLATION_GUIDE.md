# 🚀 VYAAS AI - Installation Guide
**Version 2.2 Setup Instructions**

---

## 📋 Prerequisites (ज़रूरी चीज़ें)

Before starting, make sure you have these installed:

### For Frontend:
- ✅ **Node.js** (v18 or higher) - [Download here](https://nodejs.org/)
- ✅ **pnpm** - Install with: `npm install -g pnpm`
- ✅ **Git** (optional) - [Download here](https://git-scm.com/)

### For Backend:
- ✅ **Python** (v3.10 or higher) - [Download here](https://www.python.org/)
- ✅ **pip** (comes with Python)

### For Database:
- ✅ **Supabase Account** - [Sign up free](https://supabase.com/)

---

## 📂 Folder Structure Overview

```
vyaasaiupdated/
├── Frontend/          (Next.js React App)
├── Backend/           (Python AI Agent - Jarvis)
├── Database/          (SQL Schema Files)
└── PATCH_NOTES.html   (Update Details)
```

---

## 🎯 Step-by-Step Installation

### **STEP 1: Database Setup (सबसे पहले Database)**

#### 1.1 Create Supabase Project
1. Go to [supabase.com](https://supabase.com/) and sign in
2. Click **"New Project"**
3. Enter project name: `vyaas-ai`
4. Choose a strong password
5. Select region (closest to you)
6. Click **"Create new project"**

#### 1.2 Run SQL Scripts
1. In your Supabase dashboard, go to **SQL Editor** (left sidebar)
2. Click **"New Query"**
3. Open `Database/COMPLETE_DATABASE_SCHEMA.sql` from the folder
4. Copy ALL the content
5. Paste it in the SQL Editor
6. Click **"Run"** (or press Ctrl+Enter)
7. Wait for success message ✅

8. Repeat for `Database/ANALYTICS_SCHEMA.sql`
9. Repeat for `Database/FIX_TIME_SYNC.sql`

#### 1.3 Get Your Supabase Keys
1. Go to **Settings** → **API** in Supabase
2. Copy these values (you'll need them later):
   - `Project URL` (looks like: https://xxxxx.supabase.co)
   - `anon public` key (long string starting with "eyJ...")

---

### **STEP 2: Frontend Setup (React App)**

#### 2.1 Navigate to Frontend Folder
```bash
cd vyaasaiupdated/Frontend
```

#### 2.2 Install Dependencies
```bash
pnpm install
```
*This will take 2-3 minutes. Wait for it to complete.*

#### 2.3 Configure Environment Variables
1. Create a new file named `.env.local` in the `Frontend` folder
2. Copy this template and fill in your values:

```env
# Firebase Configuration
NEXT_PUBLIC_FIREBASE_API_KEY=your_firebase_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456789
NEXT_PUBLIC_FIREBASE_APP_ID=1:123456789:web:abcdef

# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Google Gemini API
NEXT_PUBLIC_GEMINI_API_KEY=AIzaSy...

# Email Configuration (for notifications)
GMAIL_USER=your-email@gmail.com
GMAIL_APP_PASSWORD=your_16_char_app_password
```

**How to get Firebase keys:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing
3. Go to Project Settings → General
4. Scroll to "Your apps" → Web app
5. Copy the config values

**How to get Gemini API key:**
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Click "Create API Key"
3. Copy the key

#### 2.4 Run the Frontend
```bash
pnpm dev
```

✅ **Success!** Open your browser and go to: `http://localhost:3000`

---

### **STEP 3: Backend Setup (Jarvis AI Agent)**

#### 3.1 Navigate to Backend Folder
```bash
cd vyaasaiupdated/Backend
```

#### 3.2 Create Virtual Environment (Recommended)
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Mac/Linux
python3 -m venv venv
source venv/bin/activate
```

#### 3.3 Install Python Dependencies
```bash
pip install -r requirements.txt
```
*This might take 5-10 minutes depending on your internet speed.*

#### 3.4 Configure Backend Environment
1. Create a file named `.env` in the `Backend` folder
2. Add your API keys:

```env
GOOGLE_API_KEY=AIzaSy...
LIVEKIT_URL=wss://your-livekit-server.com
LIVEKIT_API_KEY=your_livekit_key
LIVEKIT_API_SECRET=your_livekit_secret
```

#### 3.5 Run the Backend
```bash
python agent.py
```

✅ **Success!** The Jarvis AI agent is now running!

---

## 🔧 Troubleshooting (समस्या हल करें)

### Frontend Issues:

**Error: "Module not found"**
```bash
# Delete node_modules and reinstall
rm -rf node_modules
pnpm install
```

**Error: "Port 3000 already in use"**
```bash
# Kill the process on port 3000
# Windows:
netstat -ano | findstr :3000
taskkill /PID <PID_NUMBER> /F

# Mac/Linux:
lsof -ti:3000 | xargs kill
```

**Error: "Environment variables not found"**
- Make sure `.env.local` file exists in `Frontend` folder
- Check that all keys are filled in correctly
- Restart the dev server after adding env variables

### Backend Issues:

**Error: "No module named 'xyz'"**
```bash
# Make sure virtual environment is activated
# Then reinstall requirements
pip install -r requirements.txt --force-reinstall
```

**Error: "API key invalid"**
- Check your `.env` file in Backend folder
- Make sure API keys are correct and active
- No spaces around the `=` sign

### Database Issues:

**Error: "relation does not exist"**
- Make sure you ran ALL SQL scripts in order:
  1. COMPLETE_DATABASE_SCHEMA.sql
  2. ANALYTICS_SCHEMA.sql
  3. FIX_TIME_SYNC.sql

**Error: "permission denied"**
- Check RLS (Row Level Security) policies
- Make sure you're using the correct Supabase keys

---

## ✅ Verification Checklist

After installation, verify everything works:

### Frontend:
- [ ] Can open `http://localhost:3000`
- [ ] Can see the welcome page
- [ ] Can sign in with Google
- [ ] Admin dashboard loads (if you're admin)

### Backend:
- [ ] Python script runs without errors
- [ ] Can see "Agent started" message
- [ ] No API key errors in console

### Database:
- [ ] All tables visible in Supabase dashboard
- [ ] Can see: users, transactions, user_sessions, etc.
- [ ] RLS policies are enabled

---

## 🎉 You're All Set!

Your VYAAS AI installation is complete! Here's what you can do now:

1. **Test the Admin Dashboard:** Go to `/admin` (only works for admin email)
2. **Check Analytics:** Click "View Analytics" in admin panel
3. **Test User Features:** Create a test account and try the features

---

## 📞 Need Help?

If you face any issues:
1. Check the error message carefully
2. Look in the Troubleshooting section above
3. Make sure all prerequisites are installed
4. Verify all environment variables are set correctly

---

## 🔄 Updating the Application

To update to a newer version:
1. Backup your `.env.local` and `.env` files
2. Replace the Frontend/Backend folders with new versions
3. Restore your environment files
4. Run `pnpm install` in Frontend
5. Run `pip install -r requirements.txt` in Backend
6. Run any new SQL migration scripts

---

**Built with ❤️ by Maheshwar**
© 2025 VYAAS AI. All rights reserved.
