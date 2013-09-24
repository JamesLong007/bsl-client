//
//  FriendMainViewController.h
//  cube-ios
//
//  Created by apple2310 on 13-9-12.
//
//

#import <UIKit/UIKit.h>

@class HeadTabView;
@class RecentTalkView;
@class ContactListView;
@class FaviorContactView;
@class CustomNavigationBar;
@class NumberView;
@interface FriendMainViewController : UIViewController{
    HeadTabView* tabView;
    
    RecentTalkView* recentTalkView;
    ContactListView* contactListView;
    FaviorContactView* faviorContactView;
    UIPopoverController *popover;

    UIButton* fliterBg;

    NumberView* numberView;
    NSFetchedResultsController* fetchedResultsController;
}


@end
