//
//  IMServerAPI.m
//  cube-ios
//
//  Created by dong on 13-9-17.
//
//

#import "IMServerAPI.h"
#import "AFAppDotNetAPIClient.h"
#import "JSONKit.h"
#import "HTTPRequest.h"

@implementation IMServerAPI

#pragma mark --收藏好友

+(void)collectIMFriend:(UserInfo*)user myJid:(NSString*)_myJid block:(void (^)(BOOL statue))_block{
    NSString* urlStr = @"";
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:user.userJid forKey:@"jid"];
    [parameters setValue:user.userName forKey:@"username"];
    [parameters setValue:user.userSex forKey:@"sex"];
    [parameters setValue:user.userStatue forKey:@"statue"];
    [parameters setValue:_myJid forKey:@"userId"];
    [[AFAppDotNetAPIClient sharedClient]getPath:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _block(true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _block(false);
    }];
}

+(void)updateCollectIMFriendStatue:(UserInfo*)user block:(void (^)(BOOL statue))_block{
    NSString* urlStr = @"";
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:user.userStatue forKey:@"statue"];
    [parameters setValue:user.userJid forKey:@"jid"];
    [[AFAppDotNetAPIClient sharedClient]getPath:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _block(true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _block(false);
    }];
}


+(void)getCollectIMFriends:(NSString*)myUserId block:(void (^)(BOOL statue,NSArray* friends))_block{
    NSString* urlStr = @"";
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:myUserId forKey:@"userId"];
    [[AFAppDotNetAPIClient sharedClient]getPath:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* friends = responseObject;
        _block(true,friends);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _block(false,nil);
    }];
}


+(void)deleteCollectIMFriend:(NSString*)myUserId deleteUser:(UserInfo*)_delUserInfo block:(void (^)(BOOL statue))_block{
    NSString* urlStr = @"";
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:myUserId forKey:@"userId"];
    [parameters setValue:_delUserInfo.userJid forKey:@"jid"];
    [[AFAppDotNetAPIClient sharedClient]getPath:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _block(true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _block(false);
    }];
}


#pragma mark --  群聊功能

+(void)grouptAddMember:(UserInfo *)userInfo roomId:(NSString *)_roomId block:(void (^)(BOOL))_block{
    
    NSString* urlStr =[NSString stringWithFormat:@"http://%@/chat/addMember",kXMPPGroupHost];
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:_roomId forKey:@"roomId"];
    [parameters setValue:userInfo.userJid forKey:@"jid"];
    
    [parameters setValue:userInfo.userName forKey:@"username"];
    [parameters setValue:userInfo.userSex forKey:@"sex"];
    [parameters setValue:userInfo.userStatue forKey:@"statue"];
    
    [[AFAppDotNetAPIClient sharedClient]getPath:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _block(true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _block(false);
    }];
}


+(void)grouptUpdateStatue:(UserInfo *)userInfo block:(void (^)(BOOL))_block{
    NSString* urlStr =[NSString stringWithFormat:@"http://%@/chat/updateStatue",kXMPPGroupHost];

    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:userInfo.userStatue forKey:@"statue"];
    [parameters setValue:userInfo.userJid forKey:@"jid"];
    [[AFAppDotNetAPIClient sharedClient]getPath:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _block(true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _block(false);
    }];
}

+(FormDataRequest*)grouptAddMembers:(NSArray *)userInfoArray roomId:(NSString *)_roomId roomName:(NSString *)_roomName addSelf:(BOOL)addSelf block:(void (^)(BOOL))_block{
    
    NSString* urlStr =[NSString stringWithFormat:@"http://%@/chat/addMembers",kXMPPGroupHost];

    NSMutableArray* userArray = [[NSMutableArray alloc]init];
    @autoreleasepool {
        
        if(addSelf){
            NSString* myJid=[[[ShareAppDelegate xmpp].xmppStream myJID] bare];
            NSString* name=myJid;
            
            int index=[name rangeOfString:@"@"].location;
            name= [name substringToIndex:index];

            NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setValue:[[[ShareAppDelegate xmpp].xmppStream myJID] bare] forKey:@"jid"];
            [dictionary setValue:_roomId forKey:@"roomId"];
            [dictionary setValue:@"" forKey:@"sex"];
            [dictionary setValue:name forKey:@"username"];
            [dictionary setValue:@"在线" forKey:@"statue"];
            [dictionary setValue:_roomName forKey:@"roomName"];
            [userArray addObject:dictionary];

        }
        
        
        for (UserInfo* userInfo in userInfoArray) {
            NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setValue:userInfo.userJid forKey:@"jid"];
            [dictionary setValue:_roomId forKey:@"roomId"];
            [dictionary setValue:userInfo.userSex forKey:@"sex"];
            [dictionary setValue:[userInfo name] forKey:@"username"];
            [dictionary setValue:userInfo.userStatue forKey:@"statue"];
            [dictionary setValue:_roomName forKey:@"roomName"];
            [userArray addObject:dictionary];
        }
    }
//    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]init];
 //   [parameters setValue:[userArray JSONString] forKey:@"members"];
    
    FormDataRequest* request=[FormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    __block FormDataRequest* __request=request;
    [request setPostValue:[userArray JSONString] forKey:@"members"];

    userArray=nil;
    
    [request setCompletionBlock:^{
        _block(true);
        [__request cancel];
    }];
    
    [request setFailedBlock:^{
        NSLog(@"error:%@",[__request error]);
        _block(false);
        [__request cancel];

    }];
    
    
    [request startAsynchronous];
    
    /*
    [[AFAppDotNetAPIClient sharedClient]putPath:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _block(true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _block(false);
    }];
    */
   // parameters=nil;
    
    return request;
}


