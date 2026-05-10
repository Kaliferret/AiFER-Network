# 🎯 How to Get Your FER Network APK in 5 Minutes

## Quick Start (Easiest Way)

### Step 1: Push to GitHub

```bash
# On your computer, clone/download the fernetwork-main folder

# Initialize git and push
cd fernetwork-main

# Option A: Use the automated script (recommended)
./github-setup.sh

# Option B: Manual push
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_NAME.git
git push -u origin main
```

### Step 2: Wait for GitHub Actions Build

1. Go to your repository on GitHub
2. Click the **Actions** tab
3. Wait ~3-5 minutes (you'll see a green checkmark when done)
4. Click on the "Build FER Network APK" workflow
5. Scroll down to **Artifacts**
6. Click **fer-network-release-apk** to download

### Step 3: Install the APK

1. Download the `.zip` file from Artifacts
2. Extract it to get `app-release.apk`
3. On your Android phone:
   - Settings → Security → **Unknown Sources** → Enable
   - Tap `app-release.apk` to install
4. Open the app and enjoy!

## Creating a Formal Release (for sharing with others)

### Step 1: Trigger Release Workflow

1. Go to **Actions** tab
2. Select **"Create Release with APK"** workflow
3. Click **Run workflow** → **Run workflow**
4. Enter version (e.g., `v1.0.0`)
5. Click **Run workflow** again

### Step 2: Download from Releases

1. Wait ~3-5 minutes
2. Go to **Releases** tab
3. Find your version tag
4. Download `app-release.apk` from Assets

## What's in the APK?

| Feature | Status |
|---------|--------|
| **Messaging** | ✅ Lattice-encrypted, offline-first |
| **Wallet** | ✅ Blockchain wallet with FER balance |
| **File Manager** | ✅ Import/share with frequency telemetry |
| **Gaming Hub** | ✅ Sessions, stats, catalog |
| **Voice Calls** | ✅ Live network monitoring + call logs |
| **Dashboard** | ✅ 4 action tiles, balance card, unread card |
| **UI** | ✅ Base44 dark theme (green/pink/blue/purple) |

## Troubleshooting

### Issue: "Actions tab shows no workflows"
**Fix:** Make sure the `.github/workflows/` folder was pushed. Run:
```bash
git add .github/
git commit -m "Add workflows"
git push
```

### Issue: Build fails
**Fix:** Check the workflow logs for errors. Most common issues:
- SDK constraint (automatically fixed by workflows)
- Network timeout (wait 30 seconds and rebuild)

### Issue: APK doesn't install
**Fix:** 
1. Try using a file manager app instead of Chrome
2. Clear cache: Settings → Apps → Chrome → Clear Cache
3. Make sure Android 5.0 or later

### Issue: App crashes on launch
This is a development build. For debugging:
```bash
# Connect phone via ADB and get logs
adb logcat | grep fer
```

## Advanced: Build Locally

If you prefer to build on your own machine:

```bash
# Requirements
# - Flutter 3.24.5+
# - Android Studio
# - Java 17
# - 5 GB free space

cd fernetwork-main

# Fix SDK constraint for older Flutter
sed -i 's/sdk: "^3.6.0"/sdk: ">=3.5.0 <4.0.0"/' pubspec.yaml

# Build
flutter pub get
flutter build apk --release

# Find APK
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

## What Next?

- ✅ APK ready for testing on Android devices
- ✅ Ready for Play Store submission (after signing)
- ✅ All features wired: messaging, wallet, files, gaming, voice
- ✅ Base44 dark UI with polish (shimmer, error states, animations)

**Need help?** Open an issue on GitHub with:
- Your device model
- Android version
- Screenshot of any errors

---

**Happy testing! 🚀**