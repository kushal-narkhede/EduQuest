# Clerk "Problems Connecting" Troubleshooting Guide

## The Error
"We are having problems connecting" typically means the Flutter app cannot reach Clerk's API servers.

## Common Causes & Solutions

### 1. Invalid Clerk Publishable Key
**Check**: Your key should look like: `pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxx`

**Your current key**: `pk_test_c2FmZS1odW1wYmFjay0zOS5jbGVyay5hY2NvdW50cy5kZXYk`

**Verify**:
1. Go to https://dashboard.clerk.com
2. Navigate to **API Keys**
3. Compare the **Publishable Key** with what's in your `lib/utils/config.dart`
4. Make sure they match EXACTLY (no extra spaces or characters)

### 2. Network/Firewall Issues
**Test**: Can you access https://clerk.com in your browser?

**If on emulator**:
- Make sure your computer has internet access
- Try restarting the emulator
- Check if antivirus/firewall is blocking connections

**If on real device**:
- Make sure device has internet/WiFi enabled
- Try switching between WiFi and mobile data
- Check if any VPN is interfering

### 3. Clerk Account Issues
**Verify your Clerk account**:
1. Go to https://dashboard.clerk.com
2. Make sure your application is **active** (not suspended)
3. Check if you're on the correct environment (Development vs Production)
4. Verify email verification is enabled:
   - Go to **User & Authentication** → **Email, Phone, Username**
   - Make sure **Email address** is enabled
   - Turn on **Verify at sign-up**

### 4. App Not Rebuilt After Config Change
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### 5. Clerk Domain Restrictions
**Check**:
1. In Clerk dashboard, go to **Settings** → **Restrictions**
2. Make sure there are no domain restrictions blocking your app
3. For mobile apps, you might need to add your app's bundle ID

### 6. SSL/Certificate Issues (Android)
If you're on Android and getting SSL errors, you might need to add network security config.

**Create**: `android/app/src/main/res/xml/network_security_config.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">clerk.accounts.dev</domain>
        <domain includeSubdomains="true">clerk.com</domain>
    </domain-config>
</network-security-config>
```

**Update**: `android/app/src/main/AndroidManifest.xml`
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

## Quick Test

Run this in your Flutter app to test Clerk connectivity:

```dart
try {
  final clerkAuth = ClerkAuth.of(context, listen: false);
  print('Clerk initialized: ${clerkAuth != null}');
  print('Clerk key: ${AppConfig.clerkPublishableKey}');
} catch (e) {
  print('Clerk error: $e');
}
```

## Alternative: Use Custom Email System (Temporary)

If Clerk continues to have issues, you can temporarily switch back to the custom email system:

1. **Server**: Change `package.json` to use `src/index.js` instead of `src/index-clerk.js`
2. **Flutter**: Remove Clerk code and use the old authentication
3. **Email**: Configure Gmail app password in server `.env`

This will let you test email verification while you troubleshoot Clerk.

## Still Not Working?

1. **Check Clerk Status**: https://status.clerk.com
2. **Clerk Logs**: Check your Clerk dashboard → **Logs** for any errors
3. **Flutter Logs**: Run `flutter run -v` to see detailed error messages
4. **Contact Clerk Support**: https://clerk.com/support

## Most Likely Issue

Based on the error, the most common cause is:
- ❌ **Wrong Clerk Publishable Key** - Double-check it matches your dashboard
- ❌ **Clerk account not properly set up** - Verify email verification is enabled
- ❌ **Network/firewall blocking Clerk API** - Test on different network

Try these in order and the issue should resolve!
