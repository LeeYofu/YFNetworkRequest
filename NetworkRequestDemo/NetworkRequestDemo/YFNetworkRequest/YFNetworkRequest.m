//
//  YFNetworkRequest.m
//  NetworkRequestDemo
//
//  Created by 李友富 on 16/1/7.
//  Copyright © 2016年 李友富. All rights reserved.
//

#import "YFNetworkRequest.h"
#import <YYCache/YYCache.h>
#import "NSJSONSerialization+YFJson.h"

typedef NS_ENUM(NSUInteger, YFNetworkRequestType) {
    YFNetworkRequestTypeGET = 0,
    YFNetworkRequestTypePOST,
};

static NSString * const YFNetworkRequestCache = @"YFNetworkRequestCache";

@implementation YFNetworkRequest

#pragma mark - public
+ (void)getWithSubUrl:(NSString *)subUrlString
           parameters:(id)parameters
               sucess:(SucessBlock)sucess
              failure:(FailureBlock)failure {
    [self requestMethod:YFNetworkRequestTypeGET subUrlString:subUrlString parameters:parameters cachePolicy:YFNetworkRequestReturnCacheDataThenLoad success:sucess failure:failure];
}

+ (void)getWithSubUrl:(NSString *)subUrlString
           parameters:(id)parameters
          cachePolicy:(YFNetworkRequestCachePolicy)requestCachePolicy
               sucess:(SucessBlock)sucess
              failure:(FailureBlock)failure {
    [self requestMethod:YFNetworkRequestTypeGET subUrlString:subUrlString parameters:parameters cachePolicy:requestCachePolicy success:sucess failure:failure];
}

+ (void)postWithSubUrl:(NSString *)subUrlString
            parameters:(id)parameters
                sucess:(SucessBlock)sucess
               failure:(FailureBlock)failure {
    [self requestMethod:YFNetworkRequestTypePOST subUrlString:subUrlString parameters:parameters cachePolicy:YFNetworkRequestReturnCacheDataThenLoad success:sucess failure:failure];
}

+ (void)postWithSubUrl:(NSString *)subUrlString
            parameters:(id)parameters
           cachePolicy:(YFNetworkRequestCachePolicy)requestCachePolicy
                sucess:(SucessBlock)sucess
               failure:(FailureBlock)failure {
    [self requestMethod:YFNetworkRequestTypePOST subUrlString:subUrlString parameters:parameters cachePolicy:requestCachePolicy success:sucess failure:failure];
}

