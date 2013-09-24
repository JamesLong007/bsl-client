//
//  ChatLogic.m
//  cube-ios
//
//  Created by apple2310 on 13-9-7.
//
//

#import "ChatLogic.h"
#import "HTTPRequest.h"
#import "JSONKit.h"
#import "RectangleChat.h"
#import "XMPPRoom.h"
#import "MessageRecord.h"
#import "XMPPSqlManager.h"

@interface ChatLogic()
-(NSString*)juingNewId;
@end

@implementation ChatLogic

@synthesize roomJID;
-(id)init{
    self=[super init];
    if(self){
    }
    return self;
}

-(void)dealloc{
    self.roomJID=nil;
}

-(NSString*)juingNewId{
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    
}

-(void)sendNotificationMessage:(NSString* )content messageId:(NSString*)messageId isGroup:(BOOL)isGroup name:(NSString*)name  onlyUpdateChat:(BOOL)onlyUpdateChat{
    
    @autoreleasepool {
        NSString* uqID=[self juingNewId];
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        //新建消息的entity
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MessageEntity" inManagedObjectContext:appDelegate.xmpp.managedObjectContext];
        [newManagedObject setValue:uqID forKey:@"uqID"];
        [newManagedObject setValue:content forKey:@"content"];
        [newManagedObject setValue:@"notification" forKey:@"type"];
        
        [newManagedObject setValue:[NSDate date] forKey:@"sendDate"];
        [newManagedObject setValue:messageId forKey:@"messageId"];
        [newManagedObject setValue:messageId forKey:@"receiveUser"];
        [newManagedObject setValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare] forKey:@"sendUser"];
        
        [newManagedObject setValue:[NSDate date] forKey:@"receiveDate"];
        
        if(!onlyUpdateChat){
            [appDelegate.xmpp newRectangleMessage:messageId name:name content:content contentType:RectangleChatContentTypeMessage isGroup:isGroup createrJid:nil];
            [appDelegate.xmpp saveContext];
        }
        
        if(!onlyUpdateChat)
            [MessageRecord createModuleBadge:@"com.foss.chat" num: [XMPPSqlManager getMessageCount]];

    }

}

-(BOOL)sendMessage:(NSString* )content messageId:(NSString*)messageId isGroup:(BOOL)isGroup name:(NSString*)name{
    
    XMPPRoom *room=nil;
    if(self.roomJID!=nil)
        room=[[ShareAppDelegate xmpp].roomService findRoomByJid:self.roomJID];

    if(room!=nil && !room.isJoined)return NO;

    NSString* uqID=[self juingNewId];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];

    @autoreleasepool {
        //拼写xml格式的xmpp消息
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:content];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message" ];
        
        [message addAttributeWithName:@"uqID" stringValue:uqID];
        if(!isGroup){
            
            [message addAttributeWithName:@"type" stringValue:@"chat"];
            [message addAttributeWithName:@"from" stringValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]];
            //消息接受者
            [message addAttributeWithName:@"to" stringValue:messageId];
            [message addChild:body];
            
            NSXMLNode* subject = [NSXMLNode elementWithName:@"subject" stringValue:@"text"];//告诉接受方 传送的是文件 还是 聊天内容
            [message addChild:subject];
        }
        else{
            [message addAttributeWithName:@"type" stringValue:@"groupchat"];
            [message addAttributeWithName:@"from" stringValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]];
            //消息接受者
            [message addAttributeWithName:@"to" stringValue:[[room roomJID] full]];
            [message addChild:body];
            
            NSXMLNode* subject = [NSXMLNode elementWithName:@"subject" stringValue:@"text"];//告诉接受方 传送的是文件 还是 聊天内容
            [message addChild:subject];
        }
        //发送消息
        [appDelegate.xmpp.xmppStream sendElement:message];
    }



    @autoreleasepool {
        //新建消息的entity
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MessageEntity" inManagedObjectContext:appDelegate.xmpp.managedObjectContext];
        [newManagedObject setValue:uqID forKey:@"uqID"];
        [newManagedObject setValue:content forKey:@"content"];
        [newManagedObject setValue:@"text" forKey:@"type"];
        
        [newManagedObject setValue:[NSDate date] forKey:@"sendDate"];
        [newManagedObject setValue:messageId forKey:@"messageId"];
        [newManagedObject setValue:messageId forKey:@"receiveUser"];
        [newManagedObject setValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare] forKey:@"sendUser"];
        
        [newManagedObject setValue:[NSDate date] forKey:@"receiveDate"];
        
        [appDelegate.xmpp newRectangleMessage:messageId name:name content:content contentType:RectangleChatContentTypeMessage isGroup:isGroup createrJid:nil];
        
        [appDelegate.xmpp saveContext];
    }


    return YES;
}

