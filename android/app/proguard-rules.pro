# Flutter Proguard Rules for Mukhliss Merchant
# Keep Flutter and Dart code
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Supabase
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**

# Keep Sentry
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# Keep GetIt
-keep class com.get_it.** { *; }

# Keep QR Scanner
-keep class net.sourceforge.zbar.** { *; }
-dontwarn net.sourceforge.zbar.**

# Keep model classes for JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# General Android rules
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Optimization
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
