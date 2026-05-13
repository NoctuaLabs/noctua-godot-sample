# CLAUDE.md — Godot Noctua App

## Project Overview

A Godot 4 sample/test application for the Noctua SDK. It exercises auth, IAP, IAA, and event tracking via the Noctua Godot plugin and serves as the integration reference for the SDK team.

- **Godot**: 4.x
- **Platforms**: Android · iOS

---

## Repository Layout

```
scenes/
  main.tscn              # Main scene
scripts/
  main.gd                # Entry point — wires up UI to Noctua SDK calls
  noctua.gd              # Local Noctua helper / thin wrapper
android/
  plugins/
	GodotNoctua.gdap     # Android plugin descriptor
ios/
  plugins/
	adjust/
	  adjust.gdip        # iOS plugin descriptor
export_presets.cfg       # Godot export configs (Android + iOS)
project.godot            # Project settings
```

---

## Config Files (gitignored)

These files contain credentials — **never commit them**. Obtain from the Noctua team and place in the project root:

| File | Purpose |
|------|---------|
| `noctuagg.json` | Noctua SDK config — `clientId`, `gameId`, Adjust tokens, AdMob/AppLovin ad unit IDs, IAA/IAP settings |
| `google-services.json` | Firebase config — project number, OAuth client IDs, API key |

> For Android builds, `google-services.json` must be in `android/build/app/` so the Firebase Gradle plugin can process it. Copy it there when setting up the custom Android build template.

---

## Android Build Setup

1. In Godot, go to **Project → Export → Android** and install the custom build template.
2. This generates `android/build/`. Copy `google-services.json` into `android/build/app/`.
3. Ensure `GodotNoctua.gdap` references the correct AAR version.
4. Build via Godot export or `./gradlew assembleDebug` inside `android/build/`.

## iOS Build Setup

1. Export from Godot to generate the Xcode project.
2. The `adjust.gdip` descriptor includes the xcframework and required system frameworks.
3. Run `pod install` if CocoaPods dependencies are added.
4. Ensure `GoogleService-Info.plist` (iOS Firebase config) is added to the Xcode project.

---

## Testing

Manual testing workflow:
1. Place `noctuagg.json` and `google-services.json` in the project root.
2. Set `sandboxEnabled: true` in `noctuagg.json` for sandbox testing.
3. Run on a device or emulator.
4. Verify events appear in the Noctua dashboard and Firebase console.
