//
//  iphoneLandingViewController.m
//  Cube-iOS
//
//  Created by Mr.幸 on 12-12-21.
//
//


#import "iphoneLandingViewController.h"
#import "CubeApplication.h"
#import "CubeModule.h"
#import "UIViewController+SEViewController.h"
#import "CubeWebViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SwitchButton.h"
#import "iphoneVoiceDetailViewController.h"
#import "MessagesViewController.h"
#import "MoreIconButton.h"
#import "SVProgressHUD.h"
#import "UIColor+expanded.h"
#import "JSONKit.h"
#import "MessageRecord.h"
#import "XMPPSqlManager.h"

#import "SettingMainViewController.h"
#import "NSMutableDictionary+SortedAllkeys.h"

#define kCUBEAUDIO_Notification @"Notification_AUDIO"
#define kCUBEMESSAGE_Notification @"Notification_MESSAGE"
#define kCUBEEBOOK_Notification @"Notification_EBOOK"

#define BACKGROUND_RGBA 0xf6f6f6
#define L_ROW_COUNT 5
#define L_COL_COUNT 4

#define P_ROW_COUNT 3
#define P_COL_COUNT 3

#define APP_COUNT_IN_ONE_PAGE 9

#define P_DOWNLOAD_VIEW_FRAME -364, 184, 640, 568
#define L_DOWNLOAD_VIEW_FRAME 192, 56, 640, 568

#define P_DOWNLOAD_VIEW_FRAME_H -64, -568, 640, 568
#define L_DOWNLOAD_VIEW_FRAME_H 192, -568, 640, 568

#define DOWNLOAD_VIEW_MOVE_SPEED 0.4

#define ICON_H 108//90//108
#define ICON_W 85//70//85

#define BEGIN_H_GAP 8
#define BEGIN_V_GAP 8
#define H_GAP 108//78//108 //95+85
#define V_GAP 128//106//128 //95+108

#import "IphoneLadingViewNewCell.h"

@interface iphoneLandingViewController (){
    MoreIconButton* moreIconButton;
    int localItemCount;
    BOOL disappear;
}

@end

@implementation iphoneLandingViewController
@synthesize itemCounts,isInEditingMode;
@synthesize currentIconDic = _currentIconDic;
@synthesize rowCount,colCount;
@synthesize myCellConfig;
@synthesize downloadViewController;

#pragma mark - Custom Methods


