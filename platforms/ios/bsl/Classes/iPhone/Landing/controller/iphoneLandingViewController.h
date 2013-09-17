//
//  iphoneLandingViewController.h
//  Cube-iOS
//
//  Created by Mr.幸 on 12-12-21.
//
//

#define kSearchCombineBar CGRectMake(0,0,320,40)
#define kSearchBarHideFrame CGRectMake(0,-40,320,40)

//retina 3.5 
#define kContentView_retina3_5 CGRectMake(0,0,320,416)
#define kInnerContentView_retina3_5 CGRectMake(0,0,320,376)
#define kContentViewStrechFrame_retina3_5 CGRectMake(0,0,320,416)
#define kInnerContentStrechFrame_retina3_5 CGRectMake(0,0,320,416)

//retina 4 support iphone5
#define kContentView_retina4 CGRectMake(0,0,320,416+88)
#define kInnerContentView_retina4 CGRectMake(0,0,320,376+88)
#define kContentViewStrechFrame_retina4 CGRectMake(0,0,320,416+88)
#define kInnerContentStrechFrame_retina4 CGRectMake(0,0,320,416+88)


#define kContentView (iPhone5? kContentView_retina4:kContentView_retina3_5)
#define kInnerContentView (iPhone5? kInnerContentView_retina4:kInnerContentView_retina3_5)
#define kContentViewStrechFrame (iPhone5? kContentViewStrechFrame_retina4:kContentViewStrechFrame_retina3_5)
#define kInnerContentStrechFrame (iPhone5? kInnerContentStrechFrame_retina4:kInnerContentStrechFrame_retina3_5)    


#import <UIKit/UIKit.h>
#import "IconButton.h"
#import "MenuView.h"
#import "DownloadingViewController.h"
#import "BaseViewController.h"
#import "SearchDataSource.h"
#import "AppDelegate.h"
#import "CubeWebViewController.h"
#import "SettingMainViewController.h"


@interface iphoneLandingViewController : BaseViewController<UIScrollViewDelegate,DownloadTableDelegate,IconButtonDelegate,UITableViewDataSource,UITableViewDelegate,DownloadCellDelegate,UIAlertViewDelegate,SettingMainViewControllerDelegate>
{
    BOOL desktopIconEnable;     //TRUE: 桌面视图模式 FALSE:  列表视图模式
    NSString * deleteModuleIdentifier;
    CubeWebViewController *cubeWebViewController;
}
@property (strong, nonatomic) NSMutableDictionary *currentIconDic;
@property (strong, nonatomic) UIScrollView *itemsContainer;
@property (strong, nonatomic) UITableView* itemsTableContainer;
@property (strong, nonatomic) UIView *backContentView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *itemCounts;
@property (strong, nonatomic) UIView *searchBarView;
@property (strong, nonatomic) NSMutableDictionary *curDic;  //当前数据源
@property (strong, nonatomic) NSString *curFliterStr;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) DownloadingViewController *downloadViewController;
@property BOOL isInEditingMode;
@property int colCount;
@property int rowCount;

@property(copy, nonatomic)NSString *selectedModule;



-(void)appsync;

@end

