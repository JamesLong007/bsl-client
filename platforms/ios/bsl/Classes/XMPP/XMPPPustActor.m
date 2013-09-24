//
//  XMPPPustActor.m
//  cube-ios
//
//  Created by 东 on 13-3-23.
//
//

#import "XMPPPustActor.h"
#import "UIDevice+IdentifierAddition.h"
#import "MessageRecord.h"
#import "HTTPRequest.h"

@implementation XMPPPustActor
@synthesize xmppStream;

-(void)setXmppStream{
    if (!xmppStream) {
        xmppStream = [[XMPPStream alloc] init];
        [xmppStream addDelegate:self delegateQueue:dispatch_get_current_queue()];
        #if !TARGET_IPHONE_SIMULATOR
        {
            xmppStream.enableBackgroundingOnSocket = YES;
        }
        #endif

    }
        // Setup roster
    
    if (!xmppReconnect) {
        xmppReconnect = [[XMPPReconnect alloc] init];
        [xmppReconnect activate:xmppStream];
        
    }
      [self connect];
    [xmppReconnect setAutoReconnect:YES];
}

-(void)teardownStream{
    [xmppStream removeDelegate:self];
    [xmppReconnect         deactivate];
    [xmppStream disconnect];
    
    xmppStream = nil;
	xmppReconnect = nil;
}

-(void)disConnect{
    if ([xmppStream isConnected]) {
        [self goOffline];
        [xmppStream disconnect];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPSTREAMPUSHOFFLINE" object:nil];
    }
}

-(BOOL)connect{
    if ([xmppStream isConnected])
    {
		return YES;
	}
    
    NSString *uniqueDeviceIdentifier = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    NSLog(@"DeviceUUID=[%@]",uniqueDeviceIdentifier);
    
    passWord= [NSString stringWithFormat:@"%@",uniqueDeviceIdentifier];
    NSString *userId=[NSString stringWithFormat:@"%@",uniqueDeviceIdentifier];
    userId = [userId stringByAppendingFormat:@"@%@",kXMPPPushDomin];
    
    [xmppStream setMyJID:[XMPPJID jidWithString:userId resource:@"Cube_Client"]];
    
    [xmppStream setHostName:kXMPPPushHost];
	[xmppStream setHostPort:kXMPPPushPort];
    
    if (userId == nil || passWord == nil)
    {
        return NO;
        NSLog(@"xmppSever userName or pwd is nil");
    }
    
    
	NSError *error = nil;
    
	if (![xmppStream connect:&error])
	{
		return NO;
	}
    return YES;
}




-(void)dealloc{
    [self teardownStream];
}




- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = @"localhost";
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    
    passWord = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] uniqueDeviceIdentifier]];
	isXmppConnected = YES;
    NSError *error=nil;
    if (![[self xmppStream] authenticateWithPassword:passWord error:&error])
    {
        [self connect];
    }
}


- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    
    NSLog(@"认证通过");
	[self goOnline];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPSTREAMPUSHONLINE" object:nil];
    [self doRegisterPushService];
    
}

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}


- (void)doRegisterPushService{
    
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    [json setObject:[NSString stringWithFormat:@"%@@%@",[[UIDevice currentDevice] uniqueDeviceIdentifier],kXMPPPushDomin] forKey:@"tokenId"];
    
    [json setObject:kAPPName forKey:@"applicationId"];
    
    [json setObject:@"Openfire" forKey:@"deviceChannel"];
    
    [json setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"deviceId"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONReadingMutableContainers error:nil];
    
    HTTPRequest *request = [HTTPRequest requestWithURL:[NSURL URLWithString:kPushServerRegisterUrl]];
    
    [request appendPostData:jsonData];
    
    [request setRequestMethod:@"POST"];
    
    [request startAsynchronous];
    

}


- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    //如果是由cube_dmin发送过来的则是推送的消息
    if([[message fromStr] hasPrefix:[NSString stringWithFormat:@"%@@%@",kXMPPPusher,kXMPPPushDomin]]){
        [MessageRecord createByJSON:[[message elementForName:@"body"] stringValue]];
        return;
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    passWord = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] uniqueDeviceIdentifier]];
    if (![[self xmppStream] registerWithPassword:passWord error:nil])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"网络繁忙,设备注册失败,请稍后再试"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }
    NSLog(@"认证不通过,错误信息为:%@",error);
    
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    passWord = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] uniqueDeviceIdentifier]];
    NSError *error=nil;
    if (![[self xmppStream] authenticateWithPassword:passWord error:&error])
    {
        [self connect];
    }
    NSLog(@"创建账号成功");
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    NSLog(@"创建账号失败");
}


@end