#pragma mark - MenuItem Delegate Methods
- (void)launch:(int)index identifier:(NSString *)identifier{
    
    for(NSArray *array in [_currentIconDic allValues]){
        
        for(IconButton *button in array){
            [button.actionButton setUserInteractionEnabled:NO];
        }
    }
    
    self.searchBar.text=nil;
    self.curFliterStr=nil;
    // if the springboard is in editing mode, do not launch any view controller
    if (isInEditingMode)
        return;
    
    CubeApplication *app = [CubeApplication currentApplication];
    CubeModule *module = [app moduleForIdentifier:identifier];
    
    if(module.local){
        NSString* iphoneLocal;
        if ([module.local isEqualToString:@"DetailViewController"]) {
            iphoneLocal = @"iphoneVoiceMasterViewController";
        }else{
            iphoneLocal = module.local;
        }
        UIViewController *localController = (UIViewController *)[[NSClassFromString(iphoneLocal) alloc] init];
        
        //        [self.view addSubview:localController.view];
        
        [self.navigationController.navigationBar setHidden:NO ];
        [self.navigationController pushViewController:localController animated:YES];
        
        
        return;
    }
    
    NSDictionary *missingModules = [module missingDependencies];
    NSArray *needInstall = [missingModules objectForKey:kMissingDependencyNeedInstallKey];
    NSArray *needUpgrade = [missingModules objectForKey:kMissingDependencyNeedUpgradeKey];
    
    if ([needInstall count] > 0 || [needUpgrade count] > 0) {
        NSMutableString *message = [[NSMutableString alloc] init];
        
        if([needInstall count] > 0){
        
            [message appendString:@"需要安装以下模块:\n"];
            for (__strong NSString *dependency in needInstall) {
                CubeModule *m = [[CubeApplication currentApplication] availableModuleForIdentifier:dependency];
                if (m) dependency = m.name;
                [message appendFormat:@"%@\n", dependency];
            }
        
        }
        
        if( [needUpgrade count] > 0){
            
            [message appendString:@"需要升级以下模块:\n"];
            for (__strong NSString *dependency in needUpgrade) {
                CubeModule *m = [[CubeApplication currentApplication] moduleForIdentifier:dependency];
                if (m) dependency = m.name;
                [message appendFormat:@"%@\n", dependency];
            }
        
        }
        
        self.selectedModule = identifier;
        UIAlertView *dependsAlert = [[UIAlertView alloc] initWithTitle:@"缺少依赖模块"
                                                               message:message
                                                              delegate:self
                                                     cancelButtonTitle:@"确定" otherButtonTitles:/*@"安装", */nil];
        [dependsAlert show];
        return;
    }
    
    //植入界面

     __weak CubeWebViewController *aCubeWebViewController  = [[CubeWebViewController alloc] init];
    
    aCubeWebViewController.title=module.name;
    
    [aCubeWebViewController loadWebPageWithModule:module didFinishBlock: ^(){
        
        NSLog(@"finish loading");
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:aCubeWebViewController animated:YES];
       
        
    }didErrorBlock:^(){
        
        NSLog(@"error loading");
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"模块加载失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        for(NSArray *array in [_currentIconDic allValues]){
            
            for(IconButton *button in array){
                [button.actionButton setUserInteractionEnabled:YES];
            }
        }
//        [aCubeWebViewController release];
    }];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //重新激活按钮
    for(NSArray *array in [_currentIconDic allValues]){
        for(IconButton *button in array){
            [button.actionButton setUserInteractionEnabled:YES];
        }
    }
    //退出登录alert
    if(alertView.tag == 1){
        if(buttonIndex == 0){
            [self logout];
        }
    }
    
    if (buttonIndex==0) {
        CubeModule *module = [[CubeApplication currentApplication] moduleForIdentifier:self.selectedModule];
        //需要下载的模块
        NSArray *missingModules = [[module missingDependencies] objectForKey:kMissingDependencyNeedInstallKey];
        for (NSString *missingModule in missingModules) {
            CubeModule *am = [[CubeApplication currentApplication] availableModuleForIdentifier:missingModule];
            am.isDownloading = YES;
            [[CubeApplication currentApplication] installModule:am];
        }
        
        //需要升级的模块
        NSArray *needUpgradeModules = [[module missingDependencies] objectForKey:kMissingDependencyNeedUpgradeKey];
        for (NSString *needUpgradeModule in needUpgradeModules) {
            CubeModule *am = [[CubeApplication currentApplication] updatableModuleModuleForIdentifier:needUpgradeModule];
            am.isDownloading = YES;
            [[CubeApplication currentApplication] installModule:am];
        }
        
        [self fliterTheDataSources:nil];
    }else if (alertView.tag == 5){
        //删除模块
        if (buttonIndex==0) {
            [UIView animateWithDuration:0.3 animations:^{
                [self deleteAtModuleIdentifier:deleteModuleIdentifier];
            } completion:^(BOOL finished){}];
        }
    
    }
}

// transition animation function required for the springboard look & feel
- (CGAffineTransform)offscreenQuadrantTransformForView:(UIView *)theView {
    CGPoint parentMidpoint = CGPointMake(CGRectGetMidX(theView.superview.bounds), CGRectGetMidY(theView.superview.bounds));
    CGFloat xSign = (theView.center.x < parentMidpoint.x) ? -1.f : 1.f;
    CGFloat ySign = (theView.center.y < parentMidpoint.y) ? -1.f : 1.f;
    return CGAffineTransformMakeTranslation(xSign * parentMidpoint.x, ySign * parentMidpoint.y);
}

-(void)removeEnuseableModuleFromSpringboard:(NSString *)identifier index:(int)index{

        CubeApplication *cubeApp = [CubeApplication currentApplication];
        
        CubeModule *m = [cubeApp moduleForIdentifier:identifier];
        [cubeApp uninstallModule:m didFinishBlock:^(){
            [self fliterTheDataSources:nil];
        }];
}