+ (void)postWithSubUrl:(NSString *)subUrl parameters:(id)parameters imageDatas:(NSArray *)imageDatas imageNames:(NSArray *)imageNames videoData:(NSData *)videoData sucess:(SucessBlock)sucess failed:(FailureBlock)failure {
    
    [[YFNetworkRequest sharedInstance] POST:subUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i = 0; i<imageDatas.count; i++) {
            [formData appendPartWithFileData:[imageDatas objectAtIndex:i]
                                        name:[imageNames objectAtIndex:i]
                                    fileName:[NSString stringWithFormat:@"%@.jpg",[imageNames objectAtIndex:i]]
                                    mimeType:@"image/jpeg"];
            
        }
        
        if (videoData) {
            [formData appendPartWithFileData:videoData
                                        name:@"video"
                                    fileName:[NSString stringWithFormat:@"%@.mp4",@"video"]
                                    mimeType:@"video/mp4"];
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (sucess) {
            sucess(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
    }];

}

#pragma mark - private
+ (void)requestMethod:(YFNetworkRequestType)type
         subUrlString:(NSString *)subUrlString parameters:(id)parameters
          cachePolicy:(YFNetworkRequestCachePolicy)cachePolicy
              success:(SucessBlock)success
              failure:(FailureBlock)failure {
    
    NSString *cacheKey = subUrlString;
    
    if (parameters) {
        if (! [NSJSONSerialization isValidJSONObject:parameters]) return;//参数不是json类型
        NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
        NSString *paramStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        cacheKey = [subUrlString stringByAppendingString:paramStr];
    }
    
    YYCache *cache = [[YYCache alloc] initWithName:YFNetworkRequestCache];
    cache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = YES;
    cache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = YES;
    
    id object = [cache objectForKey:cacheKey];
    
    switch (cachePolicy) {
        case YFNetworkRequestReturnCacheDataThenLoad : { // 先返回缓存，同时请求
            if (object) {
                success(nil,object);
            }
            break;
        }
        case YFNetworkRequestReloadIgnoringLocalCacheData : { // 忽略本地缓存直接请求
            // 不做处理，直接请求
            break;
        }
        case YFNetworkRequestReturnCacheDataElseLoad : { // 有缓存就返回缓存，没有就请求
            if (object) { // 有缓存
                success(nil,object);
                return;
            }
            break;
        }
        case YFNetworkRequestReturnCacheDataDontLoad : { // 有缓存就返回缓存,从不请求（用于没有网络）
            if (object) { // 有缓存
                success(nil,object);
            }
            return; // 退出从不请求
        }
        default: {
            break;
        }
    }
    [self requestMethod:type subUrlString:subUrlString parameters:parameters cache:cache cacheKey:cacheKey success:success failure:failure];
}

+ (void)requestMethod:(YFNetworkRequestType)type
            subUrlString:(NSString *)subUrlString
           parameters:(id)parameters
                cache:(YYCache *)cache
             cacheKey:(NSString *)cacheKey
              success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    switch (type) {
        case YFNetworkRequestTypeGET : {
            [[YFNetworkRequest sharedInstance] GET:subUrlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if ([responseObject isKindOfClass:[NSData class]]) {
                    responseObject = [NSJSONSerialization objectWithJSONData:responseObject];
                }
                [cache setObject:responseObject forKey:cacheKey]; // YYCache 已经做了responseObject为空处理
                success(task, responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                failure(task, error);
            }];
            break;
        }
        case YFNetworkRequestTypePOST : {
            [[YFNetworkRequest sharedInstance] POST:subUrlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if ([responseObject isKindOfClass:[NSData class]]) {
                    responseObject = [NSJSONSerialization objectWithJSONData:responseObject];
                }
                [cache setObject:responseObject forKey:cacheKey]; // YYCache 已经做了responseObject为空处理
                success(task,responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                failure(task, error);
            }];
            break;
        }
        default:
            break;
    }
}

+ (instancetype)sharedInstance {
    static YFNetworkRequest *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [YFNetworkRequest client];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/css", @"text/plain", nil];
    });
    return manager;
}

+ (instancetype)client {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    return [[YFNetworkRequest alloc] initWithBaseURL:[NSURL URLWithString:BASEURLSTRING] sessionConfiguration:configuration];
}

+ (void)checkNetworkStatusResult:(void (^)(id))result {
    /**
     *  AFNetworkReachabilityStatusUnknown          = -1,  // 未知
     *  AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
     *  AFNetworkReachabilityStatusReachableViaWWAN = 1,   // 3G
     *  AFNetworkReachabilityStatusReachableViaWiFi = 2,   // 局域网络Wifi
     */
    // 如果要检测网络状态的变化, 必须要用检测管理器的单例startMoitoring
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(status == AFNetworkReachabilityStatusNotReachable){
            NSLog(@"网络连接已断开，请检查您的网络！");
            result(@"-1");
            return ;
        }
    }];
}

/// URLString 应该是全url 上传单个文件
+ (NSURLSessionUploadTask *)upload:(NSString *)URLString filePath:(NSString *)filePath parameters:(id)parameters{
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    NSURLSessionUploadTask *uploadTask = [[YFNetworkRequest client] uploadTaskWithRequest:request fromFile:fileUrl progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
        }
    }];
    [uploadTask resume];
    return uploadTask;
}


@end
