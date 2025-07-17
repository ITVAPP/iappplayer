package com.itvapp.iapp_player

import android.app.Activity
import android.app.PictureInPictureParams
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.LongSparseArray
import com.itvapp.iapp_player.IAppPlayerCache.releaseCache
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.view.TextureRegistry
import java.lang.Exception
import java.util.HashMap
import java.lang.ref.WeakReference

// 视频播放器插件，管理Android平台视频播放功能
class IAppPlayerPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {
    private val videoPlayers = LongSparseArray<IAppPlayer>()
    private val dataSources = LongSparseArray<Map<String, Any?>>()
    private val playerToTextureId = HashMap<IAppPlayer, Long>()
    private var flutterState: FlutterState? = null
    private var currentNotificationTextureId: Long = -1
    private var currentNotificationDataSource: Map<String, Any?>? = null
    private var activityWeakRef: WeakReference<Activity>? = null // 使用弱引用避免内存泄漏
    private var pipHandler: Handler? = null
    private var pipRunnable: Runnable? = null

    // 初始化插件，设置Flutter引擎绑定和资源
    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        val loader = FlutterLoader()
        flutterState = FlutterState(
            binding.applicationContext,
            binding.binaryMessenger, object : KeyForAssetFn {
                override fun get(asset: String?): String {
                    return loader.getLookupKeyForAsset(
                        asset!!
                    )
                }

            }, object : KeyForAssetAndPackageName {
                override fun get(asset: String?, packageName: String?): String {
                    return loader.getLookupKeyForAsset(
                        asset!!, packageName!!
                    )
                }
            },
            binding.textureRegistry
        )
        flutterState?.startListening(this)
    }

    // 释放所有播放器和缓存，清理插件资源
    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        disposeAllPlayers()
        releaseCache()
        flutterState?.stopListening()
        flutterState = null
        stopPipHandler()
    }

    // 设置当前活动，绑定Activity
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityWeakRef = WeakReference(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        stopPipHandler()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityWeakRef = WeakReference(binding.activity)
    }

    override fun onDetachedFromActivity() {
        // 确保在Activity分离时清理Handler和引用
        stopPipHandler()
        activityWeakRef?.clear()
        activityWeakRef = null
    }

    // 销毁所有播放器实例，清理资源
    private fun disposeAllPlayers() {
        for (i in 0 until videoPlayers.size()) {
            videoPlayers.valueAt(i).dispose()
        }
        videoPlayers.clear()
        dataSources.clear()
        playerToTextureId.clear()
    }

    // 处理Flutter方法调用，分派到对应功能
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (flutterState == null || flutterState?.textureRegistry == null) {
            result.error("no_activity", "iapp_player plugin requires a foreground activity", null)
            return
        }
        when (call.method) {
            INIT_METHOD -> disposeAllPlayers()
            CREATE_METHOD -> {
                val handle = flutterState!!.textureRegistry!!.createSurfaceTexture()
                val eventChannel = EventChannel(
                    flutterState?.binaryMessenger, EVENTS_CHANNEL + handle.id()
                )
                var customDefaultLoadControl: CustomDefaultLoadControl? = null
                if (call.hasArgument(MIN_BUFFER_MS) && call.hasArgument(MAX_BUFFER_MS) &&
                    call.hasArgument(BUFFER_FOR_PLAYBACK_MS) &&
                    call.hasArgument(BUFFER_FOR_PLAYBACK_AFTER_REBUFFER_MS)
                ) {
                    customDefaultLoadControl = CustomDefaultLoadControl(
                        call.argument(MIN_BUFFER_MS),
                        call.argument(MAX_BUFFER_MS),
                        call.argument(BUFFER_FOR_PLAYBACK_MS),
                        call.argument(BUFFER_FOR_PLAYBACK_AFTER_REBUFFER_MS)
                    )
                }
                val player = IAppPlayer(
                    flutterState?.applicationContext!!, eventChannel, handle,
                    customDefaultLoadControl, result
                )
                videoPlayers.put(handle.id(), player)
                playerToTextureId[player] = handle.id()
            }
            PRE_CACHE_METHOD -> preCache(call, result)
            STOP_PRE_CACHE_METHOD -> stopPreCache(call, result)
            CLEAR_CACHE_METHOD -> clearCache(result)
            else -> {
                val textureId = (call.argument<Any>(TEXTURE_ID_PARAMETER) as Number?)!!.toLong()
                val player = videoPlayers[textureId]
                if (player == null) {
                    result.error(
                        "Unknown textureId",
                        "No video player associated with texture id $textureId",
                        null
                    )
                    return
                }
                onMethodCall(call, result, textureId, player)
            }
        }
    }

    private fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
        textureId: Long,
        player: IAppPlayer
    ) {
        when (call.method) {
            SET_DATA_SOURCE_METHOD -> {
                setDataSource(call, result, player)
            }
            SET_LOOPING_METHOD -> {
                player.setLooping(call.argument(LOOPING_PARAMETER)!!)
                result.success(null)
            }
            SET_VOLUME_METHOD -> {
                player.setVolume(call.argument(VOLUME_PARAMETER)!!)
                result.success(null)
            }
            PLAY_METHOD -> {
                setupNotification(player)
                player.play()
                result.success(null)
            }
            PAUSE_METHOD -> {
                player.pause()
                result.success(null)
            }
            SEEK_TO_METHOD -> {
                val location = (call.argument<Any>(LOCATION_PARAMETER) as Number?)!!.toInt()
                player.seekTo(location)
                result.success(null)
            }
            POSITION_METHOD -> {
                result.success(player.position)
                player.sendBufferingUpdate(false)
            }
            ABSOLUTE_POSITION_METHOD -> result.success(player.absolutePosition)
            SET_SPEED_METHOD -> {
                player.setSpeed(call.argument(SPEED_PARAMETER)!!)
                result.success(null)
            }
            SET_TRACK_PARAMETERS_METHOD -> {
                player.setTrackParameters(
                    call.argument(WIDTH_PARAMETER)!!,
                    call.argument(HEIGHT_PARAMETER)!!,
                    call.argument(BITRATE_PARAMETER)!!
                )
                result.success(null)
            }
            ENABLE_PICTURE_IN_PICTURE_METHOD -> {
                enablePictureInPicture(player)
                result.success(null)
            }
            DISABLE_PICTURE_IN_PICTURE_METHOD -> {
                disablePictureInPicture(player)
                result.success(null)
            }
            IS_PICTURE_IN_PICTURE_SUPPORTED_METHOD -> result.success(
                isPictureInPictureSupported()
            )
            SET_AUDIO_TRACK_METHOD -> {
                val name = call.argument<String?>(NAME_PARAMETER)
                val index = call.argument<Int?>(INDEX_PARAMETER)
                if (name != null && index != null) {
                    player.setAudioTrack(name, index)
                }
                result.success(null)
            }
            SET_MIX_WITH_OTHERS_METHOD -> {
                val mixWitOthers = call.argument<Boolean?>(
                    MIX_WITH_OTHERS_PARAMETER
                )
                if (mixWitOthers != null) {
                    player.setMixWithOthers(mixWitOthers)
                }
            }
            DISPOSE_METHOD -> {
                dispose(player, textureId)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // 设置视频数据源，支持资产或网络资源
    private fun setDataSource(
        call: MethodCall,
        result: MethodChannel.Result,
        player: IAppPlayer
    ) {
        val dataSource = call.argument<Map<String, Any?>>(DATA_SOURCE_PARAMETER)!!
        val textureId = playerToTextureId[player]
        if (textureId != null) {
            dataSources.put(textureId, dataSource)
        }
        
        // 批量提取参数，减少重复调用
        val key = getParameter(dataSource, KEY_PARAMETER, "")
        val headers: Map<String, String> = getParameter(dataSource, HEADERS_PARAMETER, HashMap())
        val overriddenDuration: Number = getParameter(dataSource, OVERRIDDEN_DURATION_PARAMETER, 0)
        val preferredDecoderType: Int = getParameter(dataSource, PREFERRED_DECODER_TYPE_PARAMETER, 0)
        
        if (dataSource[ASSET_PARAMETER] != null) {
            val asset = getParameter(dataSource, ASSET_PARAMETER, "")
            val assetLookupKey: String = if (dataSource[PACKAGE_PARAMETER] != null) {
                val packageParameter = getParameter(
                    dataSource,
                    PACKAGE_PARAMETER,
                    ""
                )
                flutterState!!.keyForAssetAndPackageName[asset, packageParameter]
            } else {
                flutterState!!.keyForAsset[asset]
            }
            player.setDataSource(
                flutterState?.applicationContext!!,
                key,
                "asset:///$assetLookupKey",
                null,
                result,
                headers,
                false,
                0L,
                0L,
                overriddenDuration.toLong(),
                null,
                null, null, null,
                preferredDecoderType
            )
        } else {
            val useCache = getParameter(dataSource, USE_CACHE_PARAMETER, false)
            val maxCacheSizeNumber: Number = getParameter(dataSource, MAX_CACHE_SIZE_PARAMETER, 0)
            val maxCacheFileSizeNumber: Number =
                getParameter(dataSource, MAX_CACHE_FILE_SIZE_PARAMETER, 0)
            val maxCacheSize = maxCacheSizeNumber.toLong()
            val maxCacheFileSize = maxCacheFileSizeNumber.toLong()
            val uri = getParameter(dataSource, URI_PARAMETER, "")
            val cacheKey = getParameter<String?>(dataSource, CACHE_KEY_PARAMETER, null)
            val formatHint = getParameter<String?>(dataSource, FORMAT_HINT_PARAMETER, null)
            val licenseUrl = getParameter<String?>(dataSource, LICENSE_URL_PARAMETER, null)
            val clearKey = getParameter<String?>(dataSource, DRM_CLEARKEY_PARAMETER, null)
            val drmHeaders: Map<String, String> =
                getParameter(dataSource, DRM_HEADERS_PARAMETER, HashMap())
            player.setDataSource(
                flutterState!!.applicationContext,
                key,
                uri,
                formatHint,
                result,
                headers,
                useCache,
                maxCacheSize,
                maxCacheFileSize,
                overriddenDuration.toLong(),
                licenseUrl,
                drmHeaders,
                cacheKey,
                clearKey,
                preferredDecoderType
            )
        }
    }

    // 预缓存视频数据，配置缓存参数
    private fun preCache(call: MethodCall, result: MethodChannel.Result) {
        val dataSource = call.argument<Map<String, Any?>>(DATA_SOURCE_PARAMETER)
        if (dataSource != null) {
            // 批量提取参数
            val maxCacheSizeNumber: Number =
                getParameter(dataSource, MAX_CACHE_SIZE_PARAMETER, 100 * 1024 * 1024)
            val maxCacheFileSizeNumber: Number =
                getParameter(dataSource, MAX_CACHE_FILE_SIZE_PARAMETER, 10 * 1024 * 1024)
            val preCacheSizeNumber: Number =
                getParameter(dataSource, PRE_CACHE_SIZE_PARAMETER, 3 * 1024 * 1024)
            val uri = getParameter(dataSource, URI_PARAMETER, "")
            val cacheKey = getParameter<String?>(dataSource, CACHE_KEY_PARAMETER, null)
            val headers: Map<String, String> =
                getParameter(dataSource, HEADERS_PARAMETER, HashMap())
                
            IAppPlayer.preCache(
                flutterState?.applicationContext,
                uri,
                preCacheSizeNumber.toLong(),
                maxCacheSizeNumber.toLong(),
                maxCacheFileSizeNumber.toLong(),
                headers,
                cacheKey,
                result
            )
        }
    }

    // 停止视频预缓存进程
    private fun stopPreCache(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>(URL_PARAMETER)
        IAppPlayer.stopPreCache(flutterState?.applicationContext, url, result)
    }

    // 清除视频缓存
    private fun clearCache(result: MethodChannel.Result) {
        IAppPlayer.clearCache(flutterState?.applicationContext, result)
    }

    private fun getTextureId(iappPlayer: IAppPlayer): Long? {
        return playerToTextureId[iappPlayer]
    }

    // 设置播放器通知，配置标题、作者和图片等
    private fun setupNotification(iappPlayer: IAppPlayer) {
        try {
            val textureId = getTextureId(iappPlayer)
            if (textureId != null) {
                val dataSource = dataSources[textureId]
                // 修复：使用内容比较而非引用比较
                if (textureId == currentNotificationTextureId && 
                    currentNotificationDataSource != null && 
                    dataSource != null && 
                    currentNotificationDataSource == dataSource) {
                    return
                }
                currentNotificationDataSource = dataSource
                currentNotificationTextureId = textureId
                removeOtherNotificationListeners()
                val showNotification = getParameter(dataSource, SHOW_NOTIFICATION_PARAMETER, false)
                if (showNotification) {
                    val title = getParameter(dataSource, TITLE_PARAMETER, "")
                    val author = getParameter(dataSource, AUTHOR_PARAMETER, "")
                    val imageUrl = getParameter(dataSource, IMAGE_URL_PARAMETER, "")
                    val notificationChannelName =
                        getParameter<String?>(dataSource, NOTIFICATION_CHANNEL_NAME_PARAMETER, null)
                    val activityName =
                        getParameter(dataSource, ACTIVITY_NAME_PARAMETER, "MainActivity")
                    iappPlayer.setupPlayerNotification(
                        flutterState?.applicationContext!!,
                        title, author, imageUrl, notificationChannelName, activityName
                    )
                }
            }
        } catch (exception: Exception) {
        }
    }

    // 移除其他播放器通知监听
    private fun removeOtherNotificationListeners() {
        val size = videoPlayers.size()
        for (index in 0 until size) {
            videoPlayers.valueAt(index).disposeRemoteNotifications()
        }
    }
    @Suppress("UNCHECKED_CAST")
    private fun <T> getParameter(parameters: Map<String, Any?>?, key: String, defaultValue: T): T {
        if (parameters?.containsKey(key) == true) {
            val value = parameters[key]
            if (value != null) {
                return value as T
            }
        }
        return defaultValue
    }

    // 检查设备是否支持画中画模式
    private fun isPictureInPictureSupported(): Boolean {
        val activity = activityWeakRef?.get()
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && activity != null && activity.packageManager
            .hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)
    }

    // 启用画中画模式，配置媒体会话
    private fun enablePictureInPicture(player: IAppPlayer) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val activity = activityWeakRef?.get()
            if (activity != null) {
                player.setupMediaSession(flutterState!!.applicationContext)
                activity.enterPictureInPictureMode(PictureInPictureParams.Builder().build())
                startPictureInPictureListenerTimer(player)
                player.onPictureInPictureStatusChanged(true)
            }
        }
    }

    // 禁用画中画模式，清理媒体会话
    private fun disablePictureInPicture(player: IAppPlayer) {
        stopPipHandler()
        activityWeakRef?.get()?.moveTaskToBack(false)
        player.onPictureInPictureStatusChanged(false)
        player.disposeMediaSession()
    }

    private fun startPictureInPictureListenerTimer(player: IAppPlayer) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val activity = activityWeakRef?.get()
            if (activity == null) return
            
            // 先停止现有的Handler，避免重复创建
            stopPipHandler()
            pipHandler = Handler(Looper.getMainLooper())
            pipRunnable = object : Runnable {
                override fun run() {
                    val currentActivity = activityWeakRef?.get()
                    if (currentActivity != null && currentActivity.isInPictureInPictureMode) {
                        pipHandler?.postDelayed(this, 500)
                    } else {
                        player.onPictureInPictureStatusChanged(false)
                        player.disposeMediaSession()
                        stopPipHandler()
                    }
                }
            }
            pipHandler?.post(pipRunnable!!)
        }
    }

    private fun dispose(player: IAppPlayer, textureId: Long) {
        player.dispose()
        videoPlayers.remove(textureId)
        dataSources.remove(textureId)
        playerToTextureId.remove(player)
        // 如果没有其他播放器，停止PIP Handler
        if (videoPlayers.size() == 0) {
            stopPipHandler()
        }
    }

    private fun stopPipHandler() {
        pipRunnable?.let { 
            pipHandler?.removeCallbacks(it)
        }
        pipHandler = null
        pipRunnable = null
    }

    private interface KeyForAssetFn {
        operator fun get(asset: String?): String
    }

    private interface KeyForAssetAndPackageName {
        operator fun get(asset: String?, packageName: String?): String
    }

    private class FlutterState(
        val applicationContext: Context,
        val binaryMessenger: BinaryMessenger,
        val keyForAsset: KeyForAssetFn,
        val keyForAssetAndPackageName: KeyForAssetAndPackageName,
        val textureRegistry: TextureRegistry?
    ) {
        private val methodChannel: MethodChannel = MethodChannel(binaryMessenger, CHANNEL)

        fun startListening(methodCallHandler: IAppPlayerPlugin?) {
            methodChannel.setMethodCallHandler(methodCallHandler)
        }

        fun stopListening() {
            methodChannel.setMethodCallHandler(null)
        }

    }

    companion object {
        // 日志标签
        private const val TAG = "IAppPlayerPlugin"
        // 方法通道名称
        private const val CHANNEL = "iapp_player_channel"
        // 事件通道前缀
        private const val EVENTS_CHANNEL = "iapp_player_channel/videoEvents"
        // 数据源参数
        private const val DATA_SOURCE_PARAMETER = "dataSource"
        // 键参数
        private const val KEY_PARAMETER = "key"
        // 请求头参数
        private const val HEADERS_PARAMETER = "headers"
        // 是否使用缓存
        private const val USE_CACHE_PARAMETER = "useCache"
        // 资产参数
        private const val ASSET_PARAMETER = "asset"
        // 包名参数
        private const val PACKAGE_PARAMETER = "package"
        // 资源URI
        private const val URI_PARAMETER = "uri"
        // 格式提示
        private const val FORMAT_HINT_PARAMETER = "formatHint"
        // 纹理ID
        private const val TEXTURE_ID_PARAMETER = "textureId"
        // 循环播放
        private const val LOOPING_PARAMETER = "looping"
        // 音量
        private const val VOLUME_PARAMETER = "volume"
        // 定位参数
        private const val LOCATION_PARAMETER = "location"
        // 播放速度
        private const val SPEED_PARAMETER = "speed"
        // 宽度参数
        private const val WIDTH_PARAMETER = "width"
        // 高度参数
        private const val HEIGHT_PARAMETER = "height"
        // 比特率参数
        private const val BITRATE_PARAMETER = "bitrate"
        // 是否显示通知
        private const val SHOW_NOTIFICATION_PARAMETER = "showNotification"
        // 通知标题
        private const val TITLE_PARAMETER = "title"
        // 通知作者
        private const val AUTHOR_PARAMETER = "author"
        // 通知图片URL
        private const val IMAGE_URL_PARAMETER = "imageUrl"
        // 通知通道名称
        private const val NOTIFICATION_CHANNEL_NAME_PARAMETER = "notificationChannelName"
        // 覆盖时长
        private const val OVERRIDDEN_DURATION_PARAMETER = "overriddenDuration"
        // 音频轨道名称
        private const val NAME_PARAMETER = "name"
        // 音频轨道索引
        private const val INDEX_PARAMETER = "index"
        // 许可证URL
        private const val LICENSE_URL_PARAMETER = "licenseUrl"
        // DRM请求头
        private const val DRM_HEADERS_PARAMETER = "drmHeaders"
        // DRM密钥
        private const val DRM_CLEARKEY_PARAMETER = "clearKey"
        // 是否与其他音频混合
        private const val MIX_WITH_OTHERS_PARAMETER = "mixWithOthers"
        // 视频URL
        const val URL_PARAMETER = "url"
        // 预缓存大小
        const val PRE_CACHE_SIZE_PARAMETER = "preCacheSize"
        // 最大缓存大小
        const val MAX_CACHE_SIZE_PARAMETER = "maxCacheSize"
        // 最大缓存文件大小
        const val MAX_CACHE_FILE_SIZE_PARAMETER = "maxCacheFileSize"
        // 请求头前缀
        const val HEADER_PARAMETER = "header_"
        // 文件路径
        const val FILE_PATH_PARAMETER = "filePath"
        // 活动名称
        const val ACTIVITY_NAME_PARAMETER = "activityName"
        // 最小缓冲时间
        const val MIN_BUFFER_MS = "minBufferMs"
        // 最大缓冲时间
        const val MAX_BUFFER_MS = "maxBufferMs"
        // 播放缓冲时间
        const val BUFFER_FOR_PLAYBACK_MS = "bufferForPlaybackMs"
        // 重缓冲后播放缓冲时间
        const val BUFFER_FOR_PLAYBACK_AFTER_REBUFFER_MS = "bufferForPlaybackAfterRebufferMs"
        // 缓存键
        const val CACHE_KEY_PARAMETER = "cacheKey"
        // 初始化方法
        private const val INIT_METHOD = "init"
        // 创建播放器
        private const val CREATE_METHOD = "create"
        // 设置数据源
        private const val SET_DATA_SOURCE_METHOD = "setDataSource"
        // 设置循环播放
        private const val SET_LOOPING_METHOD = "setLooping"
        // 设置音量
        private const val SET_VOLUME_METHOD = "setVolume"
        // 播放
        private const val PLAY_METHOD = "play"
        // 暂停
        private const val PAUSE_METHOD = "pause"
        // 定位
        private const val SEEK_TO_METHOD = "seekTo"
        // 获取播放位置
        private const val POSITION_METHOD = "position"
        // 获取绝对播放位置
        private const val ABSOLUTE_POSITION_METHOD = "absolutePosition"
        // 设置播放速度
        private const val SET_SPEED_METHOD = "setSpeed"
        // 设置轨道参数
        private const val SET_TRACK_PARAMETERS_METHOD = "setTrackParameters"
        // 设置音频轨道
        private const val SET_AUDIO_TRACK_METHOD = "setAudioTrack"
        // 启用画中画
        private const val ENABLE_PICTURE_IN_PICTURE_METHOD = "enablePictureInPicture"
        // 禁用画中画
        private const val DISABLE_PICTURE_IN_PICTURE_METHOD = "disablePictureInPicture"
        // 检查画中画支持
        private const val IS_PICTURE_IN_PICTURE_SUPPORTED_METHOD = "isPictureInPictureSupported"
        // 设置音频混合
        private const val SET_MIX_WITH_OTHERS_METHOD = "setMixWithOthers"
        // 清除缓存
        private const val CLEAR_CACHE_METHOD = "clearCache"
        // 释放资源
        private const val DISPOSE_METHOD = "dispose"
        // 预缓存
        private const val PRE_CACHE_METHOD = "preCache"
        // 停止预缓存
        private const val STOP_PRE_CACHE_METHOD = "stopPreCache"
        // 编码设置
        private const val PREFERRED_DECODER_TYPE_PARAMETER = "preferredDecoderType"
    }
}