-(BOOL)sendRoomQuitAction:(NSString*)messageId{
    if(self.roomJID==nil)return NO;
    XMPPRoom *room=nil;
    if(self.roomJID!=nil)
        room=[[ShareAppDelegate xmpp].roomService findRoomByJid:self.roomJID];
    
    if(room!=nil && !room.isJoined)return NO;
    
    NSString* uqID=[self juingNewId];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    @autoreleasepool {
        //拼写xml格式的xmpp消息
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:@"quit room"];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message" ];
        
        [message addAttributeWithName:@"uqID" stringValue:uqID];

        [message addAttributeWithName:@"type" stringValue:@"groupchat"];
        [message addAttributeWithName:@"from" stringValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]];
            //消息接受者
        [message addAttributeWithName:@"to" stringValue:[[room roomJID] full]];
        [message addChild:body];
            
        NSXMLNode* subject = [NSXMLNode elementWithName:@"subject" stringValue:@"quitgroup"];//告诉接受方 传送的是文件 还是 聊天内容
        [message addChild:subject];

        //发送消息
        [appDelegate.xmpp.xmppStream sendElement:message];
    }
    
    return YES;

}


-(BOOL)sendfile:(NSString* )content path:(NSString*)path messageId:(NSString*)messageId isGroup:(BOOL)isGroup name:(NSString*)name{
    XMPPRoom *room=nil;
    if(self.roomJID!=nil)
        room=[[ShareAppDelegate xmpp].roomService findRoomByJid:self.roomJID];
    
    if(room!=nil && !room.isJoined)return NO;

    NSString* uqID=[self juingNewId];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];

    //拼写xml格式的xmpp消息
    @autoreleasepool {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:content];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message" ];
        [message addAttributeWithName:@"uqID" stringValue:uqID];
        
        if(!isGroup){
            
            [message addAttributeWithName:@"type" stringValue:@"chat"];
            [message addAttributeWithName:@"from" stringValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]];
            //消息接受者
            [message addAttributeWithName:@"to" stringValue:messageId];
            [message addChild:body];
            
            NSXMLNode* subject = [NSXMLNode elementWithName:@"subject" stringValue:@"image"];//告诉接受方 传送的是文件 还是 聊天内容
            [message addChild:subject];
        }
        else{
            [message addAttributeWithName:@"type" stringValue:@"groupchat"];
            [message addAttributeWithName:@"from" stringValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]];
            //消息接受者
            [message addAttributeWithName:@"to" stringValue:[[room roomJID] full]];
            [message addChild:body];
            
            NSXMLNode* subject = [NSXMLNode elementWithName:@"subject" stringValue:@"image"];//告诉接受方 传送的是文件 还是 聊天内容
            [message addChild:subject];
        }
        
        //发送消息
        [appDelegate.xmpp.xmppStream sendElement:message];
    }
    
    @autoreleasepool {
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MessageEntity" inManagedObjectContext:appDelegate.xmpp.managedObjectContext];
        [newManagedObject setValue:uqID forKey:@"uqID"];
        [newManagedObject setValue:path forKey:@"content"];
        [newManagedObject setValue:@"image" forKey:@"type"];
        [newManagedObject setValue:[NSDate date] forKey:@"sendDate"];
        [newManagedObject setValue:messageId forKey:@"messageId"];
        [newManagedObject setValue:messageId forKey:@"receiveUser"];
        [newManagedObject setValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare] forKey:@"sendUser"];
        
        [appDelegate.xmpp newRectangleMessage:messageId name:name content:content contentType:RectangleChatContentTypeImage isGroup:isGroup createrJid:nil];
        
        [appDelegate.xmpp saveContext];
    }

    
    return YES;
}


