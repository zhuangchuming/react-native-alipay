//
//  RCTAlipay.m
//  RCTAlipay
//
//  Created by DengYun on 4/21/16.
//  Copyright © 2016 DengYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTAlipay.h"
#import <AlipaySDK/AlipaySDK.h>

static RCTPromiseResolveBlock _resolve;
static RCTPromiseRejectBlock _reject;

static NSString *gAppSchema = @"";

@implementation RCTAlipay

RCT_EXPORT_MODULE(RCTAlipay);

@synthesize bridge = _bridge;

- (NSDictionary *)constantsToExport
{
    return @{};
};

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (instancetype)init
{
    self = [super init];
    if (self) {
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:@"RCTOpenURLNotification" object:nil];
    }
    NSArray *list = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleURLTypes"];
    for (NSDictionary *item in list) {
        NSString *name = item[@"CFBundleURLName"];
        if ([name isEqualToString:@"alipay"]) {
            NSArray *schemes = item[@"CFBundleURLSchemes"];
            if (schemes.count > 0)
            {
                gAppSchema = schemes[0];
                break;
            }
        }
    }
    return self;
}

- (void)dealloc
{
}

- (void)handleOpenURL:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    NSString *strUrl = userInfo[@"url"];
    NSURL* url = [NSURL URLWithString:strUrl];
    //如果极简开发包不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给开发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            // 天地之灵补充：此时客户端界面逻辑已经不连贯，推荐由服务端在notifyUrl中处理支付。
            NSLog(@"result aaaaaaa= %@",resultDic);
            _resolve(resultDic);
        }];
    }
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
        
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            // 天地之灵补充：此时客户端界面逻辑已经不连贯，推荐由服务端在notifyUrl中处理支付。
            NSLog(@"result bbbbbb= %@",resultDic);
            _resolve(resultDic);
        }];
    }
}

RCT_EXPORT_METHOD(pay:(NSString *)orderInfo showLoading:(BOOL)showLoading resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    //手动添加用来做回调
    _resolve = resolve;
    _reject = reject;
    
    [[AlipaySDK defaultService] payOrder:orderInfo fromScheme:gAppSchema callback:^(NSDictionary *resultDic) {
        resolve(resultDic);
    }];
    
}


@end
