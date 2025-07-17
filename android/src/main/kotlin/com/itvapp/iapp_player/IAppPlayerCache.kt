package com.itvapp.iapp_player

import android.content.Context
import androidx.media3.datasource.cache.SimpleCache
import androidx.media3.datasource.cache.LeastRecentlyUsedCacheEvictor
import androidx.media3.database.StandaloneDatabaseProvider
import java.io.File
import java.lang.Exception

// 媒体播放器缓存管理单例对象
object IAppPlayerCache {
    @Volatile
    private var instance: SimpleCache? = null
    private const val TAG = "IAppPlayerCache"
    
    // 初始化并返回媒体播放器缓存实例（单例模式）
    fun createCache(context: Context, cacheFileSize: Long): SimpleCache? {
        if (instance == null) {
            synchronized(IAppPlayerCache::class.java) {
                if (instance == null) {
                    try {
                        val cacheDir = File(context.cacheDir, "iappPlayerCache")
                        // 确保缓存目录存在
                        if (!cacheDir.exists()) {
                            cacheDir.mkdirs()
                        }
                        
                        // 缓存配置
                        val databaseProvider = StandaloneDatabaseProvider(context)
                        val cacheEvictor = LeastRecentlyUsedCacheEvictor(cacheFileSize)
                        
                        instance = SimpleCache(cacheDir, cacheEvictor, databaseProvider)
                    } catch (exception: Exception) {
                        instance = null
                    }
                }
            }
        }
        return instance
    }
    
    // 释放缓存资源并置空实例，增强异常处理
    @JvmStatic
    fun releaseCache() {
        try {
            synchronized(IAppPlayerCache::class.java) {
                if (instance != null) {
                    instance!!.release()
                    instance = null
                }
            }
        } catch (exception: Exception) {
            // 即使释放失败，也要置空引用避免内存泄漏
            instance = null
        }
    }
    
    // 获取缓存统计信息（可选的调试功能）
    fun getCacheStats(): String? {
        return try {
            instance?.let {
                "缓存大小: ${it.cacheSpace / 1024 / 1024}MB"
            }
        } catch (exception: Exception) {
            null
        }
    }
}