-(void)appsync{

    //有应用下载,禁止刷新,否则会崩溃
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    for(CubeModule *each in cubeApp.availableModules){
        
        if(each.isDownloading)
            return;
    }
    
    for(CubeModule *each in cubeApp.updatableModules){
        if(each.isDownloading)
            return;
    }
    
    [cubeApp sync];
    
    
      
    //xmpp重连
    if(![((AppDelegate *)[UIApplication sharedApplication].delegate).xmpp isConnected]){
        
        [((AppDelegate *)[UIApplication sharedApplication].delegate).xmpp connect];
    }
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)sender {
//    CGFloat pageWidth = _itemsContainer.frame.size.width;
//    int page = floor((_itemsContainer.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    _pageControl.currentPage = page;
    UIScrollView *tempScrollView=(UIScrollView*)sender;
    
    
    //去掉headerView粘性
    if (tempScrollView == self.itemsTableContainer)
    {
        CGFloat sectionHeaderHeight = kHeaderViewHeight; //sectionHeaderHeight
        if (tempScrollView.contentOffset.y<=sectionHeaderHeight&&tempScrollView.contentOffset.y>=0) {
            tempScrollView.contentInset = UIEdgeInsetsMake(-tempScrollView.contentOffset.y, 0, 0, 0);
        } else if (tempScrollView.contentOffset.y>=sectionHeaderHeight) {
            tempScrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView* backgroundView ;
    if (iPhone5) {
        backgroundView =[[UIImageView alloc]initWithFrame:CGRectMake(0,0, 320, 1136/2)];
    }else{
        backgroundView =[[UIImageView alloc]initWithFrame:self.view.frame];
    }
    backgroundView.image = [UIImage imageNamed:@"homebackImg.png"];
    [self.view addSubview:backgroundView];
    
    desktopIconEnable=TRUE;
    
    self.view.userInteractionEnabled = YES;
    self.title= [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    self.currentIconDic = [NSMutableDictionary dictionary];
    
    disappear = NO;
    // Do any additional setup after loading the view from its nib.
    
    [self appsync];
    
    //覆盖屏蔽右边控制
    UIButton *navRightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 43, 30)];
    //navRightButton.style = UIBarButtonItemStyleBordered;
    
    [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn.png"] forState:UIControlStateNormal];
    
    [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn_active.png"] forState:UIControlStateSelected];
    
    [navRightButton setTitle:@"管理" forState:UIControlStateNormal];
    
    [[navRightButton titleLabel] setFont:[UIFont systemFontOfSize:13]];
    
    [navRightButton addTarget:self action:@selector(activateDownloadSrceen) forControlEvents:UIControlEventTouchUpInside];
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    
    
    //
    
        
    
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        self.rowCount = P_ROW_COUNT;
        self.colCount = P_COL_COUNT;
    }else{
        self.rowCount = L_ROW_COUNT;
        self.colCount = L_COL_COUNT;
    }
    localItemCount = 0;
    
    self.pageControl.hidden=TRUE;
//    [self initPageControl];
    
    //添加双击事件
    UITapGestureRecognizer* doubelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap)];
    doubelTap.numberOfTapsRequired = 2;
    doubelTap.numberOfTouchesRequired = 1;
    
    //屏蔽双击
//    [self.itemsContainer addGestureRecognizer:doubelTap];
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [self.navigationController.navigationBar setHidden:NO];
    if(!self.curDic){
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        self.curDic = dic;
    }
    

    [self fliterTheDataSources:nil];
    UIButton *navLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 43, 30)];
    //navRightButton.style = UIBarButtonItemStyleBordered;
    
    
    //ios5.1.1下面backContentView离奇被移出self.view
    if(!self.backContentView.superview){
        [self.view addSubview:self.backContentView];
    }

    
    [MessageRecord createModuleBadge:@"com.foss.chat" num: [XMPPSqlManager getMessageCount]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"module_badgeCount_change" object:self];
    
    [navLeftButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn_setting@2x.png"] forState:UIControlStateNormal];
    
    [navLeftButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn_active_setting@2x.png"] forState:UIControlStateSelected];
    
    [[navLeftButton titleLabel] setFont:[UIFont systemFontOfSize:13]];
    
    [navLeftButton addTarget:self action:@selector(goSettingView) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    

    //监听同步成功通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fliterTheDataSources:) name:CubeSyncFinishedNotification object:nil];
    //监听安装失败
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FailMuduleInstall:) name:CubeModuleInstallDidFailNotification object:nil];
    //监听下载失败消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FailMuduleInstall:) name:CubeModuleDownloadDidFailNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(alertMessage:) name:kCUBEAUDIO_Notification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(alertMessage:) name:kCUBEMESSAGE_Notification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(alertMessage:) name:kCUBEEBOOK_Notification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeDisappear) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeDisappear) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissDeleteProgess) name:@"DiamissDeleteProgess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteModuleFail) name:@"DeleteModuleFail" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_itemsContainer removeFromSuperview];
    [_itemsTableContainer removeFromSuperview];
    [_backContentView removeFromSuperview];
    
    self.backContentView = nil;
    self.itemsContainer = nil;
    self.itemsTableContainer = nil;
    self.currentIconDic = nil;
    [super viewWillDisappear:animated];
}

