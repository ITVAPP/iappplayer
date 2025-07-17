import Foundation
import AVFoundation

// 扩展URL以支持自定义协议
fileprivate extension URL {
    func withScheme(_ scheme: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }
}

// 定义缓存播放器委托协议
@objc protocol CachingPlayerItemDelegate {
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) // 媒体文件下载完成
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) // 下载进度更新
    @objc optional func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) // 预缓冲完成，可开始播放
    @objc optional func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem) // 播放因数据不足暂停
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) // 下载失败
}

// 自定义缓存播放器项，继承AVPlayerItem
open class CachingPlayerItem: AVPlayerItem {
    
    // 资源加载委托，处理数据下载和请求
    class ResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
        var playingFromData = false // 是否从数据播放
        var mimeType: String? // 数据播放时的MIME类型
        var session: URLSession? // 下载会话
        var headers: Dictionary<NSObject, AnyObject>? // 请求头
        var mediaData: Data? // 媒体数据缓存
        var response: URLResponse? // 下载响应
        var pendingRequests = Set<AVAssetResourceLoadingRequest>() // 待处理加载请求
        weak var owner: CachingPlayerItem? // 弱引用播放器项
        
        // 处理资源加载请求
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
            if playingFromData {
                // 数据播放无需加载
            } else if session == nil {
                // 首次请求时启动URL下载
                guard let initialUrl = owner?.url else { fatalError("internal inconsistency") }
                startDataRequest(url: initialUrl)
            }
            pendingRequests.insert(loadingRequest)
            processPendingRequests()
            return true
        }
        
        // 启动数据下载请求
        func startDataRequest(url: URL) {
            let configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let headersString = headers as? [String: AnyObject] {
                for (headerKey, headerValue) in headersString {
                    guard let headerValueString = headerValue as? String else { continue }
                    request.setValue(headerValueString, forHTTPHeaderField: headerKey)
                }
            }
            session?.dataTask(with: request).resume()
        }
        
        // 取消资源加载请求
        func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
            pendingRequests.remove(loadingRequest)
        }
        
        // URLSession接收到数据
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            mediaData?.append(data)
            processPendingRequests()
            owner?.delegate?.playerItem?(owner!, didDownloadBytesSoFar: mediaData!.count, outOf: Int(dataTask.countOfBytesExpectedToReceive))
        }
        
        // URLSession接收到响应
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
            completionHandler(.allow)
            mediaData = Data()
            self.response = response
            processPendingRequests()
        }
        
        // URLSession任务完成
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let errorUnwrapped = error {
                owner?.delegate?.playerItem?(owner!, downloadingFailedWith: errorUnwrapped)
                return
            }
            processPendingRequests()
            owner?.delegate?.playerItem?(owner!, didFinishDownloadingData: mediaData!)
        }
        
        // 处理待处理请求
        func processPendingRequests() {
            let requestsFulfilled = Set<AVAssetResourceLoadingRequest>(pendingRequests.compactMap {
                self.fillInContentInformationRequest($0.contentInformationRequest)
                if self.haveEnoughDataToFulfillRequest($0.dataRequest!) {
                    $0.finishLoading()
                    return $0
                }
                return nil
            })
            requestsFulfilled.forEach { pendingRequests.remove($0) }
        }
        
        // 填充内容信息请求
        func fillInContentInformationRequest(_ contentInformationRequest: AVAssetResourceLoadingContentInformationRequest?) {
            if playingFromData {
                contentInformationRequest?.contentType = mimeType
                contentInformationRequest?.contentLength = Int64(mediaData!.count)
                contentInformationRequest?.isByteRangeAccessSupported = true
                return
            }
            guard let responseUnwrapped = response else { return }
            contentInformationRequest?.contentType = responseUnwrapped.mimeType
            contentInformationRequest?.contentLength = responseUnwrapped.expectedContentLength
            contentInformationRequest?.isByteRangeAccessSupported = true
        }
        
        // 检查是否有足够数据满足请求
        func haveEnoughDataToFulfillRequest(_ dataRequest: AVAssetResourceLoadingDataRequest) -> Bool {
            let requestedOffset = Int(dataRequest.requestedOffset)
            let requestedLength = dataRequest.requestedLength
            let currentOffset = Int(dataRequest.currentOffset)
            guard let songDataUnwrapped = mediaData, songDataUnwrapped.count > currentOffset else { return false }
            let bytesToRespond = min(songDataUnwrapped.count - currentOffset, requestedLength)
            let dataToRespond = songDataUnwrapped.subdata(in: currentOffset..<(currentOffset + bytesToRespond))
            dataRequest.respond(with: dataToRespond)
            return songDataUnwrapped.count >= requestedLength + requestedOffset
        }
        
        // 清理会话
        deinit { session?.invalidateAndCancel() }
    }
    
    fileprivate let resourceLoaderDelegate = ResourceLoaderDelegate() // 资源加载委托
    let url: URL // 媒体URL
    var cacheKey: String? = nil // 缓存键
    fileprivate let initialScheme: String? // 原始协议
    fileprivate var customFileExtension: String? // 自定义文件扩展
    weak var delegate: CachingPlayerItemDelegate? // 委托对象
    
    // 启动下载
    open func download() {
        if resourceLoaderDelegate.session == nil {
            resourceLoaderDelegate.startDataRequest(url: url)
        }
    }
    
    // 停止下载
    open func stopDownload() {
        resourceLoaderDelegate.session?.invalidateAndCancel()
    }
    
    private let cachingPlayerItemScheme = "cachingPlayerItemScheme" // 自定义协议
    
    // 初始化远程文件播放
    convenience init(url: URL, cacheKey: String?, headers: Dictionary<NSObject, AnyObject>) {
        self.init(url: url, customFileExtension: nil, cacheKey: cacheKey, headers: headers)
    }
    
    // 初始化远程文件播放，支持自定义扩展
    init(url: URL, customFileExtension: String?, cacheKey: String?, headers: Dictionary<NSObject, AnyObject>) {
        self.cacheKey = cacheKey
        self.url = url
        self.resourceLoaderDelegate.headers = headers
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme,
              var urlWithCustomScheme = url.withScheme(cachingPlayerItemScheme) else {
            fatalError("Urls without a scheme are not supported")
        }
        self.initialScheme = scheme
        if let ext = customFileExtension {
            urlWithCustomScheme.deletePathExtension()
            urlWithCustomScheme.appendPathExtension(ext)
            self.customFileExtension = ext
        }
        let asset = AVURLAsset(url: urlWithCustomScheme)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: DispatchQueue.main)
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        resourceLoaderDelegate.owner = self
        addObserver(self, forKeyPath: "status", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalledHandler), name: .AVPlayerItemPlaybackStalled, object: self)
    }
    
    // 初始化数据播放
    init(data: Data, mimeType: String, fileExtension: String) {
        guard let fakeUrl = URL(string: cachingPlayerItemScheme + "://whatever/file.\(fileExtension)") else {
            fatalError("internal inconsistency")
        }
        self.url = fakeUrl
        self.initialScheme = nil
        resourceLoaderDelegate.mediaData = data
        resourceLoaderDelegate.playingFromData = true
        resourceLoaderDelegate.mimeType = mimeType
        let asset = AVURLAsset(url: fakeUrl)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: DispatchQueue.main)
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        resourceLoaderDelegate.owner = self
        addObserver(self, forKeyPath: "status", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalledHandler), name: .AVPlayerItemPlaybackStalled, object: self)
    }
    
    // 监听状态变化
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        delegate?.playerItemReadyToPlay?(self)
    }
    
    // 处理播放暂停通知
    @objc func playbackStalledHandler() {
        delegate?.playerItemPlaybackStalled?(self)
    }
    
    // 禁用默认初始化
    override init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
        fatalError("not implemented")
    }
    
    // 清理资源
    deinit {
        NotificationCenter.default.removeObserver(self)
        removeObserver(self, forKeyPath: "status")
        resourceLoaderDelegate.session?.invalidateAndCancel()
    }
}
