#import "IAppPlayerTimeUtils.h"

/// 时间转换工具类实现
@implementation IAppPlayerTimeUtils
/// 将 CMTime 转换为毫秒
+ (int64_t) FLTCMTimeToMillis:(CMTime) time {
    if (time.timescale == 0) return 0; // 避免除零
    return time.value * 1000 / time.timescale; // 转换为毫秒
}

/// 将 NSTimeInterval 转换为毫秒
+ (int64_t) FLTNSTimeIntervalToMillis:(NSTimeInterval) interval {
    return (int64_t)(interval * 1000.0); // 转换为毫秒
}
@end
