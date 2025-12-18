# Keep flutter_local_notifications classes
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.** { *; }

# Keep generic signatures for TypeToken (required for flutter_local_notifications)
-keepattributes Signature
-keepattributes *Annotation*

# Keep Gson classes used by flutter_local_notifications
-keepattributes Signature
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

