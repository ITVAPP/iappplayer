# IApp Player 混淆规则

# 解决 StringConcatFactory 错误（最重要的）
-dontwarn java.lang.invoke.StringConcatFactory
-dontwarn java.lang.invoke.MethodHandle
-dontwarn java.lang.invoke.MethodHandles
-dontwarn java.lang.invoke.MethodHandles$Lookup

# 保留 IApp Player 所有类
-keep class com.itvapp.iapp_player.** { *; }
-keepclassmembers class com.itvapp.iapp_player.** { *; }

# 特别保留 DataSourceUtils 相关类（因为错误提到这个类）
-keep class com.itvapp.iapp_player.DataSourceUtils { *; }
-keep class com.itvapp.iapp_player.DataSourceUtils$* { *; }

# Media3/ExoPlayer 规则
-keep class androidx.media3.** { *; }
-keep interface androidx.media3.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

# Cronet 网络库
-keep class org.chromium.net.** { *; }
-keep class com.google.net.cronet.** { *; }

# FFmpeg 解码器
-keep class org.jellyfin.** { *; }

# WorkManager
-keep class androidx.work.** { *; }

# Kotlin 相关
-keep class kotlin.** { *; }
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# 保留注解
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions

# 其他常见警告忽略
-dontwarn org.kxml2.io.**
-dontwarn org.xmlpull.v1.**
-dontwarn android.content.res.**
-dontwarn org.slf4j.impl.StaticLoggerBinder
