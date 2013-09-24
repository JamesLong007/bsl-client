//
//  MainViewViewController.m
//  cube-ios
//
//  Created by 东 on 6/4/13.
//
//

#import "MainViewViewController.h"
#import "CubeWebViewController.h"
#import "NSFileManager+Extra.h"
#import "SettingMainViewController.h"
#import "DownLoadingDetialViewController.h"
#import "MessageRecord.h"
#import "JSONKit.h"
#import "NSFileManager+Extra.h"
#import "ServerAPI.h"
#import "OperateLog.h"
#import "AutoShowRecord.h"
#import "FMDBManager.h"
#import "FMDatabaseQueue.h"
#import "HTTPRequest.h"

#define SHOW_DETAILVIEW  @"SHOW_DETAILVIEW"  //展示模块


@interface MainViewViewController (){
    BOOL isFirst;
}
@property(nonatomic,weak)UIViewController *presentingViewController;
@property (nonatomic,strong)  UIViewController * detailController;
@property (nonatomic,strong)  UIViewController * mainController;
@property (nonatomic,strong)  UIView* detailView;
@property (strong, nonatomic) NSString *selectedModule;

@end

@implementation MainViewViewController

@synthesize mainController;
@synthesize detailController;
@synthesize presentingViewController;
@synthesize detailView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil finish:(DidFinishWebViewViewBlock)didFinishBlock{
    self.finishWebViewBlock = didFinishBlock ;
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
    
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.presentedViewController viewWillDisappear:NO];
        [self.presentedViewController.view removeFromSuperview];
        [self.presentedViewController viewDidDisappear:NO];
        
        if (!skinView) {
            //读取文件信息
            @autoreleasepool {
                NSURL* documentUrl =  [NSFileManager applicationDocumentsDirectory];
                NSURL* fileUrl = [documentUrl URLByAppendingPathComponent:@"www/pad/theme/theme.json"];
                NSData* data = [[NSData alloc]initWithContentsOfURL:fileUrl];
                
                NSArray *arr = ( NSArray *)[data   mutableObjectFromJSONData ];
                skinView = [[SkinView alloc]initWithActivityItems:arr];
                skinView.delegate = self;                
            }
        }
        
        aCubeWebViewController  = [[CubeWebViewController alloc] init];
        //aCubeWebViewController.title=module.name;
        //加载本地的登录界面页
        //设置启动页面
        aCubeWebViewController.title=@"登录";
        aCubeWebViewController.wwwFolderName = @"www";
        aCubeWebViewController.startPage =   [[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"pad/main.html"] absoluteString];
        aCubeWebViewController.view.frame = self.view.frame;
        aCubeWebViewController.webView.scrollView.bounces=NO;
        [aCubeWebViewController loadWebPageWithUrl: [[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"pad/main.html"] absoluteString] didFinishBlock: ^(){
            [presentingViewController viewWillDisappear:NO];
            [presentingViewController.view removeFromSuperview];
            [presentingViewController viewDidDisappear:NO];
            
            [aCubeWebViewController viewWillAppear:NO];
            [self.view addSubview:aCubeWebViewController.view];
            [aCubeWebViewController viewDidAppear:NO];
            self.presentingViewController = aCubeWebViewController;
            [self addBadge];
            if (self.finishWebViewBlock) {
                self.finishWebViewBlock();
                self.finishWebViewBlock = nil;
            }
        }didErrorBlock:^(){
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"模块加载失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }];
        isFullScrean = NO;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad{
    [super viewDidLoad];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showView:) name:SHOW_DETAILVIEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSetting) name:@"SHOW_SETTING_VIEW" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBadge) name:@"module_badgeCount_change" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moduleDidInstalled:) name:CubeModuleInstallDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSkinView) name:@"SHOW_SETTHEME_VIEW" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissView:) name:@"DISMISS_VIEW" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBadge) name:@"MESSAGE_RECORD_DID_Change_NOTIFICATION" object:nil];
    //收到消息时候的广播
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBadge) name:MESSAGE_RECORD_DID_SAVE_NOTIFICATION object:nil];
    //收到好友消息时候
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moduleSysFinsh) name:CubeSyncFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moduleSysFinsh) name:CubeSyncFailedNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    aCubeWebViewController=nil;
    self.detailController=nil;
    self.mainController=self;
    self.detailView=nil;
    self.selectedModule=nil;
    fullScreanBtn=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}



