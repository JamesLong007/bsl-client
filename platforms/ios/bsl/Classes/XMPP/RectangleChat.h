//
//  RectangleChat.h
//  cube-ios
//
//  Created by 肖昶 on 13-9-15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    RectangleChatContentTypeMessage=0,
    RectangleChatContentTypeImage,
    RectangleChatContentTypeVoice
}RectangleChatContentType;

@interface RectangleChat : NSManagedObject

@property(nonatomic,strong) NSNumber* chatId;
@property(nonatomic,strong) NSNumber* chatMemberCount;
@property(nonatomic,strong) NSString* content;
@property(nonatomic,strong) NSNumber* contentType;
@property(nonatomic,strong) NSString* createrJid;
@property(nonatomic,strong) NSString* receiverJid;
@property(nonatomic,strong) NSNumber* isGroup;
@property(nonatomic,strong) NSDate*  updateDate;
@property(nonatomic,strong) NSNumber* noReadMsgNumber;
@property(nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSNumber* isQuit;


@end
