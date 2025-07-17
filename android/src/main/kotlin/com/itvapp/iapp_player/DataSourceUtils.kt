package com.itvapp.iapp_player
import android.net.Uri
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.datasource.rtmp.RtmpDataSource

// 处理多种协议的数据源创建与检测
internal object DataSourceUtils {
    // 用户代理请求头键
    private const val USER_AGENT = "User-Agent"
    // 系统用户代理属性键
    private const val USER_AGENT_PROPERTY = "http.agent"
    
    // HTTP/HTTPS 协议集合
    private val HTTP_SCHEMES = setOf("http", "https")
    // RTMP 协议及其变体集合
    private val RTMP_SCHEMES = setOf("rtmp", "rtmps", "rtmpe", "rtmpt", "rtmpte", "rtmpts")
    
    // 超时设置常量（与 IAppPlayer.kt 保持一致）
    private const val CONNECT_TIMEOUT_MS = 3000
    private const val READ_TIMEOUT_MS = 15000
    
    // 获取用户代理，优先使用 headers 中的值
    @JvmStatic
    fun getUserAgent(headers: Map<String, String>?): String? {
        var userAgent = System.getProperty(USER_AGENT_PROPERTY)
        if (headers != null && headers.containsKey(USER_AGENT)) {
            val userAgentHeader = headers[USER_AGENT]
            if (userAgentHeader != null) {
                userAgent = userAgentHeader
            }
        }
        return userAgent
    }
    
    // 创建 HTTP 数据源，支持自定义用户代理和请求头
    @JvmStatic
    fun getDataSourceFactory(
        userAgent: String?,
        headers: Map<String, String>?
    ): DataSource.Factory {
        val dataSourceFactory: DataSource.Factory = DefaultHttpDataSource.Factory()
            .setUserAgent(userAgent)
            .setAllowCrossProtocolRedirects(true)
            .setConnectTimeoutMs(CONNECT_TIMEOUT_MS)  // 3000ms
            .setReadTimeoutMs(READ_TIMEOUT_MS)        // 15000ms
            .setKeepPostFor302Redirects(true)
            .setTransferListener(null)
        
        // 设置自定义请求头
        headers?.filterValues { it != null }?.let { notNullHeaders ->
            if (notNullHeaders.isNotEmpty()) {
                (dataSourceFactory as DefaultHttpDataSource.Factory).setDefaultRequestProperties(
                    notNullHeaders
                )
            }
        }
        return dataSourceFactory
    }
    
    // 检测 URI 是否为 HTTP/HTTPS 协议
    @JvmStatic
    fun isHTTP(uri: Uri?): Boolean {
        val scheme = uri?.scheme?.lowercase() ?: return false
        return HTTP_SCHEMES.contains(scheme)
    }
    
    // 检测 URI 是否为 RTMP 协议
    @JvmStatic
    fun isRTMP(uri: Uri?): Boolean {
        val scheme = uri?.scheme?.lowercase() ?: return false
        return RTMP_SCHEMES.contains(scheme)
    }
    
    // 创建 RTMP 数据源
    @JvmStatic
    fun getRtmpDataSourceFactory(): DataSource.Factory {
        return RtmpDataSource.Factory()
    }
    
    // 封装 URI 协议检测结果
    data class ProtocolInfo(
        val isHttp: Boolean,
        val isRtmp: Boolean,
        val scheme: String?
    )
    
    // 批量检测 URI 协议类型
    @JvmStatic
    fun getProtocolInfo(uri: Uri?): ProtocolInfo {
        val scheme = uri?.scheme?.lowercase()
        return ProtocolInfo(
            isHttp = scheme != null && HTTP_SCHEMES.contains(scheme),
            isRtmp = scheme != null && RTMP_SCHEMES.contains(scheme),
            scheme = scheme
        )
    }
}
