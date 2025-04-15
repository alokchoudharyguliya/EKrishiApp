// // plugins {
// //     id("com.android.application")
// //     id("kotlin-android")
// //     // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
// //     id("dev.flutter.flutter-gradle-plugin")
// // }

// // android {
// //     namespace = "com.example.news"
// //     compileSdk = flutter.compileSdkVersion
// //             ndkVersion = "27.0.12077973"

// //     compileOptions {
// //         sourceCompatibility = JavaVersion.VERSION_11
// //         targetCompatibility = JavaVersion.VERSION_11
// //     }

// //     kotlinOptions {
// //         jvmTarget = JavaVersion.VERSION_11.toString()
// //     }

// //     defaultConfig {
// //         // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
// //         applicationId = "com.example.news"
// //         // You can update the following values to match your application needs.
// //         // For more information, see: https://flutter.dev/to/review-gradle-config.
// //         minSdk = flutter.minSdkVersion
// //         targetSdk = flutter.targetSdkVersion
// //         versionCode = flutter.versionCode
// //         versionName = flutter.versionName
// //     }

// //     buildTypes {
// //         release {
// //             // TODO: Add your own signing config for the release build.
// //             // Signing with the debug keys for now, so `flutter run --release` works.
// //             signingConfig = signingConfigs.getByName("debug")
// //         }
// //     }
// // }

// // flutter {
// //     source = "../.."
// // }


// /////////////////V2

// // android/app/build.gradle.kts
// // plugins {
// //     id("com.android.application")
// //     id("kotlin-android")
// //     id("dev.flutter.flutter-gradle-plugin")
// //     id("com.google.gms.google-services") // Add this line (must be last)
// // }

// // android {
// //     namespace = "com.example.news"
// //     compileSdk = flutter.compileSdkVersion
// //     ndkVersion = "27.0.12077973"

// //     compileOptions {
// //         sourceCompatibility = JavaVersion.VERSION_11
// //         targetCompatibility = JavaVersion.VERSION_11
// //     }

// //     kotlinOptions {
// //         jvmTarget = JavaVersion.VERSION_11.toString()
// //     }

// //     defaultConfig {
// //         applicationId = "com.example.newscalendar"
// //         minSdk = flutter.minSdkVersion
// //         targetSdk = flutter.targetSdkVersion
// //         versionCode = flutter.versionCode
// //         versionName = flutter.versionName
// //         multiDexEnabled = true // Add for Firebase
// //     }

// //     buildTypes {
// //         release {
// //             signingConfig = signingConfigs.getByName("debug")
// //             // Enable Proguard for release builds
// //             isMinifyEnabled = true
// //             proguardFiles(
// //                 getDefaultProguardFile("proguard-android.txt"),
// //                 "proguard-rules.pro"
// //             )
// //         }
// //     }
// // }

// // dependencies {
// //     implementation(platform("com.google.firebase:firebase-bom:32.7.0")) // Firebase BoM
// //     implementation("com.google.firebase:firebase-auth-ktx") // Auth
// //     implementation("com.google.firebase:firebase-analytics-ktx") // Analytics
// //     implementation("androidx.multidex:multidex:2.0.1")
// //     implementation("com.google.firebase:firebase-analytics")
// //     implementation(platform("com.google.firebase:firebase-bom:33.12.0"))

// // }

// // flutter {
// //     source = "../.."
// // }

 

//  plugins {
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
//         applicationId = "com.example.project"
//         // You can update the following values to match your application needs.
//         // For more information, see: https://flutter.dev/to/review-gradle-config.
//         minSdk = flutter.minSdkVersion
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

