# VYAAS AI - Android Build Script
# This script automates the entire Android build process

Write-Host "Starting VYAAS AI Android Build Process..." -ForegroundColor Cyan
Write-Host ""

# Define paths
$frontendPath = "c:\Users\mahes\OneDrive\Desktop\vyaasaiupdated\Frontend"

# Step 1: Navigate to Frontend
Write-Host "[1/5] Navigating to Frontend directory..." -ForegroundColor Yellow
Set-Location $frontendPath

# Step 2: Build Next.js app
Write-Host "[2/5] Building Next.js app (this may take a few minutes)..." -ForegroundColor Yellow
pnpm build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed! Please check the errors above." -ForegroundColor Red
    exit 1
}

Write-Host "Next.js build complete!" -ForegroundColor Green
Write-Host ""

# Step 3: Initialize Capacitor (if not already initialized)
Write-Host "[3/5] Initializing Capacitor..." -ForegroundColor Yellow
if (Test-Path "capacitor.config.json") {
    Write-Host "Capacitor already initialized, skipping..." -ForegroundColor Cyan
}
else {
    npx cap init "VYAAS AI" "com.vyaasai.app" --web-dir=out
    Write-Host "Capacitor initialized!" -ForegroundColor Green
}
Write-Host ""

# Step 4: Add Android platform (if not already added)
Write-Host "[4/5] Adding Android platform..." -ForegroundColor Yellow
if (Test-Path "android") {
    Write-Host "Android platform already exists, skipping..." -ForegroundColor Cyan
}
else {
    npx cap add android
    Write-Host "Android platform added!" -ForegroundColor Green
}
Write-Host ""

# Step 5: Sync assets
Write-Host "[5/5] Syncing assets to Android..." -ForegroundColor Yellow
npx cap sync android

if ($LASTEXITCODE -ne 0) {
    Write-Host "Sync failed! Please check the errors above." -ForegroundColor Red
    exit 1
}

Write-Host "Assets synced successfully!" -ForegroundColor Green
Write-Host ""

# Step 6: Open Android Studio
Write-Host "Opening Android Studio..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps in Android Studio:" -ForegroundColor Yellow
Write-Host "  1. Wait for Gradle sync to complete (2-3 minutes)" -ForegroundColor White
Write-Host "  2. Click Build -> Build Bundle(s) / APK(s) -> Build APK(s)" -ForegroundColor White
Write-Host "  3. Wait for build (3-5 minutes)" -ForegroundColor White
Write-Host "  4. Click 'locate' to find your APK" -ForegroundColor White
Write-Host "  5. Copy APK to your phone and install!" -ForegroundColor White
Write-Host ""
Write-Host "APK Location: Frontend\android\app\build\outputs\apk\debug\app-debug.apk" -ForegroundColor Cyan
Write-Host ""

npx cap open android

Write-Host ""
Write-Host "Build process complete! Android Studio should be opening now..." -ForegroundColor Green
Write-Host "Good luck with your Android app!" -ForegroundColor Cyan