+(HTTPRequest*)grouptGetMembers:(NSString *)_roomId block:(void (^)(BOOL, NSArray *))_block{
    NSString* urlStr =[NSString stringWithFormat:@"http://%@/chat/query/%@",kXMPPGroupHost,_roomId];
    
    HTTPRequest* request=[HTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
    __block HTTPRequest* __request=request;
    
    [request setCompletionBlock:^{
        NSArray *dict = [NSJSONSerialization JSONObjectWithData:[__request responseData] options:NSJSONReadingMutableContainers error:nil];
        _block(YES,dict);
        [__request cancel];
    }];
    
    [request setFailedBlock:^{
        NSLog(@"error:%@",[__request error]);
        _block(NO,nil);
        [__request cancel];
        
    }];
    
    
    [request startAsynchronous];

    
    /*
    [[AFAppDotNetAPIClient sharedClient]getPath:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _block(true,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _block(false,nil);
    }];

     */
    
    return request;
}


+(HTTPRequest*)grouptGetRooms:(NSString *)userJid block:(void (^)(BOOL, NSArray *))_block{
    NSString* urlStr =[NSString stringWithFormat:@"http://%@/chat/queryAllRoom/%@",kXMPPGroupHost,userJid];

    HTTPRequest* request=[HTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
    __block HTTPRequest* __request=request;
    
    [request setCompletionBlock:^{
        NSArray *dict = [NSJSONSerialization JSONObjectWithData:[__request responseData] options:NSJSONReadingMutableContainers error:nil];
        _block(YES,dict);
        [__request cancel];
    }];
    
    [request setFailedBlock:^{
        NSLog(@"error:%@",[__request error]);
        _block(NO,nil);
        [__request cancel];
        
    }];
    
    [request startAsynchronous];
    /*
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:userJid forKey:@"jid"];
    [[AFAppDotNetAPIClient sharedClient]getPath:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _block(true,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _block(false,nil);
    }];
     */
    
    return request;
}


+(HTTPRequest*)grouptDeleteMember:(NSString *)userJid roomId:(NSString *)_roomId block:(void (^)(BOOL))_block{
    NSString* urlStr =[NSString stringWithFormat:@"http://%@/chat/deleteMember/%@/%@",kXMPPGroupHost,_roomId,userJid];
    
    HTTPRequest* request=[HTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
    __block HTTPRequest* __request=request;
    
    [request setCompletionBlock:^{
        _block(YES);
        [__request cancel];
    }];
    
    [request setFailedBlock:^{
        NSLog(@"error:%@",[__request error]);
        _block(NO);
        [__request cancel];
        
    }];
    
    [request startAsynchronous];

    
    /*
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:userinfo.userJid forKey:@"jid"];
    [parameters setValue:_roomId forKey:@"roomId"];
    [[AFAppDotNetAPIClient sharedClient]getPath:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _block(true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _block(false);
    }];
     */
    
    return request;
}

+(void)grouptDeleteMembers:(NSArray *)userInfoArray roomId:(NSString *)_roomId block:(void (^)(BOOL))_block{
    
    NSString* urlStr = @"/chat/updateStatue";
    NSMutableArray* userArray = [[NSMutableArray alloc]init];
    @autoreleasepool {
        for (UserInfo* userInfo in userInfoArray) {
            NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setValue:userInfo forKey:@"jid"];
            [dictionary setValue:userInfo forKey:@"roomId"];
            [userArray addObject:dictionary];
        }
    }
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:[userArray JSONString] forKey:@"members"];
    [[AFAppDotNetAPIClient sharedClient]getPath:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _block(true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _block(false);
    }];
}

+(HTTPRequest*)grouptDeleteRoom:(NSString *)_roomId block:(void (^)(BOOL))_block{

    NSString* urlStr =[NSString stringWithFormat:@"http://%@/chat/deleteRoom/%@",kXMPPGroupHost,_roomId];
    
    HTTPRequest* request=[HTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
    __block HTTPRequest* __request=request;
    
    [request setCompletionBlock:^{
        _block(YES);
        [__request cancel];
    }];
    
    [request setFailedBlock:^{
        NSLog(@"error:%@",[__request error]);
        _block(NO);
        [__request cancel];
        
    }];
    
    [request startAsynchronous];

    /*
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:_roomId forKey:@"roomId"];
    [[AFAppDotNetAPIClient sharedClient]getPath:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _block(true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _block(false);
    }];
     */
    
    return request;
}

+(FormDataRequest*)grouptChangeRoomName:(NSString *)_roomName roomId:(NSString *)_roomId block:(void (^)(BOOL))_block{
    NSString* urlStr =[NSString stringWithFormat:@"http://%@/chat/roommember/roomname",kXMPPGroupHost];
    
    FormDataRequest* request=[FormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    __block FormDataRequest* __request=request;
    
    [request setPostValue:_roomId forKey:@"roomId"];
    [request setPostValue:_roomName forKey:@"roomName"];

    [request setCompletionBlock:^{
        _block(YES);
        [__request cancel];
    }];
    
    [request setFailedBlock:^{
        NSLog(@"error:%@",[__request error]);
        _block(NO);
        [__request cancel];
        
    }];
    
    [request startAsynchronous];
    /*
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:_roomName forKey:@"roomName"];
    [parameters setValue:_roomId forKey:@"roomId"];
    [[AFAppDotNetAPIClient sharedClient]getPath:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _block(true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _block(false);
    }];
     */
    
    return request;
}


@end
