// PLACE THIS ONLY IN: android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.bakery_management"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // REDIRECTS THE BUILD PATH SO FLUTTER LOOPS FIND THE APK AUTOMATICALLY
    layout.buildDirectory.set(layout.projectDirectory.dir("../../build/app"))

    compileOptions {
        // ENABLES CORE LIBRARY DESUGARING FOR FLUTTER LOCAL NOTIFICATIONS
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.bakery_management"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ADD THE DESUGARING ENGINE SYSTEM LOADER
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}