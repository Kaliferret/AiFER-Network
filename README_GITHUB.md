# FER Network Android APP

## 📱 Get the APK

The easiest way to get the installable APK is through **GitHub Actions**:

### Option 1: Automatic Build on Push (Recommended)
1. Fork this repository or create your own
2. Clone it and push code:
   ```bash
   git init
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
   git add .
   git commit -m "Initial commit"
   git push -u origin main
   ```
3. Wait ~3-5 minutes
4. Go to the **Actions** tab in GitHub
5. Click on the latest "Build FER Network APK" workflow
6. Download the artifact: **fer-network-release-apk**

### Option 2: Manual Trigger
1. Go to the **Actions** tab
2. Select "Build FER Network APK"
3. Click **Run workflow** → **Run workflow**
4. Wait ~3-5 minutes
5. Download the artifact

## 🔧 Build Locally

If you want to build the APK yourself:

### Requirements
- Flutter 3.24.5+ ([install guide](https://flutter.dev/get-started/install))
- Android Studio or Android SDK
- Java 17
- 5 GB free disk space

### Quick Build
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO/fernetwork-main

# Install dependencies
flutter pub get

# Build APK (release)
flutter build apk --release

# Find your APK
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

## 📦 APK Details

| Property | Value |
|----------|-------|
| **Target** | Android 5.0+ (API 21) |
| **Architectures** | arm64-v8a, armeabi-v7a, x86_64 |
| **Type** | Release build (optimized) |
| **Min Size** | ~30-50 MB |
| **Install Size** | ~100-150 MB |

## 🚀 Install the APK

1. Download the APK (GitHub Actions → Artifacts)
2. Enable **Install from Unknown Sources**:
   - Settings → Security → Unknown Sources → Enable
3. Tap the APK file to install
4. Grant permissions when prompted

## 🐛 Troubleshooting

### Build fails with SDK version error
The build script automatically handles SDK constraints. If you see issues locally, temporarily edit `pubspec.yaml`:
```yaml
environment:
  sdk: ">=3.5.0 <4.0.0"
```

### APK won't install
- Make sure "Unknown Sources" is enabled
- Try using a file manager app instead of Chrome
- Check Android version (requires 5.0+)

### App crashes on startup
Try a **debug build** for more detailed logs:
```bash
flutter build apk --debug
```

## 📞 Support

If you encounter issues:
1. Check the [GitHub Actions logs](../../actions) for build errors
2. Open an issue with your device model and Android version
3. Include logs from `adb logcat` if available

## 📄 License

This project is a proprietary fork of the FER Network application.