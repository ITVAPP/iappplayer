#import "IAppPlayer.h"
#import <iapp_player/iapp_player-Swift.h>

static void* timeRangeContext = &timeRangeContext; // 时间范围观察上下文
static void* statusContext = &statusContext; // 状态观察上下文
static void* playbackLikelyToKeepUpContext = &playbackLikelyToKeepUpContext; // 缓冲充足观察上下文
static void* playbackBufferEmptyContext = &playbackBufferEmptyContext; // 缓冲空观察上下文
static void* playbackBufferFullContext = &playbackBufferFullContext; // 缓冲满观察上下文
static void* presentationSizeContext = &presentationSizeContext; // 视频尺寸观察上下文

// 常量定义
static const int MAX_RETRY_COUNT = 2; // 最大重试次数
static const int RETRY_DELAY_MS = 500; // 重试延迟（毫秒）
static const int BUFFERING_UPDATE_THROTTLE_MS = 600; // 缓冲更新节流时间（毫秒）

// 解码器优先级常量
static const int DECODER_HARDWARE_FIRST = 1;
static const int DECODER_SOFTWARE_FIRST = 2;

// 网络配置常量
static const NSTimeInterval CONNECT_TIMEOUT_SEC = 3.0;  // 3秒连接超时
static const NSTimeInterval READ_TIMEOUT_SEC = 15.0;    // 15秒读取超时

#if TARGET_OS_IOS
void (^__strong _Nonnull _restoreUserInterfaceForPIPStopCompletionHandler)(BOOL); // 画中画停止后界面恢复回调
API_AVAILABLE(ios(9.0))
AVPictureInPictureController *_pipController; // 画中画控制器
#endif

/// 视频播放器插件实现，管理播放、画中画和事件监听
@implementation IAppPlayer {
    AVPlayerItem* _currentObservedItem; // 当前观察的播放项
    // DRM相关属性（用于重试）
    NSString* _currentCertificateUrl; // 当前 DRM 证书 URL
    NSString* _currentLicenseUrl; // 当前 DRM 许可 URL
    // 缓冲更新使用可变数组
    NSMutableArray<NSArray<NSNumber*>*>* _bufferRangesCache; // 缓冲范围缓存
    // 缓冲参数存储
    int _minBufferMs;
    int _maxBufferMs;
    int _bufferForPlaybackMs;
    int _bufferForPlaybackAfterRebufferMs;
    // 线程安全锁
    NSLock* _observerLock; // 观察者操作锁
}

/// 初始化播放器，设置默认状态和行为
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _isInitialized = false; // 初始化状态
    _isPlaying = false; // 播放状态
    _disposed = false; // 释放状态
    _player = [[AVPlayer alloc] init]; // 初始化播放器
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone; // 播放结束不自动处理
    /// 禁用自动等待以减少卡顿（iOS 10+）
    if (@available(iOS 10.0, *)) {
        _player.automaticallyWaitsToMinimizeStalling = false; // 禁用自动等待
    }
    self._observersAdded = false; // 观察者添加状态
    _currentObservedItem = nil; // 初始化观察项
    
    // 初始化重试相关属性
    _retryCount = 0; // 重试计数
    _wasPlayingBeforeError = false; // 错误前播放状态
    
    // 初始化缓冲节流相关属性
    _lastSendBufferedPosition = 0; // 上次发送的缓冲位置
    _lastBufferingUpdateTime = 0; // 上次缓冲更新时间
    
    // 初始化缓冲范围缓存
    _bufferRangesCache = [[NSMutableArray alloc] init];
    
    // 初始化解码器优先级（默认硬解优先）
    _preferredDecoderType = DECODER_HARDWARE_FIRST;
    
    // 设置默认缓冲参数
    _minBufferMs = 50000;  // 50秒
    _maxBufferMs = 50000;  // 50秒
    _bufferForPlaybackMs = 2500;  // 2.5秒
    _bufferForPlaybackAfterRebufferMs = 5000;  // 5秒
    
    // 初始化线程安全锁
    _observerLock = [[NSLock alloc] init];
    
    return self;
}

/// 配置缓冲参数
- (void)configureBufferParameters:(NSNumber*)minBufferMs
                      maxBufferMs:(NSNumber*)maxBufferMs
              bufferForPlaybackMs:(NSNumber*)bufferForPlaybackMs
 bufferForPlaybackAfterRebufferMs:(NSNumber*)bufferForPlaybackAfterRebufferMs {
    
    _minBufferMs = (minBufferMs && [minBufferMs intValue] > 0) ? [minBufferMs intValue] : 30000;
    _maxBufferMs = (maxBufferMs && [maxBufferMs intValue] > 0) ? [maxBufferMs intValue] : 30000;
    _bufferForPlaybackMs = (bufferForPlaybackMs && [bufferForPlaybackMs intValue] > 0) ? [bufferForPlaybackMs intValue] : 3000;
    _bufferForPlaybackAfterRebufferMs = (bufferForPlaybackAfterRebufferMs && [bufferForPlaybackAfterRebufferMs intValue] > 0) ? [bufferForPlaybackAfterRebufferMs intValue] : 5000;
}

/// 返回播放器视图
- (nonnull UIView *)view {
    IAppPlayerView *playerView = [[IAppPlayerView alloc] initWithFrame:CGRectZero]; // 创建播放器视图
    playerView.player = _player; // 设置播放器
    return playerView;
}

/// 为播放项添加 KVO 和通知观察者
- (void)addObservers:(AVPlayerItem*)item {
    [_observerLock lock];
    @try {
        // 确保不重复添加观察者，且播放项有效
        if (!self._observersAdded && item && !_disposed && item != _currentObservedItem) {
            // 先记录新的观察项
            _currentObservedItem = item;
            
            [_player addObserver:self forKeyPath:@"rate" options:0 context:nil]; // 播放速率观察
            [item addObserver:self forKeyPath:@"loadedTimeRanges" options:0 context:timeRangeContext]; // 加载时间范围观察
            [item addObserver:self forKeyPath:@"status" options:0 context:statusContext]; // 播放状态观察
            [item addObserver:self forKeyPath:@"presentationSize" options:0 context:presentationSizeContext]; // 视频尺寸观察
            [item addObserver:self
                   forKeyPath:@"playbackLikelyToKeepUp"
                      options:0
                      context:playbackLikelyToKeepUpContext]; // 播放缓冲充足观察
            [item addObserver:self
                   forKeyPath:@"playbackBufferEmpty"
                      options:0
                      context:playbackBufferEmptyContext]; // 缓冲区空观察
            [item addObserver:self
                   forKeyPath:@"playbackBufferFull"
                      options:0
                      context:playbackBufferFullContext]; // 缓冲区满观察
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(itemDidPlayToEndTime:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:item]; // 播放结束通知
            self._observersAdded = true; // 更新观察状态
        }
    }
    @finally {
        [_observerLock unlock];
    }
}