- (void)dealloc{
    [skinView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.mainController=self;
    
}


-(void)moduleSysFinsh{
    [self checkModules];
    if (!isFirst) {
        [self autoShowModule];
        isFirst = true;
    }
}


-(void)checkModules{
    //检测是否需要自动安装
    
    NSMutableArray *downloadArray = [[CubeApplication currentApplication] availableModules];
    if(downloadArray && downloadArray.count>0)
    {
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendString:@"检测到有以下模块需要下载:\n"];
        for(CubeModule *module in downloadArray)
        {
            [message appendFormat:@"%@\n", module.name];
        }
        UIAlertView *alertView  =[[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"立即下载" otherButtonTitles:@"取消",nil];
        alertView.tag =830;
        [alertView show];
        return;
    }
    else
    {
        [self checkAutoUpdate];
    }
    
}

-(void)checkAutoUpdate{
    NSMutableArray *updateModules = [[CubeApplication currentApplication] updatableModules];
    NSMutableString *message = [[NSMutableString alloc] init];
    if(updateModules.count>0)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [message appendString:@"以下模块可以更新:\n"];
        for(CubeModule *module in updateModules)
        {
            [message appendFormat:@"%@\n", module.name];
        }
        //        [defaults setBool:NO forKey:@"firstTime"];
        if(![defaults boolForKey:@"firstTime"])
        {
            [defaults setBool:YES forKey:@"firstTime"];
            UIAlertView *alertView  =[[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
            alertView.tag =829;
            [alertView show];
        }
        
    }
}

//异步判断哪个模块打开
-(void)autoShowModule
{
    NSString *userName = [[NSUserDefaults standardUserDefaults]valueForKey:@"username"];
    NSMutableArray * modulesArray = [[CubeApplication currentApplication]modules];
    for (CubeModule *module in modulesArray) {
        if([module moduleIsInstalled])
        {
            if(module.isAutoShow && module.privileges )
            {
                //建表保存用户，模块名 弹出时间，判断时间间隔内不再弹出模块
                if(![[FMDBManager getInstance].database tableExists:@"AutoShowRecord"])
                {
                    AutoShowRecord *record = [[AutoShowRecord alloc]init];
                    [[FMDBManager getInstance]createTable:@"AutoShowRecord" withObject:record];
                }
                
                if(![[FMDBManager getInstance]recordIsExist:@"identifier" withtableName:@"AutoShowRecord" withConditios:userName])
                {
                    [self showWebViewModue:module];
                    AutoShowRecord *newRecord = [[AutoShowRecord alloc]init];
                    newRecord.identifier = module.identifier;
                    newRecord.userName = userName;
                    long time = [[NSDate date]timeIntervalSince1970];
                    newRecord.showTime = [NSString stringWithFormat:@"%ld",time];
                    [[FMDBManager getInstance]insertToTable:newRecord withTableName:@"AutoShowRecord" andOtherDB:nil];
                    
                    break;
                }
                else
                {
                    NSString *sql = [NSString stringWithFormat:@"select * from AutoShowRecord where identifier='%@' and userName='%@'",module.identifier,userName];
                    FMResultSet *result = [[[FMDBManager getInstance] database] executeQuery:sql];
                    while([result next])
                    {
                        NSString * showTimeTmp = [result objectForColumnName:@"showTime"];
                        long showTime = [showTimeTmp longLongValue];
                        
                        if([module.timeUnit isEqualToString:@"H"])
                        {
                            long currentTime = [[NSDate date]timeIntervalSince1970];
                            if((currentTime-showTime)>module.showIntervalTime*60*60)
                            {
                                [self showWebViewModue:module];
                                //更新表
                                [self updateAuthoShowTime:module.identifier];
                                return;
                            }
                            
                        }
                        else if([module.timeUnit isEqualToString:@"M"])
                        {
                            long currentTime = [[NSDate date]timeIntervalSince1970];
                            if((currentTime-showTime)>module.showIntervalTime*60)
                            {
                                [self showWebViewModue:module];
                                //更新表
                                [self updateAuthoShowTime:module.identifier];
                                return;
                            }
                            
                        }
                        else if([module.timeUnit isEqualToString:@"S"])
                        {
                            
                            long currentTime = [[NSDate date]timeIntervalSince1970];
                            //                            NSLog(@"%ld------%ld-------%ld",currentTime,showTime,(currentTime-showTime));
                            if((currentTime-showTime)>module.showIntervalTime)
                            {
                                [self showWebViewModue:module];
                                //更新表
                                [self updateAuthoShowTime:module.identifier];
                                return;
                            }
                            
                        }
                        
                    }
                }
                
            }
        }
    }
    
    
}

-(void)updateAuthoShowTime:(NSString*)identifier
{
    
    long currentTime = [[NSDate date]timeIntervalSince1970];
    NSString *userName = [[NSUserDefaults standardUserDefaults]valueForKey:@"username"];
    NSString *sql = [NSString stringWithFormat:@"update AutoShowRecord set showTime='%ld' where identifier='%@' and userName='%@'",currentTime,identifier,userName];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FMDatabase *database = [[FMDBManager getInstance]database ];
        if (![database open])
        {
            [database open];
        }
        [database executeUpdate:sql];
 
    });

}



