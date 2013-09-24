//
//  Main_IphoneViewController.m
//  cube-ios
//
//  Created by 东 on 8/2/13.
//
//

#import "Main_IphoneViewController.h"
#import "CubeWebViewController.h"
#import "NSFileManager+Extra.h"
#import "SettingMainViewController.h"
#import "DownLoadingDetialViewController.h"
#import "MessageRecord.h"
#import "JSONKit.h"
#import "NSFileManager+Extra.h"
#import "ServerAPI.h"
#import "FMDBManager.h"
#import "HTTPRequest.h"
#import "AutoDownLoadRecord.h"
#import "OperateLog.h"

#import "DownLoadingDetialViewController.h"
#import "SettingMainViewController.h"


@interface Main_IphoneViewController ()<DownloadCellDelegate,SettingMainViewControllerDelegate,UIGestureRecognizerDelegate>
@end

@implementation Main_IphoneViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addBadge{
    if (aCubeWebViewController) {
        for (  CubeModule* module in [[CubeApplication currentApplication] modules]) {
            if (!module.hidden) {
                NSString* moduleIdentifier = module.identifier;
                int count = [moduleIdentifier  isEqualToString:@"com.foss.message.record"] ? [MessageRecord countAllAtBadge] :[MessageRecord countForModuleIdentifierAtBadge:moduleIdentifier];
                //判断模块是否需要显示右上角的数字
                if(module.showPushMsgCount ==1)
                {
                    [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"receiveMessage('%@',%d);",moduleIdentifier,count]];
                }
                
            }
        }
    }
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden  = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showView:) name:@"SHOW_DETAILVIEW" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSetting) name:@"SHOW_SETTING_VIEW" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBadge) name:@"module_badgeCount_change" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moduleDidInstalled:) name:CubeModuleInstallDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBadge) name:@"MESSAGE_RECORD_DID_Change_NOTIFICATION" object:nil];
    //收到消息时候的广播
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBadge) name:MESSAGE_RECORD_DID_SAVE_NOTIFICATION object:nil];
    //收到好友消息时候
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteModuleFromNotification:) name:KNOTIFICATION_DETIALPAGE_DELETESUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moduleDidInstalled:) name:KNOTIFICATION_DETIALPAGE_INSTALLSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didProgressUpdate:) name:@"queue_module_download_progressupdate" object:nil];
    
    [self addBadge];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkModules) name:CubeSyncFinishedNotification object:nil];
}

