package com.example.iapp_player_example

import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.iapp_player_example"
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        // 优化窗口背景设置
        window.setBackgroundDrawableResource(android.R.color.transparent)
        
        super.onCreate(savedInstanceState)
        
        // 创建通知渠道
        createNotificationChannel()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val channelId = CHANNEL
                // 动态获取桌面图标名称（android:label）
                val appInfo = packageManager.getApplicationInfo(packageName, 0)
                val channelName = packageManager.getApplicationLabel(appInfo).toString()
                
                val importance = NotificationManager.IMPORTANCE_DEFAULT
                val channel = NotificationChannel(channelId, channelName, importance).apply {
                    description = "Notification for iapp_player playback"
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
    
    override fun onDestroy() {
        // 清理资源防止内存泄漏
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }
}
