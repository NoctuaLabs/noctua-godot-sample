# CLAUDE.md — Godot Noctua App

## Project Overview

A Godot 4 sample/test application for the Noctua SDK. It exercises event tracking, revenue tracking, IAP, ad revenue, and session management via the Noctua Godot plugin and serves as the integration reference for the SDK team.

- **Godot**: 4.6.x
- **Platforms**: Android · iOS

---

## Repository Layout

```
scenes/
  main.tscn                    # Main scene (portrait, 1080×1920)
scripts/
  main.gd                      # Demo UI — wires buttons to Noctua SDK calls
sdk/                           # git submodule → slabgames/godot-noctua (branch: fix/gdscript-api-alignment)
  gd/noctua.gd                 # GDScript autoload singleton (registered as "adjust")
  android-plugin/
    src/…/GodotNoctua.java     # Android plugin bridge
    build.gradle               # Gradle build (produces GodotNoctua.*.aar)
    GodotNoctua.gdap           # Android plugin descriptor (SDK copy — not loaded by Godot editor)
  noctua/
    adjust.mm / adjust.h       # iOS native bridge (legacy filenames)
    adjust.gdip                # iOS plugin descriptor
    AdjustSdk.framework/       # Pre-built Noctua iOS framework
android/
  plugins/
    GodotNoctua.gdap           # Android plugin descriptor (loaded by Godot editor)
    GodotNoctua.release.aar    # Pre-built Android plugin binary
ios/
  plugins/
    adjust/
      adjust.gdip              # iOS plugin descriptor (loaded by Godot editor)
export_presets.cfg             # Godot export configs (Android + iOS)
project.godot                  # Project settings — autoload, display, rendering
```

> The `sdk/` folder is a git submodule. After cloning, run `git submodule update --init` to populate it.

---

## GDScript API

The SDK auto-registers as the `adjust` autoload singleton. No manual initialisation is needed — the SDK reads `noctuagg.json` from the project root automatically.

```gdscript
# ── Event Tracking ────────────────────────────────────────────────────────────
adjust.track_event(event: String)
adjust.track_event_with_params(event: String, params: Dictionary)

# ── Revenue Tracking ──────────────────────────────────────────────────────────
adjust.track_revenue(event: String, revenue: float, currency := "USD")
adjust.track_purchase(order_id: String, amount: String, currency: String, payload: Dictionary)
adjust.track_ad_revenue(ad_source: String, revenue: String, currency: String, params: Dictionary)
adjust.track_custom_event_with_revenue(event_name: String, revenue: String, currency: String, payload: Dictionary)

# ── Session ───────────────────────────────────────────────────────────────────
adjust.set_session_tag(session_name: String)
adjust.get_session_tag() -> String
adjust.set_session_extra_params(params: Dictionary)

# ── Experiments ───────────────────────────────────────────────────────────────
adjust.set_experiment(experiment: String)
adjust.get_experiment() -> String
adjust.set_general_experiment(experiment: String)
adjust.get_general_experiment(key: String) -> String

# ── Network State ─────────────────────────────────────────────────────────────
adjust.on_online()
adjust.on_offline()
```

All calls are no-ops when running in the editor (no native plugin) — the expected desktop warning is:  
`Noctua plugin not found! Running without native SDK.`

---

## Config Files (never commit)

These files contain credentials. Obtain from the Noctua team and place in the **project root**:

| File | Purpose |
|------|---------|
| `noctuagg.json` | Noctua SDK config — `clientId`, `gameId`, Noctua tokens, AdMob/AppLovin ad unit IDs, IAA/IAP settings |
| `google-services.json` | Firebase config — project number, OAuth client IDs, API key |

Both are listed in `.gitignore` and must never be committed.

> For Android builds, `google-services.json` must also be copied to `android/build/app/` so the Firebase Gradle plugin can process it.

---

## Android Build Setup

### One-time setup

1. In Godot: **Project → Export → Android** → install the custom build template.  
   This generates `android/build/`.
2. Copy `google-services.json` into `android/build/app/`.
3. Ensure `android/plugins/GodotNoctua.gdap` references the correct AAR filename.
4. Place a valid `noctuagg.json` in the project root.

### Rebuild the plugin AAR (when SDK changes)

```bash
cd sdk/android-plugin

# Requires the Godot AAR in sdk/android-plugin/libs/
# Download from https://github.com/godotengine/godot/releases
# File: godot-lib-<version>-template_release.aar

JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" \
  ./gradlew assembleRelease

cp build/outputs/aar/GodotNoctua.release.aar ../../android/plugins/
```

### Run on device

Build via **Godot Export → Android** or:
```bash
cd android/build
./gradlew assembleDebug
```

---

## iOS Build Setup

1. Export from Godot to generate the Xcode project.
2. Build the xcframework from `sdk/`:
   ```bash
   cd sdk
   ./scripts/release_xcframework.sh adjust 4.0
   # Output: bin/adjust.release.xcframework
   ```
3. Copy `adjust.release.xcframework` to `ios/plugins/adjust/`.
4. Ensure `GoogleService-Info.plist` (iOS Firebase config) is added to the Xcode project.
5. The `ios/plugins/adjust/adjust.gdip` descriptor references the framework and system dependencies.

---

## Submodule Notes

| Command | Purpose |
|---------|---------|
| `git submodule update --init` | Populate `sdk/` after a fresh clone |
| `git submodule update --remote` | Pull latest SDK changes from remote |
| Commit inside `sdk/` then commit in root | Update the submodule pointer after SDK changes |

The submodule currently tracks branch `fix/gdscript-api-alignment` of `slabgames/godot-noctua`.

---

## Testing

Manual workflow:
1. Place `noctuagg.json` (with `"sandboxEnabled": true`) and `google-services.json` in the project root.
2. Build and run on a physical Android device.
3. Use the in-app UI to fire events (track event, track revenue, track purchase, track ad revenue, set session tag).
4. Verify events appear in the Noctua dashboard.