-(void)goSettingView{
    SettingMainViewController *settingView = [[SettingMainViewController alloc]initWithNibName:@"SettingMainViewController" bundle:nil];
    settingView.delegate = self;
    [self.navigationController pushViewController:settingView animated:YES];
}

-(void)ExitLogin{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"退出登录" message:@"是否确认退出登录?" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
    alert.tag = 1;
    [alert show];
}

-(void)logout{
    [(AppDelegate *)[UIApplication sharedApplication].delegate showLoginView];
}

-(void)deleteModuleFail{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DETIALPAGE_DELETEFAILED object:nil];
    [SVProgressHUD showErrorWithStatus:@"删除失败"];
    sleep(1);
    [SVProgressHUD dismiss];
    [self appsync];
//    self.view.userInteractionEnabled = YES;
}

-(void)dismissDeleteProgess{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DETIALPAGE_DELETESUCCESS object:nil];
    [SVProgressHUD dismiss];
//    self.view.userInteractionEnabled = YES;
}


- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

//初始化布局
-(void)initPatch
{
    self.searchBarView = nil;
    
    UIView *aview = [[UIView alloc]initWithFrame:kContentView];
    self.backContentView= aview;
    UIScrollView *asview = [[UIScrollView alloc]initWithFrame:kContentView];
    self.itemsContainer=asview;
    
    self.itemsContainer.delegate=self;
    
    UITableView *atview = [[UITableView alloc]initWithFrame:kContentView style:UITableViewStyleGrouped];
    self.itemsTableContainer= atview;
    
    self.itemsTableContainer.delegate=self;
    self.itemsTableContainer.dataSource=self;
    self.itemsTableContainer.delegate=self;
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    backgroundView.backgroundColor = [UIColor colorWithRGBHex:BACKGROUND_RGBA];
    [self.itemsTableContainer setBackgroundView:backgroundView];
    if(desktopIconEnable){
        [self.backContentView addSubview:_itemsContainer];
    }else{
        [self.backContentView addSubview:_itemsTableContainer];
        self.itemsTableContainer.tableHeaderView = nil;  //不知为啥,要先设成nil再设view才可以成功显示
            }
    [self.view addSubview:_backContentView];
    
}



//初始化pageControl
-(void)initPageControl{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger number = [defaults integerForKey:@"PageControl"];
    
    if (number == 0) {
        _pageControl.numberOfPages = 1;
    }else{
        _pageControl.numberOfPages = number;
    }
}

-(void)FailMuduleInstall:(NSNotification *) notification{
    
    CubeModule *failModule = (CubeModule *)notification.object;
    
    [self fliterTheDataSources:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@安装失败",[failModule name]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alert show];
    
    
}

-(void)activateDownloadSrceen{

    //同步一下  
    self.searchBar.text=nil;
    self.curFliterStr=nil;
    
    DownloadingViewController *aDownloadViewController= [[DownloadingViewController alloc] initWithNibName:@"IphoneDownloadingViewController" bundle:nil];
    aDownloadViewController.delegate = self;
    [self.navigationController pushViewController:aDownloadViewController animated:YES];
    self.downloadViewController = aDownloadViewController;
}

- (void)exitDownloadScreen{
    
    //退出下载页面
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        [UIView animateWithDuration:DOWNLOAD_VIEW_MOVE_SPEED animations:^{
            [downloadViewController.view setFrame:CGRectMake(P_DOWNLOAD_VIEW_FRAME_H)];
        } completion:^(BOOL finished) {
            
            [downloadViewController.view removeFromSuperview];
            
            downloadViewController = nil;
            
//            self.MaskView.hidden = YES;
        }];
        
    }
    else
    {
        [UIView animateWithDuration:DOWNLOAD_VIEW_MOVE_SPEED animations:^{
            [downloadViewController.view setFrame:CGRectMake(L_DOWNLOAD_VIEW_FRAME_H)];
        } completion:^(BOOL finished) {
            
            [downloadViewController.view removeFromSuperview];
            
            downloadViewController = nil;
            
//            self.MaskView.hidden = YES;
        }];
    }
    
}