-(void)dismissView:(NSNotification*)notification{
    NSNumber* number=notification.object;
    if(selectedTabIndex!=[number intValue])
        [self dismissDetailViewController];
    selectedTabIndex=[number intValue];

}


-(void)addBadge{
    NSLog(@"addBadge");
    CubeApplication* cube = [CubeApplication currentApplication];
    for (  CubeModule* module in cube.modules) {
        if (!module.hidden ) {
            NSString* moduleIdentifier = module.identifier;
            int count = 0 ;
            if ([moduleIdentifier  isEqualToString:@"com.foss.message.record"]) {
                count  =[MessageRecord countAllAtBadge];
            }else{
                count = [MessageRecord countForModuleIdentifierAtBadge:moduleIdentifier];
            }
            [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"receiveMessage('%@',%d);",moduleIdentifier,count]];
        }
    }
}

-(void)showSetting{
    SettingMainViewController *settingView = [[SettingMainViewController alloc]initWithNibName:@"SettingMainViewController" bundle:nil];
    settingView.modalPresentationStyle = UIModalPresentationFormSheet;
    settingView.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:settingView];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)ExitLogin{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"退出登录" message:@"是否确认退出登录?" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
    alert.tag = 1;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag ==829)
    {
        if(buttonIndex == 0)
        {
            NSMutableArray *modules =[[CubeApplication currentApplication ]updatableModules];
            for (CubeModule *m in modules) {
                m.isDownloading = YES;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[CubeApplication currentApplication] installModule:m];
                });
                
            }
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstTime"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    if(alertView.tag == 830)
    {
        NSMutableArray *downloadArray = [[CubeApplication currentApplication] downloadingModules];
        //        NSMutableArray *copyArray = [NSMutableArray arrayWithArray:downloadArray];
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(![[FMDBManager getInstance].database tableExists:@"AutoDownLoadRecord"])
        {
            AutoDownLoadRecord *record = [[AutoDownLoadRecord alloc]init];
            [[FMDBManager getInstance] createTable:(@"AutoDownLoadRecord") withObject:record];
        }
        if(downloadArray && downloadArray.count>0)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *records = [[NSMutableArray alloc]initWithCapacity:0];
            for(CubeModule *module in downloadArray)
            {
                AutoDownLoadRecord *record = [[AutoDownLoadRecord alloc]init];
                [record setHasShow:@"1"];
                [record setIdentifier:module.identifier];
                [record setUserName:[defaults valueForKey:@"username"]];
                [records addObject:record];
            }
            [[FMDBManager getInstance] batchInsertToTable:records withtableName:@"AutoDownLoadRecord"];
        }
        if(buttonIndex == 0)
        {
            if(downloadArray && downloadArray.count>0)
            {
                
                for(CubeModule *module in downloadArray)
                {
                    [module install];
                }
                [[[CubeApplication currentApplication] downloadingModules] removeAllObjects];
                
            }
            return;
            
        }
        else
        {
            
            CubeApplication *cubeApp = [CubeApplication currentApplication];
            for(CubeModule *module in downloadArray)
            {
                [[cubeApp availableModules] removeObject:module];
                module.isDownloading = NO;
                [cubeApp uninstallModule:module];
                
            }
            [[[CubeApplication currentApplication] downloadingModules] removeAllObjects];

            return;
        }
        
    }
 
    
    if (alertView.tag == 1 && buttonIndex== 0 ) {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        
        HTTPRequest* request=[HTTPRequest requestWithURL:[NSURL URLWithString:[ServerAPI urlForlogout:[userDefaults objectForKey:@"token"]]]];
        [request startAsynchronous];
        [self logout];
    }
}

