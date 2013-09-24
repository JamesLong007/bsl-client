//
//  ServerAPI.m
//  Cube-iOS
//
//  Created by Justin Yip on 2/2/13.
//
//

#import "ServerAPI.h"
#import "Config.h"
#import "stdlib.h"

@implementation ServerAPI

+(NSString*)urlForAttachmentId:(NSString*)aid {
    return [kServerURLString stringByAppendingFormat:@"/mam/api/mam/clients/files/%@/", aid];
}

+(NSString*)urlForAppUpdate {
    return [kServerURLString stringByAppendingFormat:@"/mam/api/mam/clients/update/ios/%@/?ts=%f", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], [NSDate timeIntervalSinceReferenceDate]];
}

+(NSString*)urlForLogin {
    return kServerLoginURLString;
}

+(NSString*)urlforUserSync{
    return [kServerURLString stringByAppendingFormat:@"/mam/api/mam/clients/modules/%@/?ts=%f",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], [NSDate timeIntervalSinceReferenceDate]];
}

+(NSString*)urlForSync {
    return [kServerURLString stringByAppendingFormat:@"/mam/api/mam/clients/ios/%@/%@/", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
}

+(NSString*)urlForlogout:(NSString* )sessionKey{
     return [kServerURLString stringByAppendingFormat:@"/system/api/system/mobile/accounts/logout/%@", sessionKey];
}

+(NSString*)urlForAppApnsCheckin{
//    return [kServerLoginURLString stringByAppendingString:@"/push-ws/service/checkinservice/checkins"];
    return @"http://10.108.1.49:9090/push-ws/service/checkinservice/checkins";
}

@end

NSURL* ServerAPI2(NSString *path, ...) {
    NSURL *serverURL = [NSURL URLWithString:kServerURLString];
    return [NSURL URLWithString:path relativeToURL:serverURL];
}