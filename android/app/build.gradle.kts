plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.isadmin"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true // ESTA LÍNEA ES CLAVE
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.isadmin"
        minSdk = 23
        targetSdk = 35
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
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    implementation("com.google.firebase:firebase-storage")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-analytics")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
