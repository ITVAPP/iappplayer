package com.itvapp.iapp_player

import io.flutter.plugin.common.EventChannel.EventSink
import java.util.ArrayList

// 队列管理事件发送，支持延迟分发
internal class QueuingEventSink : EventSink {
    // 事件接收器
    private var delegate: EventSink? = null
    // 事件缓存队列
    private val eventQueue = ArrayList<Any>()
    // 流结束标志
    private var done = false

    // 设置事件接收器并分发队列事件
    fun setDelegate(delegate: EventSink?) {
        this.delegate = delegate
        maybeFlush()
    }

    // 标记流结束并入队
    override fun endOfStream() {
        enqueue(EndOfStreamEvent())
        maybeFlush()
        done = true
    }

    // 入队错误事件
    override fun error(code: String, message: String, details: Any) {
        enqueue(ErrorEvent(code, message, details))
        maybeFlush()
    }

    // 入队成功事件
    override fun success(event: Any) {
        enqueue(event)
        maybeFlush()
    }

    // 将事件添加到队列
    private fun enqueue(event: Any) {
        if (done) {
            return
        }
        eventQueue.add(event)
    }

    // 分发队列中的事件到接收器
    private fun maybeFlush() {
        if (delegate == null) {
            return
        }
        for (event in eventQueue) {
            when (event) {
                is EndOfStreamEvent -> {
                    delegate!!.endOfStream()
                }
                is ErrorEvent -> {
                    delegate!!.error(event.code, event.message, event.details)
                }
                else -> {
                    delegate!!.success(event)
                }
            }
        }
        eventQueue.clear()
    }

    // 表示事件流结束
    private class EndOfStreamEvent

    // 封装错误事件信息
    private class ErrorEvent(
        var code: String,
        var message: String,
        var details: Any
    )
}
