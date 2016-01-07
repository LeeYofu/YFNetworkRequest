//
//  YFNetworkRequest.h
//  NetworkRequestDemo
//
//  Created by 李友富 on 16/1/7.
//  Copyright © 2016年 李友富. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#define BASEURLSTRING @"http://t16.beauityworld.com"

typedef NS_ENUM(NSUInteger, YFNetworkRequestCachePolicy) {
    YFNetworkRequestReturnCacheDataThenLoad = 0, // 有缓存就先返回缓存，同步请求数据
    YFNetworkRequestReloadIgnoringLocalCacheData, // 忽略缓存，重新请求
    YFNetworkRequestReturnCacheDataElseLoad, // 有缓存就用缓存，没有缓存就重新请求(用于数据不变时)
    YFNetworkRequestReturnCacheDataDontLoad // 有缓存就用缓存，没有缓存就不发请求，当做请求出错处理（用于离线模式）
};

typedef void(^SucessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void(^FailureBlock)(NSURLSessionDataTask *task, NSError *error);

@interface YFNetworkRequest : AFHTTPSessionManager

// GET请求（无缓存）
+ (void)getWithSubUrl:(NSString *)subUrlString
           parameters:(id)parameters
               sucess:(SucessBlock)sucess
              failure:(FailureBlock)failure;

// GET请求（有缓存）
+ (void)getWithSubUrl:(NSString *)subUrlString
           parameters:(id)parameters
          cachePolicy:(YFNetworkRequestCachePolicy)requestCachePolicy
               sucess:(SucessBlock)sucess
              failure:(FailureBlock)failure;

// POST请求（无缓存）
+ (void)postWithSubUrl:(NSString *)subUrlString
            parameters:(id)parameters
                sucess:(SucessBlock)sucess
               failure:(FailureBlock)failure;

// POST请求（有缓存）
+ (void)postWithSubUrl:(NSString *)subUrlString
            parameters:(id)parameters
           cachePolicy:(YFNetworkRequestCachePolicy)requestCachePolicy
                sucess:(SucessBlock)sucess
               failure:(FailureBlock)failure;

// 上传图片/诗篇
+ (void)postWithSubUrl:(NSString *)subUrl parameters:(id)parameters imageDatas:(NSArray *)imageDatas imageNames:(NSArray *)imageNames videoData:(NSData *)videoData sucess:(SucessBlock)sucess failed:(FailureBlock)failure;

@end
