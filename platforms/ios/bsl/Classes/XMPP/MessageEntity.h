//
//  MessageEntity.h
//  iPhoneXMPP
//
//  Created by 俞 億 on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MessageEntity : NSManagedObject

@property(nonatomic,strong) NSString* uqID;
@property(nonatomic,strong) NSString* messageId;
@property (nonatomic, strong) NSString * sendUser;
@property(nonatomic,strong) NSString* receiveUser;

@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSNumber * flag_sended;
@property (nonatomic, strong) NSDate   * sendDate;
@property (nonatomic, strong) NSNumber * flag_readed;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * statue;
@property (nonatomic, strong) NSString * fileId;

//fanty 
@property(nonatomic,strong) NSDate* receiveDate;

-(NSString*)name;

@end
