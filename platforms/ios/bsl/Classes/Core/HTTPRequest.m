//
//  HTTPRequest.m
//  PetNews
//
//  Created by fanty on 13-8-26.
//  Copyright (c) 2013年 fanty. All rights reserved.
//

#import "HTTPRequest.h"

#define HTTP_TIMEOUT   15.0f

@implementation HTTPRequest

-(id)init{
    self=[super init];
    
    if(self){
        [self setTimeOutSeconds:HTTP_TIMEOUT];
        self.persistentConnectionTimeoutSeconds=HTTP_TIMEOUT;
    }
    
    
    return  self;
}

-(void)dealloc{
    NSLog(@"it is dealloc");
}

-(void)cancel{
    [self setCompletionBlock:nil];
    [self setFailedBlock:nil];
    [super cancel];
}

@end


@implementation FormDataRequest

- (id)init{
    self = [super init];
    if (self) {
        [self setTimeOutSeconds:HTTP_TIMEOUT];
        self.persistentConnectionTimeoutSeconds=HTTP_TIMEOUT;
    }
    return self;
}

-(void)dealloc{
    NSLog(@"it is dealloc");
}

-(void)cancel{
    [self setCompletionBlock:nil];
    [self setFailedBlock:nil];
    [super cancel];
}


@end
