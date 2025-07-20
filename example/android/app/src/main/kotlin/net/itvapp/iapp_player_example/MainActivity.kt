package net.itvapp.iapp_player_example

import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startNotificationService()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopNotificationService()
    }

    private fun startNotificationService() {
        try {
            val intent = Intent(this, IAppPlayerService::class.java)
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
        } catch (exception: Exception) {
        }
    }

    private fun stopNotificationService() {
        try {
            val intent = Intent(this, IAppPlayerService::class.java)
            stopService(intent)
        } catch (exception: Exception) {

        }
    }
}
