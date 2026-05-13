# CLAUDE.md — Godot Noctua App

## Project Overview

A Godot 4 sample/test application for the Noctua SDK. It exercises event tracking, revenue tracking, IAP, ad revenue, and session management via the Noctua Godot plugin and serves as the integration reference for the SDK team.

- **Godot**: 4.2+ (plugin v2 format)
- **Platform**: Android
- **SDK**: `com.noctuagames.sdk:noctua-android-sdk:0.32.0` (via the `sdk/` submodule)

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
sdk/                           # git submodule → slabgames/godot-noctua (fix/gdscript-api-alignment)
  gd/noctua.gd                 # GDScript autoload singleton (registered as "noctua")
  android-plugin/
    src/…/GodotNoctua.java     # Android plugin bridge (v2)
    src/…/AndroidManifest.xml  # Plugin v2 meta-data (org.godotengine.plugin.v2.GodotNoctua)
    build.gradle               # Gradle build → GodotNoctua.*.aar
android/
  plugins/
    GodotNoctua.release.aar    # Pre-built Android plugin binary
export_presets.cfg             # Godot export configs (Android)
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
| AAR binary | `android/plugins/GodotNoctua.release.aar` | Bundled into the APK at export |

The `export_plugin.gd` injects:
- **Library**: `android/plugins/GodotNoctua.release.aar`
- **Maven dep**: `com.noctuagames.sdk:noctua-android-sdk:0.32.0`
- **Repos**: Google Maven + Maven Central

---

## GDScript API

The SDK auto-registers as the **`noctua`** autoload singleton. No manual initialisation is needed — the SDK reads `noctuagg.json` from the project root automatically.

```gdscript
# ── Event Tracking ────────────────────────────────────────────────────────────
noctua.track_event(event: String)
noctua.track_event_with_params(event: String, params: Dictionary)

# ── Revenue Tracking ──────────────────────────────────────────────────────────
noctua.track_revenue(event: String, revenue: float, currency := "USD")
noctua.track_purchase(order_id: String, amount: String, currency: String, payload: Dictionary)
noctua.track_ad_revenue(ad_source: String, revenue: String, currency: String, params: Dictionary)
noctua.track_custom_event_with_revenue(event_name: String, revenue: String, currency: String, payload: Dictionary)

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
| `google-services.json` | Firebase config — project number, OAuth client IDs, API key |

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
cd android/build && ./gradlew assembleDebug
```

---

## Submodule Notes

| Command | Purpose |
|---------|---------|
| `git submodule update --init` | Populate `sdk/` after a fresh clone |
| `git submodule update --remote` | Pull latest SDK changes from remote |
| Commit inside `sdk/`, then commit in root | Update the submodule pointer after SDK changes |

The submodule tracks branch `fix/gdscript-api-alignment` of `slabgames/godot-noctua`.

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

---

## Testing

Manual workflow:
1. Place `noctuagg.json` (with `"sandboxEnabled": true`) and `google-services.json` in the project root.
2. Enable the plugin: **Project → Project Settings → Plugins → GodotNoctua**.
3. Build and run on a physical Android device.
4. Use the in-app UI to fire: track event, track revenue, track purchase, track ad revenue, set session tag.
5. Verify events appear in the Noctua dashboard.
