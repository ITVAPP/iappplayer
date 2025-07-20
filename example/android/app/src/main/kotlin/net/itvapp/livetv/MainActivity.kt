package net.itvapp.livetv

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.app.UiModeManager
import android.content.res.Configuration
import android.os.Build
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "net.itvapp.livetv"
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        // 优化窗口背景设置
        window.setBackgroundDrawableResource(android.R.color.transparent)
        
        // 优化刘海屏适配
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            window.attributes.layoutInDisplayCutoutMode = 
                WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
        }
        
        super.onCreate(savedInstanceState)
        
        // 创建通知渠道
        createNotificationChannel()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val channelId = CHANNEL // 使用包名作为渠道 ID
                // 动态获取桌面图标名称（android:label）
                val appInfo = packageManager.getApplicationInfo(packageName, 0)
                val channelName = packageManager.getApplicationLabel(appInfo).toString()
                
                val importance = NotificationManager.IMPORTANCE_DEFAULT
                val channel = NotificationChannel(channelId, channelName, importance).apply {
                    description = "Notification for live TV playback"
                    // 优化通知显示
                    enableLights(true)
                    enableVibration(false)
                }
                
                val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.createNotificationChannel(channel)
            } catch (e: PackageManager.NameNotFoundException) {
                // 增强错误处理
                e.printStackTrace()
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isTV" -> {
                    // 优化：将检测逻辑放到后台线程执行，避免阻塞UI
                    Thread {
                        val isTV = isTVDevice()
                        // 确保在主线程回调结果
                        handler.post { 
                            result.success(isTV) 
                        }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isTVDevice(): Boolean {
        val uiModeManager = getSystemService(Context.UI_MODE_SERVICE) as UiModeManager
        val isTelevision = uiModeManager.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION
        val isTVBox = Build.DEVICE.contains("box", ignoreCase = true) || Build.MODEL.contains("box", ignoreCase = true)
        val isTVFingerprint = Build.FINGERPRINT.contains("tv", ignoreCase = true) || Build.FINGERPRINT.contains("box", ignoreCase = true)
        val hasLeanbackFeature = packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
        
        // 增强TV检测：检查大屏幕无触摸设备
        val isLargeScreen = resources.configuration.screenLayout and 
                Configuration.SCREENLAYOUT_SIZE_MASK >= Configuration.SCREENLAYOUT_SIZE_LARGE
        val hasNoTouchscreen = !packageManager.hasSystemFeature(PackageManager.FEATURE_TOUCHSCREEN)
        
        return isTelevision || isTVBox || isTVFingerprint || hasLeanbackFeature || 
               (isLargeScreen && hasNoTouchscreen)
    }
    
    override fun onDestroy() {
        // 清理资源防止内存泄漏
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }
}
