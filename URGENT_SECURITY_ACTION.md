# URGENT: Exposed API Keys - Action Required

## ⚠️ Critical Security Issue

Your API keys were previously committed to the public GitHub repository. Even though they're now removed from the code, **they still exist in the Git history**.

## Exposed Keys Found

1. **OpenRouter API Key**: `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`
   - Location: `lib/ai/utils/constants.dart`
   
2. **MongoDB Connection String**: `mongodb+srv://kushalnarkhede09_db_user:ky7LvmoMvAdePmuj@eduquest.xqha7jn.mongodb.net/eduquest`
   - Location: `server/src/index-clerk.js`
   
3. **Clerk Secret Key**: `sk_test_R4oMlPpKSItvNuXLNEDb5PpmEnBq94KMlwpqsSTydH`
   - Location: `server/src/index-clerk.js`

## Immediate Actions Required

### 1. Revoke/Regenerate All Keys (DO THIS FIRST!)

#### OpenRouter
- Go to https://openrouter.ai/keys
- Delete the exposed key
- Generate a new API key
- Update your `.env` file with the new key

#### MongoDB Atlas
- Go to https://cloud.mongodb.com/
- Navigate to Database Access
- Change the password for user `kushalnarkhede09_db_user`
- Update `server/.env` with new connection string

#### Clerk (if still using)
- Go to https://dashboard.clerk.com/
- Regenerate your secret key
- Update `server/.env` with new key

### 2. Clean Git History

The old keys are still in your Git history. You need to remove them:

#### Option A: Using BFG Repo-Cleaner (Recommended)
```bash
# Download BFG from https://rtyley.github.io/bfg-repo-cleaner/
# Then run:
java -jar bfg.jar --replace-text passwords.txt EduQuestBackup
cd EduQuestBackup
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

Create `passwords.txt` with:
```
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
ky7LvmoMvAdePmuj
sk_test_R4oMlPpKSItvNuXLNEDb5PpmEnBq94KMlwpqsSTydH
```

#### Option B: Using git-filter-repo
```bash
pip install git-filter-repo
git filter-repo --invert-paths --path lib/ai/utils/constants.dart
git filter-repo --invert-paths --path server/src/index-clerk.js
```

### 3. Force Push (WARNING: Destructive)

After cleaning history:
```bash
git push origin main --force
```

⚠️ **Warning**: This will rewrite history. Inform any collaborators.

### 4. Verify on GitHub

1. Go to your repository on GitHub
2. Click on "History" or use GitHub search
3. Search for partial strings of your old keys
4. Ensure they don't appear anywhere

## What's Now Protected

✅ Added `.env` files to `.gitignore`
✅ Moved all secrets to environment variables
✅ Created `.env.example` templates
✅ Updated code to use `flutter_dotenv`
✅ Removed hardcoded secrets from code

## Prevention Going Forward

1. **Never** commit `.env` files
2. Use `.env.example` for documentation only
3. Review changes before committing: `git diff --cached`
4. Use a pre-commit hook to check for secrets
5. Consider using `git-secrets` tool

## Setup for New Developers

1. Copy `.env.example` to `.env`
2. Copy `server/.env.example` to `server/.env`
3. Get API keys from team lead
4. Never commit actual keys

## Need Help?

If you're unsure about any of these steps, stop and ask for help before proceeding. Improperly handling this could cause data loss or security issues.

---
**Status**: ⚠️ Action Required - Keys exposed in Git history
**Priority**: URGENT
**Created**: December 10, 2025
