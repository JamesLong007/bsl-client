//
//  ChatLogic.h
//  cube-ios
//
//  Created by apple2310 on 13-9-7.
//
//

#import <Foundation/Foundation.h>
@class FormDataRequest;
@interface ChatLogic : NSObject{
//    FormDataRequest * request;
    
}

@property(nonatomic,strong) NSString* roomJID;


-(void)sendNotificationMessage:(NSString* )content messageId:(NSString*)messageId isGroup:(BOOL)isGroup name:(NSString*)name onlyUpdateChat:(BOOL)onlyUpdateChat;

-(BOOL)sendMessage:(NSString* )content messageId:(NSString*)messageId isGroup:(BOOL)isGroup name:(NSString*)name;

-(BOOL)sendfile:(NSString* )content path:(NSString*)path messageId:(NSString*)messageId isGroup:(BOOL)isGroup name:(NSString*)name;


-(BOOL)sendVoice:(NSString* )content urlVoiceFile:(NSURL*)urlVoiceFile messageId:(NSString*)messageId isGroup:(BOOL)isGroup name:(NSString*)name;

-(BOOL)sendRoomQuitAction:(NSString*)messageId;


-(BOOL)uploadImageToServer:(UIImage*)image finish:(void (^)(NSString* id,NSString* path))finish;


-(BOOL)isInFaviorContacts:(NSString*)chatWithUser;
-(void)addFaviorInContacts:(NSString*)chatWithUser;
-(void)removeFaviorInContacts:(NSString*)chatWithUser;


@end

