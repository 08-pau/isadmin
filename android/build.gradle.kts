// build.gradle.kts (raíz del proyecto Android)

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.2.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.0")
        classpath("com.google.gms:google-services:4.4.0") // si usas Firebase
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Opcional: cambiar la carpeta build a un nivel común
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
