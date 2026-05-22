# sportsphere_mobile

SportSphere mobile app for staff and players.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Phase 5 — Manual Steps (Hazim)

### Link iOS Entitlements in Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the `Runner` target → Signing & Capabilities
3. Click `+` → add **Associated Domains**
4. Add entry: `applinks:sprtsphr.app`
5. Xcode will write the entitlement to the project automatically

### Switch AppCheck to Production Providers
When Apple Developer Program is approved and Play Console is set up:
- iOS: change `appleProvider: const AppleDebugProvider()` → `const AppleDeviceCheckProvider()`
- Android: change `androidProvider: const AndroidDebugProvider()` → `const AndroidPlayIntegrityProvider()`

### TestFlight + Play Internal
- Uncomment `ios-beta` workflow in `codemagic.yaml` once Apple Dev is approved
- Set Codemagic environment groups: `app_store_credentials` + `google_play_credentials`
- Tag a release: `git tag v1.0.0-beta && git push --tags`