/// 清除播放器状态和资源
- (void)clear {
    _isInitialized = false; // 重置初始化状态
    _isPlaying = false; // 重置播放状态
    _key = nil; // 重置密钥
    
    // 重置重试相关状态
    [self resetRetryState]; // 重置重试状态
    
    // 清理数据源相关属性
    _currentMediaURL = nil; // 清空媒体 URL
    _currentHeaders = nil; // 清空请求头
    _currentUseCache = NO; // 清空缓存状态
    _currentCacheKey = nil; // 清空缓存键
    _currentVideoExtension = nil; // 清空视频扩展
    _currentCacheManager = nil; // 清空缓存管理器
    _currentCertificateUrl = nil; // 清空证书 URL
    _currentLicenseUrl = nil; // 清空许可 URL
    
    // 重置缓冲节流状态
    _lastSendBufferedPosition = 0; // 重置缓冲位置
    _lastBufferingUpdateTime = 0; // 重置缓冲更新时间
    [_bufferRangesCache removeAllObjects]; // 清空缓冲范围缓存
    
    if (_player.currentItem == nil) {
        return;
    }

    [self removeObservers]; // 移除观察者
    AVAsset* asset = [_player.currentItem asset]; // 获取当前资源
    [asset cancelLoading]; // 取消资源加载
}

/// 移除播放器和播放项的观察者
- (void)removeObservers {
    [_observerLock lock];
    @try {
        if (self._observersAdded) {
            @try {
                [_player removeObserver:self forKeyPath:@"rate" context:nil]; // 移除播放速率观察
            }
            @catch (NSException *exception) {
                NSLog(@"移除 rate 观察者异常: %@", exception.description);
            }
            
            AVPlayerItem* currentItem = _player.currentItem;
            if (currentItem != nil) {
                @try {
                    [currentItem removeObserver:self forKeyPath:@"status" context:statusContext]; // 移除状态观察
                }
                @catch (NSException *exception) {
                    NSLog(@"移除 status 观察者异常: %@", exception.description);
                }
                
                @try {
                    [currentItem removeObserver:self forKeyPath:@"presentationSize" context:presentationSizeContext]; // 移除尺寸观察
                }
                @catch (NSException *exception) {
                    NSLog(@"移除 presentationSize 观察者异常: %@", exception.description);
                }
                
                @try {
                    [currentItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:timeRangeContext]; // 移除加载时间观察
                }
                @catch (NSException *exception) {
                    NSLog(@"移除 loadedTimeRanges 观察者异常: %@", exception.description);
                }
                
                @try {
                    [currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:playbackLikelyToKeepUpContext]; // 移除缓冲充足观察
                }
                @catch (NSException *exception) {
                    NSLog(@"移除 playbackLikelyToKeepUp 观察者异常: %@", exception.description);
                }
                
                @try {
                    [currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:playbackBufferEmptyContext]; // 移除缓冲空观察
                }
                @catch (NSException *exception) {
                    NSLog(@"移除 playbackBufferEmpty 观察者异常: %@", exception.description);
                }
                
                @try {
                    [currentItem removeObserver:self forKeyPath:@"playbackBufferFull" context:playbackBufferFullContext]; // 移除缓冲满观察
                }
                @catch (NSException *exception) {
                    NSLog(@"移除 playbackBufferFull 观察者异常: %@", exception.description);
                }
            }
            
            // 从保存的 _currentObservedItem 移除
            if (_currentObservedItem != nil && _currentObservedItem != currentItem) {
                @try {
                    [_currentObservedItem removeObserver:self forKeyPath:@"status" context:statusContext];
                }
                @catch (NSException *exception) {
                    // 静默处理，因为可能已经被移除
                }
                
                @try {
                    [_currentObservedItem removeObserver:self forKeyPath:@"presentationSize" context:presentationSizeContext];
                }
                @catch (NSException *exception) {
                    // 静默处理
                }
                
                @try {
                    [_currentObservedItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:timeRangeContext];
                }
                @catch (NSException *exception) {
                    // 静默处理
                }
                
                @try {
                    [_currentObservedItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:playbackLikelyToKeepUpContext];
                }
                @catch (NSException *exception) {
                    // 静默处理
                }
                
                @try {
                    [_currentObservedItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:playbackBufferEmptyContext];
                }
                @catch (NSException *exception) {
                    // 静默处理
                }
                
                @try {
                    [_currentObservedItem removeObserver:self forKeyPath:@"playbackBufferFull" context:playbackBufferFullContext];
                }
                @catch (NSException *exception) {
                    // 静默处理
                }
            }
            
            [[NSNotificationCenter defaultCenter] removeObserver:self]; // 移除通知
            self._observersAdded = false; // 更新观察状态
            _currentObservedItem = nil; // 清空观察项
        }
    }
    @finally {
        [_observerLock unlock];
    }
}

/// 处理视频播放结束事件
- (void)itemDidPlayToEndTime:(NSNotification*)notification {
    if (_isLooping) {
        AVPlayerItem* p = [notification object]; // 获取播放项
        [p seekToTime:kCMTimeZero completionHandler:nil]; // 循环播放
    } else {
        if (_eventSink) {
            _eventSink(@{@"event" : @"completed", @"key" : _key}); // 发送完成事件
            [self removeObservers]; // 移除观察者
        }
    }
}

/// 将弧度转换为角度
static inline CGFloat radiansToDegrees(CGFloat radians) {
    CGFloat degrees = GLKMathRadiansToDegrees((float)radians); // 转换角度
    if (degrees < 0) {
        return degrees + 360; // 修正负角度
    }
    return degrees;
}

