//
//  RoomService.h
//  cube-ios
//
//  Created by 肖昶 on 13-9-17.
//
//

#import <Foundation/Foundation.h>

@class XMPPRoom;
@class HTTPRequest;

@interface RoomService : NSObject{
    NSTimer* checkTimer;
    NSMutableArray*  rooms;
    
    HTTPRequest* request;

}
-(void)tearDown;
-(XMPPRoom*)findRoomByJid:(NSString*)roomId;
-(NSString*)createNewRoom;
-(void)removeNewRoom:(NSString*)roomId destory:(BOOL)destory;
-(void)joinAllRoomService;
-(void)joinRoomServiceWithRoomID:(NSString*)roomID;

@end
