# CLAUDE.md — Godot Noctua App

## Project Overview

A Godot 4 sample/test application for the Noctua SDK. It exercises event tracking, revenue tracking, IAP, ad revenue, and session management via the Noctua Godot plugin and serves as the integration reference for the SDK team.

- **Godot**: 4.2+ (plugin v2 format); project last saved with 4.6.1 (`android/.build_version`)
- **Platform**: Android + iOS
- **SDK**: `com.noctuagames.sdk:noctua-android-sdk:0.35.1` (via the `sdk/` submodule)
- **iOS SDK**: CocoaPods `NoctuaSDK 0.40.1` (installed after export by `sdk/ios-plugin/scripts/setup_xcode.sh`)

---

## Repository Layout

```
scenes/
  main.tscn                    # Main scene (portrait, 1080×1920)
scripts/
  main.gd                      # Demo UI — wires buttons to Noctua SDK calls via `noctua.*`
addons/
  GodotNoctua/
	plugin.cfg                 # EditorPlugin descriptor (Godot 4.2+ v2 format)
	GodotNoctuaPlugin.gd       # EditorPlugin — registers the export plugin on editor start
	export_plugin.gd           # EditorExportPlugin — injects AAR + Maven deps at export time
sdk/                           # git submodule → NoctuaLabs/noctua-godot-sdk (main)
  gd/noctua.gd                 # GDScript autoload singleton (registered as "noctua")
  android-plugin/
	src/main/…/GodotNoctua.java     # Java plugin bridge (shared)
	src/godot3/AndroidManifest.xml  # Godot 3.x: plugin v1 meta-data
	src/godot4/AndroidManifest.xml  # Godot 4.x: plugin v2 meta-data
	build.gradle                    # Gradle — godot3/godot4 product flavors
android/
  plugins/
	GodotNoctua.godot4Release.aar   # Pre-built plugin for Godot 4.x (EditorExportPlugin uses this)
	GodotNoctua.godot3.gdap         # Plugin descriptor for Godot 3.x projects
ios/
  plugins/GodotNoctua/          # iOS plugin: GodotNoctua.gdip + {debug,release}.xcframework (built by sdk/ios-plugin/scripts/build.sh 4.x)
sdk/ios-plugin/                # iOS Objective-C++ bridge source, build + post-export scripts
export_presets.cfg             # Godot export configs (Android, iOS)
README.md                      # Overview, run on Android/iOS, updating the SDK
project.godot                  # Project settings — autoload + EditorPlugin enabled
```

> The `sdk/` folder is a git submodule. After cloning, run:
> ```bash
> git submodule update --init
> ```

---

## Plugin Architecture (v2)

This project uses the **Godot 4.2+ v2 plugin format**, replacing the deprecated `.gdap` file with an `EditorExportPlugin` addon:

| Component | File | Role |
|-----------|------|------|
| EditorPlugin | `addons/GodotNoctua/GodotNoctuaPlugin.gd` | Loaded by Godot editor on startup (enabled in Project Settings → Plugins) |
| EditorExportPlugin | `addons/GodotNoctua/export_plugin.gd` | Called at export time — injects the AAR and Maven dependency |
| Java bridge | `sdk/android-plugin/…/GodotNoctua.java` | Runtime plugin, discovered via `AndroidManifest.xml` v2 meta-data |
| AAR binary | `android/plugins/GodotNoctua.godot4Release.aar` | Bundled into the APK at export (debug and release) |
| iOS plugin | `ios/plugins/GodotNoctua/GodotNoctua.gdip` | Links the GodotNoctua xcframework; registers the same `GodotNoctua` singleton as Android |

The `export_plugin.gd` injects:
- **Library**: `res://android/plugins/GodotNoctua.godot4Release.aar` (used for both debug and release exports; must be a `res://` path — relative paths resolve under `res://addons/`)
- **Maven dep**: `com.noctuagames.sdk:noctua-android-sdk:0.35.1` (must match `sdk/android-plugin/build.gradle`)
- **Repos**: Google Maven + Maven Central

---

## GDScript API

The SDK auto-registers as the **`noctua`** autoload singleton. No manual initialisation is needed — the SDK reads `noctuagg.json` from the project root automatically.

```gdscript
# ── Event Tracking ────────────────────────────────────────────────────────────
noctua.track_event(event: String)
noctua.track_event_with_params(event: String, params: Dictionary)

# ── Revenue Tracking ──────────────────────────────────────────────────────────
noctua.track_purchase(order_id: String, amount: String, currency: String, payload: Dictionary)
noctua.track_ad_revenue(ad_source: String, revenue: String, currency: String, params: Dictionary)
noctua.track_custom_event_with_revenue(event_name: String, revenue: float, currency := "USD", payload := {})

# ── Session ───────────────────────────────────────────────────────────────────
noctua.set_session_tag(session_name: String)
noctua.get_session_tag() -> String
noctua.set_session_extra_params(params: Dictionary)

# ── Experiments ───────────────────────────────────────────────────────────────
noctua.set_experiment(experiment: String)
noctua.get_experiment() -> String
noctua.set_general_experiment(experiment: String)
noctua.get_general_experiment(key: String) -> String

# ── Network State ─────────────────────────────────────────────────────────────
noctua.on_online()
noctua.on_offline()
```

