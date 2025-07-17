package com.itvapp.iapp_player

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.work.Data
import androidx.work.WorkerParameters
import androidx.work.Worker
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.lang.Exception
import java.net.HttpURLConnection
import java.net.URL
import kotlin.math.min

// 处理图像下载、解码和缓存的后台工作，使用现代化的错误处理和内存管理
class ImageWorker(
    context: Context,
    params: WorkerParameters
) : Worker(context, params) {
    
    // 下载并缓存图像，返回文件路径，增强的错误处理和性能优化
    override fun doWork(): Result {
        return try {
            val imageUrl = inputData.getString(IAppPlayerPlugin.URL_PARAMETER)
            if (imageUrl.isNullOrEmpty()) {
                return Result.failure()
            }
            
            // 检查URL有效性
            val uri = Uri.parse(imageUrl)
            if (uri == null || uri.scheme.isNullOrEmpty()) {
                return Result.failure()
            }
            
            // 根据URL类型选择处理方式
            val filePath = if (DataSourceUtils.isHTTP(uri)) {
                downloadAndCacheExternalImage(imageUrl)
            } else {
                processInternalImage(imageUrl)
            }
            
            if (filePath != null) {
                val data = Data.Builder()
                    .putString(IAppPlayerPlugin.FILE_PATH_PARAMETER, filePath)
                    .build()
                Result.success(data)
            } else {
                Result.failure()
            }
            
        } catch (e: Exception) {
            Result.failure()
        }
    }

    // 下载外部图片并智能处理
    private fun downloadAndCacheExternalImage(imageUrl: String): String? {
        var connection: HttpURLConnection? = null
        
        return try {
            val url = URL(imageUrl)
            connection = url.openConnection() as HttpURLConnection
            
            // 连接配置
            connection.apply {
                connectTimeout = CONNECT_TIMEOUT_MS
                readTimeout = READ_TIMEOUT_MS
                requestMethod = "GET"
                setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36 OPR/114.0.0.0")
                // 添加缓存控制
                setRequestProperty("Cache-Control", "max-age=3600")
                doInput = true
                useCaches = true
            }
            
            // 检查响应码
            val responseCode = connection.responseCode
            if (responseCode != HttpURLConnection.HTTP_OK) {
                return null
            }
            
            // 获取文件扩展名
            val extension = getFileExtension(imageUrl, connection.contentType)
            val fileName = "${imageUrl.hashCode()}$extension"
            
            // 获取文件大小用于判断是否需要调整尺寸
            val contentLength = connection.contentLength
            
            // 如果文件较小或无法获取大小，直接流式保存
            if (contentLength in 1 until DIRECT_SAVE_SIZE_THRESHOLD) {
                return saveStreamToCache(connection.inputStream, fileName)
            }
            
            // 对于大文件或未知大小，先检查图片尺寸
            val imageData = connection.inputStream.readBytes()
            
            // 检查图片尺寸
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            BitmapFactory.decodeByteArray(imageData, 0, imageData.size, options)
            
            // 判断是否需要调整尺寸
            if (needsResize(options.outWidth, options.outHeight)) {
                return resizeAndSaveImage(imageData, fileName, extension)
            } else {
                return saveBytesToCache(imageData, fileName)
            }
            
        } catch (exception: Exception) {
            null
        } finally {
            connection?.disconnect()
        }
    }

    // 处理本地图片
    private fun processInternalImage(imagePath: String): String? {
        return try {
            val file = File(imagePath)
            if (!file.exists() || !file.isFile()) {
                return null
            }
            
            if (!file.canRead()) {
                return null
            }
            
            // 检查图片尺寸
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            BitmapFactory.decodeFile(imagePath, options)
            
            // 判断是否需要调整尺寸
            if (needsResize(options.outWidth, options.outHeight)) {
                // 获取文件扩展名
                val extension = getFileExtensionFromPath(imagePath)
                val fileName = "${imagePath.hashCode()}_resized$extension"
                
                // 读取并调整图片大小
                val imageData = file.readBytes()
                return resizeAndSaveImage(imageData, fileName, extension)
            } else {
                // 不需要调整尺寸，直接返回原始路径
                return imagePath
            }
            
        } catch (exception: Exception) {
            null
        }
    }

    // 判断是否需要调整图片尺寸
    private fun needsResize(width: Int, height: Int): Boolean {
        return width > MAX_IMAGE_SIZE_PX || height > MAX_IMAGE_SIZE_PX
    }

    // 调整图片尺寸并保存（保持原格式）
    private fun resizeAndSaveImage(imageData: ByteArray, fileName: String, extension: String): String? {
        return try {
            // 计算采样率
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            BitmapFactory.decodeByteArray(imageData, 0, imageData.size, options)
            
            options.inSampleSize = calculateOptimalInSampleSize(options)
            options.inJustDecodeBounds = false
            options.inPreferredConfig = Bitmap.Config.ARGB_8888
            
            // 解码位图
            val bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.size, options)
                ?: return null
            
            // 根据原始格式选择压缩参数
            val (format, quality) = when (extension.lowercase()) {
                ".png" -> Pair(Bitmap.CompressFormat.PNG, 100)  // PNG 无损压缩
                ".webp" -> Pair(Bitmap.CompressFormat.WEBP, 85) // WebP 高质量
                else -> Pair(Bitmap.CompressFormat.JPEG, 90)    // JPEG 高质量
            }
            
            // 保存调整后的图片
            val cacheDir = applicationContext.cacheDir
            val file = File(cacheDir, fileName)
            
            FileOutputStream(file).use { out ->
                val success = bitmap.compress(format, quality, out)
                bitmap.recycle() // 及时释放内存
                
                if (success) {
                    out.flush()
                    file.absolutePath
                } else {
                    null
                }
            }
            
        } catch (e: Exception) {
            null
        }
    }

    // 直接保存流到缓存
    private fun saveStreamToCache(inputStream: InputStream, fileName: String): String? {
        return try {
            val cacheDir = applicationContext.cacheDir
            val file = File(cacheDir, fileName)
            
            inputStream.use { input ->
                FileOutputStream(file).use { output ->
                    input.copyTo(output, bufferSize = BUFFER_SIZE)
                    output.flush()
                }
            }
            
            file.absolutePath
            
        } catch (e: Exception) {
            null
        }
    }

    // 保存字节数组到缓存
    private fun saveBytesToCache(data: ByteArray, fileName: String): String? {
        return try {
            val cacheDir = applicationContext.cacheDir
            val file = File(cacheDir, fileName)
            
            FileOutputStream(file).use { output ->
                output.write(data)
                output.flush()
            }
            
            file.absolutePath
            
        } catch (e: Exception) {
            null
        }
    }

    // 复制文件到缓存
    private fun copyFileToCache(sourceFile: File, fileName: String): String? {
        return try {
            val cacheDir = applicationContext.cacheDir
            val destFile = File(cacheDir, fileName)
            
            sourceFile.inputStream().use { input ->
                FileOutputStream(destFile).use { output ->
                    input.copyTo(output, bufferSize = BUFFER_SIZE)
                }
            }
            destFile.absolutePath
            
        } catch (e: Exception) {
            null
        }
    }

    // 获取文件扩展名
    private fun getFileExtension(url: String, contentType: String?): String {
        // 优先从URL获取扩展名
        val urlExtension = getFileExtensionFromPath(url)
        if (urlExtension.isNotEmpty()) {
            return urlExtension
        }
        
        // 其次从Content-Type获取
        return when (contentType?.lowercase()) {
            "image/jpeg", "image/jpg" -> ".jpg"
            "image/png" -> ".png"
            "image/gif" -> ".gif"
            "image/webp" -> ".webp"
            "image/bmp" -> ".bmp"
            else -> ".jpg" // 默认使用jpg
        }
    }

    // 从路径获取文件扩展名
    private fun getFileExtensionFromPath(path: String): String {
        val lastDot = path.lastIndexOf('.')
        val lastSlash = path.lastIndexOf('/')
        
        return if (lastDot > lastSlash && lastDot < path.length - 1) {
            path.substring(lastDot).lowercase()
        } else {
            ""
        }
    }

    // 采样率计算算法
    private fun calculateOptimalInSampleSize(options: BitmapFactory.Options): Int {
        val height = options.outHeight
        val width = options.outWidth
        var inSampleSize = 1
        
        if (height > DEFAULT_NOTIFICATION_IMAGE_SIZE_PX || width > DEFAULT_NOTIFICATION_IMAGE_SIZE_PX) {
            val halfHeight = height / 2
            val halfWidth = width / 2
            
            // 计算最大的inSampleSize值，该值是2的幂，并且保持height和width都大于等于目标尺寸
            while ((halfHeight / inSampleSize) >= DEFAULT_NOTIFICATION_IMAGE_SIZE_PX &&
                   (halfWidth / inSampleSize) >= DEFAULT_NOTIFICATION_IMAGE_SIZE_PX) {
                inSampleSize *= 2
            }
        }
        
        // 确保采样率至少为1，最大为16（避免过度压缩）
        return min(inSampleSize, MAX_IN_SAMPLE_SIZE)
    }

    companion object {
        private const val TAG = "ImageWorker"
        private const val DEFAULT_NOTIFICATION_IMAGE_SIZE_PX = 256
        private const val MAX_IN_SAMPLE_SIZE = 16
        private const val MAX_IMAGE_SIZE_PX = 512  // 超过此尺寸才调整大小
        private const val DIRECT_SAVE_SIZE_THRESHOLD = 100 * 1024  // 100KB以下直接保存
        private const val BUFFER_SIZE = 8192  // 8KB缓冲区
        
        // 网络连接超时配置
        private const val CONNECT_TIMEOUT_MS = 6000
        private const val READ_TIMEOUT_MS = 12000
    }
}