/// 创建视频合成对象，应用变换
- (AVMutableVideoComposition*)getVideoCompositionWithTransform:(CGAffineTransform)transform
                                                     withAsset:(AVAsset*)asset
                                                withVideoTrack:(AVAssetTrack*)videoTrack {
    AVMutableVideoCompositionInstruction* instruction =
    [AVMutableVideoCompositionInstruction videoCompositionInstruction]; // 创建合成指令
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [asset duration]); // 设置时间范围
    AVMutableVideoCompositionLayerInstruction* layerInstruction =
    [AVMutableVideoCompositionLayerInstruction
     videoCompositionLayerInstructionWithAssetTrack:videoTrack]; // 创建层指令
    [layerInstruction setTransform:_preferredTransform atTime:kCMTimeZero]; // 设置变换

    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition]; // 创建视频合成
    instruction.layerInstructions = @[ layerInstruction ]; // 设置层指令
    videoComposition.instructions = @[ instruction ]; // 设置合成指令

    /// 调整视频尺寸以适配旋转
    CGFloat width = videoTrack.naturalSize.width; // 获取视频宽度
    CGFloat height = videoTrack.naturalSize.height; // 获取视频高度
    NSInteger rotationDegrees =
    (NSInteger)round(radiansToDegrees(atan2(_preferredTransform.b, _preferredTransform.a))); // 计算旋转角度
    if (rotationDegrees == 90 || rotationDegrees == 270) {
        width = videoTrack.naturalSize.height; // 调整宽高
        height = videoTrack.naturalSize.width;
    }
    videoComposition.renderSize = CGSizeMake(width, height); // 设置渲染尺寸

    float nominalFrameRate = videoTrack.nominalFrameRate; // 获取帧率
    int fps = 30; // 默认帧率
    if (nominalFrameRate > 0) {
        fps = (int) ceil(nominalFrameRate); // 设置实际帧率
    }
    videoComposition.frameDuration = CMTimeMake(1, fps); // 设置帧时长
    
    return videoComposition;
}

/// 修正视频轨道变换
- (CGAffineTransform)fixTransform:(AVAssetTrack*)videoTrack {
    CGAffineTransform transform = videoTrack.preferredTransform; // 获取变换
    NSInteger rotationDegrees = (NSInteger)round(radiansToDegrees(atan2(transform.b, transform.a))); // 计算旋转角度
    if (rotationDegrees == 90) {
        transform.tx = videoTrack.naturalSize.height; // 修正90度
        transform.ty = 0;
    } else if (rotationDegrees == 180) {
        transform.tx = videoTrack.naturalSize.width; // 修正180度
        transform.ty = videoTrack.naturalSize.height;
    } else if (rotationDegrees == 270) {
        transform.tx = 0; // 修正270度
        transform.ty = videoTrack.naturalSize.width;
    }
    return transform; // 返回修正变换
}

/// 设置本地资源数据源
- (void)setDataSourceAsset:(NSString*)asset withKey:(NSString*)key withCertificateUrl:(NSString*)certificateUrl withLicenseUrl:(NSString*)licenseUrl cacheKey:(NSString*)cacheKey cacheManager:(CacheManager*)cacheManager overriddenDuration:(int)overriddenDuration preferredDecoderType:(int)decoderType {
    NSString* path = [[NSBundle mainBundle] pathForResource:asset ofType:nil]; // 获取资源路径
    return [self setDataSourceURL:[NSURL fileURLWithPath:path] withKey:key withCertificateUrl:certificateUrl withLicenseUrl:(NSString*)licenseUrl withHeaders:@{} withCache:false cacheKey:cacheKey cacheManager:cacheManager overriddenDuration:overriddenDuration videoExtension:nil preferredDecoderType:decoderType]; // 设置本地URL
}

/// 设置网络资源数据源
- (void)setDataSourceURL:(NSURL*)url withKey:(NSString*)key withCertificateUrl:(NSString*)certificateUrl withLicenseUrl:(NSString*)licenseUrl withHeaders:(NSDictionary*)headers withCache:(BOOL)useCache cacheKey:(NSString*)cacheKey cacheManager:(CacheManager*)cacheManager overriddenDuration:(int)overriddenDuration videoExtension:(NSString*)videoExtension preferredDecoderType:(int)decoderType {
    _overriddenDuration = 0; // 重置覆盖时长
    // 合并 null 检查
    headers = (headers == [NSNull null] || headers == NULL) ? @{} : headers;
    
    // 保存解码器优先级
    _preferredDecoderType = decoderType;
    
    // 保存当前数据源信息，用于重试
    _currentMediaURL = url; // 保存媒体 URL
    _currentHeaders = headers; // 保存请求头
    _currentUseCache = useCache; // 保存缓存状态
    _currentCacheKey = cacheKey; // 保存缓存键
    _currentVideoExtension = videoExtension; // 保存视频扩展
    _currentCacheManager = cacheManager; // 保存缓存管理器
    _currentCertificateUrl = certificateUrl; // 保存证书 URL
    _currentLicenseUrl = licenseUrl; // 保存许可 URL
    
    // 重置重试状态
    [self resetRetryState]; // 重置重试状态
    
    AVPlayerItem* item;
    if (useCache){
        // 合并 null 检查
        cacheKey = (cacheKey == [NSNull null]) ? nil : cacheKey;
        videoExtension = (videoExtension == [NSNull null]) ? nil : videoExtension;
        
        item = [cacheManager getCachingPlayerItemForNormalPlayback:url cacheKey:cacheKey videoExtension:videoExtension headers:headers]; // 获取缓存播放项
    } else {
        // 创建AVURLAsset
        NSMutableDictionary* options = [NSMutableDictionary dictionary];
        options[@"AVURLAssetHTTPHeaderFieldsKey"] = headers;
        // 优化网络性能
        options[AVURLAssetPreferPreciseDurationAndTimingKey] = @NO;
        options[AVURLAssetReferenceRestrictionsKey] = @(AVAssetReferenceRestrictionForbidNone);
        
        // 添加网络超时配置（iOS 13+）
        if (@available(iOS 13.0, *)) {
            // 设置HTTP最大连接数
            options[AVURLAssetHTTPMaximumConnectionsPerHostKey] = @6;
            
            // 配置URLSession
            NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
            config.timeoutIntervalForRequest = READ_TIMEOUT_SEC;
            config.timeoutIntervalForResource = READ_TIMEOUT_SEC * 2; // 资源总超时
            config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            config.HTTPShouldSetCookies = YES;
            config.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
            
            // 允许蜂窝网络
            config.allowsCellularAccess = YES;
            
            // 优化传输
            if (@available(iOS 13.0, *)) {
                config.allowsConstrainedNetworkAccess = YES;
                config.allowsExpensiveNetworkAccess = YES;
            }
            
            NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
            options[AVURLAssetURLSessionKey] = session;
        }
        
        // 允许跨协议重定向
        options[AVURLAssetAllowsCellularAccessKey] = @YES;
        
        AVURLAsset* asset = [AVURLAsset URLAssetWithURL:url options:options]; // 创建网络资源
        if (certificateUrl && certificateUrl != [NSNull null] && [certificateUrl length] > 0) {
            NSURL * certificateNSURL = [[NSURL alloc] initWithString:certificateUrl]; // 初始化证书URL
            NSURL * licenseNSURL = [[NSURL alloc] initWithString:licenseUrl]; // 初始化许可URL
            _loaderDelegate = [[IAppPlayerEzDrmAssetsLoaderDelegate alloc] init:certificateNSURL withLicenseURL:licenseNSURL]; // 初始化加载器
            dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, -1);
            dispatch_queue_t streamQueue = dispatch_queue_create("streamQueue", qos); // 创建流处理队列
            [asset.resourceLoader setDelegate:_loaderDelegate queue:streamQueue]; // 设置资源加载器
        }
        item = [AVPlayerItem playerItemWithAsset:asset]; // 创建播放项
    }

    if (@available(iOS 10.0, *) && overriddenDuration > 0) {
        _overriddenDuration = overriddenDuration; // 设置覆盖时长
    }
    
    // 先应用缓冲参数，再判断是否为HLS
    [self applyBufferParametersToItem:item];
    
    // 检测是否为HLS直播流并进行配置
    NSString* urlString = url.absoluteString.lowercaseString;
    if ([urlString containsString:@".m3u8"] || [urlString containsString:@"application/vnd.apple.mpegurl"]) {
        [self configureHLSLivePlayback:item];
    }
    
    return [self setDataSourcePlayerItem:item withKey:key]; // 设置播放项
}