//配置列表视图数据源和刷新界面
-(void)tableListPatch
{
    [self.itemsTableContainer reloadData];
}


//更换视图
-(void)changeViewSight:(id)sender
{
    
    
    //覆盖屏蔽右边控制
    UIButton *navRightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 43, 30)];
    //navRightButton.style = UIBarButtonItemStyleBordered;
    
    [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn.png"] forState:UIControlStateNormal];
    
    [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn_active.png"] forState:UIControlStateSelected];
    
    [navRightButton setTitle:@"管理" forState:UIControlStateNormal];
    
    [[navRightButton titleLabel] setFont:[UIFont systemFontOfSize:13]];
    
    [navRightButton addTarget:self action:@selector(activateDownloadSrceen) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    
    desktopIconEnable=!desktopIconEnable;
    
    [self fliterTheDataSources:self.curFliterStr];
    
	// disable user interaction during the flip
    self.backContentView.userInteractionEnabled = NO;
    //	flipIndicatorButton.userInteractionEnabled = NO;
	
	// setup the animation group
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    
	// swap the views and transition
    if (!desktopIconEnable) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.backContentView cache:YES];
        
        [self.backContentView addSubview:_itemsTableContainer];
        self.itemsTableContainer.tableHeaderView = nil;  //不知为啥,要先设成nil再设view才可以成功显示
       
        [_itemsContainer removeFromSuperview];
		
    } else {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.backContentView cache:YES];
        [self.backContentView addSubview:_itemsContainer];
         [_itemsTableContainer removeFromSuperview];
		// update the reflection image for the new view
    }
	[UIView commitAnimations];
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    
	[UIView commitAnimations];
    self.backContentView.userInteractionEnabled = YES;
   

}
//画出宫格试图
-(void)drawPageNewVersion:(NSMutableDictionary *)items
{
    int sectionNum=[items count];
    int rowNum=0;
    for (int i=0;i<[items count];i++)
    {
        NSMutableArray *tempArr=[items objectForKey:[[items sortedAllkeysBaseModuleEnd] objectAtIndex:i] ];
        rowNum+=(ceil((float)([tempArr count])/ KCOLUMNCOUNT));
    }
    NSLog(@"total %d section, %d row",sectionNum,rowNum);
    
    self.itemsContainer.contentSize=CGSizeMake(320, ORGIN_V_GAP+sectionNum*(kHeaderGap+kHeaderViewHeight)+rowNum*(kButtonHeight+BETWEEN_V_GAP)+40+5);
    [self.itemsContainer setScrollEnabled:YES];
    self.itemsContainer.showsHorizontalScrollIndicator = NO;
    
    //[self.itemsContainer insertSubview:backgroundView aboveSubview:self.searchBar];
    int horgap = ORGIN_H_GAP;
    int vergap = kSearchCombineBar.size.height+5;
    int startTag=0;
    
    for (int i=0;i<[items count];i++)
    {
        horgap=ORGIN_H_GAP;
        NSMutableArray *tempArr=[items objectForKey:[[items sortedAllkeysBaseModuleEnd] objectAtIndex:i] ];
        
        if([tempArr count] == 0)
            continue;
        
        //网格视图 header样式设置
        UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, vergap,320,kHeaderViewHeight)];
        UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 2.5, 80, 20)];
        titleLabel.font=[UIFont systemFontOfSize:12];
        titleLabel.textColor=[UIColor colorWithRGBHex:0x8b8b8b];
        titleLabel.minimumFontSize=13;
        titleLabel.adjustsFontSizeToFitWidth=TRUE;
        titleLabel.backgroundColor=[UIColor clearColor];
        [headerView addSubview:titleLabel];
        titleLabel.text=[NSString stringWithFormat:@"%@",[[_currentIconDic sortedAllkeysBaseModuleEnd] objectAtIndex:i]];
        
        UIImageView *backgroundView = [[UIImageView alloc] init];
        [self.itemsContainer addSubview:backgroundView];
        [headerView addSubview:titleLabel];
        
        vergap+=kHeaderViewHeight+kHeaderGap;
        int segmentOriginX = vergap;
        CGFloat segmentBackgroundHeight = kButtonHeight;
        [self.itemsContainer addSubview:headerView];
        int counter = 0;
        for (int itemNum=0;itemNum<[tempArr count];itemNum++) {
            IconButton *item=[tempArr objectAtIndex:itemNum];
            item.tag = startTag;
            [item defaultSet];
            [item setFrame:CGRectMake(horgap,vergap, kButtonWidth, kButtonHeight)];
            
            [item transformWithWidth:kButtonWidth andHeight:kButtonHeight];
            [self.itemsContainer addSubview:item];
            //加上addBadge
            [item addBadge];
            
            horgap = horgap + kButtonWidth + BETWEEN_H_GAP;
            counter = counter + 1;
            startTag++;
            
            if(counter %KCOLUMNCOUNT == 1 && counter != 1){
                segmentBackgroundHeight = segmentBackgroundHeight + item.frame.size.height + BETWEEN_V_GAP;
            }
            if(counter % KCOLUMNCOUNT == 0){
                vergap = vergap + BETWEEN_V_GAP + kButtonHeight;
                horgap = ORGIN_H_GAP;
            }
            //针对最后一项的换行做判断
            if (itemNum==([tempArr count]-1)&&!(counter % KCOLUMNCOUNT == 0)) {
                vergap = vergap + BETWEEN_V_GAP + kButtonHeight;
                horgap = ORGIN_H_GAP;
                
            }
            
            if (isInEditingMode) {
                [item enableEditing];
            }
        }
        CGRect backgroundViewFrame = CGRectMake(10, segmentOriginX, 320-20, segmentBackgroundHeight);
        backgroundView.frame = backgroundViewFrame;
        backgroundView.backgroundColor =[UIColor whiteColor];
        [backgroundView.layer setMasksToBounds:YES];
        [backgroundView.layer setCornerRadius:6];
        
        backgroundView.layer.borderWidth =0.5 ;
        backgroundView.layer.borderColor = [[UIColor colorWithRGBHex:0xcacaca] CGColor];
        
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//根据标识删除deskTop上的图标
- (void)deleteAtModuleIdentifier:(NSString *)identifier
{
    
    [self removeEnuseableModuleFromSpringboard:identifier index:0];
}

