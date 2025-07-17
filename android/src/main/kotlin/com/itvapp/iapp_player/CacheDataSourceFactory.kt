package com.itvapp.iapp_player
import android.content.Context
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.cache.CacheDataSource
import androidx.media3.datasource.FileDataSource
import androidx.media3.datasource.cache.CacheDataSink
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DefaultDataSource

@UnstableApi
internal class CacheDataSourceFactory(
    private val context: Context,
    private val maxCacheSize: Long,
    private val maxFileSize: Long,
    private val upstreamDataSource: DataSource.Factory?
) : DataSource.Factory {
    
    private var cacheDataSourceFactory: CacheDataSource.Factory? = null
    
    // 初始化缓存数据源工厂
    init {
        val iappPlayerCache = IAppPlayerCache.createCache(context, maxCacheSize)
        if (iappPlayerCache != null && upstreamDataSource != null) {
            cacheDataSourceFactory = CacheDataSource.Factory()
                .setCache(iappPlayerCache)
                .setUpstreamDataSourceFactory(upstreamDataSource)
                .setCacheWriteDataSinkFactory(
                    CacheDataSink.Factory()
                        .setCache(iappPlayerCache)
                        .setFragmentSize(maxFileSize)
                )
                .setCacheReadDataSourceFactory(FileDataSource.Factory())
                .setFlags(CacheDataSource.FLAG_IGNORE_CACHE_ON_ERROR)
        }
    }
    
    // 创建缓存数据源
    override fun createDataSource(): DataSource {
        return cacheDataSourceFactory?.createDataSource() 
            ?: throw IllegalStateException("无法创建缓存数据源，缓存或上游数据源未正确初始化")
    }
}