/// 配置HLS直播优化
- (void)configureHLSLivePlayback:(AVPlayerItem*)item {
    if (@available(iOS 13.0, *)) {
        // 设置前向缓冲时长为8秒
        item.preferredForwardBufferDuration = 8.0;
    }
    
    if (@available(iOS 10.0, *)) {
        // 允许暂停时继续使用网络资源（直播场景）
        item.canUseNetworkResourcesForLiveStreamingWhilePaused = YES;
        // 不限制峰值比特率
        item.preferredPeakBitRate = 0;
    }
    
    // 配置播放器以降低直播延迟
    if (@available(iOS 10.0, *)) {
        _player.automaticallyWaitsToMinimizeStalling = NO;
    }
    
    // HLS专用网络配置
    if (@available(iOS 14.0, *)) {
        // 配置HLS变体选择策略
        item.preferredPeakBitRateForExpensiveNetworks = 0; // 不限制
        item.preferredMaximumResolutionForExpensiveNetworks = CGSizeZero; // 不限制
    }
    
    if (@available(iOS 14.5, *)) {
        item.startsOnFirstEligibleVariant = YES; // 快速启动
    }
}

/// 应用缓冲参数到播放项
- (void)applyBufferParametersToItem:(AVPlayerItem*)item {
    if (@available(iOS 10.0, *)) {
        // 设置缓冲时长（转换为秒）
        item.preferredForwardBufferDuration = _maxBufferMs / 1000.0;
        
        // 配置播放器的自动等待行为
        if (_bufferForPlaybackMs < 3000) {
            // 快速启动模式
            _player.automaticallyWaitsToMinimizeStalling = NO;
        } else {
            // 标准模式
            _player.automaticallyWaitsToMinimizeStalling = YES;
        }
    }
    
    // 根据缓冲策略调整播放行为
    if (@available(iOS 13.0, *)) {
        // 设置变体切换策略
        if (_bufferForPlaybackMs < 3000) {
            // 快速启动：选择较低质量的变体
            item.startsOnFirstEligibleVariant = YES;
        }
    }
}

/// 配置解码器优先级（简化版，避免过度设计）
- (void)configureDecoderPriority:(AVPlayerItem*)item {
    // iOS的AVFoundation会自动处理解码器回退，这里只做基本配置
    if (@available(iOS 11.0, *)) {
        if (_preferredDecoderType == DECODER_SOFTWARE_FIRST) {
            // 软解优先时，减少缓冲以加快启动
            item.preferredForwardBufferDuration = 2.0;
        }
    }
}

/// 设置播放项并初始化观察者
- (void)setDataSourcePlayerItem:(AVPlayerItem*)item withKey:(NSString*)key {
    _key = key; // 设置键
    _stalledCount = 0; // 重置卡顿计数
    _isStalledCheckStarted = false; // 重置卡顿检查状态
    _playerRate = 1; // 初始化播放速率
    
    // 配置解码器优先级
    [self configureDecoderPriority:item];
    
    [_player replaceCurrentItemWithPlayerItem:item]; // 替换当前播放项

    AVAsset* asset = [item asset]; // 获取资源
    void (^assetCompletionHandler)(void) = ^{
        if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
            NSArray* tracks = [asset tracksWithMediaType:AVMediaTypeVideo]; // 获取视频轨道
            if ([tracks count] > 0) {
                AVAssetTrack* videoTrack = tracks[0]; // 获取首个视频轨道
                void (^trackCompletionHandler)(void) = ^{
                    if (self->_disposed) return;
                    if ([videoTrack statusOfValueForKey:@"preferredTransform"
                                                  error:nil] == AVKeyValueStatusLoaded) {
                        /// 应用修正后的视频变换
                        self->_preferredTransform = [self fixTransform:videoTrack]; // 修正变换
                        AVMutableVideoComposition* videoComposition =
                        [self getVideoCompositionWithTransform:self->_preferredTransform
                                                     withAsset:asset
                                                withVideoTrack:videoTrack]; // 获取视频合成
                        item.videoComposition = videoComposition; // 设置视频合成
                    }
                };
                [videoTrack loadValuesAsynchronouslyForKeys:@[ @"preferredTransform" ]
                                          completionHandler:trackCompletionHandler]; // 异步加载变换
            }
        }
    };

    [asset loadValuesAsynchronouslyForKeys:@[ @"tracks" ] completionHandler:assetCompletionHandler]; // 异步加载轨道
    [self addObservers:item]; // 添加观察者
}

// 重置重试状态
- (void)resetRetryState {
    _retryCount = 0; // 重置重试计数
    _wasPlayingBeforeError = false; // 重置错误前播放状态
}

// 判断是否为网络错误
- (BOOL)isNetworkError:(NSError*)error {
    if (!error) return NO; // 空错误返回否
    
    NSInteger code = error.code; // 获取错误码
    
    // AVFoundation 网络错误码
    if (code == AVErrorServerIncorrectlyConfigured ||
        code == AVErrorHTTPServerError ||
        code == AVErrorNetworkConnectionFailed ||
        code == AVErrorContentIsNotAuthorized ||
        code == AVErrorApplicationIsNotAuthorized ||
        code == AVErrorUnknown) {
        return YES; // 返回是网络错误
    }
    
    // 检查错误域
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        return YES; // URL 错误
    }
    
    // 检查错误信息中的网络关键词
    NSString* errorMessage = [[error.localizedDescription lowercaseString] copy]; // 转换为小写
    NSArray* networkKeywords = @[@"network", @"timeout", @"connection", @"failed to connect", @"unable to connect"]; // 网络关键词
    for (NSString* keyword in networkKeywords) {
        if ([errorMessage containsString:keyword]) {
            return YES; // 包含网络关键词
        }
    }
    
    return NO; // 非网络错误
}

