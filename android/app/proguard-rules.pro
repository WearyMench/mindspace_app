# Flutter specific ProGuard rules
# For more details, see https://flutter.dev/docs/deployment/android#enabling-proguard

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter engine
-keep class io.flutter.embedding.** { *; }

# Flutter local notifications
-keep class com.dexterous.** { *; }

# SQLite
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# Shared preferences
-keep class android.content.SharedPreferences { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R8 from removing classes that are only used via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep classes that might be used via reflection
-keep class com.mindspace.wellness.** { *; }

# Keep all classes in the main package
-keep class com.mindspace.wellness.MainActivity { *; }

# Google Play Core (for deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter deferred components
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# Keep all Flutter engine classes
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# Keep all plugin classes
-keep class io.flutter.plugins.** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep all Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep all Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep classes that might be used via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep all classes that might be accessed via reflection
-keep class * {
    @androidx.annotation.Keep *;
}

# Keep all classes in the main package and subpackages
-keep class com.mindspace.wellness.** { *; }