-(void)logout{
    [(AppDelegate *)[UIApplication sharedApplication].delegate showLoginView];
    [self.presentedViewController dismissViewControllerAnimated:NO completion:^{}];
//    [self dismissViewControllerAnimated:NO completion:^{}];
}


-(void)showSkinView{
    if (!skinView.isShowing) {
        [skinView show];
    }
}


-(void)onclick:(int)index source:(NSArray *)source{
    if ([source count] < index) {
    }else{
        NSLog(@"send javascript Start %@",[NSDate date]);
        NSString* name= [[source objectAtIndex:index]  objectForKey:@"name"];
        [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeTheme('%@');",name]];
        NSLog(@"send javascript fnish %@",[NSDate date]);
    }
    
}

//通过通知回调函数 显示需要暂时的view
-(void)showView:(NSNotification*)notification{
    
    //notification.userInfo
    NSArray* arguments = notification.object;
    NSString* identifier = [arguments objectAtIndex:0];
    NSString* type = [arguments objectAtIndex:1];
    CubeApplication *app = [CubeApplication currentApplication];
    CubeModule *module = [app moduleForIdentifier:identifier];
    if ([type isEqualToString:@"main"]) {
        //记录用户点击的模块添加到数据库 begin
        [OperateLog recordOperateLog:module];
        //end--------
        if([module.local length]>0){
            NSString* iphoneLocal;
            if ([module.local isEqualToString:@"DetailViewController"]) {
                iphoneLocal = @"iphoneVoiceMasterViewController";
            }else if([module.local isEqualToString:@"MessageRecord"]){
                iphoneLocal = @"MessageRecordTableViewController";
            }else if([module.local isEqualToString:@"XMPPFriends"]){
                ///*remove by fanty
                //iphoneLocal = @"XMPPFriendsViewController";
                
                iphoneLocal=@"FriendMainViewController";
            }else if([module.local isEqualToString:@"Announcement"]){
                iphoneLocal = @"AnnouncementTableViewController";
            }else{
                 iphoneLocal = module.local;
            }
            UIViewController* controller=self.detailController;
            if([controller isKindOfClass:[UINavigationController class]]){
                UINavigationController* navController=(UINavigationController*)self.detailController;
                controller=[navController topViewController];
            }
            if([controller isKindOfClass:NSClassFromString(iphoneLocal)]){
                return;
            }
            
            UIViewController *localController = (UIViewController *)[[NSClassFromString(iphoneLocal) alloc] init];
            [self showDetailViewController:localController];
            return;
        }else{
            [self showWebViewModue:module];
            
        }
    }else if ([type isEqualToString:@"install"] || [type isEqualToString:@"uninstall"] || [type isEqualToString:@"upgrade"]){
        //显示模块的详细信息
        
        
        UIViewController* controller=self.detailController;
        if([controller isKindOfClass:[UINavigationController class]]){
            UINavigationController* navController=(UINavigationController*)self.detailController;
            controller=[navController topViewController];
        }
        if([controller isKindOfClass:[DownLoadingDetialViewController class]]){
            
            DownLoadingDetialViewController* __controller=(DownLoadingDetialViewController*)controller;
            if([__controller.identifier isEqual:identifier])
                return;
        }

        
        CubeApplication *cubeApp = [CubeApplication currentApplication];
        
        
        DownLoadingDetialViewController *funDetialVC=[[DownLoadingDetialViewController alloc]init];
        @autoreleasepool {
        //循环已安装列表
            for(CubeModule *each in [cubeApp modules]){
                if([each.identifier isEqualToString:identifier]){
                    funDetialVC.curCubeModlue=each;
                    funDetialVC.buttonStatus = InstallButtonStateInstalled;
                    break;
                }
            }
            //循环更新列表
            for(CubeModule *each in [cubeApp updatableModules]){
                if([each.identifier isEqualToString:identifier]){
                    funDetialVC.curCubeModlue=each;
                    funDetialVC.buttonStatus = InstallButtonStateUpdatable;
                    break;
                }
            }
            //循环未安装列表
            for(CubeModule *each in [cubeApp availableModules]){
                if([each.identifier isEqualToString:identifier]){
                    funDetialVC.curCubeModlue=each;
                    funDetialVC.buttonStatus = InstallButtonStateUninstall;
                    break;
                }
            }
        }
        
        funDetialVC.delegate = self;
        if(funDetialVC.curCubeModlue.isDownloading){
            funDetialVC.iconImage=[[IconButton alloc] initWithModule:funDetialVC.curCubeModlue stauts:IconButtonStautsDownloading delegate:nil];
            funDetialVC.iconImage.badgeView.hidden = NO;
            funDetialVC.iconImage.downloadProgressView.progress = funDetialVC.curCubeModlue.downloadProgress;
            funDetialVC.iconImage.category=funDetialVC.curCubeModlue.category;
        }else
        {
            funDetialVC.iconImage =[[IconButton alloc] initWithModule:funDetialVC.curCubeModlue stauts:IconButtonStautsDownloadEnable delegate:nil];
            funDetialVC.iconImage.category=funDetialVC.curCubeModlue.category;
        }
        [self showDetailViewController:funDetialVC];
    }
    
}

-(void)showWebViewModue:(CubeModule*)module{
    UIViewController* controller=self.detailController;
    if([controller isKindOfClass:[UINavigationController class]]){
        UINavigationController* navController=(UINavigationController*)self.detailController;
        controller=[navController topViewController];
    }

    if([controller isKindOfClass:[CubeWebViewController class]]){
        if([controller.title isEqual:module.name]){
            return;
        }
    }
    //检查依赖包 是否已经安装
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
        self.selectedModule = module.identifier;
        UIAlertView *dependsAlert = [[UIAlertView alloc] initWithTitle:@"缺少依赖模块"
                                                               message:message
                                                              delegate:self
                                                     cancelButtonTitle:@"确定" otherButtonTitles:/*@"安装", */nil];
        [dependsAlert show];
        return;
    }
    
    CGRect frame = self.view.frame;
    frame.size.width =CGRectGetHeight(self.view.frame)/2+2;
    frame.size.height= CGRectGetWidth(self.view.frame);
    
    __block CubeWebViewController *bCubeWebViewController  = [[CubeWebViewController alloc] init];
    bCubeWebViewController.title = module.name;
    [bCubeWebViewController loadWebPageWithModule:module  frame:frame  didFinishBlock: ^(){
        //如果webView加载成功  这显示放大缩小按钮
        
        bCubeWebViewController.webView.scrollView.bounces=NO;
        bCubeWebViewController.closeButton.hidden = NO;
        if (!fullScreanBtn) {
            UIImage *image = [UIImage imageNamed:@"fullBtn.png"];
            fullScreanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [fullScreanBtn setImage:image forState:UIControlStateNormal];
            fullScreanBtn.frame = CGRectMake(CGRectGetHeight(self.view.frame) -65,CGRectGetWidth(self.view.frame) - 65 , 45, 45);
            [self.view addSubview:fullScreanBtn];
            fullScreanBtn.backgroundColor = [UIColor grayColor];
            fullScreanBtn.layer.cornerRadius = 8;
            [fullScreanBtn addTarget:self action:@selector(didClickFullScrean:) forControlEvents:UIControlEventTouchUpInside];
            fullScreanBtn.alpha = 0.6;
            [self showDetailViewController:bCubeWebViewController];
        }
    }didErrorBlock:^(){
        NSLog(@"error loading %@", bCubeWebViewController.webView.request.URL);
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"模块加载失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }];
    
    
    
}


-(void)didClickFullScrean:(id)tag{
    
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (!isFullScrean) {
            self.detailView.frame = CGRectMake(0, 0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame));
            UIImage *image = [UIImage imageNamed:@"fullBtn1.png"];
            [fullScreanBtn setImage:image forState:UIControlStateNormal];
            
        }else{
            CGRect frame = self.detailView.frame;
            frame.origin.x=CGRectGetHeight(self.view.frame)/2-2;
            frame.origin.y= 0;
            self.detailView.frame = frame;
            UIImage *image = [UIImage imageNamed:@"fullBtn.png"];
            [fullScreanBtn setImage:image forState:UIControlStateNormal];
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGRect frame = self.detailView.frame;
                frame.size.width =CGRectGetHeight(self.view.frame)/2+2;
                frame.size.height= CGRectGetWidth(self.view.frame);
                self.detailView.frame = frame;
            } completion:^(BOOL finished) {
                
            }];
            
            
            
        }
    }completion:^(BOOL finished) {
        isFullScrean = !isFullScrean;
    }];
    
    
}

