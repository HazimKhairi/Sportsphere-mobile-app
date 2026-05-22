# Universal Links + App Links Setup

## Status

- **Android App Links:** wired (AndroidManifest.xml intent filters).
- **iOS Universal Links:** DEFERRED until Apple Developer enrollment grants a Team ID.

## What Hazim must host on the SportSphere web repo

These two files need to exist at `https://sprtsphr.app/.well-known/`:

### 1. `apple-app-site-association` (iOS)

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.app.sprtsphr.mobile",
        "paths": [
          "/m/*"
        ]
      }
    ]
  }
}
```

Replace `TEAM_ID` with the Apple Developer Team ID once enrollment is approved.

**Important:**
- Serve with `Content-Type: application/json`.
- No file extension (NOT `.json`).
- Must be over HTTPS.
- Test with `https://app-site-association.cdn-apple.com/a/v1/sprtsphr.app` after deploy.

### 2. `assetlinks.json` (Android)

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "app.sprtsphr.mobile",
      "sha256_cert_fingerprints": [
        "SHA256_FINGERPRINT_HERE"
      ]
    }
  }
]
```

The SHA-256 fingerprint comes from the Android signing certificate. For local debug builds:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA256
```

For Play Store release builds, get the fingerprint from Play Console -> App Integrity.

## Deep link routes supported

- `https://sprtsphr.app/m/programs/{id}` -> opens program detail
- `https://sprtsphr.app/m/training-sessions/{id}` -> opens session detail
- `https://sprtsphr.app/m/payments/{id}` -> opens payment detail
- `https://sprtsphr.app/m/sphere-ai/thread/{id}` -> opens chat thread
- `https://sprtsphr.app/m/auth/reset?oobCode=...` -> password reset
- `https://sprtsphr.app/m/stripe/return` -> Stripe redirect return
- `sportsphere://stripe/return` -> custom scheme fallback
