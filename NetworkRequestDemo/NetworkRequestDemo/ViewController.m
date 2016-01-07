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
@property (nonatomic, strong) UILabel *label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSubViews];
    
    [self dataRequest];
}

- (void)setSubViews {
    self.label = ({
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 200, 30)];
        view.backgroundColor = [UIColor yellowColor];
        view;
    });
    
    [self.view addSubview:self.label];
}

- (void)dataRequest {
    
    NSDictionary *parameters = @{
                                 @"user_id" : @"1"
                                 };
    
    [YFNetworkRequest getWithSubUrl:@"/JobUserAPI/getUserInfoById" parameters:parameters sucess:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@", responseObject);
        NSDictionary *oriDic = (NSDictionary *)responseObject;
        NSDictionary *dataDic = oriDic[@"data"];
        self.label.text = dataDic[@"city"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
