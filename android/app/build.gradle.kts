plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun loadLocalOauthEnv(): Map<String, String> {
    // android/ → project root
    val envFile = rootProject.file("../local.oauth.env")
    if (!envFile.exists()) return emptyMap()
    val out = mutableMapOf<String, String>()
    envFile.readLines().forEach { raw ->
        val line = raw.trim()
        if (line.isEmpty() || line.startsWith("#") || !line.contains("=")) return@forEach
        val eq = line.indexOf('=')
        val key = line.substring(0, eq).trim()
        var value = line.substring(eq + 1).trim()
        if (value.length >= 2) {
            val q = value.first()
            if ((q == '"' || q == '\'') && value.last() == q) {
                value = value.substring(1, value.length - 1)
            }
        }
        if (key.isNotEmpty() && value.isNotEmpty()) {
            out[key] = value
        }
    }
    return out
}

fun googleOAuthRedirectSchemeFromEnv(env: Map<String, String>): String {
    val clientId = (env["GOOGLE_OAUTH_CLIENT_ID_ANDROID"]
        ?: env["GOOGLE_OAUTH_CLIENT_ID"]
        ?: "").trim()
    if (clientId.isEmpty()) {
        // Placeholder so APK builds without local.oauth.env still merge the manifest.
        // Sign-in will not work until GOOGLE_OAUTH_CLIENT_ID_ANDROID is set.
        return "com.googleusercontent.apps.missing"
    }
    val suffix = ".apps.googleusercontent.com"
    val prefix = if (clientId.endsWith(suffix)) {
        clientId.removeSuffix(suffix)
    } else {
        clientId
    }
    return "com.googleusercontent.apps.$prefix"
}

val localOauthEnv = loadLocalOauthEnv()
val googleOAuthRedirectScheme = googleOAuthRedirectSchemeFromEnv(localOauthEnv)

android {
    namespace = "com.valtero.valtero"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.valtero.valtero"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["googleOAuthRedirectScheme"] = googleOAuthRedirectScheme
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
