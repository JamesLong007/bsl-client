//
//  MessageDelayHandler.h
//  cube-ios
//
//  Created by zhoujun on 13-8-27.
//
//

#import <Foundation/Foundation.h>
#import "MessageObject.h"
@interface MessageDelayHandler : NSObject
{
    NSMutableArray *queueArray;
    
    NSMutableArray *handlerArray;
    
    
}
@property(nonatomic)NSMutableArray *queueArray;
@property(nonatomic)NSMutableArray *handlerArray;
+(MessageDelayHandler*)shareInstance;
-(void)addToQueue:(MessageObject*)msg;
-(void)sendBroadCast:(MessageObject*)msg;
-(void)handleQueue;
@end
