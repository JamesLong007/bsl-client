//
//  GroupMemberManagerViewController.h
//  cube-ios
//
//  Created by 肖昶 on 13-9-18.
//
//

#import <UIKit/UIKit.h>

@class GroupPanel;
@class NSManagedObjectContext;
@class NSFetchedResultsController;

@class GroupMemberManagerViewController;
@class ASIHTTPRequest;

@protocol GroupMemberManagerViewControllerDelegate <NSObject>

-(void)updateMemberName:(GroupMemberManagerViewController*)controller memberName:(NSString*)memberName;

-(void)deleteMember:(GroupMemberManagerViewController*)controller;
@end

@interface GroupMemberManagerViewController : UIViewController{
    UITableView* tableView;
    GroupPanel* groupPanel;
    UIButton* quitButton;
    NSMutableArray* list;
    
    UIPopoverController *popover;

    ASIHTTPRequest* request;
    
    
    
    BOOL  isMyGroup;
    
//btn_red
}
@property(nonatomic,weak) id<GroupMemberManagerViewControllerDelegate> delegate;
@property (strong,nonatomic) NSString* messageId;
@property(strong,nonatomic) NSString* chatName;
@property(nonatomic,assign) BOOL isGroupChat;
@property(nonatomic,assign) BOOL isQuit;

@end
