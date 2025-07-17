import AVKit
import Cache
import HLSCachingReverseProxyServer
import GCDWebServer
import PINCache

/// 视频缓存管理类，支持 HLS 流和普通视频的缓存
@objc public class CacheManager: NSObject {

    /// 存储预缓存的播放项，支持未完成下载的播放
    var _preCachedURLs = Dictionary<String, CachingPlayerItem>()

    /// 缓存完成回调
    var completionHandler: ((_ success: Bool) -> Void)? = nil

    /// 磁盘缓存配置，设置缓存名称、过期时间和最大容量
    var diskConfig = DiskConfig(name: "IAppPlayerCache", expiry: .date(Date().addingTimeInterval(3600*24*30)),
                                maxSize: 100*1024*1024)
    
    /// 是否存在于缓存存储的标志
    var _existsInStorage: Bool = false
    
    /// 内存缓存配置，设置永不过期、无数量和大小限制
    let memoryConfig = MemoryConfig(
        expiry: .never,
        countLimit: 0,
        totalCostLimit: 0
    )
    
    /// HLS 缓存反向代理服务器
    var server: HLSCachingReverseProxyServer?

    /// 缓存存储实例
    lazy var storage: Cache.Storage<String,Data>? = {
        return try? Cache.Storage<String,Data>(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: Data.self))
    }()
    
    /// MIME 类型映射字典，优化查找效率
    private static let mimeTypeMapping: [String: String] = [
        "m3u": "application/vnd.apple.mpegurl",
        "m3u8": "application/vnd.apple.mpegurl",
        "3gp": "video/3gpp",
        "mp4": "video/mp4",
        "m4a": "video/mp4",
        "m4p": "video/mp4",
        "m4b": "video/mp4",
        "m4r": "video/mp4",
        "m4v": "video/mp4",
        "m1v": "video/mpeg",
        "mpg": "video/mpeg",
        "mp2": "video/mpeg",
        "mpeg": "video/mpeg",
        "mpe": "video/mpeg",
        "mpv": "video/mpeg",
        "ogg": "video/ogg",
        "mov": "video/quicktime",
        "qt": "video/quicktime",
        "webm": "video/webm",
        "asf": "video/ms-asf",
        "wma": "video/ms-asf",
        "wmv": "video/ms-asf",
        "avi": "video/x-msvideo"
    ]

    /// 初始化 HLS 缓存服务器
    @objc public func setup() {
        GCDWebServer.setLogLevel(4)
        let webServer = GCDWebServer()
        let cache = PINCache.shared
        let urlSession = URLSession.shared
        server = HLSCachingReverseProxyServer(webServer: webServer, urlSession: urlSession, cache: cache)
        server?.start(port: 8080)
    }
    
    /// 设置最大缓存大小
    @objc public func setMaxCacheSize(_ maxCacheSize: NSNumber?) {
        if let unsigned = maxCacheSize {
            let _maxCacheSize = unsigned.uintValue
            diskConfig = DiskConfig(name: "IAppPlayerCache", expiry: .date(Date().addingTimeInterval(3600*24*30)), maxSize: _maxCacheSize)
        }        
    }

    // MARK: - Logic
    /// 预缓存视频资源
    @objc public func preCacheURL(_ url: URL, cacheKey: String?, videoExtension: String?, withHeaders headers: Dictionary<NSObject,AnyObject>, completionHandler: ((_ success: Bool) -> Void)?) {
        self.completionHandler = completionHandler
        
        let _key: String = cacheKey ?? url.absoluteString
        /// 确保不重复下载缓存项
        if self._preCachedURLs[_key] == nil {            
            if let item = self.getCachingPlayerItem(url, cacheKey: _key, videoExtension: videoExtension, headers: headers) {
                if !self._existsInStorage {
                    self._preCachedURLs[_key] = item
                    item.download()
                } else {
                    self.completionHandler?(true)
                }
            } else {
                self.completionHandler?(false)
            }
        } else {
            self.completionHandler?(true)
        }
    }
    
    /// 停止预缓存
    @obj
