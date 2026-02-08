# Publishing EduQuest to the Google Play Store

This guide walks you through publishing the EduQuest app to Google Play.

---

## 1. Google Play Developer Account

1. **Sign up** at [Google Play Console](https://play.google.com/console/signup).
2. **Pay the one-time registration fee** (currently **$25**).
3. **Complete your account profile**: developer name, email, website (if any), and accept the Developer Distribution Agreement.

---

## 2. Prepare Your App for Release

### 2.1 Choose an application ID (package name)

Your app currently uses `com.example.fbla_2`. For production you should use a unique ID you own, for example:

- `com.yourname.eduquest`
- `com.yourschool.eduquest`

**To change it:**

- In **`android/app/build.gradle`**: set `applicationId` and `namespace` to your new package name.
- In **`android/app/build.gradle.kts`** (if you use it): same `applicationId` and `namespace`.
- Rename the Kotlin package folder under `android/app/src/main/kotlin/` to match (e.g. `com/yourname/eduquest`) and update the `package` declaration in `MainActivity.kt`.

Once you change the application ID, you **cannot** change it again on Play Store, so choose carefully.

### 2.2 Version and build number

In **`pubspec.yaml`**:

```yaml
version: 1.0.0+1   # 1.0.0 = versionName (shown to users), 1 = versionCode (integer, must increase each upload)
```

- For each new upload to Play Store, **increase `versionCode`** (the number after `+`), e.g. `1.0.0+2`, `1.0.1+3`, etc.

### 2.3 Create an upload keystore (release signing)

You need a **keystore** to sign the release build. Keep it safe and backed up; if you lose it, you cannot update the app on Play Store.

**One-time setup:**

1. Open a terminal in your project root and run (replace with your own values):

   **Windows (PowerShell):**
   ```powershell
   cd android
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

   **macOS/Linux:**
   ```bash
   cd android
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. When prompted:
   - Enter a **keystore password** (remember it).
   - Enter **key password** (can be same as keystore password).
   - Fill in your name, organization, city, state, country.

3. **Do not commit** `upload-keystore.jks` or `key.properties` to Git (they are already in `.gitignore`). Back them up somewhere secure (e.g. encrypted drive or password manager that supports files).

### 2.4 Create `key.properties`

In the **`android`** folder (same level as `app/`), create a file named **`key.properties`** with:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

- Replace `YOUR_KEYSTORE_PASSWORD` and `YOUR_KEY_PASSWORD` with the passwords you used when creating the keystore.
- `storeFile` is relative to the **`android`** folder, so if the keystore is `android/upload-keystore.jks`, use `upload-keystore.jks`.

The project is already set up to use `key.properties` for release signing when this file exists.

---

## 3. Build the App Bundle (AAB)

Google Play requires the **Android App Bundle** (`.aab`) format, not APK.

From your **project root** (EduQuest folder):

```bash
flutter clean
flutter pub get
flutter build appbundle
```

The signed release bundle will be at:

**`build/app/outputs/bundle/release/app-release.aab`**

Use this file in Play Console.

---

## 4. Create the App in Play Console

1. In [Play Console](https://play.google.com/console), click **Create app**.
2. Fill in:
   - **App name**: EduQuest
   - **Default language**
   - **App or game**: App
   - **Free or paid**: Free (or Paid if you choose)
3. Accept declarations (e.g. export compliance, policies) and create the app.

---

## 5. Complete Store Listing and Policy

In the Play Console, complete at least:

### 5.1 Store listing (Main store listing)

- **Short description** (up to 80 characters).
- **Full description** (up to 4000 characters).
- **App icon**: 512 x 512 px PNG (no transparency).
- **Feature graphic**: 1024 x 500 px (optional but recommended).
- **Screenshots**: at least 2 phone screenshots (e.g. 1080 x 1920 or 1080 x 2340). You can add more and tablet later.
- **App category** (e.g. Education).
- **Contact email** and optionally **privacy policy URL** (required if you collect user data).

### 5.2 Content rating

- Complete the **questionnaire** (e.g. target age, in-app purchases, ads).
- Submit to get a **content rating** (e.g. Everyone, Teen). Required before publishing.

### 5.3 Target audience and content

- **Target audience**: e.g. ages 13+ or 18+.
- **News app**: No (unless it is).
- **COVID-19 apps**: No (unless it is).
- **Data safety**: Declare what data you collect (e.g. account, in-app actions) and how it’s used. Your app uses usernames and study data; declare that and link to your privacy policy if needed.

### 5.4 Privacy policy

If you collect any user data (accounts, progress, etc.), a **privacy policy** URL is required. Host a page (e.g. on GitHub Pages or your school site) and add the URL in Store listing and Data safety.

---

## 6. Upload the AAB and Release

1. In Play Console, go to **Release** → **Production** (or **Testing** → **Internal testing** to try first).
2. **Create new release**.
3. **Upload** `app-release.aab` from `build/app/outputs/bundle/release/`.
4. Add **release name** (e.g. "1.0.0 (1)") and **release notes** (what’s new for users).
5. **Review release** and then **Start rollout to Production** (or save for internal testing).

---

## 7. After Submitting

- **Review time**: First app can take from a few days to a week or more.
- **Status**: Check **Publishing overview** and your email for any issues.
- **Rejections**: Fix the issues mentioned in the email, update the app or store listing, and resubmit (with a higher `versionCode` for the new AAB).

---

## Quick reference

| Step              | Where / What |
|-------------------|--------------|
| Developer account | [play.google.com/console](https://play.google.com/console) – $25 one-time |
| App ID            | `android/app/build.gradle` → `applicationId` |
| Version           | `pubspec.yaml` → `version: 1.0.0+1` (bump +number each upload) |
| Keystore          | `keytool` → `android/upload-keystore.jks` (back up securely) |
| key.properties    | `android/key.properties` (do not commit) |
| Build AAB         | `flutter build appbundle` |
| Output AAB        | `build/app/outputs/bundle/release/app-release.aab` |

For more detail, see [Flutter’s Android deployment docs](https://docs.flutter.dev/deployment/android) and [Play Console Help](https://support.google.com/googleplay/android-developer).
