# Release Runbook

## Prerequisites (one-time)

- [x] Flutter 3.27+ installed
- [x] Firebase project `sportsphere-production` configured (Tasks 7-9)
- [x] Codemagic account connected to GitHub repo
- [ ] Apple Developer Program enrolled (USD 99/yr) <- BLOCKING TestFlight
- [ ] Apple Team ID noted
- [ ] App Store Connect app slot reserved (Bundle ID `app.sprtsphr.mobile`)
- [ ] App Store Connect API key generated for Codemagic (.p8 file)
- [ ] Play Console account created (USD 25 one-time)
- [ ] Play Console internal app slot reserved (Package `app.sprtsphr.mobile`)
- [ ] Play Console service account JSON for Codemagic
- [ ] `.well-known/apple-app-site-association` hosted on sprtsphr.app
- [ ] `.well-known/assetlinks.json` hosted on sprtsphr.app
- [ ] Firebase Auth: Google provider enabled
- [ ] Firebase Auth: Apple provider enabled (after Apple Dev)

## Per-release flow

### Beta release

1. Bump version in `pubspec.yaml`. Example: `1.0.0-beta.1+1`.
2. Commit + tag: `git tag v1.0.0-beta.1 && git push origin v1.0.0-beta.1`.
3. Codemagic auto-runs:
   - `android-beta` workflow -> AAB -> uploads to Play Console internal track (once publishing config enabled)
   - `ios-beta` workflow (when Apple Dev approved) -> IPA -> uploads to TestFlight
4. Manual sign-off -> promote internal -> closed -> open -> production.

### Production release

1. Bump version: `1.0.0+1`.
2. Tag without `-beta` suffix.
3. Codemagic builds -> manual promotion in App Store Connect + Play Console.

## Smoke test checklist before promotion

- [ ] Splash logo renders
- [ ] Onboarding 3 slides swipe smoothly
- [ ] Role pick saves selection
- [ ] Email login works
- [ ] Google Sign-In works (test account)
- [ ] Apple Sign-In works (after enrollment) (test on physical iPhone)
- [ ] Home screen renders with floating navbar
- [ ] Force-quit + reopen preserves auth + role
- [ ] FCM token registers (Phase 2)
- [ ] Universal Link from email opens app (Phase 2)
- [ ] Crashlytics records zero crashes in test session

## Rollback

- App Store: phased release allows rollback within 24h via "Stop Release" in App Store Connect
- Play Store: halt rollout in Play Console -> revert to previous version

## Beta tester list

- Hazim (CTO)
- Black Viper FC pilot staff (5-10 users)
- Internal QA (TBD)
