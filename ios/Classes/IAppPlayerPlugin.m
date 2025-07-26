#import "IAppPlayerPlugin.h"
#import <iapp_player/iapp_player-Swift.h>

#if !__has_feature(objc_arc)
#error Code Requires ARC.
#endif

@implementation IAppPlayerPlugin
NSMutableDictionary* _dataSourceDict; // 数据源字典，存储播放器数据源配置
NSMutableDictionary* _timeObserverIdDict; // 时间观察者ID字典，管理播放进度监听
NSMutableDictionary* _artworkImageDict; // 封面图像字典，缓存通知封面
NSMutableDictionary* _playerToTextureIdMap; // 播放器到纹理ID映射
CacheManager* _cacheManager; // 缓存管理器，处理视频缓存
int texturesCount = -1; // 纹理计数器，生成唯一纹理ID
IAppPlayer* _notificationPlayer; // 通知播放器，管理远程控制通知
bool _remoteCommandsInitialized = false; // 远程命令初始化标志

#pragma mark - FlutterPlugin protocol
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    // 注册Flutter方法通道和视图工厂
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"iapp_player_channel" binaryMessenger:[registrar messenger]];
    IAppPlayerPlugin* instance = [[IAppPlayerPlugin alloc] initWithRegistrar:registrar];
    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar registerViewFactory:instance withId:@"com.jhomlala/iapp_player"];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    // 初始化插件，配置消息通道和核心数据结构
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _messenger = [registrar messenger];
    _registrar = registrar;
    _players = [NSMutableDictionary dictionaryWithCapacity:1];
    _playerToTextureIdMap = [NSMutableDictionary dictionaryWithCapacity:1];
    _timeObserverIdDict = [NSMutableDictionary dictionary];
    _artworkImageDict = [NSMutableDictionary dictionary];
    _dataSourceDict = [NSMutableDictionary dictionary];
    _cacheManager = [[CacheManager alloc] init];
    [_cacheManager setup];
    return self;
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    // 清理所有播放器资源，移除纹理映射
    [_playerToTextureIdMap removeAllObjects];
    
    // 然后清理播放器
    for (NSNumber* textureId in _players.allKeys) {
        IAppPlayer* player = _players[textureId];
        [player disposeSansEventChannel];
    }
    [_players removeAllObjects];
}

#pragma mark - FlutterPlatformViewFactory protocol
- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
    // 创建播放器视图，根据纹理ID获取播放器
    NSNumber* textureId = [args objectForKey:@"textureId"];
    IAppPlayerView* player = [_players objectForKey:@(textureId.intValue)];
    return player;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    // 返回标准消息编解码器
    return [FlutterStandardMessageCodec sharedInstance];
}

#pragma mark - IAppPlayerPlugin class
- (int)newTextureId {
    // 生成新的唯一纹理ID
    texturesCount += 1;
    return texturesCount;
}

- (void)onPlayerSetup:(IAppPlayer*)player result:(FlutterResult)result {
    // 配置播放器，注册事件通道并记录纹理映射
    int64_t textureId = [self newTextureId];
    FlutterEventChannel* eventChannel = [FlutterEventChannel eventChannelWithName:[NSString stringWithFormat:@"iapp_player_channel/videoEvents%lld", textureId] binaryMessenger:_messenger];
    [player setMixWithOthers:false];
    [eventChannel setStreamHandler:player];
    player.eventChannel = eventChannel;
    _players[@(textureId)] = player;
    // 使用强引用避免野指针问题
    NSString* playerAddress = [NSString stringWithFormat:@"%p", player];
    _playerToTextureIdMap[playerAddress] = @(textureId);
    result(@{@"textureId" : @(textureId)});
}

- (void)setupRemoteNotification:(IAppPlayer*)player {
    // 配置远程通知，设置播放器为通知对象
    _notificationPlayer = player;
    [self stopOtherUpdateListener:player];
    
    // 缓存textureId，避免重复查找
    NSString* textureIdString = [self getTextureId:player];
    NSDictionary* dataSource = [_dataSourceDict objectForKey:textureIdString];
    
    // 检查是否显示通知，优化null检查
    BOOL showNotification = false;
    id showNotificationObject = dataSource[@"showNotification"];
    if (showNotificationObject && showNotificationObject != [NSNull null]) {
        showNotification = [showNotificationObject boolValue];
    }
    
    if (showNotification) {
        NSString* title = dataSource[@"title"];
        NSString* author = dataSource[@"author"];
        NSString* imageUrl = dataSource[@"imageUrl"];
        
        [self setRemoteCommandsNotificationActive];
        [self setupRemoteCommands:player];
        [self setupRemoteCommandNotification:player, title, author, imageUrl];
        [self setupUpdateListener:player, title, author, imageUrl];
    }
}

