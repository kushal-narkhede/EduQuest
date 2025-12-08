# Gmail App Password Setup Guide

Your custom email verification system is ready, but Gmail requires an **App Password** instead of your regular password for security.

## Quick Setup (5 minutes)

### Step 1: Enable 2-Factor Authentication
1. Go to https://myaccount.google.com/security
2. Sign in with `eduquestlearningapp@gmail.com`
3. Under "How you sign in to Google", enable **2-Step Verification**
4. Follow the prompts to set it up (you'll need a phone number)

### Step 2: Generate App Password
1. Go to https://myaccount.google.com/apppasswords
2. Sign in if prompted
3. In the "Select app" dropdown, choose **Mail**
4. In the "Select device" dropdown, choose **Other (Custom name)**
5. Type: `EduQuest Backend`
6. Click **Generate**
7. Copy the 16-character password (it will look like: `abcd efgh ijkl mnop`)

### Step 3: Update Your .env File
1. Open `server/.env`
2. Replace the `EMAIL_PASSWORD` line with your new App Password (remove spaces):
   ```
   EMAIL_PASSWORD=abcdefghijklmnop
   ```
3. Save the file
4. Restart your server (it will auto-restart if nodemon is running)

## Testing

Once configured, try signing up in your app:
1. Run the Flutter app
2. Click "Sign Up"
3. Enter username, email, and password
4. Click "Sign Up"
5. Check your email for the 6-digit verification code
6. Enter the code to complete registration

## Troubleshooting

**"Invalid credentials" error:**
- Make sure 2-Factor Authentication is enabled first
- Double-check you copied the App Password correctly (no spaces)
- Try generating a new App Password

**Email not arriving:**
- Check spam/junk folder
- Verify the email address is correct
- Check server logs for error messages

**Server not starting:**
- Make sure MongoDB connection string is valid
- Check that port 3000 is not already in use

## Current Status

✅ Server is running on http://localhost:3000
✅ MongoDB is connected
✅ Email endpoint is ready at `/auth/send-verification`
⚠️ Gmail App Password needs to be configured

Once you set up the App Password, your custom email verification will work perfectly!
