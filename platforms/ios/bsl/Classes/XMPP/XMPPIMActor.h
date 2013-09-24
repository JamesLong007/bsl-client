//
//  XMPPIMActor.h
//  cube-ios
//
//  Created by 东 on 13-3-5.
//
//

#import <Foundation/Foundation.h>

#import "MessageEntity.h"
#import "UserInfo.h"

#import "XMPP.h"
#import "XMPPRoster.h"
#import "XMPPReconnect.h"
#import "XMPPRosterCoreDataStorage.h"
#import "ChatDelegate.h"

#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardTempModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "RectangleChat.h"

#import "XMPPRoom.h"
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPMUC.h"
#import "RoomService.h"

@class GroupRoomUserEntity;

@protocol XMPPIMActorDelegate <NSObject>

-(void)setupXmppSucces;
-(void)setupUnsucces;
-(void)setupError:(NSString*)aError;

@end


@interface XMPPIMActor : NSObject<XMPPStreamDelegate,UIAlertViewDelegate>{
    id<ChatDelegate> charDelegate;
    
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    
    XMPPMUC *xmppMUC;

    NSString *passWord;
    BOOL isOpen;
    BOOL isLoginOperation;
    
    
    BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	BOOL isXmppConnected;
    BOOL isRegister;
    
    
    BOOL islogin;
    NSString* loginUserStr;
    
    NSString* oldLoginUser;
    
    NSMutableArray*turnSockets;
}
@property (nonatomic,assign ) id<ChatDelegate> chatDelegate;

@property (nonatomic,assign ) BOOL islogin;
@property (nonatomic,retain ) NSString* loginUserStr;
@property (nonatomic,readonly) XMPPStream* xmppStream;
@property (nonatomic,readonly) RoomService* roomService;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;

@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property(nonatomic,strong,readonly) XMPPMUC *xmppMUC;

@property(nonatomic,assign) id<XMPPIMActorDelegate> delegate;

-(id)initWithDelegate:(id<XMPPIMActorDelegate>) delegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;



-(BOOL)connect;

-(void)disConnect;

-(BOOL)isConnected;

-(void)setupXmppStream;

-(void)goOnline;

-(void)goOffLine;

-(void)addFrindFromUsers:(NSString*)jid;


-(void)findFriendsList;


-(MessageEntity*)fetchMessageFromUqID:(NSString*)uqID messageId:(NSString*)messageId;
-(RectangleChat*)fetchRectangleChatFromJid:(NSString*)messageId isGroup:(BOOL)isGroup;

-(void)newRectangleMessage:(NSString*)messageId name:(NSString*)name content:(NSString*)content contentType:(RectangleChatContentType)contentType isGroup:(BOOL)isGroup createrJid:(NSString*)createrJid;


-(GroupRoomUserEntity*)fetchGroupRoomUser:(NSString*)roomId memberId:(NSString*)memberId;

-(void)addGroupRoomMember:(NSString*)roomId memberId:(NSString*)memberId sex:(NSString*)sex status:(NSString*)status username:(NSString*)username;

-(UserInfo*)fetchUserFromJid:(NSString*)userJid;

-(void)newvCard;

@end
