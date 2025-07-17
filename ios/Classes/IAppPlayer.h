#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#import "IAppPlayerTimeUtils.h"
#import "IAppPlayerView.h"
#import "IAppPlayerEzDrmAssetsLoaderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class CacheManager;

/// 视频播放器插件，管理视频播放、画中画和事件通道
@interface IAppPlayer : NSObject <FlutterPlatformView, FlutterStreamHandler, AVPictureInPictureControllerDelegate>
/// 视频播放器实例
@property(readonly, nonatomic) AVPlayer* player; // 核心播放器实例
/// DRM 资源加载委托
@property(readonly, nonatomic) IAppPlayerEzDrmAssetsLoaderDelegate* loaderDelegate; // DRM 资源加载代理
/// Flutter 事件通道
@property(nonatomic) FlutterEventChannel* eventChannel; // Flutter 事件通信通道
/// 事件接收器
@property(nonatomic) FlutterEventSink eventSink; // 事件回调函数
/// 视频变换矩阵
@property(nonatomic) CGAffineTransform preferredTransform; // 视频旋转变换
/// 是否已释放资源
@property(nonatomic, readonly) bool disposed; // 资源释放状态
/// 是否正在播放
@property(nonatomic, readonly) bool isPlaying; // 当前播放状态
/// 是否循环播放
@property(nonatomic) bool isLooping; // 循环播放配置
/// 是否初始化完成
@property(nonatomic, readonly) bool isInitialized; // 初始化完成状态
/// 视频资源标识
@property(nonatomic, readonly) NSString* key; // 视频资源唯一标识
/// 失败重试次数
@property(nonatomic, readonly) int failedCount; // 播放失败重试计数
/// 视频播放层
@property(nonatomic) AVPlayerLayer* _playerLayer; // 播放器显示层
/// 是否启用画中画
@property(nonatomic) bool _pictureInPicture; // 画中画模式状态
/// 是否添加了观察者
@property(nonatomic) bool _observersAdded; // KVO 观察者添加状态
/// 卡顿次数
@property(nonatomic) int stalledCount; // 播放卡顿计数
/// 是否开始卡顿检查
@property(nonatomic) bool isStalledCheckStarted; // 卡顿检查状态
/// 播放速率
@property(nonatomic) float playerRate; // 当前播放速度
/// 覆盖的视频时长
@property(nonatomic) int overriddenDuration; // 自定义视频时长（毫秒）
/// 上次播放器时间控制状态
@property(nonatomic) AVPlayerTimeControlStatus lastAvPlayerTimeControlStatus; // 播放器时间控制状态

/// 网络错误重试次数
@property(nonatomic) int retryCount; // 网络错误重试计数
/// 错误前是否在播放
@property(nonatomic) BOOL wasPlayingBeforeError; // 错误发生前播放状态
/// 当前媒体URL
@property(nonatomic, strong) NSURL* currentMediaURL; // 当前视频URL
/// 当前请求头
@property(nonatomic, strong) NSDictionary* currentHeaders; // 当前请求头信息
/// 当前缓存配置
@property(nonatomic) BOOL currentUseCache; // 是否启用缓存
@property(nonatomic, strong) NSString* currentCacheKey; // 缓存键
@property(nonatomic, strong) NSString* currentVideoExtension; // 视频文件扩展名
@property(nonatomic, strong) CacheManager* currentCacheManager; // 缓存管理器实例

/// 上次发送缓冲位置
@property(nonatomic) int64_t lastSendBufferedPosition; // 上次发送的缓冲位置（毫秒）
/// 上次缓冲更新时间
@property(nonatomic) NSTimeInterval lastBufferingUpdateTime; // 上次缓冲更新时间（毫秒）

/// 解码器优先级类型
@property(nonatomic) int preferredDecoderType; // 0:AUTO, 1:HARDWARE_FIRST, 2:SOFTWARE_FIRST

/// 初始化播放器视图
- (instancetype)initWithFrame:(CGRect)frame; // 初始化播放器视图
/// 设置是否与其他音频混音
- (void)setMixWithOthers:(bool)mixWithOthers; // 配置音频混播模式
/// 播放视频
- (void)play; // 开始播放视频
/// 暂停视频
- (void)pause; // 暂停视频播放
/// 设置循环播放状态
- (void)setIsLooping:(bool)isLooping; // 配置循环播放
/// 更新播放状态
- (void)updatePlayingState; // 更新播放器状态
/// 获取视频总时长（毫秒）
- (int64_t)duration; // 返回视频总时长
/// 获取当前播放位置（毫秒）
- (int64_t)position; // 返回当前播放位置
/// 定位到指定时间（毫秒）
- (void)seekTo:(int)location; // 跳转到指定时间
/// 设置本地资源数据源
- (void)setDataSourceAsset:(NSString*)asset withKey:(NSString*)key withCertificateUrl:(NSString*)certificateUrl withLicenseUrl:(NSString*)licenseUrl cacheKey:(NSString*)cacheKey cacheManager:(CacheManager*)cacheManager overriddenDuration:(int)overriddenDuration preferredDecoderType:(int)decoderType; // 设置本地视频资源
/// 设置网络资源数据源
- (void)setDataSourceURL:(NSURL*)url withKey:(NSString*)key withCertificateUrl:(NSString*)certificateUrl withLicenseUrl:(NSString*)licenseUrl withHeaders:(NSDictionary*)headers withCache:(BOOL)useCache cacheKey:(NSString*)cacheKey cacheManager:(CacheManager*)cacheManager overriddenDuration:(int)overriddenDuration videoExtension:(NSString*)videoExtension preferredDecoderType:(int)decoderType; // 设置网络视频资源
/// 设置音量
- (void)setVolume:(double)volume; // 设置播放音量
/// 设置播放速度
- (void)setSpeed:(double)speed result:(FlutterResult)result; // 设置播放速度
/// 设置音频轨道
- (void)setAudioTrack:(NSString*)name index:(int)index; // 选择音频轨道
/// 设置视频轨道参数
- (void)setTrackParameters:(int)width :(int)height :(int)bitrate; // 设置视频分辨率和比特率
/// 启用画中画模式
- (void)enablePictureInPicture:(CGRect)frame; // 启用画中画模式
/// 设置画中画状态
- (void)setPictureInPicture:(BOOL)pictureInPicture; // 设置画中画状态
/// 禁用画中画模式
- (void)disablePictureInPicture; // 禁用画中画模式
/// 获取绝对播放位置（毫秒）
- (int64_t)absolutePosition; // 返回绝对播放位置
/// 将 CMTime 转换为毫秒
- (int64_t)FLTCMTimeToMillis:(CMTime)time; // CMTime 转毫秒
/// 清除播放器资源
- (void)clear; // 清除播放器资源
/// 释放播放器资源（不含事件通道）
- (void)disposeSansEventChannel; // 释放资源（不含事件通道）
/// 释放播放器所有资源
- (void)dispose; // 释放所有资源
@end

NS_ASSUME_NONNULL_END
