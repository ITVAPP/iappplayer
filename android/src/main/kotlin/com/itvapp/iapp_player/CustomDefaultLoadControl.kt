package com.itvapp.iapp_player

import androidx.media3.exoplayer.DefaultLoadControl

internal class CustomDefaultLoadControl {
    // 缓冲区最小持续时间（毫秒）
    @JvmField
    val minBufferMs: Int

    // 缓冲区最大持续时间（毫秒）
    @JvmField
    val maxBufferMs: Int

    // 播放所需缓冲区持续时间（毫秒）
    @JvmField
    val bufferForPlaybackMs: Int

    // 重新缓冲后播放所需缓冲区持续时间（毫秒）
    @JvmField
    val bufferForPlaybackAfterRebufferMs: Int

    // 使用默认缓冲参数初始化
    constructor() {
        minBufferMs = DefaultLoadControl.DEFAULT_MIN_BUFFER_MS
        maxBufferMs = DefaultLoadControl.DEFAULT_MAX_BUFFER_MS
        bufferForPlaybackMs = DefaultLoadControl.DEFAULT_BUFFER_FOR_PLAYBACK_MS
        bufferForPlaybackAfterRebufferMs =
            DefaultLoadControl.DEFAULT_BUFFER_FOR_PLAYBACK_AFTER_REBUFFER_MS
    }

    // 支持自定义缓冲参数，空值使用默认配置
    constructor(
        minBufferMs: Int?,
        maxBufferMs: Int?,
        bufferForPlaybackMs: Int?,
        bufferForPlaybackAfterRebufferMs: Int?
    ) {
        this.minBufferMs = minBufferMs ?: DefaultLoadControl.DEFAULT_MIN_BUFFER_MS
        this.maxBufferMs = maxBufferMs ?: DefaultLoadControl.DEFAULT_MAX_BUFFER_MS
        this.bufferForPlaybackMs =
            bufferForPlaybackMs ?: DefaultLoadControl.DEFAULT_BUFFER_FOR_PLAYBACK_MS
        this.bufferForPlaybackAfterRebufferMs = bufferForPlaybackAfterRebufferMs
            ?: DefaultLoadControl.DEFAULT_BUFFER_FOR_PLAYBACK_AFTER_REBUFFER_MS
    }
}
