# ProGuard and R8 rules for FridgeWise

# Keep SharedPreferences Flutter plugin Pigeon-generated API registrar and companion classes
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

