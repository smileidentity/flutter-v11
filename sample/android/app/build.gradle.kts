import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.smileidentity.flutter.sample"
    compileSdk = 36

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.smileidentity.flutter.sample"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        getByName("release") {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    tasks.withType<KotlinJvmCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
            freeCompilerArgs.add("-Xskip-metadata-version-check")
        }
    }
    packaging {
        resources {
            excludes += "META-INF/versions/9/OSGI-INF/MANIFEST.MF"
        }
    }
}
val checkSmileConfigFileTask = tasks.register("checkSmileConfigFile") {
    doLast {
        val configFile = file("src/main/assets/smile_config.json")
        if (configFile.readText().isBlank()) {
            throw IllegalArgumentException("Empty smile_config.json file in src/main/assets!")
        }
    }
}

tasks.named("assemble") {
    dependsOn(checkSmileConfigFileTask)
}
