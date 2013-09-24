/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.h
//  cube-ios
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>

#import "XMPPIMActor.h"

#import "UpdateChecker.h"

#import "DownQueueActor.h"

@class DDMenuController;
@class XMPPIMActor;
@class XMPPPustActor;

@interface AppDelegate : NSObject
// invoke string is passed to your app on launch, this is only valid if you
// edit cube-ios-Info.plist to add a protocol
// a simple tutorial can be found here :
// http://iphonedevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html

@property (nonatomic, strong) IBOutlet UIWindow* window;
@property(nonatomic, strong) UIViewController* mainViewController;
@property(nonatomic,strong) UINavigationController* navControl;
//@property (nonatomic, strong) IBOutlet CDVViewController* viewController;


@property (nonatomic,strong)XMPPPustActor *xmppPustActor;
@property (nonatomic,strong)XMPPIMActor *xmpp;

@property (nonatomic,strong)DownQueueActor *downQueueActor;
//记录各个模块消息收到的时间
@property (nonatomic,strong) NSMutableDictionary *moduleReceiveMsg;

@property(nonatomic,strong) UpdateChecker *uc;


-(void)didLogin;
-(void)showLoginView;
-(void)showExit;
-(void)ativatePushSound;
@end
