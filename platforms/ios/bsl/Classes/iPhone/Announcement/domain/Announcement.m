//
//  Announcement.m
//  Cube-iOS
//
//  Created by chen shaomou on 2/5/13.
//
//

#import "Announcement.h"
#import "ConfigManager.h"
#import "HTTPRequest.h"
#import "NSObject+propertyList.h"
#import "NSManagedObject+Repository.h"


@implementation Announcement

@dynamic title;

@dynamic content;

/**
 * 公告状态
 * 0: 未生效
 * 1：已生效
 * 2：已过期
 * 3：已失效
 */
@dynamic state;

@dynamic activeTime;

@dynamic invalidTime;

/**
 * 重要级别
 * 0: 一般
 * 1: 重要
 * 2: 紧急
 */
@dynamic level;

@dynamic attachment;

@dynamic applicationId;

@dynamic announcementId;

@dynamic createdAt;

@dynamic modifiedAt;

@dynamic isRead;

@dynamic reviceTime;
@dynamic recordId;

+(void)requestAnnouncement:(NSString *)announcementId{
    
    HTTPRequest *request = [HTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kRequestAnnouncementUrl,announcementId]]];
    __block HTTPRequest*  __request=request;
    [request setRequestMethod:@"GET"];
    
    [request setCompletionBlock:^{
        
        NSData *data = [__request responseData];
        
       // NSString *reponseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            return;
        }
        
        Announcement *announcement = [Announcement insert];
        
        NSArray *propertyList = [announcement getPropertyList];
        
        for(NSString *each in propertyList){
            
            if([dict objectForKey:each])
                [announcement setValue:[dict objectForKey:each] forKey:each];
        }
        
        //id 要另外设定
        [announcement setAnnouncementId:[dict objectForKey:@"id"]];
        
        [announcement setIsRead:0];
        
        [announcement setReviceTime:[NSDate date]];
        
        [announcement save];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ANNOUNCEMENT_DID_SAVE_NOTIFICATION object:nil];
        
        
    }];
    
    [request setFailedBlock:^{
        NSLog(@"cat not get announcement");
    }];
    
    [request startAsynchronous];
    
}

+(void)requestAnnouncement:(NSString *)announcementId withRecordId:(NSString*)recordId
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kRequestAnnouncementUrl,announcementId]]];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* token = [userDefaults objectForKey:@"token"];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"sessionKey" value:token];
    
    [request setCompletionBlock:^{
        
        NSData *data = [request responseData];
        
       // NSString *reponseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if(error) {
            return;
        }
        
        Announcement *announcement = [Announcement insert];
        
        NSArray *propertyList = [announcement getPropertyList];
        
        for(NSString *each in propertyList){
            
            if([dict objectForKey:each] && ![[dict objectForKey:each] isEqual:[NSNull null]] ){
                if (![each isEqualToString:@"level"]) {
                     [announcement setValue:[dict objectForKey:each] forKey:each];
                }
               
            }
        }
        /*
        NSString *content = announcement.content;
        content = [content stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
        content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        content = [content stringByReplacingOccurrencesOfString:@"]" withString:@"/]"];
        content = [content stringByReplacingOccurrencesOfString:@"[" withString:@"/["];
        content = [content stringByReplacingOccurrencesOfString:@"%" withString:@"/%"];
        content = [content stringByReplacingOccurrencesOfString:@"&" withString:@"/&"];
        content = [content stringByReplacingOccurrencesOfString:@")" withString:@"/)"];
        content = [content stringByReplacingOccurrencesOfString:@"(" withString:@"/("];
        content = [content stringByReplacingOccurrencesOfString:@"_" withString:@"/_"];
         */
        [announcement setRecordId:recordId];
        //id 要另外设定
        [announcement setAnnouncementId:[dict objectForKey:@"id"]];
        
        [announcement setIsRead:0];
        
        [announcement setReviceTime:[NSDate date]];
        
        [announcement save];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ANNOUNCEMENT_DID_SAVE_NOTIFICATION object:nil];
        
        
    }];
    
    [request setFailedBlock:^{
        NSLog(@"cat not get announcement");
    }];
    
    [request startAsynchronous];
    
}



+(NSArray *)findAllOrderByReviceTime{
    
    NSArray *array = [Announcement findAll];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"reviceTime" ascending:NO];
    
    return [array sortedArrayUsingDescriptors:@[sort]];
    
}


@end