- (void)setRemoteCommandsNotificationActive {
    // 激活远程控制通知和音频会话
    [[AVAudioSession sharedInstance] setActive:true error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)setRemoteCommandsNotificationNotActive {
    // 停用远程控制通知和音频会话
    if ([_players count] == 0) {
        [[AVAudioSession sharedInstance] setActive:false error:nil];
    }
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)setupRemoteCommands:(IAppPlayer*)player {
    // 配置远程控制命令，绑定播放控制事件
    if (_remoteCommandsInitialized) {
        return;
    }
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.togglePlayPauseCommand setEnabled:YES];
    [commandCenter.playCommand setEnabled:YES];
    [commandCenter.pauseCommand setEnabled:YES];
    [commandCenter.nextTrackCommand setEnabled:NO];
    [commandCenter.previousTrackCommand setEnabled:NO];
    if (@available(iOS 9.1, *)) {
        [commandCenter.changePlaybackPositionCommand setEnabled:YES];
    }
    [commandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (_notificationPlayer != [NSNull null]) {
            _notificationPlayer.eventSink(@{@"event" : _notificationPlayer.isPlaying ? @"play" : @"pause"});
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (_notificationPlayer != [NSNull null]) {
            _notificationPlayer.eventSink(@{@"event" : @"play"});
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (_notificationPlayer != [NSNull null]) {
            _notificationPlayer.eventSink(@{@"event" : @"pause"});
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    if (@available(iOS 9.1, *)) {
        [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            if (_notificationPlayer != [NSNull null]) {
                MPChangePlaybackPositionCommandEvent *playbackEvent = (MPChangePlaybackRateCommandEvent *)event;
                CMTime time = CMTimeMake(playbackEvent.positionTime, 1);
                int64_t millis = [IAppPlayerTimeUtils FLTCMTimeToMillis:(time)];
                [_notificationPlayer seekTo:millis];
                _notificationPlayer.eventSink(@{@"event" : @"seek", @"position": @(millis)});
            }
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
    _remoteCommandsInitialized = true;
}

- (void)setupRemoteCommandNotification:(IAppPlayer*)player, NSString* title, NSString* author, NSString* imageUrl {
    // 配置远程通知信息，包含标题、作者和封面
    float positionInSeconds = player.position / 1000;
    float durationInSeconds = player.duration / 1000;
    NSMutableDictionary *nowPlayingInfoDict = [@{MPMediaItemPropertyArtist: author,
                                                 MPMediaItemPropertyTitle: title,
                                                 MPNowPlayingInfoPropertyElapsedPlaybackTime: @(positionInSeconds),
                                                 MPMediaItemPropertyPlaybackDuration: @(durationInSeconds),
                                                 MPNowPlayingInfoPropertyPlaybackRate: @1} mutableCopy];
    if (imageUrl != [NSNull null]) {
        NSString* key = [self getTextureId:player];
        MPMediaItemArtwork* artworkImage = [_artworkImageDict objectForKey:key];
        if (key != [NSNull null]) {
            if (artworkImage) {
                [nowPlayingInfoDict setObject:artworkImage forKey:MPMediaItemPropertyArtwork];
                [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfoDict;
            } else {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                __weak typeof(self) weakSelf = self;
                dispatch_async(queue, ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (!strongSelf) return;
                    @try {
                        UIImage *tempArtworkImage = nil;
                        if ([imageUrl rangeOfString:@"http"].location == NSNotFound) {
                            tempArtworkImage = [UIImage imageWithContentsOfFile:imageUrl];
                        } else {
                            NSURL *nsImageUrl = [NSURL URLWithString:imageUrl];
                            tempArtworkImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:nsImageUrl]];
                        }
                        if (tempArtworkImage) {
                            MPMediaItemArtwork* artworkImage = [[MPMediaItemArtwork alloc] initWithImage:tempArtworkImage];
                            [strongSelf->_artworkImageDict setObject:artworkImage forKey:key];
                            [nowPlayingInfoDict setObject:artworkImage forKey:MPMediaItemPropertyArtwork];
                        }
                        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfoDict;
                    } @catch (NSException *exception) {}
                });
            }
        }
    } else {
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfoDict;
    }
}

- (NSString*)getTextureId:(IAppPlayer*)player {
    // 通过反向映射快速获取播放器的纹理ID
    NSString* playerAddress = [NSString stringWithFormat:@"%p", player];
    NSNumber* textureId = _playerToTextureIdMap[playerAddress];
    return textureId ? [textureId stringValue] : nil;
}

- (void)setupUpdateListener:(IAppPlayer*)player, NSString* title, NSString* author, NSString* imageUrl {
    // 设置播放进度监听，定期更新通知信息
    id _timeObserverId = [player.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        [self setupRemoteCommandNotification:player, title, author, imageUrl];
    }];
    NSString* key = [self getTextureId:player];
    [_timeObserverIdDict setObject:_timeObserverId forKey:key];
}

- (void)disposeNotificationData:(IAppPlayer*)player {
    // 清理播放器通知数据，移除时间观察者和封面缓存
    if (player == _notificationPlayer) {
        _notificationPlayer = NULL;
        _remoteCommandsInitialized = false;
    }
    NSString* key = [self getTextureId:player];
    id _timeObserverId = _timeObserverIdDict[key];
    [_timeObserverIdDict removeObjectForKey:key];
    [_artworkImageDict removeObjectForKey:key];
    if (_timeObserverId) {
        [player.player removeTimeObserver:_timeObserverId];
        _timeObserverId = nil;
    }
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{};
}

- (void)stopOtherUpdateListener:(IAppPlayer*)player {
    // 停止其他播放器的时间观察者，确保单一通知更新
    NSString* currentPlayerTextureId = [self getTextureId:player];
    NSArray* keysToRemove = [_timeObserverIdDict allKeys];
    for (NSString* textureId in keysToRemove) {
        if ([currentPlayerTextureId isEqualToString:textureId]) {
            continue;
        }
        id timeObserverId = [_timeObserverIdDict objectForKey:textureId];
        IAppPlayer* playerToRemoveListener = [_players objectForKey:textureId];
        if (playerToRemoveListener && timeObserverId) {
            [playerToRemoveListener.player removeTimeObserver:timeObserverId];
        }
    }
    [_timeObserverIdDict removeAllObjects];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // 处理Flutter方法调用，分发到对应功能
    if ([@"init" isEqualToString:call.method]) {
        [_playerToTextureIdMap removeAllObjects];
        for (NSNumber* textureId in _players) {
            [_players[textureId] dispose];
        }
        [_players removeAllObjects];
        result(nil);
    } else if ([@"create" isEqualToString:call.method]) {
        IAppPlayer* player = [[IAppPlayer alloc] initWithFrame:CGRectZero];
        
        // 从参数中获取缓冲配置
        NSDictionary* args = call.arguments;
        if (args) {
            NSNumber* minBufferMs = args[@"minBufferMs"];
            NSNumber* maxBufferMs = args[@"maxBufferMs"];
            NSNumber* bufferForPlaybackMs = args[@"bufferForPlaybackMs"];
            NSNumber* bufferForPlaybackAfterRebufferMs = args[@"bufferForPlaybackAfterRebufferMs"];
            
            // 设置缓冲参数到播放器
            [player configureBufferParameters:minBufferMs
                                   maxBufferMs:maxBufferMs
                           bufferForPlaybackMs:bufferForPlaybackMs
              bufferForPlaybackAfterRebufferMs:bufferForPlaybackAfterRebufferMs];
        }
        
        [self onPlayerSetup:player result:result];
    } else {
        NSDictionary* argsMap = call.arguments;
        int64_t textureId = ((NSNumber*)argsMap[@"textureId"]).unsignedIntegerValue;
        IAppPlayer* player = _players[@(textureId)];
        if ([@"setDataSource" isEqualToString:call.method]) {
            // 配置播放器数据源，支持资产或URL
            [player clear];
            NSDictionary* dataSource = argsMap[@"dataSource"];
            [_dataSourceDict setObject:dataSource forKey:[self getTextureId:player]];
            NSString* assetArg = dataSource[@"asset"];
            NSString* uriArg = dataSource[@"uri"];
            NSString* key = dataSource[@"key"];
            NSString* certificateUrl = dataSource[@"certificateUrl"];
            NSString* licenseUrl = dataSource[@"licenseUrl"];
            NSDictionary* headers = dataSource[@"headers"];
            NSString* cacheKey = dataSource[@"cacheKey"];
            NSNumber* maxCacheSize = dataSource[@"maxCacheSize"];
            NSString* videoExtension = dataSource[@"videoExtension"];
            int overriddenDuration = 0;
            
            // null检查
            id overriddenDurationObj = dataSource[@"overriddenDuration"];
            if (overriddenDurationObj && overriddenDurationObj != [NSNull null]) {
                overriddenDuration = [overriddenDurationObj intValue];
            }
            
            // 解码器类型参数
            int preferredDecoderType = 1; // 默认硬解优先
            id decoderTypeObj = dataSource[@"preferredDecoderType"];
            if (decoderTypeObj && decoderTypeObj != [NSNull null]) {
                int decoderType = [decoderTypeObj intValue];
                if (decoderType >= 0 && decoderType <= 2) {
                    preferredDecoderType = decoderType;
                }
            }
            
            BOOL useCache = false;
            id useCacheObject = dataSource[@"useCache"];
            if (useCacheObject && useCacheObject != [NSNull null]) {
                useCache = [useCacheObject boolValue];
                if (useCache) {
                    [_cacheManager setMaxCacheSize:maxCacheSize];
                }
            }
            if (headers == [NSNull null] || headers == NULL) {
                headers = @{};
            }
            if (assetArg) {
                NSString* assetPath;
                NSString* package = dataSource[@"package"];
                if (![package isEqual:[NSNull null]]) {
                    assetPath = [_registrar lookupKeyForAsset:assetArg fromPackage:package];
                } else {
                    assetPath = [_registrar lookupKeyForAsset:assetArg];
                }
                [player setDataSourceAsset:assetPath withKey:key withCertificateUrl:certificateUrl withLicenseUrl:licenseUrl cacheKey:cacheKey cacheManager:_cacheManager overriddenDuration:overriddenDuration preferredDecoderType:preferredDecoderType];
            } else if (uriArg) {
                [player setDataSourceURL:[NSURL URLWithString:uriArg] withKey:key withCertificateUrl:certificateUrl withLicenseUrl:licenseUrl withHeaders:headers withCache:useCache cacheKey:cacheKey cacheManager:_cacheManager overriddenDuration:overriddenDuration videoExtension:videoExtension preferredDecoderType:preferredDecoderType];
            } else {
                result(FlutterMethodNotImplemented);
            }
            result(nil);
        } else if ([@"dispose" isEqualToString:call.method]) {
            // 清理播放器资源，移除通知和纹理映射
            [player clear];
            [self disposeNotificationData:player];
            [self setRemoteCommandsNotificationNotActive];
            
            // 移除映射关系
            NSString* playerAddress = [NSString stringWithFormat:@"%p", player];
            [_playerToTextureIdMap removeObjectForKey:playerAddress];
            [_players removeObjectForKey:@(textureId)];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!player.disposed) {
                    [player dispose];
                }
            });
            if ([_players count] == 0) {
                [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
            }
            result(nil);
        } else if ([@"setLooping" isEqualToString:call.method]) {
            // 设置播放循环模式
            [player setIsLooping:[argsMap[@"looping"] boolValue]];
            result(nil);
        } else if ([@"setVolume" isEqualToString:call.method]) {
            // 设置播放音量
            [player setVolume:[argsMap[@"volume"] doubleValue]];
            result(nil);
        } else if ([@"play" isEqualToString:call.method]) {
            // 开始播放并配置通知
            [self setupRemoteNotification:player];
            [player play];
            result(nil);
        } else if ([@"position" isEqualToString:call.method]) {
            // 获取当前播放位置
            result(@([player position]));
        } else if ([@"absolutePosition" isEqualToString:call.method]) {
            // 获取绝对播放位置
            result(@([player absolutePosition]));
        } else if ([@"seekTo" isEqualToString:call.method]) {
            // 跳转到指定播放位置
            [player seekTo:[argsMap[@"location"] intValue]];
            result(nil);
        } else if ([@"pause" isEqualToString:call.method]) {
            // 暂停播放
            [player pause];
            result(nil);
        } else if ([@"setSpeed" isEqualToString:call.method]) {
            // 设置播放速度
            [player setSpeed:[[argsMap objectForKey:@"speed"] doubleValue] result:result];
        } else if ([@"setTrackParameters" isEqualToString:call.method]) {
            // 设置视频轨道参数
            int width = [argsMap[@"width"] intValue];
            int height = [argsMap[@"height"] intValue];
            int bitrate = [argsMap[@"bitrate"] intValue];
            [player setTrackParameters:width :height :bitrate];
            result(nil);
        } else if ([@"enablePictureInPicture" isEqualToString:call.method]) {
            // 启用画中画模式
            [player enablePictureInPicture];
            result(nil);
        } else if ([@"isPictureInPictureSupported" isEqualToString:call.method]) {
            // 检查画中画支持状态
            if (@available(iOS 9.0, *)) {
                if ([AVPictureInPictureController isPictureInPictureSupported]) {
                    result([NSNumber numberWithBool:true]);
                    return;
                }
            }
            result([NSNumber numberWithBool:false]);
        } else if ([@"disablePictureInPicture" isEqualToString:call.method]) {
            // 禁用画中画模式
            [player disablePictureInPicture];
            [player setPictureInPicture:false];
        } else if ([@"setAudioTrack" isEqualToString:call.method]) {
            // 设置音频轨道
            NSString* name = argsMap[@"name"];
            int index = [argsMap[@"index"] intValue];
            [player setAudioTrack:name index:index];
        } else if ([@"setMixWithOthers" isEqualToString:call.method]) {
            // 设置与其他音频混音
            [player setMixWithOthers:[argsMap[@"mixWithOthers"] boolValue]];
        } else if ([@"preCache" isEqualToString:call.method]) {
            // 预缓存视频数据
            NSDictionary* dataSource = argsMap[@"dataSource"];
            NSString* urlArg = dataSource[@"uri"];
            NSString* cacheKey = dataSource[@"cacheKey"];
            NSDictionary* headers = dataSource[@"headers"];
            NSNumber* maxCacheSize = dataSource[@"maxCacheSize"];
            NSString* videoExtension = dataSource[@"videoExtension"];
            if (headers == [NSNull null]) {
                headers = @{};
            }
            if (videoExtension == [NSNull null]) {
                videoExtension = nil;
            }
            if (urlArg != [NSNull null]) {
                NSURL* url = [NSURL URLWithString:urlArg];
                if ([_cacheManager isPreCacheSupportedWithUrl:url videoExtension:videoExtension]) {
                    [_cacheManager setMaxCacheSize:maxCacheSize];
                    [_cacheManager preCacheURL:url cacheKey:cacheKey videoExtension:videoExtension withHeaders:headers completionHandler:^(BOOL success) {}];
                } else {
                    NSLog(@"Pre cache is not supported for given data source.");
                }
            }
            result(nil);
        } else if ([@"clearCache" isEqualToString:call.method]) {
            // 清除缓存
            [_cacheManager clearCache];
            result(nil);
        } else if ([@"stopPreCache" isEqualToString:call.method]) {
            // 停止预缓存
            NSString* urlArg = argsMap[@"url"];
            NSString* cacheKey = argsMap[@"cacheKey"];
            NSString* videoExtension = argsMap[@"videoExtension"];
            if (urlArg != [NSNull null]) {
                NSURL* url = [NSURL URLWithString:urlArg];
                if ([_cacheManager isPreCacheSupportedWithUrl:url videoExtension:videoExtension]) {
                    [_cacheManager stopPreCache:url cacheKey:cacheKey completionHandler:^(BOOL success) {}];
                } else {
                    NSLog(@"Stop pre cache is not supported for given data source.");
                }
            }
            result(nil);
        } else {
            result(FlutterMethodNotImplemented);
        }
    }
}
@end
