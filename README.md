# Noctua Godot Sample

A Godot 4.6 sample app for the [Noctua Godot SDK](https://github.com/NoctuaLabs/noctua-godot-sdk).
It is the integration reference for game teams: a single demo screen that fires every
SDK call on **Android** and **iOS** and shows the result in an on-screen event log.

| | Version |
|---|---|
| Godot | 4.6.1 (plugin works on 4.2+) |
| Noctua Android SDK | `com.noctuagames.sdk:noctua-android-sdk:0.35.1` |
| Noctua iOS SDK | CocoaPods `NoctuaSDK 0.40.1` |
| Android | min SDK 23 |
| iOS | 15.0+ |

A Godot 3.6 version of this sample lives on GitLab (`evosverse/noctua/godot-noctua-app`).

---

## What the demo covers

| Section | SDK call |
|---|---|
| Track Events | `noctua.track_event("level_start")` and friends, plus a custom event name |
| Track Purchase | `noctua.track_purchase(order_id, amount, "USD", {})` |
| Track Ad Revenue | `noctua.track_ad_revenue("admob_sdk" / "applovin_max_sdk", revenue, "USD", {})` |
| Session Tag | `noctua.set_session_tag(tag)` |

The header shows **SDK Connected** when the native plugin is present. In the editor
(desktop) every call is a no-op and the log shows
`Noctua plugin not found! Running without native SDK.`

---

## Getting started

```bash
git clone --recurse-submodules https://github.com/NoctuaLabs/noctua-godot-sample.git
cd noctua-godot-sample
```

Already cloned? `git submodule sync && git submodule update --init`.

Place the config files (from the Noctua team — never commit them) in the project root:

| File | Used by |
|---|---|
| `noctuagg.json` | Noctua SDK (both platforms) |
| `google-services.json` | Firebase, Android. The plugin copies it into `android/build/` and applies the Firebase Gradle plugins at export |
| `GoogleService-Info.plist` | Firebase, iOS |

The SDK is installed as the **GodotNoctua editor plugin** (`addons/GodotNoctua/`, already
enabled in this project). On editor start it registers the `noctua` autoload, installs the
iOS plugin into `ios/plugins/` and prints a `Noctua:` warning for any missing setup.

---

## Run on Android

1. **Project → Install Android Build Template** (creates `android/build/`).
2. Export or one-click deploy with the **Android** preset (Gradle build, debug keystore).

The app is locked to portrait (`display/window/handheld/orientation=1`) and renders with
**GL Compatibility**, so it also runs on emulators whose Vulkan support draws a black screen
(BlueStacks, for example).

The plugin injects the prebuilt bridge (`addons/GodotNoctua/native/android/`), the Maven
dependency and `noctuagg.json` at export time.

## Run on iOS

1. Export with the **iOS** preset (Export Project Only):
   ```bash
   godot --headless --path . --export-debug "iOS" build/ios/NoctuaGodotSample.ipa
   ```
2. Link NoctuaSDK with CocoaPods:
   ```bash
   sdk/ios-plugin/scripts/setup_xcode.sh build/ios .
   ```
3. Open `build/ios/NoctuaGodotSample.xcworkspace`, pick your team, and run on a device.

The plugin installs the prebuilt iOS plugin into `ios/plugins/GodotNoctua/`. Use a real device —
Godot's official iOS simulator library is x86_64-only and does not run on iOS 26 simulators.

The iOS preset uses bundle ID `com.noctuagames.ios.unitysdktest` (matching the test
Firebase project); change it and `application/app_store_team_id` for your own app.

---

## Updating the SDK

```bash
git submodule update --remote sdk
```

Rebuild the native plugins if the bridge changed, then repackage and reinstall the addon:

```bash
(cd sdk/android-plugin && ./gradlew assembleGodot4Release)   # only when the bridge changed
sdk/ios-plugin/scripts/build.sh 4.x                          # only when the bridge changed
rm -rf addons/GodotNoctua && unzip -q "$(sdk/scripts/package_addon.sh 4.x)"
```

Reopen the editor: the plugin sees the new `BUILD` stamp and refreshes `ios/plugins/GodotNoctua/`.

A new iOS SDK version only needs `NOCTUA_IOS_SDK_VERSION=<version>` when running
`setup_xcode.sh` — no plugin rebuild. See the
[SDK README](https://github.com/NoctuaLabs/noctua-godot-sdk#readme) for the full API
reference and troubleshooting.
