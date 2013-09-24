//
//  ContactSelectedForGroupViewController.h
//  cube-ios
//
//  Created by 肖昶 on 13-9-15.
//
//

#import <UIKit/UIKit.h>
@class ImageUploaded;
@class TouchTableView;
@class CustomNavigationBar;
@class ContactSelectedForGroupViewController;
@class FormDataRequest;

@protocol ContactSelectedForGroupViewControllerDelegate <NSObject>

-(void)dismiss:(ContactSelectedForGroupViewController*)controller selectedInfo:(NSArray*)selectedInfo;

@end

@interface ContactSelectedForGroupViewController : UIViewController{
    NSArray *sortedKeys;
    NSDictionary* showDicts;
    

    UINavigationBar* bar;
    TouchTableView* tableView;
    ImageUploaded* imageUploaded;
    UIButton* fliterBg;

    UISearchBar* searchBar;
    NSMutableArray* selectedUserInfos;
    
    NSTimer* timeOutTimer;
    
    FormDataRequest* request;
    
    float maxHeight;
}
@property(nonatomic,weak) id<ContactSelectedForGroupViewControllerDelegate> delegate;
@property(nonatomic,strong) NSString* tempNewjid;
@property(nonatomic,strong) NSDictionary* dicts;
@property(nonatomic,strong) NSString* groupName;
@property(nonatomic,strong) NSString*  existsGroupJid;

@end