// 判断是否为直播流
- (BOOL)isLiveStream {
    // RTMP/RTSP流
    NSString* scheme = _currentMediaURL.scheme.lowercaseString;
    if ([scheme isEqualToString:@"rtmp"] ||
        [scheme isEqualToString:@"rtmps"] ||
        [scheme isEqualToString:@"rtmpe"] ||
        [scheme isEqualToString:@"rtmpt"] ||
        [scheme isEqualToString:@"rtmpte"] ||
        [scheme isEqualToString:@"rtmpts"] ||
        [scheme isEqualToString:@"rtsp"]) {
        return YES;
    }
    
    // HLS直播流判断
    if ([_currentMediaURL.absoluteString.lowercaseString containsString:@"live"]) {
        return YES;
    }
    
    // 使用播放器判断
    if (_player.currentItem) {
        return CMTIME_IS_INDEFINITE(_player.currentItem.duration);
    }
    
    return NO;
}

// 处理播放器错误
- (void)handlePlayerError:(NSError*)error {
    if (_disposed) return; // 已释放则返回
    
    // 记录播放状态（仅非直播流）
    if (![self isLiveStream]) {
        _wasPlayingBeforeError = _isPlaying; // 保存播放状态
    }
    
    NSInteger code = error.code;
    
    // 解码器错误 - iOS会自动处理解码器回退
    if (code == AVErrorDecoderNotFound || 
        code == AVErrorDecoderTemporarilyUnavailable ||
        code == AVErrorDecodeFailed) {
        // iOS的AVFoundation会自动尝试软解，无需手动处理
        NSLog(@"解码器错误，系统将自动回退: %@", error.localizedDescription);
        return;
    }
    
    // 格式相关错误
    if (code == AVErrorFileFormatNotRecognized ||
        code == AVErrorInvalidSourceMedia ||
        code == AVErrorUnknown ||
        code == AVErrorCompositionTrackSegmentsNotContiguous) {
        if ([self isNetworkError:error] && _retryCount < MAX_RETRY_COUNT) {
            [self performNetworkRetry];
        } else {
            if (_eventSink) {
                _eventSink([FlutterError errorWithCode:@"VideoError"
                                             message:[NSString stringWithFormat:@"格式错误: %@", error.localizedDescription]
                                             details:nil]);
            }
        }
        return;
    }
    
    // 直播流相关错误
    if (code == AVErrorLiveStreamNotSeekable || 
        code == AVErrorNoLongerPlayable) {
        // 重新定位到当前直播位置
        [_player.currentItem seekToTime:kCMTimeZero 
                      toleranceBefore:kCMTimeZero 
                       toleranceAfter:kCMTimeZero 
                     completionHandler:^(BOOL finished) {
            if (finished && self->_wasPlayingBeforeError) {
                [self play];
            }
        }];
        return;
    }
    
    // 其他错误，尝试网络重试
    if ([self isNetworkError:error] && _retryCount < MAX_RETRY_COUNT) {
        [self performNetworkRetry]; // 执行网络重试
    } else {
        // 发送错误事件
        if (_eventSink) {
            _eventSink([FlutterError errorWithCode:@"VideoError"
                                          message:[NSString stringWithFormat:@"播放错误: %@", error.localizedDescription]
                                          details:nil]); // 发送错误事件
        }
    }
}

// 执行网络重试
- (void)performNetworkRetry {
    _retryCount++; // 增加重试次数
    
    // 计算重试延迟
    NSTimeInterval delaySeconds = (RETRY_DELAY_MS * _retryCount) / 1000.0; // 计算延迟
    
    // 使用GCD延迟执行重试
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self->_disposed) {
            [self performRetry]; // 执行重试
        }
    });
}

// 执行重试操作
- (void)performRetry {
    if (_disposed || !_currentMediaURL) return; // 已释放或无URL退出
    
    // 停止当前播放
    [_player pause]; // 暂停播放
    
    // 对于非直播流，尝试直接 seek 到开始位置而不是重建所有对象
    if (![self isLiveStream] && _player.currentItem && _player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        // 如果当前项目状态良好，只需重新开始
        [_player.currentItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            if (finished && self->_wasPlayingBeforeError) {
                [self play]; // 恢复播放
            }
        }];
        return;
    }
    
    // 如果无法复用或是直播流，则重新创建播放项
    AVPlayerItem* item;
    if (_currentUseCache && _currentCacheManager) {
        item = [_currentCacheManager getCachingPlayerItemForNormalPlayback:_currentMediaURL 
                                                                  cacheKey:_currentCacheKey 
                                                           videoExtension:_currentVideoExtension 
                                                                  headers:_currentHeaders]; // 获取缓存播放项
    } else {
        // 使用选项创建AVURLAsset
        NSMutableDictionary* options = [NSMutableDictionary dictionary];
        options[@"AVURLAssetHTTPHeaderFieldsKey"] = _currentHeaders;
        options[AVURLAssetPreferPreciseDurationAndTimingKey] = @NO;
        options[AVURLAssetReferenceRestrictionsKey] = @(AVAssetReferenceRestrictionForbidNone);
        
        AVURLAsset* asset = [AVURLAsset URLAssetWithURL:_currentMediaURL options:options]; // 创建资源
        
        // 处理DRM
        if (_currentCertificateUrl && _currentCertificateUrl != [NSNull null] && [_currentCertificateUrl length] > 0) {
            NSURL * certificateNSURL = [[NSURL alloc] initWithString:_currentCertificateUrl]; // 初始化证书
            NSURL * licenseNSURL = [[NSURL alloc] initWithString:_currentLicenseUrl]; // 初始化许可
            _loaderDelegate = [[IAppPlayerEzDrmAssetsLoaderDelegate alloc] init:certificateNSURL withLicenseURL:licenseNSURL]; // 初始化加载器
            dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, -1);
            dispatch_queue_t streamQueue = dispatch_queue_create("streamQueue", qos); // 创建流处理队列
            [asset.resourceLoader setDelegate:_loaderDelegate queue:streamQueue]; // 设置资源加载器
        }
        
        item = [AVPlayerItem playerItemWithAsset:asset]; // 创建播放项
    }
    
    // 应用缓冲参数
    [self applyBufferParametersToItem:item];
    
    // 如果是HLS流，配置优化参数
    NSString* urlString = _currentMediaURL.absoluteString.lowercaseString;
    if ([urlString containsString:@".m3u8"]) {
        [self configureHLSLivePlayback:item];
    }
    
    // 设置新的播放项
    [self setDataSourcePlayerItem:item withKey:_key]; // 设置播放项
    
    // 恢复播放状态
    if (_wasPlayingBeforeError) {
        [self play]; // 恢复播放
    }
}