//移除之前的view  显示
-(void)showDetailViewController:(UIViewController*)vc{
    [self addBadge];
    CGRect frame = vc.view.frame;
    frame.size.width =CGRectGetHeight(self.view.frame)/2+2;
    frame.size.height= CGRectGetWidth(self.view.frame);
    vc.view.frame = frame;
    
    self.detailController = nil;
    //需要在view仲添加一个导航栏
    if ([self.view viewWithTag:200]) {
        [[self.view viewWithTag:200] removeFromSuperview];
    }
    if (fullScreanBtn) {
        [fullScreanBtn removeFromSuperview];
        fullScreanBtn = nil;
    }
    self.detailView = nil;
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    self.detailController = nav;

    nav.view.frame = frame;
    
    self.detailView= nav.view;
    nav.view.tag = 200;
    CGRect detailViewFrame = frame;
    detailViewFrame.origin.x = CGRectGetWidth(self.view.bounds);
    self.detailView.frame = detailViewFrame;
    
    self.detailView.layer.cornerRadius = 10;
    
    [self.detailView.layer setShadowColor: [UIColor blackColor].CGColor];
    self.detailView.layer.shadowOpacity = 0.5;
    self.detailView.layer.shadowRadius = 20.0;
    self.detailView.layer.shadowOffset = CGSizeMake(0,0);
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanOnDetailView:)];
    pan.minimumNumberOfTouches = 1;
    pan.maximumNumberOfTouches = 1;
    pan.delegate = self;
    [nav.navigationBar addGestureRecognizer:pan];
    [self.view addSubview:self.detailView];
    
    self.view.userInteractionEnabled=NO;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
        self.detailView.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - CGRectGetWidth(vc.view.frame), 0,
                                      CGRectGetWidth(vc.view.frame), CGRectGetHeight(vc.view.frame));
    
    } completion:^(BOOL finished){
        self.view.userInteractionEnabled=YES;
    }];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}
