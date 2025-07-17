#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 时间转换工具类
@interface IAppPlayerTimeUtils : NSObject
/// 将 CMTime 转换为毫秒
+ (int64_t) FLTCMTimeToMillis:(CMTime) time;
/// 将 NSTimeInterval 转换为毫秒
+ (int64_t) FLTNSTimeIntervalToMillis:(NSTimeInterval) interval;
@end

NS_ASSUME_NONNULL_END