/// 处理播放卡顿
- (void)handleStalled {
    if (_isStalledCheckStarted){
        return; // 已开始检查则返回
    }
    _isStalledCheckStarted = true; // 标记开始检查
    [self startStalledCheck]; // 开始卡顿检查
}

/// 开始卡顿检查并尝试恢复播放
- (void)startStalledCheck {
    // 使用配置的缓冲参数判断
    float bufferTimeInSeconds = _bufferForPlaybackAfterRebufferMs / 1000.0;
    
    if (_player.currentItem.playbackLikelyToKeepUp ||
        [self availableDuration] - CMTimeGetSeconds(_player.currentItem.currentTime) > bufferTimeInSeconds) {
        [self play]; // 缓冲充足则播放
    } else {
        _stalledCount++; // 增加卡顿计数
        if (_stalledCount > 60){
            if (_eventSink != nil) {
                _eventSink([FlutterError
                        errorWithCode:@"VideoError"
                        message:@"视频播放卡顿失败"
                        details:nil]); // 发送卡顿错误
            }
            return;
        }
        /// 使用 GCD 定时检查，替换 performSelector
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self startStalledCheck]; // 定时重新检查
        });
    }
}

/// 获取已加载的视频时长
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges]; // 获取加载时间范围
    if (loadedTimeRanges.count > 0){
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue]; // 获取首个时间范围
        Float64 startSeconds = CMTimeGetSeconds(timeRange.start); // 开始时间
        Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration); // 时长
        NSTimeInterval result = startSeconds + durationSeconds; // 总时长
        return result; // 返回时长
    } else {
        return 0; // 无时间范围返回0
    }
}

// 获取缓冲位置（毫秒）
- (int64_t)getBufferedPosition {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges]; // 获取加载时间范围
    if (loadedTimeRanges.count > 0) {
        CMTimeRange timeRange = [[loadedTimeRanges lastObject] CMTimeRangeValue]; // 获取最后时间范围
        Float64 startSeconds = CMTimeGetSeconds(timeRange.start); // 开始时间
        Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration); // 时长
        return (int64_t)((startSeconds + durationSeconds) * 1000); // 返回毫秒
    }
    return 0; // 无范围返回0
}

// 发送缓冲更新（带节流）
- (void)sendBufferingUpdate {
    if (_disposed || !_key || !_eventSink) return; // 无效状态返回
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970] * 1000; // 当前时间（毫秒）
    int64_t bufferedPosition = [self getBufferedPosition]; // 获取缓冲位置
    
    // 节流：如果距离上次更新时间小于阈值，并且位置没有显著变化，则跳过
    if ((currentTime - _lastBufferingUpdateTime) < BUFFERING_UPDATE_THROTTLE_MS &&
        bufferedPosition == _lastSendBufferedPosition) {
        return; // 跳过更新
    }
    
    // 复用缓冲范围数组，避免每次创建新数组
    [_bufferRangesCache removeAllObjects]; // 清空缓存
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges]; // 加载时间范围
    for (NSValue* rangeValue in loadedTimeRanges) {
        CMTimeRange range = [rangeValue CMTimeRangeValue]; // 获取时间范围
        int64_t start = [IAppPlayerTimeUtils FLTCMTimeToMillis:(range.start)]; // 开始时间
        int64_t end = start + [IAppPlayerTimeUtils FLTCMTimeToMillis:(range.duration)]; // 结束时间
        if (!CMTIME_IS_INVALID(_player.currentItem.forwardPlaybackEndTime)) {
            int64_t endTime = [IAppPlayerTimeUtils FLTCMTimeToMillis:(_player.currentItem.forwardPlaybackEndTime)]; // 结束时间
            if (end > endTime){
                end = endTime; // 修正结束时间
            }
        }
        [_bufferRangesCache addObject:@[ @(start), @(end) ]]; // 添加范围
    }
    
    // 发送事件
    _eventSink(@{@"event" : @"bufferingUpdate", @"values" : _bufferRangesCache, @"key" : _key}); // 发送缓冲更新
    
    // 更新记录
    _lastSendBufferedPosition = bufferedPosition; // 更新缓冲位置
    _lastBufferingUpdateTime = currentTime; // 更新时间
}

/// 监听播放器状态变化
- (void)observeValueForKeyPath:(NSString*)path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
    if ([path isEqualToString:@"rate"]) {
        if (@available(iOS 10.0, *)) {
            if (_pipController.pictureInPictureActive == true){
                if (_lastAvPlayerTimeControlStatus != [NSNull null] && _lastAvPlayerTimeControlStatus == _player.timeControlStatus){
                    return; // 状态不变返回
                }

                if (_player.timeControlStatus == AVPlayerTimeControlStatusPaused){
                    _lastAvPlayerTimeControlStatus = _player.timeControlStatus; // 更新状态
                    if (_eventSink != nil) {
                        _eventSink(@{@"event" : @"pause"}); // 发送暂停事件
                    }
                    return;
                }
                if (_player.timeControlStatus == AVPlayerTimeControlStatusPlaying){
                    _lastAvPlayerTimeControlStatus = _player.timeControlStatus; // 更新状态
                    if (_eventSink != nil) {
                        _eventSink(@{@"event" : @"play"}); // 发送播放事件
                    }
                }
            }
        }

        if (_player.rate == 0 &&
            CMTIME_COMPARE_INLINE(_player.currentItem.currentTime, >, kCMTimeZero) &&
            CMTIME_COMPARE_INLINE(_player.currentItem.currentTime, <, _player.currentItem.duration) &&
            _isPlaying) {
            [self handleStalled]; // 处理卡顿
        }
    }

    if (context == timeRangeContext) {
        // 使用节流的缓冲更新
        [self sendBufferingUpdate]; // 发送缓冲更新
    }
    else if (context == presentationSizeContext){
        [self onReadyToPlay]; // 准备播放
    }

    else if (context == statusContext) {
        AVPlayerItem* item = (AVPlayerItem*)object; // 获取播放项
        switch (item.status) {
            case AVPlayerItemStatusFailed:
                // 使用增强的错误处理
                [self handlePlayerError:item.error]; // 处理错误
                break;
            case AVPlayerItemStatusUnknown:
                break; // 未知状态
            case AVPlayerItemStatusReadyToPlay:
                [self onReadyToPlay]; // 准备播放
                break;
        }
    } else if (context == playbackLikelyToKeepUpContext) {
        if ([[_player currentItem] isPlaybackLikelyToKeepUp]) {
            [self updatePlayingState]; // 更新播放状态
            if (_eventSink != nil) {
                _eventSink(@{@"event" : @"bufferingEnd", @"key" : _key}); // 发送缓冲结束
            }
        }
    } else if (context == playbackBufferEmptyContext) {
        if (_eventSink != nil) {
            _eventSink(@{@"event" : @"bufferingStart", @"key" : _key}); // 发送缓冲开始
        }
    } else if (context == playbackBufferFullContext) {
        if (_eventSink != nil) {
            _eventSink(@{@"event" : @"bufferingEnd", @"key" : _key}); // 发送缓冲结束
        }
    }
}

