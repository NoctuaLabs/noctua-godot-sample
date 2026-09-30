@tool
extends EditorExportPlugin

func _get_name() -> String:
	return "GodotNoctua"

func _supports_platform(platform: EditorExportPlatform) -> bool:
	return platform is EditorExportPlatformAndroid

func _get_android_libraries(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
	# Only the release AAR is built; it is used for debug exports as well.
	return PackedStringArray(["android/plugins/GodotNoctua.godot4Release.aar"])

func _get_android_dependencies(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
	return PackedStringArray([
		"com.noctuagames.sdk:noctua-android-sdk:0.34.0",
	])

func _get_android_dependencies_maven_repos(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
	return PackedStringArray([
		"https://dl.google.com/dl/android/maven2",
		"https://repo1.maven.org/maven2",
	])
