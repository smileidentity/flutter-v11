pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    plugins {
        id("com.android.library") version "8.9.2"
        id("org.jetbrains.kotlin.android") version "2.2.21"
        id("org.jetbrains.kotlin.plugin.compose") version "2.2.21"
        id("org.jlleitschuh.gradle.ktlint") version "13.1.0"
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://central.sonatype.com/repository/maven-snapshots/") }
    }
}

rootProject.name = "smile_id_flutter"
