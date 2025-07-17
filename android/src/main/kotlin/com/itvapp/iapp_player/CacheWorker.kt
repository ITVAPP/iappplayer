package com.itvapp.iapp_player

import android.content.Context
import android.net.Uri
import com.itvapp.iapp_player.DataSourceUtils.getUserAgent
import com.itvapp.iapp_player.DataSourceUtils.getDataSourceFactory
import com.itvapp.iapp_player.DataSourceUtils.getProtocolInfo
import androidx.work.WorkerParameters
import androidx.media3.datasource.cache.CacheWriter
import androidx.work.Worker
import androidx.media3.datasource.DataSpec
import androidx.media3.datasource.HttpDataSource.HttpDataSourceException
import androidx.media3.datasource.cache.CacheDataSource
import androidx.media3.datasource.cache.SimpleCache
import java.lang.Exception
import java.util.*

// 缓存工作器，执行视频流预缓存并存储至缓存供后续使用
class CacheWorker(
    private val context: Context,
    params: WorkerParameters
) : Worker(context, params) {
    // 缓存写入器，管理缓存操作
    private var cacheWriter: CacheWriter? = null
    // 缓存进度报告索引，记录上一次报告进度
    private var lastCacheReportIndex = 0

    // 执行缓存任务，处理输入参数并根据协议类型执行缓存
    override fun doWork(): Result {
        try {
            val data = inputData
            val url = data.getString(IAppPlayerPlugin.URL_PARAMETER)
            val cacheKey = data.getString(IAppPlayerPlugin.CACHE_KEY_PARAMETER)
            val preCacheSize = data.getLong(IAppPlayerPlugin.PRE_CACHE_SIZE_PARAMETER, 0)
            val maxCacheSize = data.getLong(IAppPlayerPlugin.MAX_CACHE_SIZE_PARAMETER, 0)
            val maxCacheFileSize = data.getLong(IAppPlayerPlugin.MAX_CACHE_FILE_SIZE_PARAMETER, 0)
            
            // 提取 HTTP 请求头到键值映射
            val headers = extractHeaders(data)
            val uri = Uri.parse(url)
            
            // 获取协议信息，避免重复计算
            val protocolInfo = getProtocolInfo(uri)
            
            return when {
                protocolInfo.isHttp -> {
                    performHttpCaching(uri, headers, preCacheSize, maxCacheSize, maxCacheFileSize, cacheKey, url)
                    Result.success()
                }
                protocolInfo.isRtmp -> {
                    Result.success() // RTMP 流不支持预缓存，直接返回成功
                }
                else -> {
                    Result.failure()
                }
            }
        } catch (exception: Exception) {
            return if (exception is HttpDataSourceException) {
                Result.success()
            } else {
                Result.failure()
            }
        }
    }

    // 优化：提取 HTTP 请求头到键值映射
    private fun extractHeaders(data: androidx.work.Data): Map<String, String> {
        val headers = mutableMapOf<String, String>()
        val headerPrefix = IAppPlayerPlugin.HEADER_PARAMETER
        val prefixLength = headerPrefix.length
        
        for ((key, value) in data.keyValueMap) {
            if (key.startsWith(headerPrefix) && key.length > prefixLength) {
                val headerKey = key.substring(prefixLength)
                val headerValue = value as? String
                if (headerValue != null) {
                    headers[headerKey] = headerValue
                }
            }
        }
        return headers
    }

    // 执行 HTTP 流缓存，配置数据源并启动缓存
    private fun performHttpCaching(
        uri: Uri,
        headers: Map<String, String>,
        preCacheSize: Long,
        maxCacheSize: Long,
        maxCacheFileSize: Long,
        cacheKey: String?,
        url: String?
    ) {
        val userAgent = getUserAgent(headers)
        val dataSourceFactory = getDataSourceFactory(userAgent, headers)
        
        var dataSpec = DataSpec(uri, 0, preCacheSize)
        if (cacheKey != null && cacheKey.isNotEmpty()) {
            dataSpec = dataSpec.buildUpon().setKey(cacheKey).build()
        }
        
        val cache = IAppPlayerCache.createCache(context, maxCacheSize)
        if (cache == null) {
            throw Exception("缓存创建失败")
        }
        
        val cacheDataSource = CacheDataSource.Factory()
            .setCache(cache)
            .setUpstreamDataSourceFactory(dataSourceFactory)
            // 在后台线程中使用FLAG_BLOCK_ON_CACHE是安全的
            .setFlags(CacheDataSource.FLAG_IGNORE_CACHE_ON_ERROR or CacheDataSource.FLAG_BLOCK_ON_CACHE)
            .createDataSource()
        
        cacheWriter = CacheWriter(
            cacheDataSource,
            dataSpec,
            null
        ) { _: Long, bytesCached: Long, _: Long ->
            // 报告缓存进度
            reportCacheProgress(bytesCached, preCacheSize, url)
        }
        cacheWriter?.cache()
    }

    // 报告缓存进度，优化日志输出频率
    private fun reportCacheProgress(bytesCached: Long, preCacheSize: Long, url: String?) {
        if (preCacheSize > 0) {
            val completedData = (bytesCached * 100f / preCacheSize).toDouble()
            val currentReportIndex = (completedData / 10).toInt()
            
            if (currentReportIndex > lastCacheReportIndex) {
                lastCacheReportIndex = currentReportIndex
            }
        }
    }

    // 取消缓存任务并清理资源
    override fun onStopped() {
        try {
            cacheWriter?.cancel()
            super.onStopped()
        } catch (exception: Exception) {
        }
    }

    companion object {
        private const val TAG = "CacheWorker"
    }
}