- (void)downloadAtModuleIdentifier:(NSString *)identifier  andCategory:(NSString *)category{
    
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    
    CubeModule *module = [cubeApp updatableModuleModuleForIdentifier:identifier];
    
    if(module){
        NSArray *iconArray = [self.currentIconDic objectForKey:category];
        for(IconButton *each in iconArray){
            NSLog(@"identifier : %@",each.identifier);
            if([each.identifier isEqualToString:identifier]){
                each.category=module.category;
                 //先更新一下图片
                [each.iconImageView loadImageWithURLString:module.iconUrl];
                break;
            }
        }
        
    }else{
        //添加
        
        module = [cubeApp availableModuleForIdentifier:identifier];
        
        IconButton *newButton = [[IconButton alloc] initWithModule:module stauts:IconButtonStautsDownloading delegate:self];
        
        newButton.category=module.category;
        
        [[_currentIconDic objectForKey:module.category] addObject:newButton];
    }
    
    [self drawWithDataSource:_currentIconDic];
    
    //    //先画出来再替换 否则会重复加载 调了好久 fuck
    //       [self drawPageNewVersion:currentIconArray];
    
    self.currentIconDic = _currentIconDic;
    

}

- (void)dealloc {
    
    NSLog(@"dealloc: %@", self);
}

//设置和保存moreIconButton坐标
-(void)setAndSaveMoreButtonData:(CGRect)buttonRect{
    [moreIconButton setFrame:buttonRect];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:buttonRect.origin.x forKey:@"ButtonX"];
    [defaults setFloat:buttonRect.origin.y forKey:@"ButtonY"];

}

//设置和保存pagecontrol个数
-(void)setAndSavePageControl:(NSInteger)number{
    _pageControl.numberOfPages = number;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:number forKey:@"PageControl"];
}