//拖动事件
-(void)didPanOnDetailView:(UIPanGestureRecognizer*)gs
{
    CGPoint translation = [gs translationInView:detailView];
    
    if (gs.state == UIGestureRecognizerStateChanged) {
        
        CGRect frame = self.detailView.frame;
        frame.origin.x += translation.x;
        self.detailView.frame = frame;
        
        [gs setTranslation:CGPointMake(0, translation.y) inView:detailView];
        
    } else if (gs.state == UIGestureRecognizerStateEnded) {
        
        if(CGRectGetMinX(self.detailView.frame) > CGRectGetWidth(self.view.bounds) - CGRectGetWidth(detailView.bounds) / 3 * 2) {
            
            [self dismissDetailViewController];
            return;
        }
        
        CGFloat dockCriticalValue =  (CGRectGetWidth(self.view.bounds) - CGRectGetWidth(detailView.frame)) / 2;
        
        CGFloat finalX = (CGRectGetMinX(self.detailView.frame) <= dockCriticalValue) ? 0: CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.detailView.frame);
        
        self.view.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.detailView.frame = CGRectMake(finalX, 0,
                                          CGRectGetWidth(self.detailView.frame), CGRectGetHeight(self.detailView.frame));
        } completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
        }];
    }
}


-(void)dismissDetailViewController{
    self.view.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
        CGFloat detailViewWidth = 520;
        self.detailView.frame = CGRectMake(CGRectGetWidth(self.view.bounds), 0,
                                      detailViewWidth, CGRectGetHeight(self.detailView.frame));
    } completion:^(BOOL finished){
        if (fullScreanBtn) {
            [fullScreanBtn removeFromSuperview];
            fullScreanBtn = nil;
            isFullScrean = NO;
        }
        [self.detailController viewWillDisappear:NO];
        [self.detailController.view removeFromSuperview];
        [self.detailController viewDidDisappear:NO];
        self.detailController=nil;
        self.view.userInteractionEnabled = YES;
    }];
}