/// 更新播放状态
- (void)updatePlayingState {
    if (!_isInitialized || !_key) {
        return; // 无效状态
    }
    if (!self._observersAdded){
        [self addObservers:[_player currentItem]]; // 添加观察者
    }

    if (_isPlaying) {
        if (@available(iOS 10.0, *)) {
            [_player playImmediatelyAtRate:1.0]; // 立即播放
            _player.rate = _playerRate; // 设置速率
        } else {
            [_player play]; // 播放
            _player.rate = _playerRate; // 设置速率
        }
    } else {
        [_player pause]; // 暂停
    }
}

/// 处理播放器准备完成
- (void)onReadyToPlay {
    if (_eventSink && !_isInitialized && _key) {
        if (!_player.currentItem) {
            return; // 空播放项
        }
        if (_player.status != AVPlayerStatusReadyToPlay) {
            return; // 非就绪状态
        }

        CGSize size = [_player currentItem].presentationSize; // 获取视频尺寸
        CGFloat width = size.width; // 宽度
        CGFloat height = size.height; // 高度

        AVAsset *asset = _player.currentItem.asset; // 获取资源
        bool onlyAudio = [[asset tracksWithMediaType:AVMediaTypeVideo] count] == 0; // 仅音频

        if (!onlyAudio && height == CGSizeZero.height && width == CGSizeZero.width) {
            return; // 无效尺寸
        }
        const BOOL isLive = CMTIME_IS_INDEFINITE([_player currentItem].duration); // 是否直播
        if (isLive == false && [self duration] == 0) {
            return; // 非直播无效时长
        }

        AVPlayerItemTrack *track = [_player currentItem].tracks.firstObject; // 获取轨道
        CGSize naturalSize = track.assetTrack.naturalSize; // 自然尺寸
        CGAffineTransform prefTrans = track.assetTrack.preferredTransform; // 变换
        CGSize realSize = CGSizeApplyAffineTransform(naturalSize, prefTrans); // 实际尺寸

        int64_t duration = [IAppPlayerTimeUtils FLTCMTimeToMillis:(_player.currentItem.asset.duration)]; // 时长
        if (_overriddenDuration > 0 && duration > _overriddenDuration){
            _player.currentItem.forwardPlaybackEndTime = CMTimeMake(_overriddenDuration/1000, 1); // 设置结束时间
        }

        _isInitialized = true; // 标记初始化
        
        // 成功初始化后重置重试计数
        if (_retryCount > 0) {
            _retryCount = 0; // 重置重试
        }
        
        [self updatePlayingState]; // 更新状态
        _eventSink(@{
            @"event" : @"initialized",
            @"duration" : @([self duration]),
            @"width" : @(fabs(realSize.width) ? : width),
            @"height" : @(fabs(realSize.height) ? : height),
            @"key" : _key
        }); // 发送初始化事件
    }
}

/// 播放视频
- (void)play {
    _stalledCount = 0; // 重置卡顿计数
    _isStalledCheckStarted = false; // 重置卡顿检查
    _isPlaying = true; // 标记播放
    [self updatePlayingState]; // 更新状态
}

/// 暂停视频
- (void)pause {
    _isPlaying = false; // 标记暂停
    [self updatePlayingState]; // 更新状态
}

/// 获取当前播放位置（毫秒）
- (int64_t)position {
    return [IAppPlayerTimeUtils FLTCMTimeToMillis:([_player currentTime])]; // 返回当前时间
}

/// 获取绝对播放位置（毫秒）
- (int64_t)absolutePosition {
    return [IAppPlayerTimeUtils FLTNSTimeIntervalToMillis:([[_player currentItem] currentDate] timeIntervalSince1970])]; // 返回绝对时间
}

/// 获取视频总时长（毫秒）
- (int64_t)duration {
    CMTime time;
    if (@available(iOS 13, *)) {
        time = [[_player currentItem] duration]; // iOS 13 获取时长
    } else {
        time = [[[_player currentItem] asset] duration]; // 旧版获取
    }
    if (!CMTIME_IS_INVALID(_player.currentItem.forwardPlaybackEndTime)) {
        time = [[_player currentItem] forwardPlaybackEndTime]; // 更新结束时间
    }

    return [IAppPlayerTimeUtils FLTCMTimeToMillis:(time)]; // 返回毫秒
}

/// 定位到指定时间（毫秒）
- (void)seekTo:(int)location {
    bool wasPlaying = _isPlaying; // 记录状态
    if (wasPlaying){
        [_player pause]; // 暂停
    }

    [_player seekToTime:CMTimeMake(location, 1000)
        toleranceBefore:kCMTimeZero
         toleranceAfter:kCMTimeZero
      completionHandler:^(BOOL finished){
        if (wasPlaying){
            _player.rate = _playerRate; // 恢复播放
        }
    }]; // 定位
}

/// 设置循环播放状态
- (void)setIsLooping:(bool)isLooping {
    _isLooping = isLooping; // 设置循环状态
}

/// 设置音量
- (void)setVolume:(double)volume {
    _player.volume = (float)((volume < 0.0) ? 0.0 : ((volume > 1.0) ? 1.0 : volume)); // 设置音量
}

/// 设置播放速度
- (void)setSpeed:(double)speed result:(FlutterResult)result {
    if (speed == 1.0 || speed == 0.0) {
        _playerRate = 1; // 默认速率
        result(nil);
    } else if (speed < 0 || speed > 2.0) {
        result([FlutterError errorWithCode:@"unsupported_speed"
                                   message:@"播放速度必须在 0.0 到 2.0 之间"
                                   details:nil]); // 速度不支持
    } else if ((speed > 1.0 && _player.currentItem.canPlayFastForward) ||
               (speed < 1.0 && _player.currentItem.canPlaySlowForward)) {
        _playerRate = speed; // 设置速率
        result(nil);
    } else {
        if (speed > 1.0) {
            result([FlutterError errorWithCode:@"unsupported_fast_forward"
                                       message:@"此视频不支持快进"
                                       details:nil]); // 不支持快进
        } else {
            result([FlutterError errorWithCode:@"unsupported_slow_forward"
                                       message:@"此视频不支持慢放"
                                       details:nil]); // 不支持慢放
        }
    }

    if (_isPlaying){
        _player.rate = _playerRate; // 更新播放速率
    }
}

