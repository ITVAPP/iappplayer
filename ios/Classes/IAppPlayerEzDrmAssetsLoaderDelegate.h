#import "IAppPlayerEzDrmAssetsLoaderDelegate.h"

/// DRM 资源加载委托，处理内容密钥请求
@implementation IAppPlayerEzDrmAssetsLoaderDelegate {
    NSString *_assetId; 
    NSURLSession *_urlSession;
}

/// 默认许可证服务器 URL
static NSString * const DEFAULT_LICENSE_SERVER_URL = @"https://fps.ezdrm.com/api/licenses/";

/// 初始化委托，设置证书和许可证 URL
- (instancetype)init:(NSURL *)certificateURL withLicenseURL:(NSURL *)licenseURL {
    self = [super init];
    if (self) {
        _certificateURL = certificateURL;
        _licenseURL = licenseURL;
        
        // 配置URLSession，复用连接
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 30.0;
        config.timeoutIntervalForResource = 60.0;
        config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _urlSession = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

/// 从密钥服务器获取内容密钥和租赁期限
- (NSData *)getContentKeyAndLeaseExpiryFromKeyServerModuleWithRequest:(NSData*)requestBytes and:(NSString *)assetId and:(NSString *)customParams and:(NSError **)errorOut {
    __block NSData * decodedData = nil;
    __block NSError * responseError = nil;
    
    /// 确定最终许可证 URL，优先使用传入的 URL
    NSURL * finalLicenseURL;
    if (_licenseURL && _licenseURL != [NSNull null]) {
        finalLicenseURL = _licenseURL;
    } else {
        finalLicenseURL = [[NSURL alloc] initWithString: DEFAULT_LICENSE_SERVER_URL];
    }
    
    // 构建完整URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", finalLicenseURL.absoluteString, assetId, customParams];
    NSURL * ksmURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:ksmURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:requestBytes];
    
    @try {
        /// 使用异步网络请求但保持同步行为（因为AVAssetResourceLoaderDelegate需要同步返回）
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [[_urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"DRM 密钥请求失败: %@", error.localizedDescription);
                responseError = error;
            } else {
                // 检查HTTP响应状态
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                        decodedData = data;
                    } else {
                        NSLog(@"DRM 密钥请求失败，HTTP状态码: %ld", (long)httpResponse.statusCode);
                        responseError = [NSError errorWithDomain:NSURLErrorDomain 
                                                           code:httpResponse.statusCode 
                                                       userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP状态码: %ld", (long)httpResponse.statusCode]}];
                    }
                } else {
                    decodedData = data;
                }
            }
            dispatch_semaphore_signal(semaphore);
        }] resume];
        
        /// 设置 30 秒超时
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC);
        if (dispatch_semaphore_wait(semaphore, timeout) != 0) {
            NSLog(@"DRM 密钥请求超时");
            responseError = [NSError errorWithDomain:NSURLErrorDomain 
                                               code:NSURLErrorTimedOut 
                                           userInfo:@{NSLocalizedDescriptionKey: @"DRM密钥请求超时"}];
        }
    }
    @catch (NSException* excp) {
        NSLog(@"DRM 密钥请求异常: %@", excp.description);
        responseError = [NSError errorWithDomain:NSURLErrorDomain 
                                           code:NSURLErrorUnknown 
                                       userInfo:@{NSLocalizedDescriptionKey: excp.description}];
    }
    
    if (errorOut) {
        *errorOut = responseError;
    }
    
    return decodedData;
}

/// 获取应用证书，用于服务器身份验证
- (NSData *)getAppCertificate:(NSString *)String {
    if (!_certificateURL) {
        return nil;
    }
    
    NSData * certificate = nil;
    NSError *error = nil;
    
    // 使用NSData的错误处理版本
    certificate = [NSData dataWithContentsOfURL:_certificateURL options:NSDataReadingUncached error:&error];
    
    if (error) {
        NSLog(@"获取DRM证书失败: %@", error.localizedDescription);
        return nil;
    }
    
    return certificate;
}

