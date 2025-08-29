#!/bin/bash

# Railway Deployment Helper Script
# Run this after you've forked the repository

echo "🚀 Railway Deployment Setup Script"
echo "=================================="
echo ""

# Get GitHub username
read -p "Enter your GitHub username: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ GitHub username is required!"
    exit 1
fi

echo ""
echo "📋 Setting up git remote for your fork..."

# Update git remote
git remote set-url origin https://github.com/$GITHUB_USERNAME/Archon.git

echo "✅ Remote updated to: https://github.com/$GITHUB_USERNAME/Archon.git"
echo ""
echo "📤 Pushing to your fork..."

# Push to fork
git push -u origin main

echo ""
echo "✅ Code pushed to your GitHub fork!"
echo ""
echo "🎯 Next Steps:"
echo "1. Go to https://railway.app"
echo "2. Sign in with your GitHub account"
echo "3. Click 'New Project' → 'Deploy from GitHub repo'"
echo "4. Select your Archon fork"
echo "5. Add these environment variables in Railway:"
echo ""
echo "   SUPABASE_URL=https://ypjffkganqnkgaqskggy.supabase.co"
echo "   SUPABASE_SERVICE_KEY=[Your service key from .env file]"
echo ""
echo "   SERVER_PORT=8181"
echo "   MCP_SERVER_PORT=8051"
echo "   FRONTEND_PORT=3737"
echo ""
echo "   NODE_ENV=production"
echo ""
echo "Railway will handle the rest automatically!"
echo ""
echo "📚 For detailed instructions, see DEPLOYMENT_GUIDE.md"