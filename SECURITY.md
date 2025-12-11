# Security Setup Guide

This document explains how API keys and sensitive credentials are managed in this project.

## Environment Variables

All sensitive information is stored in `.env` files which are **NOT** committed to the repository.

### Flutter App (.env)

1. Copy `.env.example` to `.env` in the project root
2. Fill in your actual API keys:

```bash
# OpenRouter API Key for AI features
OPENROUTER_API_KEY=your_actual_key_here

# Backend API URL
API_BASE_URL=https://your-backend-url.com
```

### Backend Server (server/.env)

1. Copy `server/.env.example` to `server/.env`
2. Fill in your actual credentials:

```bash
# MongoDB Atlas connection string
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/database

# Clerk authentication (if using)
CLERK_SECRET_KEY=your_clerk_secret_key

# Email configuration
EMAIL_SERVICE=gmail
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-specific-password
```

## What's Protected

The following files are in `.gitignore` and will never be committed:

- `.env` - Flutter app environment variables
- `server/.env` - Backend server environment variables
- Any `*.env` files

## Important Notes

1. **Never commit real API keys** to the repository
2. The `.env` file is loaded at app startup in `lib/main.dart`
3. API keys are accessed via `flutter_dotenv` package
4. Server uses Node.js `dotenv` package for environment variables

## First Time Setup

1. Clone the repository
2. Copy `.env.example` to `.env` and add your keys
3. Copy `server/.env.example` to `server/.env` and add your credentials
4. Run `flutter pub get` to install dependencies
5. Start the backend: `cd server && npm install && npm run dev`
6. Run the Flutter app: `flutter run`

## Getting API Keys

- **OpenRouter**: Sign up at https://openrouter.ai/ and generate an API key
- **MongoDB Atlas**: Create a free cluster at https://www.mongodb.com/cloud/atlas
- **Clerk** (optional): Get credentials from https://clerk.com/

## If You've Already Committed Keys

If you've accidentally committed API keys:

1. **Immediately revoke/regenerate** the exposed keys
2. Remove them from git history using tools like `git-filter-repo` or BFG Repo-Cleaner
3. Add new keys to `.env` file
4. Never commit the `.env` file

## Questions?

Check the main README.md for more information about running the project.