/// 处理资源加载请求
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSURL *assetURI = loadingRequest.request.URL;
    NSString * str = assetURI.absoluteString;
    
    // 验证URL格式
    if (str.length < 36) {
        NSLog(@"DRM资源URL格式错误: %@", str);
        [loadingRequest finishLoadingWithError:[[NSError alloc] initWithDomain:NSURLErrorDomain 
                                                                          code:NSURLErrorBadURL 
                                                                      userInfo:@{NSLocalizedDescriptionKey: @"URL格式错误"}]];
        return NO;
    }
    
    NSString * mySubstring = [str substringFromIndex:str.length - 36];
    _assetId = mySubstring;
    NSString * scheme = assetURI.scheme;
    
    if (!([scheme isEqualToString:@"skd"])) {
        return NO;
    }
    
    NSData * requestBytes = nil;
    NSData * certificate = nil;
    
    @try {
        /// 获取 DRM 证书
        certificate = [self getAppCertificate:_assetId];
        if (!certificate) {
            [loadingRequest finishLoadingWithError:[[NSError alloc] initWithDomain:NSURLErrorDomain 
                                                                              code:NSURLErrorClientCertificateRejected 
                                                                          userInfo:@{NSLocalizedDescriptionKey: @"无法获取DRM证书"}]];
            return YES;
        }
    }
    @catch (NSException* excp) {
        NSLog(@"获取DRM证书异常: %@", excp.description);
        [loadingRequest finishLoadingWithError:[[NSError alloc] initWithDomain:NSURLErrorDomain 
                                                                          code:NSURLErrorClientCertificateRejected 
                                                                      userInfo:@{NSLocalizedDescriptionKey: excp.description}]];
        return YES;
    }
    
    @try {
        /// 获取流式内容密钥数据
        NSError *spcError = nil;
        requestBytes = [loadingRequest streamingContentKeyRequestDataForApp:certificate 
                                                         contentIdentifier:[str dataUsingEncoding:NSUTF8StringEncoding] 
                                                                   options:nil 
                                                                     error:&spcError];
        if (spcError) {
            NSLog(@"生成SPC失败: %@", spcError.localizedDescription);
            [loadingRequest finishLoadingWithError:spcError];
            return YES;
        }
    }
    @catch (NSException* excp) {
        NSLog(@"生成SPC异常: %@", excp.description);
        [loadingRequest finishLoadingWithError:[[NSError alloc] initWithDomain:NSURLErrorDomain 
                                                                          code:NSURLErrorUnknown 
                                                                      userInfo:@{NSLocalizedDescriptionKey: excp.description}]];
        return YES;
    }
    
    NSString * passthruParams = [NSString stringWithFormat:@"?customdata=%@", _assetId];
    NSData * responseData = nil;
    NSError * error = nil;
    
    /// 请求内容密钥
    responseData = [self getContentKeyAndLeaseExpiryFromKeyServerModuleWithRequest:requestBytes 
                                                                               and:_assetId 
                                                                               and:passthruParams 
                                                                               and:&error];
    
    if (responseData && responseData.length > 0) {
        AVAssetResourceLoadingDataRequest * dataRequest = loadingRequest.dataRequest;
        [dataRequest respondWithData:responseData];
        [loadingRequest finishLoading];
    } else {
        NSError *finalError = error ?: [[NSError alloc] initWithDomain:NSURLErrorDomain 
                                                                  code:NSURLErrorUnknown 
                                                              userInfo:@{NSLocalizedDescriptionKey: @"无法获取DRM密钥"}];
        [loadingRequest finishLoadingWithError:finalError];
    }
    
    return YES;
}

/// 处理资源续订请求
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest {
    return [self resourceLoader:resourceLoader shouldWaitForLoadingOfRequestedResource:renewalRequest];
}

/// 清理资源
- (void)dealloc {
    [_urlSession invalidateAndCancel];
}

@end