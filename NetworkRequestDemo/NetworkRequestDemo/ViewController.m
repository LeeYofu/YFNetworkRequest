//
//  ViewController.m
//  NetworkRequestDemo
//
//  Created by 李友富 on 16/1/7.
//  Copyright © 2016年 李友富. All rights reserved.
//

#import "ViewController.h"
#import "YFNetworkRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self dataRequest];
}

- (void)dataRequest {
    
    NSDictionary *parameters = @{
                                 @"user_id" : @"1"
                                 };
    
    [YFNetworkRequest getWithSubUrl:@"/JobUserAPI/getUserInfoById" parameters:parameters sucess:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
