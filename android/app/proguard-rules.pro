#######################
# Flutter & Dart core #
#######################

-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

-keep class io.flutter.plugins.** { *; }

#########################
# Firebase & Firestore #
#########################

-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

-keep class com.google.firestore.** { *; }
-dontwarn com.google.firestore.**

##################
# InAppWebView   #
##################

-keep class com.pichillilorenzo.** { *; }
-dontwarn com.pichillilorenzo.**

##########################
# YouTube & Video player #
##########################

-keep class com.pierfrancescosoffritti.androidyoutubeplayer.** { *; }
-dontwarn com.pierfrancescosoffritti.androidyoutubeplayer.**

##################
# AndroidX       #
##################

-keep class androidx.** { *; }
-dontwarn androidx.**

##################
# Kotlin Support #
##################

-keep class kotlin.** { *; }
-dontwarn kotlin.**

-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

##################
# OkHttp / Retrofit #
##################

-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

##################
# Gson / JSON    #
##################

-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

#########################################
# Android R class (prevents resource errors)
#########################################

-keep class **.R$* { *; }

#############################
# Logs - remove for release #
#############################

-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

#########################################
# Fix for Android 14 BackEvent R8 Error #
#########################################

-dontwarn android.window.BackEvent
-keep class android.window.BackEvent { *; }
