#!/bin/bash
set -e

echo "🚀 Setting up Flutter development environment..."

# Detect workspace directory
if [ -n "$WORKSPACE_FOLDER" ]; then
    WORKSPACE="$WORKSPACE_FOLDER"
elif [ -n "$GITHUB_WORKSPACE" ]; then
    WORKSPACE="$GITHUB_WORKSPACE"
else
    WORKSPACE="$(pwd)"
fi

echo "📁 Workspace detected at: $WORKSPACE"

# Install system dependencies
echo "📦 Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    file \
    x11-utils \
    openjdk-17-jdk

# Install Flutter
echo "🦋 Installing Flutter..."
FLUTTER_VERSION="3.24.0"
cd /opt
if [ ! -d "flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
else
    cd flutter && git pull
fi

export PATH="$PATH:/opt/flutter/bin"
echo 'export PATH="$PATH:/opt/flutter/bin"' >> /home/vscode/.bashrc

# Pre-download Flutter dependencies
echo "🔥 Pre-downloading Flutter dependencies..."
flutter precache

# Install Android SDK
echo "📱 Installing Android SDK..."
ANDROID_SDK_ROOT="/opt/android-sdk"
mkdir -p $ANDROID_SDK_ROOT/cmdline-tools

# Download and install Android Command Line Tools
cd /tmp
if [ ! -f "commandlinetools-linux-11076708_latest.zip" ]; then
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
fi
unzip -q commandlinetools-linux-11076708_latest.zip
mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest
mv cmdline-tools/* $ANDROID_SDK_ROOT/cmdline-tools/latest/

export ANDROID_HOME=$ANDROID_SDK_ROOT
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
echo "export ANDROID_HOME=/opt/android-sdk" >> /home/vscode/.bashrc
echo 'export PATH="$PATH:/opt/android-sdk/cmdline-tools/latest/bin"' >> /home/vscode/.bashrc

# Accept Android SDK licenses
echo "📜 Accepting Android SDK licenses..."
yes | sdkmanager --licenses || true

# Install Android SDK components
echo "📦 Installing Android SDK components..."
sdkmanager --install "platform-tools" "platforms;android-34" "build-tools;34.0.0" "ndk;25.2.9519653"

# Install additional platforms for compatibility
sdkmanager --install "platforms;android-33" "platforms;android-35"
sdkmanager --install "build-tools;33.0.0" "build-tools;35.0.0"

# Set environment variables
echo "export PATH=\"$PATH:$ANDROID_HOME/platform-tools\"" >> /home/vscode/.bashrc
echo "export PATH=\"$PATH:$ANDROID_HOME/build-tools/34.0.0\"" >> /home/vscode/.bashrc

# Create local.properties file
echo "🏗️  Creating local.properties..."
if [ -f "$WORKSPACE/local.properties" ]; then
    echo "local.properties already exists"
else
    echo "sdk.dir=$ANDROID_SDK_ROOT" > "$WORKSPACE/local.properties"
    echo "Created local.properties at $WORKSPACE/local.properties"
fi

# Ensure workspace is correct
cd "$WORKSPACE"

# Install project dependencies
echo "📚 Installing Flutter project dependencies..."
flutter pub get

# Verify Flutter installation
echo "✅ Verifying Flutter installation..."
flutter doctor -v

# Run flutter analyze to verify code
echo "🔍 Running flutter analyze..."
flutter analyze

echo "✨ Setup complete! Your Flutter environment is ready."
echo ""
echo "To build the APK, run:"
echo "  cd $WORKSPACE"
echo "  flutter build apk --release --verbose"
echo ""
echo "To run the app in debug mode, run:"
echo "  cd $WORKSPACE"
echo "  flutter run"