c public func stopPreCache(_ url: URL, cacheKey: String?, completionHandler: ((_ success: Bool) -> Void)?) {
        let _key: String = cacheKey ?? url.absoluteString
        if self._preCachedURLs[_key] != nil {
            let playerItem = self._preCachedURLs[_key]!
            playerItem.stopDownload()
            self._preCachedURLs.removeValue(forKey: _key)
            self.completionHandler?(true)
            return
        }
        self.completionHandler?(false)
    }
    
    /// 获取用于普通播放的缓存播放项，支持 HLS 和常规视频
    @objc public func getCachingPlayerItemForNormalPlayback(_ url: URL, cacheKey: String?, videoExtension: String?, headers: Dictionary<NSObject,AnyObject>) -> AVPlayerItem? {
        let mimeTypeResult = getMimeType(url: url, explicitVideoExtension: videoExtension)
        if (mimeTypeResult.1 == "application/vnd.apple.mpegurl") {
            /// 使用反向代理 URL 处理 HLS 流
            let reverseProxyURL = server?.reverseProxyURL(from: url)!
            let playerItem = AVPlayerItem(url: reverseProxyURL!)
            return playerItem
        } else {
            return getCachingPlayerItem(url, cacheKey: cacheKey, videoExtension: videoExtension, headers: headers)
        }
    }
    
    /// 获取缓存播放项，支持从缓存或网络加载
    @objc public func getCachingPlayerItem(_ url: URL, cacheKey: String?, videoExtension: String?, headers: Dictionary<NSObject,AnyObject>) -> CachingPlayerItem? {
        let playerItem: CachingPlayerItem
        let _key: String = cacheKey ?? url.absoluteString
        /// 检查是否存在预缓存项
        if self._preCachedURLs[_key] != nil {
            playerItem = self._preCachedURLs[_key]!
            self._preCachedURLs.removeValue(forKey: _key)
        } else {
            /// 同步检查缓存是否存在
            let data = try? storage?.object(forKey: _key)
            if data != nil {
                self._existsInStorage = true
                let mimeTypeResult = getMimeType(url: url, explicitVideoExtension: videoExtension)
                if (mimeTypeResult.1.isEmpty) {
                    NSLog("缓存错误: 未找到 URL 的 MIME 类型: \(url.absoluteURL)。视频将不使用缓存播放。")
                    playerItem = CachingPlayerItem(url: url, cacheKey: _key, headers: headers)
                } else {
                    playerItem = CachingPlayerItem(data: data!, mimeType: mimeTypeResult.1, fileExtension: mimeTypeResult.0)
                }
            } else {
                /// 文件未缓存，从网络加载
                playerItem = CachingPlayerItem(url: url, cacheKey: _key, headers: headers)
                self._existsInStorage = false
            }
        }
        playerItem.delegate = self
        return playerItem
    }
    
    /// 清除所有缓存
    @objc public func clearCache() {
        try? storage?.removeAll()
        self._preCachedURLs = Dictionary<String,CachingPlayerItem>()
    }
    
    /// 获取 MIME 类型和文件扩展名
    private func getMimeType(url: URL, explicitVideoExtension: String?) -> (String, String) {
        var videoExtension = url.pathExtension
        if let explicitExtension = explicitVideoExtension {
            videoExtension = explicitExtension
        }
        
        /// 使用字典查找 MIME 类型，优化性能
        let mimeType = CacheManager.mimeTypeMapping[videoExtension] ?? ""
        return (videoExtension, mimeType)
    }
    
    /// 检查是否支持预缓存
    @objc public func isPreCacheSupported(url: URL, videoExtension: String?) -> Bool {
        let mimeTypeResult = getMimeType(url: url, explicitVideoExtension: videoExtension)
        return !mimeTypeResult.1.isEmpty && mimeTypeResult.1 != "application/vnd.apple.mpegurl"
    }
}

// MARK: - CachingPlayerItemDelegate
extension CacheManager: CachingPlayerItemDelegate {
    /// 处理下载完成，异步保存到缓存
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        storage?.async.setObject(data, forKey: playerItem.cacheKey ?? playerItem.url.absoluteString, completion: { _ in })
        self.completionHandler?(true)
    }

    /// 处理下载进度
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        let percentage = Double(bytesDownloaded)/Double(bytesExpected)*100.0
        let str = String(format: "%.1f%%", percentage)
        //NSLog("下载进度: %@", str)
    }

    /// 处理下载失败
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        NSLog("缓存文件下载失败: \(error.localizedDescription)")
        self.completionHandler?(false)
    }
}