/// 设置视频轨道参数
- (void)setTrackParameters:(int)width :(int)height :(int)bitrate {
    _player.currentItem.preferredPeakBitRate = bitrate; // 设置字节率
    if (@available(iOS 11.0, *)) {
        if (width == 0 && height == 0){
            _player.currentItem.preferredMaximumResolution = CGSizeZero; // 无限制分辨率
        } else {
            _player.currentItem.preferredMaximumResolution = CGSizeMake(width, height); // 设置分辨率
        }
    }
}

/// 设置画中画状态
- (void)setPictureInPicture:(BOOL)pictureInPicture {
    self._pictureInPicture = pictureInPicture; // 设置画中画状态
    if (@available(iOS 9.0, *)) {
        if (_pipController && self._pictureInPicture && ![_pipController isPictureInPictureActive]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_pipController startPictureInPicture]; // 启动画中画
            });
        } else if (_pipController && !self._pictureInPicture && [_pipController isPictureInPictureActive]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_pipController stopPictureInPicture]; // 停止画中画
            });
        }
    }
}

#if TARGET_OS_IOS
/// 设置画中画停止后的界面恢复回调
- (void)setRestoreUserInterfaceForPIPStopCompletionHandler:(BOOL)restore {
    if (_restoreUserInterfaceForPIPStopCompletionHandler != NULL) {
        _restoreUserInterfaceForPIPStopCompletionHandler(restore); // 执行回调
        _restoreUserInterfaceForPIPStopCompletionHandler = NULL; // 清空回调
    }
}

/// 初始化画中画控制器
- (void)setupPipController {
    if (@available(iOS 9.0, *)) {
        [[AVAudioSession sharedInstance] setActive:YES error:nil]; // 激活音频会话
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents]; // 接收远程控制
        
        // 创建或获取播放器层
        if (!self._playerLayer) {
            self._playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player]; // 创建播放器层
        }
        
        if (!_pipController && self._playerLayer && [AVPictureInPictureController isPictureInPictureSupported]) {
            _pipController = [[AVPictureInPictureController alloc] initWithPlayerLayer:self._playerLayer]; // 初始化控制器
            _pipController.delegate = self; // 设置代理
        }
    }
}

/// 启用画中画模式
- (void)enablePictureInPicture {
    [self disablePictureInPicture]; // 禁用现有画中画
    
    if (_player) {
        // 创建播放器层
        if (!self._playerLayer) {
            self._playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player]; // 创建播放器层
        }
        
        if (@available(iOS 9.0, *)) {
            _pipController = NULL; // 清空控制器
        }
        
        [self setupPipController]; // 初始化控制器
        
        // 延迟启动画中画，确保控制器初始化完成
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self setPictureInPicture:true]; // 启用画中画
        });
    }
}

/// 禁用画中画模式
- (void)disablePictureInPicture {
    [self setPictureInPicture:false]; // 设置非画中画状态
    if (@available(iOS 9.0, *)) {
        if (_pipController) {
            _pipController = nil; // 清空控制器
        }
    }
    if (_playerLayer) {
        _playerLayer = nil; // 清空层
        if (_eventSink != nil) {
            _eventSink(@{@"event" : @"pipStop"}); // 发送停止事件
        }
    }
}

/// 画中画停止回调
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController API_AVAILABLE(ios(9.0)){
    [self disablePictureInPicture]; // 禁用画中画
}

/// 画中画启动回调
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController API_AVAILABLE(ios(9.0)){
    if (_eventSink != nil) {
        _eventSink(@{@"event" : @"pipStart"}); // 发送启动事件
    }
}

/// 画中画即将停止回调
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController API_AVAILABLE(ios(9.0)){
}

/// 画中画即将启动回调
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
}

/// 画中画启动失败回调
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
}

/// 恢复画中画用户界面
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    [self setRestoreUserInterfaceForPIPStopCompletionHandler:true]; // 设置恢复回调
}

/// 设置音频轨道
- (void)setAudioTrack:(NSString*)name index:(int)index {
    AVMediaSelectionGroup *audioSelectionGroup = [[[_player currentItem] asset] mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicAudible]; // 获取音频组
    NSArray* options = audioSelectionGroup.options; // 获取选项

    for (int audioTrackIndex = 0; audioTrackIndex < [options count]; audioTrackIndex++) {
        AVMediaSelectionOption* option = [options objectAtIndex:audioTrackIndex]; // 获取选项
        NSArray *metaDatas = [AVMetadataItem metadataItemsFromArray:option.commonMetadata withKey:@"title" keySpace:@"comn"]; // 获取元数据
        if (metaDatas.count > 0) {
            NSString *title = ((AVMetadataItem*)[metaDatas objectAtIndex:0]).stringValue; // 获取标题
            if ([name compare:title] == NSOrderedSame && audioTrackIndex == index ){
                [[_player currentItem] selectMediaOption:option inMediaSelectionGroup: audioSelectionGroup]; // 选择音频
            }
        }
    }
}

/// 设置音频混音模式
- (void)setMixWithOthers:(bool)mixWithOthers {
    if (mixWithOthers) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                     withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                           error:nil]; // 设置混播
    } else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil]; // 设置独占
    }
}
#endif

/// 取消事件监听
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil; // 清空事件接收器
    return nil;
}

/// 开始事件监听
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events; // 设置事件接收器
    [self onReadyToPlay]; // 队列播放
    return nil;
}

/// 释放资源（不含事件通道）
- (void)disposeSansEventChannel {
    @try{
        [self clear]; // 清除状态
    }
    @catch(NSException *exception) {
        NSLog(@"释放资源失败: %@", exception.debugDescription); // 记录错误
    }
}

/// 释放所有资源
- (void)dispose {
    _disposed = true; // 先标记已释放，防止并发问题
    [self pause]; // 暂停
    [self disposeSansEventChannel]; // 释放资源
    [_eventChannel setStreamHandler:nil]; // 删除事件通道
    [self disablePictureInPicture]; // 禁用画中画
    [self setPictureInPicture:false]; // 清除画中画状态
}

@end
