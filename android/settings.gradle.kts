pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven { url = uri("https://central.sonatype.com/repository/maven-snapshots/") }
    }
    plugins {
        id("com.android.library") version "9.2.1"
        id("org.jetbrains.kotlin.android") version "2.4.0"
        id("org.jetbrains.kotlin.plugin.compose") version "2.4.0"
        id("org.jlleitschuh.gradle.ktlint") version "14.2.0"
    }
}
plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
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