All calls are no-ops in the editor (no native plugin). Expected desktop warning:
`Noctua plugin not found! Running without native SDK.`

---

## Config Files (never commit)

These files contain credentials. Obtain from the Noctua team and place in the **project root**:

| File | Purpose |
|------|---------|
| `noctuagg.json` | Noctua SDK config — `clientId`, `gameId`, Noctua tokens, AdMob/AppLovin ad unit IDs, IAA/IAP settings |
| `google-services.json` | Firebase config (Android) — project number, OAuth client IDs, API key |
| `GoogleService-Info.plist` | Firebase config (iOS) — bundle ID `com.noctuagames.ios.unitysdktest`, project `noctua-sdk-test` |

Both are listed in `.gitignore` and must never be committed.

> For Android builds, `google-services.json` must also be copied to `android/build/app/` so the Firebase Gradle plugin can process it.

---

## Android Build Setup

### One-time setup

1. In Godot: **Project → Export → Android** → install the custom build template (generates `android/build/`).
2. Copy `google-services.json` into `android/build/app/`.
3. Place `noctuagg.json` in the project root.
4. Enable the plugin: **Project → Project Settings → Plugins → GodotNoctua** → tick **Enable**.

### Rebuild the plugin AAR (when SDK changes)

```bash
cd sdk/android-plugin

# Download Godot AARs from https://github.com/godotengine/godot/releases
# Place godot-lib-3.6.2.*.aar in libs/godot3/
# Place godot-lib-4.x.x.*.aar in libs/godot4/

JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" \
  ./gradlew assembleGodot4Release   # for Godot 4.x (used by this sample app)
  # or: ./gradlew assembleRelease   # builds both godot3 + godot4 variants

cp build/outputs/aar/GodotNoctua.godot4Release.aar ../../android/plugins/
```

### Run on device

Build via **Godot Export → Android** or:
```bash
cd android/build && ./gradlew assembleDebug
```

---

## iOS Build Setup

1. Build the plugin (once per SDK change): `sdk/ios-plugin/scripts/build.sh 4.x`, then copy `sdk/ios-plugin/bin/4.x/GodotNoctua/` to `ios/plugins/GodotNoctua/`.
2. Export with the **iOS** preset (Export Project Only, team `2TFDF8BB6J`, bundle `com.noctuagames.ios.unitysdktest`, min iOS 15.0):
   ```bash
   /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-debug "iOS" build/ios/NoctuaGodotSample.ipa
   ```
3. Link NoctuaSDK: `sdk/ios-plugin/scripts/setup_xcode.sh build/ios .`
4. Open `build/ios/NoctuaGodotSample.xcworkspace` and run on a device (Godot's simulator library is x86_64-only; iOS 26 simulators cannot run it).

## Submodule Notes

| Command | Purpose |
|---------|---------|
| `git submodule update --init` | Populate `sdk/` after a fresh clone |
| `git submodule update --remote` | Pull latest SDK changes from remote |
| Commit inside `sdk/`, then commit in root | Update the submodule pointer after SDK changes |

The submodule tracks branch `main` of `NoctuaLabs/noctua-godot-sdk` (set via `branch = main` in `.gitmodules`).

---

## Maintenance — Keeping This File Current

**Update this CLAUDE.md whenever:**

| Change | Section to update |
|--------|------------------|
| New file or directory added | Repository Layout |
| File or directory removed | Repository Layout |
| New method added to `sdk/gd/noctua.gd` | GDScript API |
| Method removed or signature changed | GDScript API |
| Noctua Android SDK version bumped | Project Overview · export_plugin.gd dep string |
| Build step changes | Android Build Setup |
| Submodule branch changes | Repository Layout · Submodule Notes |
| New config file required | Config Files table |
| Plugin addon structure changes | Plugin Architecture table |
| NoctuaSDK iOS pod version bumped | Project Overview · `setup_xcode.sh` DEFAULT_SDK_VERSION · `noctua_sdk_api.h` selectors |

---

## Testing

Manual workflow:
1. Place `noctuagg.json` (with `"sandboxEnabled": true`) and `google-services.json` in the project root.
2. Enable the plugin: **Project → Project Settings → Plugins → GodotNoctua**.
3. Build and run on a physical Android device and/or iPhone (see iOS Build Setup).
4. Use the in-app UI to fire: track event, track revenue, track purchase, track ad revenue, set session tag.
5. Verify events appear in the Noctua dashboard.
