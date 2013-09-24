//
//  ChatMainViewController.h
//  WeChat
//
//  Created by apple2310 on 13-9-5.
//  Copyright (c) 2013年 apple2310. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChatPanel;
@class TouchTableView;
@class RecordingView;
@class Recorder;
@class ChatLogic;



/*!
 @abstract:chat main page viewcontroller
 */
@interface ChatMainViewController : UIViewController{
    TouchTableView* tableView;
    ChatPanel* chatPanel;

    ChatLogic* chatLogic;
    NSMutableArray*  messageArray;
    
    NSFetchedResultsController *fetchController;
    RecordingView* recordingView;
    Recorder* recorder;
    int playingIndex;
    UIPopoverController *popover;
    
    NSDictionary* emoctionList;

}

@property (strong,nonatomic) NSString* messageId;
@property(strong,nonatomic) NSString* chatName;
@property(nonatomic,assign) BOOL isGroupChat;
@property(nonatomic,assign) BOOL isQuit;

@end
