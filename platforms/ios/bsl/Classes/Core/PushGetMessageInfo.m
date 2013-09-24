//
//  PushGetMessageInfo.m
//  cube-ios
//
//  Created by 东 on 8/8/13.
//
//

#import "PushGetMessageInfo.h"
#import "UIDevice+IdentifierAddition.h"
#import "JSONKit.h"
#import "MessageRecord.h"

@implementation PushGetMessageInfo

+(void)getPushMessageInfo{
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* token = [userDefaults objectForKey:@"deviceToken"];
    NSString* deviceId = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/%@/%@/%@",kPushGetMessageUrl,token,deviceId,kAPPKey];
    
    if (token && [token length] > 0 ) {
        HTTPRequest * request = [[HTTPRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
        __block HTTPRequest* __request=request;
        [request setRequestMethod:@"GET"];
        [request setCompletionBlock:^{
            NSLog(@"获取推送信息完成");
            if (__request.responseStatusCode != 500) {
                NSData *data = [__request responseData];
                NSMutableArray * messageArray = [data objectFromJSONData];
                if ([messageArray count]>0) {
                    //FMDB 事务
                    for (NSDictionary* dictionary in messageArray) {
                        [MessageRecord createByApnsInfo:dictionary];
                    }
                }
            }
        }];
        [request setFailedBlock:^{
            NSLog(@"获取推送信息出错");
        }];
        [request startAsynchronous];
    }
}

@end
