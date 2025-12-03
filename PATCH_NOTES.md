# VYAAS AI - Patch Notes & Update Summary
**Date:** November 23, 2025
**Version:** 2.2 (Complete System Update)

This folder contains the complete source code for VYAAS AI, organized into Frontend, Backend, and Database components.

## 📂 Folder Structure

### 1. `Frontend/` (Next.js Application)
The user interface and client-side logic.
- **`app/`**: Next.js App Router pages (Admin, Dashboard, etc.).
- **`components/`**: React components (SessionGuard, WelcomeView, etc.).
- **`lib/`**: Integration logic (Supabase, Firebase, Rewards).
- **Config**: `package.json`, `tsconfig.json`, etc.

### 2. `Backend/` (Jarvis AI Agent)
The Python-based AI agent logic (LiveKit/Gemini).
- **`Jarvis_code/`**: Contains the Python scripts for the voice/chat agent.
- **`agent.py`**: Main entry point for the AI agent.
- **`requirements.txt`**: Python dependencies.

### 3. `Database/` (SQL Schemas)
SQL scripts to set up the Supabase infrastructure.
- **`COMPLETE_DATABASE_SCHEMA.sql`**: Full database setup.
- **`ANALYTICS_SCHEMA.sql`**: Schema for Analytics & Earnings.
- **`FIX_TIME_SYNC.sql`**: Security fix for session management.

---

## 🚀 Key Features in This Update

### 1. Analytics & Earnings Dashboard
- **New Page:** `/admin/analytics`
- **Features:**
    - **Revenue Tracking:** Real-time display of Total, Monthly, and Daily earnings.
    - **Transaction History:** Detailed table of all user purchases and credit top-ups.
    - **Visuals:** Beautiful charts and summary cards for quick insights.
- **Integration:** Accessible via a new "View Analytics" button on the main Admin Dashboard.

### 2. Enhanced Admin Dashboard
- **Price Display Fix:** Corrected the logic that was showing "1000 Rupees" for the Ultra plan. It now correctly displays **₹299**.
- **Manual Top-up Tracking:** Admin manual credit additions are now recorded as transactions, so they show up in your revenue reports (marked as "manual_admin").
- **Force Logout:** Admins can now force-logout users from all devices.

### 3. Robust Session Security
- **Server-Side Time Sync:** Fixed an issue where users could bypass logout by changing their device time. The system now uses server-side timestamps for 100% reliable session invalidation.
- **Session Guard:** A new `SessionGuard` component protects the entire application, ensuring banned or logged-out users are immediately removed.

## 📝 How to Run

### Frontend
1.  Open `Frontend` folder in VS Code.
2.  Run `pnpm install` -> `pnpm dev`.

### Backend (Jarvis)
1.  Open `Backend` folder.
2.  Install Python dependencies: `pip install -r requirements.txt`.
3.  Run the agent: `python agent.py` (or specific entry file).

### Database
1.  Run the SQL scripts in `Database/` folder in your Supabase SQL Editor.
