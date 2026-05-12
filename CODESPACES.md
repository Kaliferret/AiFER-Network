# Building AiFER Network APK in GitHub Codespaces

This guide shows you how to build the FER Network Flutter APK using GitHub Codespaces.

## What is GitHub Codespaces?

GitHub Codespaces provides a cloud development environment with:
- 32GB+ disk space (plenty for Flutter+Android builds)
- 2-4 vCPUs
- Up to 60 hours of free usage per month
- Full VS Code in your browser
- No local setup required!

## Quick Start

### Step 1: Create a Codespace

1. Go to your repository: https://github.com/Kaliferret/AiFER-Network
2. Click the green **Code** button
3. Select the **Codespaces** tab
4. Click **Create codespace on main**

The setup will automatically:
- Install Flutter 3.24.0
- Install Android SDK with NDK
- Configure all build tools
- Install project dependencies

This takes about 3-5 minutes on first setup.

### Step 2: Verify the Setup

Once the codespace is ready, open the terminal and verify:

```bash
# Check Flutter installation
flutter doctor -v

# Should see "Flutter (Channel stable, 3.24.0)"
# Android SDK, Android toolchain, and Android Studio/VS Code should all be ✓
```

### Step 3: Verify Code Correctness

```bash
# Run flutter analyze to ensure no errors
flutter analyze

# Should show: "No issues found!"
```

### Step 4: Build the APK

```bash
# Build release APK
flutter build apk

# This will take 2-5 minutes
# APK will be created at: build/app/outputs/flutter-apk/app-release.apk
```

### Step 5: Download the APK

After the build completes, download the APK:

**Option A: Using VS Code File Explorer**
1. In the left sidebar, click the Files Explorer icon
2. Navigate to: `build/app/outputs/flutter-apk/`
3. Right-click on `app-release.apk`
4. Select "Download"

**Option B: Using Terminal**
```bash
# The APK is located here:
ls -lh build/app/outputs/flutter-apk/app-release.apk

# You can also copy it to a location easier to download from:
cp build/app/outputs/flutter-apk/app-release.apk /tmp/fer-network.apk
```

## Alternative Build Options

### Debug Build (Faster)
```bash
flutter build apk --debug
```

### Split APKs (For Google Play)
```bash
flutter build appbundle
```

### Build with Release Notes
```bash
flutter build apk --release --build-name="1.0.0" --build-number=1
```

## Troubleshooting

### Issue: flutter doctor shows Android SDK not found
**Solution**:
```bash
export ANDROID_HOME=/opt/android-sdk
export PATH="$PATH:/opt/android-sdk/cmdline-tools/latest/bin"
flutter doctor
```

### Issue: Build fails with NDK errors
**Solution**:
```bash
# Ensure NDK is installed
/sdkmanager --install "ndk;25.2.9519653"
```

### Issue: Out of memory during build
**Solution**:
- Upgrade to a larger codespace instance (4 or 8 cores)
- Or reduce Gradle memory:
  ```bash
  echo "org.gradle.jvmargs=-Xmx1536m" >> android/gradle.properties
  ```

### Issue: Build succeeds but APK is too large
**Solution**:
```bash
# Check APK size
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Use app-bundle for Google Play (smaller downloads)
flutter build appbundle
```

## Codespace Tips

### Increase Performance
You can upgrade your codespace instance for faster builds:
1. Click your profile in bottom-left corner
2. Select "Settings" (gear icon)
3. Under "Machine type" choose:
   - **2 cores** (default) - Good for development
   - **4 cores** - Faster builds
   - **8 cores** - Fastest builds

### Running the App

You can run the app directly in the codespace using the Android Emulator:
```bash
# List available emulators
flutter emulators

# Start an emulator (if available)
flutter emulators --launch <emulator-id>

# Run the app
flutter run
```

### Access DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Then open the DevTools URL in your browser.

## Build Times (Estimates)

- **Debug APK**: ~2-3 minutes on 2-core instance
- **Release APK**: ~3-5 minutes on 2-core instance
- **App Bundle**: ~4-6 minutes on 2-core instance

## Free Tier Limits

- **60 hours** of free codespace usage per month
- Standard instance: 2 cores, 4GB RAM, 32GB storage
- Perfect for development and occasional builds

## What's Included in This Codespace Setup

- ✅ Flutter 3.24.0 (stable)
- ✅ Java 17 JDK
- ✅ Android SDK (Platforms 33, 34, 35)
- ✅ Android Build Tools (33.0.0, 34.0.0, 35.0.0)
- ✅ Android NDK 25.2.9519653
- ✅ VS Code extensions (Flutter, Dart, GitLens)
- ✅ Pre-configured settings
- ✅ Auto-setup script

## Next Steps After Successful Build

1. **Test the APK** on an Android device or emulator
2. **Sign the APK** with your keystore for distribution
3. **Upload to Google Play** (using app-bundle format)
4. **Share the APK** directly with users

## Support

If you encounter any issues:
1. Check the terminal output for error messages
2. Run `flutter doctor -v` to see detailed status
3. Check `flutter analyze` for code issues
4. Review the build log in `build/app/outputs/flutter-apk/`

---

**Happy Building! 🚀**

The sandbox couldn't build the APK due to disk constraints, but GitHub Codespaces has ample space (32GB+) for the full Flutter + Android SDK + Gradle + NDK build process.