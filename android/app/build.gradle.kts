plugins {
    id("com.android.application")
    id("kotlin-android")
    //Flutter Gradle Plugin must be applied last
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.smarthome"
    compileSdk = flutter.compileSdkVersion

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
    compileSdk = 35
    defaultConfig {
        applicationId = "com.example.smarthome"
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        minSdk = 23
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}