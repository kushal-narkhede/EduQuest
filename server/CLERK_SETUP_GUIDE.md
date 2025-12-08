# Clerk Integration Setup Guide for EduQuest

## What I've Done

1. ✅ Installed `@clerk/clerk-sdk-node` package
2. ✅ Created Clerk authentication routes (`src/routes/clerkAuth.js`)
3. ✅ Created new Clerk-enabled server file (`src/index-clerk.js`)
4. ✅ Updated User model to support Clerk IDs
5. ✅ Added Clerk configuration to `.env`

## What You Need to Do

### Step 1: Get Clerk API Keys

1. Go to https://clerk.com and sign up/login
2. Create a new application (or use existing one)
3. Go to **API Keys** in the dashboard
4. Copy your keys:
   - **Publishable Key** (starts with `pk_test_` or `pk_live_`)
   - **Secret Key** (starts with `sk_test_` or `sk_live_`)

### Step 2: Update `.env` File

Replace the placeholder values in `server/.env`:

```env
CLERK_PUBLISHABLE_KEY=pk_test_your_actual_key_here
CLERK_SECRET_KEY=sk_test_your_actual_key_here
```

### Step 3: Configure Clerk Dashboard

In your Clerk dashboard (https://dashboard.clerk.com):

1. **Enable Email Verification**:
   - Go to **User & Authentication** → **Email, Phone, Username**
   - Enable **Email address**
   - Turn on **Verify at sign-up**
   - Clerk will automatically send verification emails!

2. **Configure Email Settings** (Optional):
   - Go to **Customization** → **Emails**
   - Customize the verification email template
   - Add your branding

3. **Set up Allowed Domains** (Optional):
   - Go to **Settings** → **Restrictions**
   - Configure allowed email domains if needed

### Step 4: Switch to Clerk Server

Update `server/package.json` to use the Clerk-enabled server:

```json
{
  "scripts": {
    "start": "node src/index-clerk.js",
    "dev": "nodemon src/index-clerk.js",
    "start-old": "node src/index.js"
  }
}
```

### Step 5: Restart Your Server

```bash
cd server
npm run dev
```

## How Clerk Handles Emails

✅ **Clerk automatically sends emails for**:
- Email verification when users sign up
- Password reset requests
- Magic link authentication
- Account notifications

✅ **No email configuration needed** - Clerk uses its own email infrastructure

✅ **Customizable** - You can customize email templates in the Clerk dashboard

## Testing

1. Start your server: `npm run dev`
2. The server should log: `API with Clerk authentication listening on :3000`
3. Test the health endpoint: `curl http://localhost:3000/health`
4. You should see: `{"ok":true,"uptime":X,"auth":"clerk"}`

## Next Steps for Flutter App

You'll need to integrate Clerk in your Flutter app:

1. Add Clerk Flutter SDK: `flutter pub add clerk_flutter`
2. Update authentication flow to use Clerk
3. Store Clerk session tokens
4. Send tokens with API requests

## Troubleshooting

**Error: "CLERK_SECRET_KEY is missing"**
- Make sure you've added your actual Clerk keys to `.env`
- Restart the server after updating `.env`

**Emails not sending**
- Check Clerk dashboard → **Logs** to see email delivery status
- Verify email verification is enabled in settings
- Check spam folder

**Authentication failing**
- Verify your Clerk keys are correct
- Check that the publishable key matches your environment (test/production)

## Support

- Clerk Documentation: https://clerk.com/docs
- Clerk Discord: https://clerk.com/discord
- EduQuest Issues: Check your project repository

---

**Note**: The old authentication system (`src/index.js`) is still available if you need to roll back. Just change the `start` script back to `node src/index.js`.