-(BOOL)sendVoice:(NSString* )content urlVoiceFile:(NSURL*)urlVoiceFile messageId:(NSString*)messageId isGroup:(BOOL)isGroup name:(NSString*)name{
    XMPPRoom *room=nil;
    if(self.roomJID!=nil)
        room=[[ShareAppDelegate xmpp].roomService findRoomByJid:self.roomJID];
    
    if(room!=nil && !room.isJoined)return NO;

    NSString* uqID=[self juingNewId];

    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];

    @autoreleasepool {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:content];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message" ];
        [message addAttributeWithName:@"uqID" stringValue:uqID];
        
        //拼写xml格式的xmpp消息
        if(!isGroup){
            //消息发送者
            [message addAttributeWithName:@"type" stringValue:@"chat"];
            [message addAttributeWithName:@"from" stringValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]];
            //消息接受者
            [message addAttributeWithName:@"to" stringValue:messageId];
            
            [message addChild:body];
            NSXMLNode* subject = [NSXMLNode elementWithName:@"subject" stringValue:@"voice"];//告诉接受方 传送的是文件 还是 聊天内容
            [message addChild:subject];
        }
        else{
            //消息发送者
            [message addAttributeWithName:@"type" stringValue:@"groupchat"];
            [message addAttributeWithName:@"from" stringValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare]];
            //消息接受者
            [message addAttributeWithName:@"to" stringValue:[[room roomJID] full]];
            [message addChild:body];
            NSXMLNode* subject = [NSXMLNode elementWithName:@"subject" stringValue:@"voice"];//告诉接受方 传送的是文件 还是 聊天内容
            [message addChild:subject];
        }
        //发送消息
        [appDelegate.xmpp.xmppStream sendElement:message];
    }

    
    @autoreleasepool {
        //新建消息的entity
        
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MessageEntity" inManagedObjectContext:appDelegate.xmpp.managedObjectContext];
        
        [newManagedObject setValue:uqID forKey:@"uqID"];
        [newManagedObject setValue:[urlVoiceFile absoluteString] forKey:@"content"];
        [newManagedObject setValue:@"voice" forKey:@"type"];
        [newManagedObject setValue:[NSDate date] forKey:@"sendDate"];
        [newManagedObject setValue:messageId forKey:@"messageId"];
        [newManagedObject setValue:messageId forKey:@"receiveUser"];
        [newManagedObject setValue:[[[[ShareAppDelegate xmpp]xmppStream] myJID]bare] forKey:@"sendUser"];
        
        
        [appDelegate.xmpp newRectangleMessage:messageId name:name content:content contentType:RectangleChatContentTypeVoice isGroup:isGroup createrJid:nil];
        
        [appDelegate.xmpp saveContext];
    }
    
    return YES;
}

-(BOOL)isInFaviorContacts:(NSString*)chatWithUser{
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userJid == \"%@\"",chatWithUser]];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FaviorUserInfo"];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedPersonArray = [appDelegate.xmpp.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return ([fetchedPersonArray count]>0);
}

-(void)addFaviorInContacts:(NSString*)chatWithUser{

    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];

    UserInfo* userInfo=[appDelegate.xmpp fetchUserFromJid:chatWithUser];
    
    NSManagedObject *newManagedObject=[NSEntityDescription insertNewObjectForEntityForName:@"FaviorUserInfo" inManagedObjectContext:appDelegate.xmpp.managedObjectContext];
    
    [newManagedObject setValue:userInfo.userGroup forKey:@"userGroup"];
    [newManagedObject setValue:userInfo.userName forKey:@"userName"];
    [newManagedObject setValue:userInfo.userJid forKey:@"userJid"];
    [newManagedObject setValue:userInfo.userSubscription forKey:@"userSubscription"];
    [newManagedObject setValue:userInfo.userSex forKey:@"userSex"];
    [newManagedObject setValue:userInfo.userStatue forKey:@"userStatue"];
    
    [appDelegate.xmpp saveContext];
}

-(void)removeFaviorInContacts:(NSString*)chatWithUser{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FaviorUserInfo"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userJid == \"%@\"",chatWithUser]];
    NSError *error=nil;
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext* context=[appDelegate xmpp].managedObjectContext;
    NSArray *fetchResult=[context executeFetchRequest:fetchRequest error:&error];
    if(!error){
        for(id obj in fetchResult){
            [context deleteObject:obj];
        }
    }
    [appDelegate.xmpp saveContext];

}


-(BOOL)uploadImageToServer:(UIImage*)image finish:(void (^)(NSString* id,NSString* path))finish{
    //[request cancel];
    
     NSString* token=[[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    NSURL *requestURL = [NSURL URLWithString:[kFileUploadUrl stringByAppendingFormat:@"?sessionKey=%@&&appKey=%@",token,kAPPKey]];
  
    FormDataRequest* request = [FormDataRequest requestWithURL:requestURL];
    __block FormDataRequest* __request=request;
    request.delegate = self;
    @autoreleasepool {
        NSData *imageData = UIImagePNGRepresentation(image);

        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:0];
        [dict setObject:imageData forKey:@"file"];
        [request setUserInfo:dict];
        
        [request setData:imageData forKey:@"file"];
        dict=nil;
        imageData=nil;
    }

    [request setCompletionBlock:^{
        
        
        NSString *resultStr = [__request responseString];
        NSData *imageData = [[__request userInfo] valueForKey:@"file"];
        NSDictionary *dict = [resultStr objectFromJSONString];
        NSString *fileId = [dict valueForKey:@"id"];
        NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"sendFiles"];
        NSFileManager *manager = [NSFileManager defaultManager];
        if(![manager fileExistsAtPath:path]){
            [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        path = [[path stringByAppendingPathComponent:fileId] stringByAppendingString:@".png"];
        
        [imageData writeToFile:path atomically:YES];
                
        if(finish!=nil)
            finish(fileId,path);
        [__request cancel];
    }];
    
    [request setFailedBlock:^{
        if(finish!=nil)
            finish(nil,nil);
        [__request cancel];
    }];
    
    [request startAsynchronous];
        
    return YES;
}

@end
