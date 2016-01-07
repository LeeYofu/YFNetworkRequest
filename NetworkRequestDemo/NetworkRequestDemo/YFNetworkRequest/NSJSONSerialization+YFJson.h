//
//  NSJSONSerialization+YFJson.h
//  NetworkRequestDemo
//
//  Created by 李友富 on 16/1/7.
//  Copyright © 2016年 李友富. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (YFJson)

+ (nullable NSString *)stringWithJSONObject:(nonnull id)JSONObject;

+ (nullable id)objectWithJSONString:(nonnull NSString *)JSONString;

+ (nullable id)objectWithJSONData:(nonnull NSData *)JSONData;

@end
