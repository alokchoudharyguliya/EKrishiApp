// // allprojects {
// //     repositories {
// //         google()
// //         mavenCentral()
// //     }
// // }

// // val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
// // rootProject.layout.buildDirectory.value(newBuildDir)

// // subprojects {
// //     val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
// //     project.layout.buildDirectory.value(newSubprojectBuildDir)
// // }
// // subprojects {
// //     project.evaluationDependsOn(":app")
// // }

// // tasks.register<Delete>("clean") {
// //     delete(rootProject.layout.buildDirectory)
// // }



// //////////////////////////V2

// // // android/build.gradle.kts
// // buildscript {
// //     repositories {
// //         google()
// //         mavenCentral()
// //     }
// //     dependencies {
// //         classpath("com.android.tools.build:gradle:7.3.1")
// //         classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.20")
// //         classpath("com.google.gms:google-services:4.4.2")
// //     }
// // }

// // allprojects {
// //     repositories {
// //         google()
// //         mavenCentral()
// //     }
// // }

// // val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
// // rootProject.layout.buildDirectory.value(newBuildDir)

// // subprojects {
// //     val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
// //     project.layout.buildDirectory.value(newSubprojectBuildDir)
// //     // Add Firebase dependency resolution strategy
// //     afterEvaluate {
// //         configurations.all {
// //             resolutionStrategy {
// //                 force("com.google.firebase:firebase-analytics:21.5.0")
// //                 force("com.google.firebase:firebase-auth:22.3.1")
// //             }
// //         }
// //     }
// // }

// // tasks.register<Delete>("clean") {
// //     delete(rootProject.layout.buildDirectory)
// // }


// // allprojects {
// //     repositories {
// //         google()
// //         mavenCentral()
// //     }
// // }

// // val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
// // rootProject.layout.buildDirectory.value(newBuildDir)

// // subprojects {
// //     val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
// //     project.layout.buildDirectory.value(newSubprojectBuildDir)
// // }
// // subprojects {
// //     project.evaluationDependsOn(":app")
// // }

// // tasks.register<Delete>("clean") {
// //     delete(rootProject.layout.buildDirectory)
// // }



// plugins {
//     id("com.android.application")
//     id("kotlin-android")
//     // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
//     id("dev.flutter.flutter-gradle-plugin")
// }

// android {
//     namespace = "com.example.project"
//     compileSdk = flutter.compileSdkVersion
//     ndkVersion = flutter.ndkVersion

//     compileOptions {
//         sourceCompatibility = JavaVersion.VERSION_11
//         targetCompatibility = JavaVersion.VERSION_11
//     }

//     kotlinOptions {
//         jvmTarget = JavaVersion.VERSION_11.toString()
//     }

//     defaultConfig {
//         // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
//         applicationId = "com.example.newscalendar"
//         // You can update the following values to match your application needs.
//         // For more information, see: https://flutter.dev/to/review-gradle-config.
//         minSdk = 23
//         targetSdk = flutter.targetSdkVersion
//         versionCode = flutter.versionCode
//         versionName = flutter.versionName
//     }

//     buildTypes {
//         release {
//             // TODO: Add your own signing config for the release build.
//             // Signing with the debug keys for now, so `flutter run --release` works.
//             signingConfig = signingConfigs.getByName("debug")
//         }
//     }
// }

// flutter {
//     source = "../.."
// }