- (void)downloadAtModuleIdentifier:(NSString *)identifier  andCategory:(NSString *)category;{
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    
    CubeModule *module = [cubeApp availableModuleForIdentifier:identifier];
    
    if(!module){
        module = [cubeApp updatableModuleModuleForIdentifier:identifier];
    }
    [cubeApp installModule:module ];
}

- (void)deleteAtModuleIdentifier:(NSString *)identifier{
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    
    CubeModule *m = [cubeApp moduleForIdentifier:identifier];
    
    NSMutableDictionary* moduleDictionary = [self modueToJson:m];
    NSString* JSO=   [[NSString alloc] initWithData:moduleDictionary.JSONData encoding:NSUTF8StringEncoding];
    NSString * javaScript = [NSString stringWithFormat:@"refreshModule('%@','uninstall','%@');",identifier,JSO ];
    [cubeApp uninstallModule:m didFinishBlock:^(){
        [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:javaScript];
    }];
}



-(void)moduleDidInstalled:(NSNotification*)note
{
    CubeModule *newModule = [note object];
    if (newModule) {
        NSMutableDictionary* moduleDictionary = [self modueToJson:newModule];
        NSString* JSO=   [[NSString alloc] initWithData:moduleDictionary.JSONData encoding:NSUTF8StringEncoding];
        NSString * javaScript = @"";
        if (newModule.installType) {
            javaScript = [NSString stringWithFormat:@"refreshModule('%@','upgrade','%@');",newModule.identifier,JSO];
        }else{
            javaScript = [NSString stringWithFormat:@"refreshModule('%@','install','%@');",newModule.identifier,JSO];
        }
        newModule.installType = nil;
        [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:javaScript];
    }
}



-(NSMutableDictionary*)modueToJson:(CubeModule* )each{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *token =  [defaults objectForKey:@"token"];
    NSMutableDictionary *jsonCube = [NSMutableDictionary dictionary];
    [jsonCube setObject:[NSNumber numberWithBool:each.hidden] forKey:@"hidden"];
    [jsonCube  setObject:each.version forKey:@"version"];
    [jsonCube  setObject:each.releaseNote forKey:@"releaseNote"];
    [jsonCube  setObject:each.category forKey:@"category"];
    [jsonCube  setObject:[each.iconUrl stringByAppendingFormat:@"?sessionKey=%@&appKey=%@",token,kAPPKey]  forKey:@"icon"];
    [jsonCube  setObject:each.identifier forKey:@"identifier"];
    [jsonCube  setObject:!each.local?@"":each.local forKey:@"local"];
    [jsonCube  setObject:each.name forKey:@"name"];
    //=========================================
    int count = 0 ;
    if ([each.identifier  isEqualToString:@"com.foss.message.record"]) {
        count  =[MessageRecord countAllAtBadge];
    }else{
        count = [MessageRecord countForModuleIdentifierAtBadge:each.identifier];
    }
    [jsonCube  setObject: [NSNumber numberWithInt:count] forKey:@"msgCount"];
    [jsonCube  setObject: [NSNumber numberWithInt:0] forKey:@"progress"];
    //=========================================
    [jsonCube  setObject: [NSNumber numberWithInteger:each.build] forKey:@"build"];
    if ([self isUpdateModule:each.identifier]) {
        [jsonCube  setObject:  [NSNumber numberWithBool:YES] forKey:@"updatable"];
    }else{
        [jsonCube  setObject:  [NSNumber numberWithBool:NO] forKey:@"updatable"];
    }
    return jsonCube;
}
//根据模块的Identifier判断当前模块是否是可更新的模块
-(Boolean)isUpdateModule:(NSString*)moduleIdentifier{
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    CubeModule *module = [cubeApp updatableModuleModuleForIdentifier:moduleIdentifier];
    if (module) {
        return YES;
    }
    return NO;
}

- (void)clickItemWithIndex:(int)aIndex andIdentifier:(NSString*)aStr{
}


@end
