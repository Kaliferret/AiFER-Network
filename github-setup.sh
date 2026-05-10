#!/bin/bash

# FER Network - GitHub Setup Script
# This script helps you push the project to GitHub and build the APK automatically

set -e

echo "🚀 FER Network GitHub Setup"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    echo "   - Ubuntu/Debian: sudo apt-get install git"
    echo "   - Mac: xcode-select --install"
    exit 1
fi

# Check if gh CLI is installed (optional)
if command -v gh &> /dev/null; then
    HAS_GH_CLI=true
    echo "✅ GitHub CLI found"
else
    HAS_GH_CLI=false
    echo "⚠️  GitHub CLI not found (optional)"
fi

# Get repository info
echo ""
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter your repository name: " REPO_NAME

# Full repo URL
REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"

echo ""
echo "📦 Repository: ${REPO_URL}"
echo ""

# Initialize git if needed
if [ ! -d ".git" ]; then
    echo "📝 Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: FER Network Flutter App"
else
    echo "✅ Git already initialized"
fi

# Create repository (with GitHub CLI if available)
if [ "$HAS_GH_CLI" = true ] && ! git remote get-url origin &> /dev/null; then
    echo "🔧 Creating GitHub repository..."
    gh repo create ${REPO_NAME} --public --source=. --push=false
    git remote add origin ${REPO_URL}
elif ! git remote get-url origin &> /dev/null; then
    echo ""
    echo "📌 Please create the repository manually:"
    echo "   1. Go to: https://github.com/new"
    echo "   2. Repository name: ${REPO_NAME}"
    echo "   3. Make it Public"
    echo "   4. Click 'Create repository'"
    echo "   5. Copy the remote URL (HTTPS or SSH)"
    echo ""
    read -p "Paste the repository URL: " REPO_URL
    git remote add origin ${REPO_URL}
else
    echo "✅ Remote already configured: $(git remote get-url origin)"
fi

# Push to GitHub
echo ""
echo "📤 Pushing to GitHub..."
echo ""

# Check if main branch exists
if git show-ref --quiet refs/heads/main; then
    git branch -M main
else
    git checkout -b main
fi

# Push with upstream tracking (will fail if repo doesn't exist)
if git push -u origin main 2>/dev/null; then
    echo ""
    echo "✅ Code pushed successfully!"
else
    echo ""
    echo "❌ Push failed. Please ensure:"
    echo "   1. Repository ${REPO_URL} exists"
    echo "   2. You have permission to push to it"
    echo "   3. Run: git remote -v  to check the remote URL"
    exit 1
fi

echo ""
echo "================================================"
echo -e "${GREEN}✨ Setup Complete!${NC}"
echo "================================================"
echo ""
echo "📱 Your APK is being built..."
echo ""
echo "1. Go to: ${REPO_URL}/actions"
echo "2. Wait ~3-5 minutes for the build to complete"
echo "3. Download the APK from 'Artifacts'"
echo ""
echo "📋 Actions URL:"
echo "   ${REPO_URL}/actions"
echo ""
echo "💡 Tip: You can also create a formal release by:"
echo "   1. Going to Actions → 'Release with APK'"
echo "   2. Click 'Run workflow'"
echo "   3. Enter version (e.g., v1.0.0)"
echo "   4. Click 'Run workflow' again"
echo ""
echo "📦 Then download the APK from the Releases tab"
echo ""