-(void)alertMessage:(NSNotification*)note{
    NSString* alertMessage = nil;
    Class class = nil;
    
    if ([[note name] isEqualToString:kCUBEMESSAGE_Notification]) {
        alertMessage = @"文本信息";
        class = [MessagesViewController class];
    }else if([[note name] isEqualToString:kCUBEAUDIO_Notification]){
        alertMessage = @"语音信息";
        class = [iphoneVoiceDetailViewController class];
    }else if([[note name] isEqualToString:kCUBEEBOOK_Notification]){
        alertMessage = @"文档文件";
    }
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
        if ([[self.navigationController.childViewControllers objectAtIndex:[self.navigationController.childViewControllers count]-1] class] != class && !disappear) {
            UIAlertView* messageAlerView = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"您有新的%@，请注意查收！",alertMessage] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [messageAlerView show];
        }
	}
	else
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"知道了";
        localNotification.alertBody = [NSString stringWithFormat:@"您有新的%@，请注意查收！",alertMessage];
		localNotification.soundName = UILocalNotificationDefaultSoundName;
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
    
}

-(void)changeDisappear{
    disappear = !disappear;
}

#pragma mark datasource
-(void)fliterTheDataSources:(NSString*)aFliterStr
{
    if(!self.backContentView){
        [self initPatch];
    }
    
    [SearchDataSource filterTheDataSources:aFliterStr forDelegate:self];

}

-(NSMutableArray *)modulesToFilt{
    
    NSMutableArray *array = [[CubeApplication currentApplication] modules];
    
    NSMutableArray *filtArray = [NSMutableArray array];
    
    NSMutableArray *updatableArray = [[CubeApplication currentApplication] updatableModules];
    
    for(CubeModule *each in array){
        [filtArray addObject:each];
        for(CubeModule *u in updatableArray){
            
            if([u.identifier isEqualToString:each.identifier] &&  u.isDownloading){
                
                [filtArray addObject:u];
                
                [filtArray removeObject:each];
            }
            
        }
    }
    
    NSMutableArray *availableArray = [[CubeApplication currentApplication] availableModules];
    
    for(CubeModule *each in availableArray){
    
        if(each.isDownloading){
            
            [filtArray addObject:each];
        
        }
            
    }
    
    return filtArray;
}


#pragma mark - Custom Methods

- (void) disableEditingMode {
    // loop thu all the items of the board and disable each's editing mode
    self.isInEditingMode = NO;
    
    if (desktopIconEnable) {
        NSMutableArray * itemsArray =  [[NSMutableArray alloc]init];
        NSArray *keys = [_currentIconDic sortedAllkeysBaseModuleEnd];
        for(NSString *key in keys){
            NSArray *iconArray = [self.currentIconDic objectForKey:key];
            for(IconButton *each in iconArray){
                [itemsArray addObject:each];
            }
        }
        
        for (IconButton *each in itemsArray) {
            [each disableEditing];
        }
        
    }

}

-(void)enableEditingMode{
    if (desktopIconEnable) {
        NSMutableArray * itemsArray =  [[NSMutableArray alloc]init];
        NSArray *keys = [_currentIconDic sortedAllkeysBaseModuleEnd];
        for(NSString *key in keys){
            NSArray *iconArray = [self.currentIconDic objectForKey:key];
            for(IconButton *each in iconArray){
                [itemsArray addObject:each];
            }
        }
        self.isInEditingMode = YES;
        
        for (IconButton *each in itemsArray) {
            [each enableEditing];
        }

        [self.navigationItem setRightBarButtonItem:
                                            [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                    target:self action:@selector(DoneEditing)]  animated:YES] ;
    }
   
}