-(void)checkModules{
    //检测是否需要自动安装
    
    NSMutableArray *downloadArray = [[CubeApplication currentApplication] downloadingModules];
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

-(void)checkAutoUpdate
{
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


- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title=@"";
    
    if (!aCubeWebViewController) {
        aCubeWebViewController = [[CubeWebViewController alloc]init];
        aCubeWebViewController.title=@"登录";
        aCubeWebViewController.wwwFolderName = @"www";
        aCubeWebViewController.startPage =   [[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"phone/index.html"] absoluteString];
        aCubeWebViewController.view.frame = self.view.bounds;
        
        [aCubeWebViewController loadWebPageWithUrl: [[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"phone/index.html"] absoluteString] didFinishBlock: ^(){
            aCubeWebViewController.closeButton.hidden = YES;
            aCubeWebViewController.webView.scrollView.bounces=NO;
            [aCubeWebViewController viewWillAppear:NO];
            [self.view addSubview:aCubeWebViewController.view];
            [aCubeWebViewController viewDidAppear:NO];
            
            [self addBadge];
        }didErrorBlock:^(){
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"模块加载失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }];
        
    }
    
    
    //模块自动加载
    NSMutableArray * modulesArray = [[CubeApplication currentApplication]modules];
    for (CubeModule *module in modulesArray) {
        if([module moduleIsInstalled]&& module.isAutoShow){
            [self showWebViewModue:module];
            
        }
    }
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 皮肤功能

- (void)onclick:(int)index source:(NSArray *)source{
    if ([source count] > index) {
        NSString* name= [[source objectAtIndex:index]  objectForKey:@"name"];
        [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeTheme('%@');",name]];
    }
}


-(void)didProgressUpdate:(NSNotification *) notification{
    NSDictionary* dictionary = [notification userInfo];
    NSNumber* num = [dictionary objectForKey:@"newProgress"];
    NSString* key = [dictionary objectForKey:@"key"];
    float pro = [num floatValue]*100;
    int proInt = pro;
    NSString * javaScript = [NSString stringWithFormat:@"updateProgress('%@',%d);",key,proInt];
    [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:javaScript];
}

#pragma mark - 展示详情界面

//通过通知回调函数 显示需要暂时的view
-(void)showView:(NSNotification*)notification{
    NSArray* arguments = notification.object;
    NSString* identifier = [arguments objectAtIndex:0];
    NSString* type = [arguments objectAtIndex:1];
    CubeApplication *app = [CubeApplication currentApplication];
    CubeModule *module = [app moduleForIdentifier:identifier];
    if ([type isEqualToString:@"main"]) {
        //记录模块点击begin
        [OperateLog recordOperateLog:module];
        //end
        if([module.local length] >0){
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
                iphoneLocal = [module.local stringByAppendingString:@"ViewController"];
            }
            self.navigationController.navigationBar.hidden = NO;
            UIViewController *localController = (UIViewController *)[[NSClassFromString(iphoneLocal) alloc] init];
            [self.navigationController pushViewController:localController animated:YES];
            return;
        }else{
            [self showWebViewModue:module];
        }
    }else if ([type isEqualToString:@"install"] || [type isEqualToString:@"uninstall"] || [type isEqualToString:@"upgrade"]){
        //显示模块的详细信息
        CubeApplication *cubeApp = [CubeApplication currentApplication];
        NSMutableArray *modules  = [NSMutableArray array];
        
        [modules addObjectsFromArray:[cubeApp updatableModules]];
        [modules addObjectsFromArray:[cubeApp modules]];
        [modules addObjectsFromArray:[cubeApp availableModules]];
        self.navigationController.navigationBar.hidden = NO;
        
        DownLoadingDetialViewController *funDetialVC=[[DownLoadingDetialViewController alloc]init];
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
        
        funDetialVC.delegate = self;
        if(funDetialVC.curCubeModlue.isDownloading){
            funDetialVC.iconImage=[[IconButton alloc] initWithModule:funDetialVC.curCubeModlue stauts:IconButtonStautsDownloading delegate:nil];
            funDetialVC.iconImage.badgeView.hidden = YES;
            funDetialVC.iconImage.downloadProgressView.progress = funDetialVC.curCubeModlue.downloadProgress;
            funDetialVC.iconImage.category=funDetialVC.curCubeModlue.category;
            funDetialVC.buttonStatus = InstallButtonStateUpdating;
        }else
        {
            funDetialVC.iconImage =[[IconButton alloc] initWithModule:funDetialVC.curCubeModlue stauts:IconButtonStautsDownloadEnable delegate:nil];
            funDetialVC.iconImage.category=funDetialVC.curCubeModlue.category;
        }
        [self.navigationController pushViewController:funDetialVC animated:YES];
    }
}

-(void)showWebViewModue:(CubeModule*)module{
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
    
    CubeWebViewController *bCubeWebViewController  = [[CubeWebViewController alloc] init];
    //记录html5模块点击begin
    [OperateLog recordOperateLog:module];
    //end
    bCubeWebViewController.title = module.name;
    [bCubeWebViewController loadWebPageWithModule:module  frame:frame  didFinishBlock: ^(){
        //如果webView加载成功  这显示放大缩小按钮
        
        bCubeWebViewController.webView.scrollView.bounces=NO;
        [self.navigationController pushViewController:bCubeWebViewController animated:YES];
        bCubeWebViewController.closeButton.hidden = NO;
    }didErrorBlock:^(){
        NSLog(@"error loading %@", bCubeWebViewController.webView.request.URL);
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"模块加载失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}


-(void)showSetting{
    self.navigationController.navigationBar.hidden = NO;
    SettingMainViewController *settingView = [[SettingMainViewController alloc]initWithNibName:@"SettingMainViewController" bundle:nil];
    settingView.modalPresentationStyle = UIModalPresentationFormSheet;
    settingView.delegate = self;
    [self.navigationController pushViewController:settingView animated:YES];
}



#pragma mark - SettingView delegate
-(void)ExitLogin{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"退出登录" message:@"是否确认退出登录?" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
    alert.tag = 1;
    [alert show];
}

#pragma mark - 退出登陆
-(void)logout{
    [(AppDelegate *)[UIApplication sharedApplication].delegate showLoginView];
}


#pragma mark - alerview Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag ==829)
    {
        if(buttonIndex == 0)
        {
            NSMutableArray *modules =[[CubeApplication currentApplication ]updatableModules];
            for (CubeModule *m in modules) {
                m.isDownloading = YES;
                [[CubeApplication currentApplication] installModule:m];
            }
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstTime"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }else{
            [self  checkAutoUpdate];
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    if(alertView.tag == 830)
    {
        NSMutableArray *downloadArray = [[CubeApplication currentApplication] downloadingModules];
        
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
            //                [copyArray release];
        }
        //        });
        if(buttonIndex == 0)
        {
            if(downloadArray && downloadArray.count>0)
            {
                
                for(CubeModule *module in downloadArray)
                {
                    module.isDownloading = YES;
                    [[CubeApplication currentApplication] installModule:module];
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
    
    
    //退出登录alert
    if (alertView.tag == 1 && buttonIndex== 0 ) {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        HTTPRequest * request = [HTTPRequest requestWithURL:[NSURL URLWithString:[ServerAPI urlForlogout:[userDefaults objectForKey:@"token"]]]];
        
        [request startAsynchronous];
        [self logout];
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
        
    }
    
}



- (void)downloadAtModuleIdentifier:(NSString *)identifier  andCategory:(NSString *)category;{
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    CubeModule *module = [cubeApp availableModuleForIdentifier:identifier];
    if(!module){
        module = [cubeApp updatableModuleModuleForIdentifier:identifier];
    }
    [cubeApp installModule:module ];
}

-(void)deleteModuleFromNotification:(NSNotification*)tion{
    NSString *identifier = [tion object];
    [self deleteAtModuleIdentifier:identifier];
    
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

-(void)inStalledModuleIdentifierr:(NSString *)identifier{
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    CubeModule *m = [cubeApp moduleForIdentifier:identifier];
    NSMutableDictionary* moduleDictionary = [self modueToJson:m];
    NSString* JSO=   [[NSString alloc] initWithData:moduleDictionary.JSONData encoding:NSUTF8StringEncoding];
    NSString * javaScript = [NSString stringWithFormat:@"refreshModule('%@','install','%@');",m.identifier,JSO];
    [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:javaScript];
    
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
        
        if (!newModule.hidden) {
            NSString * mainScript = [NSString stringWithFormat:@"refreshMainPage();"];
            [aCubeWebViewController.webView stringByEvaluatingJavaScriptFromString:mainScript];
        }
    }
}


-(NSMutableDictionary*)modueToJson:(CubeModule* )each{
    if(each){
        
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
        }[jsonCube  setObject: [NSNumber numberWithInt:count] forKey:@"msgCount"];
        [jsonCube  setObject: [NSNumber numberWithInt:0] forKey:@"progress"];
        //=========================================
        [jsonCube  setObject: [NSNumber numberWithInteger:each.build] forKey:@"build"];
        if ([self isUpdateModule:each.identifier]) {
            [jsonCube  setObject:  [NSNumber numberWithBool:YES] forKey:@"updatable"];
        }else{
            [jsonCube  setObject:  [NSNumber numberWithBool:NO] forKey:@"updatable"];
        }
        return jsonCube;
    }else{
        return nil;
    }
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


@end
