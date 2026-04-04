# GetX
-keep class com.getwidgets.** { *; }
-keep class com.get** { *; }

# Dio
-keep class com.dio.** { *; }

# Keep all feature classes (especially data models)
-keep class com.example.giolee78.features.** { *; }
-keep interface com.example.giolee78.features.** { *; }

# Keep app data models
-keep class com.example.giolee78.data.** { *; }
-keep class com.example.giolee78.models.** { *; }

# General Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.android.gms.location.** { *; }

# Play Core (fix for missing classes during R8)
-dontwarn com.google.android.play.core.**