-(void)DoneEditing {
    [self disableEditingMode];
    
    //覆盖屏蔽右边控制
    UIButton *navRightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 43, 30)];
    //navRightButton.style = UIBarButtonItemStyleBordered;
    
    [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn.png"] forState:UIControlStateNormal];
    
    [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn_active.png"] forState:UIControlStateSelected];
    
    [navRightButton setTitle:@"管理" forState:UIControlStateNormal];
    
    [[navRightButton titleLabel] setFont:[UIFont systemFontOfSize:13]];
    
    [navRightButton addTarget:self action:@selector(activateDownloadSrceen) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
}





//视图数据源配置
-(void)drawWithDataSource:(NSMutableDictionary*)tempDic
{
    NSMutableDictionary *dicSource = [[NSMutableDictionary alloc] init];
    
    NSArray *keys = [tempDic sortedAllkeysBaseModuleEnd];
    
    for(NSString *eachKey in keys){
        
        NSMutableArray *eachArraySource = [[NSMutableArray alloc] init];
    
        NSArray *array = [tempDic objectForKey:eachKey];
        
        for(IconButton *eachIcon in array){
        
            if(!eachIcon.hidden){
            
                [eachArraySource addObject:eachIcon];
            }
        }
        
        [dicSource setValue:eachArraySource forKey:eachKey];
        
    }
    
    //删除旧界面布局
    if([[_itemsContainer subviews] count]!=0&&desktopIconEnable){
        for(UIView *each in [_itemsContainer subviews]){
            [each removeFromSuperview];
        }
    }
    if(desktopIconEnable){
     }else{
        [self.itemsTableContainer reloadData];
    }
    if(dicSource != nil && [dicSource count] > 0){
        self.currentIconDic=dicSource;
        if (desktopIconEnable) {
            [self drawPageNewVersion:dicSource];
        }else{
            [self tableListPatch];
        }
    }
    

}

-(void)saveCurrentIconDic:(NSMutableDictionary *)iconDic{
    self.currentIconDic = iconDic;
}

- (void)clickItemWithIndex:(int)aIndex andIdentifier:(NSString*)aStr
{
    [self launch:aIndex identifier:aStr];
}

#pragma mark -- UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [super searchBarShouldBeginEditing:searchBar];
    self.itemsTableContainer.scrollEnabled = NO;
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [super searchBarShouldEndEditing:searchBar];
    self.itemsTableContainer.scrollEnabled = YES;
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%@",searchText);
    self.curFliterStr=searchText;
    [self fliterTheDataSources:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *) searchBar
{
    //[self fliterTheDataSources:nil];
    [searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.itemsTableContainer.frame=([[[CubeApplication currentApplication] modules] count]==0)?CGRectZero:kContentView;
    if ([[[CubeApplication currentApplication] modules] count]>0) {
        return [[_currentIconDic sortedAllkeysBaseModuleEnd] count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *key=[[_currentIconDic sortedAllkeysBaseModuleEnd] objectAtIndex:section];
    return [[_currentIconDic objectForKey:key] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeaderViewHeight+20;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, kHeaderViewHeight+10)];
    
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, 80, 40)];
    titleLabel.font=[UIFont systemFontOfSize:12];
    titleLabel.textColor=[UIColor grayColor];
    titleLabel.minimumFontSize=8;
    titleLabel.adjustsFontSizeToFitWidth=TRUE;
    titleLabel.backgroundColor=[UIColor clearColor];
    //titleLabel.alignmentRectInsets
    [headerView addSubview:titleLabel];
    
    titleLabel.text=[NSString stringWithFormat:@"%@",[[_currentIconDic sortedAllkeysBaseModuleEnd] objectAtIndex:section]];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"IphoneDownloadingTableViewCell";
    
    IphoneDownloadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[IphoneDownloadingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.delegate=self;
    
    NSString *key=[[_currentIconDic sortedAllkeysBaseModuleEnd] objectAtIndex:indexPath.section];
    CubeModule *tempModule=[[CubeApplication currentApplication] moduleForIdentifier:[[[_currentIconDic objectForKey:key] objectAtIndex:indexPath.row] identifier]];
    //为空的话就从下载队列去取值
    if (!tempModule) {
         tempModule=[[CubeApplication currentApplication] availableModuleForIdentifier:[[[_currentIconDic objectForKey:key] objectAtIndex:indexPath.row] identifier]];
    }
    [cell configWithModule:tempModule andConfig:EDELETE];
    cell.downloadButton.hidden=TRUE;
    cell.nameLabel.hidden =NO;
    cell.versionLabel.hidden= YES;
    cell.infoLabel.hidden = YES;
    cell.releasenoteLabel.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key=[[_currentIconDic sortedAllkeysBaseModuleEnd] objectAtIndex:indexPath.section];
    [self launch:0 identifier:[[[_currentIconDic objectForKey:key] objectAtIndex:indexPath.row] identifier]];
}

@end
