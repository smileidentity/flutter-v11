import org.gradle.kotlin.dsl.withType
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile

val kotlinVersion = findProperty("kotlinVersion") as String? ?: "2.2.21"
val kotlinCompilerExtension = findProperty("kotlinCompilerExtensionVersion") as String? ?: "1.5.14"

extra.apply {
    set("kotlinVersion", kotlinVersion)
    set("kotlinCompilerExtension", kotlinCompilerExtension)
}

buildscript {
    val kotlinVersion = rootProject.findProperty("kotlinVersion") as String? ?: "2.2.21"

    dependencies {
        if (kotlinVersion.startsWith("2")) {
            classpath("org.jetbrains.kotlin:compose-compiler-gradle-plugin:$kotlinVersion")
        } else {
            classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        }
    }
}

allprojects {
    repositories {
        maven {
            url = uri("https://central.sonatype.com/repository/maven-snapshots/")
        }
    }
}

plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("org.jlleitschuh.gradle.ktlint") version "13.1.0"
}

if (kotlinVersion.startsWith("2")) {
    apply(plugin = "org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "com.smileidentity.flutter"
    compileSdk = 36

    defaultConfig {
        minSdk = 21

        // Read version from pubspec.yaml for setWrapperInfo
        val pubspecYaml = File("../pubspec.yaml")
        val pubspecText = pubspecYaml.readText()
        val versionLine = Regex("""version:\s*(.+)""").find(pubspecText)
        val version = if (versionLine != null) {
            pubspecText.split(Regex("""version:\s*"""))[1].split("\n")[0].trim()
        } else {
            "11.0.0"
        }
        buildConfigField("String", "SMILE_ID_VERSION", "\"$version\"")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    tasks.withType<KotlinJvmCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
            freeCompilerArgs.add("-Xskip-metadata-version-check")
        }
    }

    sourceSets {
        sourceSets["main"].java.srcDirs("src/main/kotlin")
        sourceSets["test"].java.srcDirs("src/test/kotlin")
    }

    lint {
        disable.add("NullSafeMutableLiveData")
    }

    buildFeatures {
        buildConfig = true
        compose = true
    }
    if (!kotlinVersion.startsWith("2")) {
        composeOptions {
            kotlinCompilerExtensionVersion = kotlinCompilerExtension
        }
    }
}

dependencies {
    implementation("com.smileidentity:android-sdk:11.1.5")
    implementation("androidx.core:core-ktx:1.17.0")
    implementation(platform("androidx.compose:compose-bom:2025.11.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.9.4")
    implementation("androidx.fragment:fragment-ktx:1.8.9")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.2")
    implementation("org.jetbrains.kotlinx:kotlinx-collections-immutable:0.4.0")
    implementation("com.google.mlkit:object-detection:17.0.2")

    testImplementation("org.jetbrains.kotlin:kotlin-test:$kotlinVersion")
    testImplementation("io.mockk:mockk:1.14.6")
}

ktlint {
    android.set(true)
    filter {
        exclude { it.file.path.contains(".g.kt") }
    }
}
