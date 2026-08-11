pluginManagement {
    val flutterSdkPath = System.getenv("FLUTTER_ROOT")
    if (flutterSdkPath != null) {
        settings.ext["flutterSdkPath"] = flutterSdkPath
    }
    includeBuild("${settings.ext["flutterSdkPath"]}/packages/flutter_tools/gradle")
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.1" apply false
}

include(":app")
