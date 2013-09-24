//
//  SettingMainViewController.m
//  cube-ios
//
//  Created by 东 on 13-3-20.
//
//

#import "SettingMainViewController.h"
#import "AboutViewController.h"
#import "SetttingIMViewController.h"
#import "CubeApplication.h"
#import "CubeModule.h"
#import "AsyncImageView.h"
#import "IconButton.h"
#import "NSFileManager+Extra.h"

@interface SettingMainViewController (){
    
    
}

@property (strong,nonatomic) NSMutableArray* settingSource;

@end

@implementation SettingMainViewController
@synthesize delegate;
@synthesize selectedModule;
@synthesize settingSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title= @"设置";
    
    NSMutableArray* array=[[NSMutableArray alloc]init];
    self.settingSource = array;
    
    titleArray = [[NSArray alloc]initWithObjects:@"系统设置",@"模块设置", nil];
//    titleArray = [[NSArray alloc]initWithObjects:@"系统设置",@"上传下载模块信息",@"模块设置", nil];
    
    NSMutableArray* firstArray = [[NSMutableArray alloc]init];
    NSMutableArray* secondArray = [[NSMutableArray alloc]init];
    
    
    NSArray* array1 = [[NSArray alloc]initWithObjects:@"更新版本",@"setting_update.png", nil];
    NSArray* array2 = [[NSArray alloc]initWithObjects:@"关于我们",@"setting_about.png", nil];
    NSArray* array3 = [[NSArray alloc]initWithObjects:@"即时通讯",@"setting_about.png", nil];
    self.settingTableView.delegate = self;
    self.settingTableView.dataSource  = self;
    [firstArray addObject:array1];
    [firstArray addObject:array2];
    [firstArray addObject:array3];
    
    [settingSource addObject:firstArray];
    
    NSArray* array_1 = [[NSArray alloc]initWithObjects:@"上传",@"setting_about.png", nil];
    NSArray* array_2 = [[NSArray alloc]initWithObjects:@"下载",@"setting_update.png", nil];
    NSMutableArray* settingArray= [[NSMutableArray alloc]init];
    [settingArray addObject:array_1];
    [settingArray addObject:array_2];
//    [settingSource addObject:settingArray];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    CubeApplication *cubeApp = [CubeApplication currentApplication];
    for (CubeModule* module in  cubeApp.modules) {
        NSURL* moduleUrl =[module runtimeURL];
        NSURL* settingsFileURL = [moduleUrl URLByAppendingPathComponent:@"settings.html"];
        if ([fileManager fileExistsAtPath:[settingsFileURL path]]) {
            [secondArray addObject:module];
        }
    }
    if([secondArray count]>0){
        [settingSource addObject:secondArray];
    }
   
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0,0,UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 320:640,44)];
    //添加退出登陆按钮
   
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 14:28, 0, UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 292: 484, 44)];
    
    [btn setBackgroundImage:[UIImage imageNamed:@"setting_exitBg.png"] forState:UIControlStateNormal];
    [btn setTitle:@"登出当前账号" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(exitBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:btn];

    self.settingTableView.tableFooterView = footerView;
    
    self.uc = [[UpdateChecker alloc] initWithDelegate:self];
    
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad ) {
        //添加关闭按钮
        
        if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad) {
            self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleBordered target:self action:@selector(closeSettingView)];
        }
        else{
            UIButton *navRightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 43, 30)];
            [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn.png"] forState:UIControlStateNormal];
            [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn_active.png"] forState:UIControlStateSelected];
            [navRightButton setTitle:@"关闭" forState:UIControlStateNormal];
            [[navRightButton titleLabel] setFont:[UIFont systemFontOfSize:13]];
            [navRightButton addTarget:self action:@selector(closeSettingView) forControlEvents:UIControlEventTouchUpInside];
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];

            
        }
        
    }
    
}

-(void)closeSettingView{
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        [[self presentingViewController] dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [[self parentViewController] dismissModalViewControllerAnimated:YES];
    }
}

//========= tableview delegate start ===============
-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[settingSource objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [settingSource count];
}


-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
}

//选中cell后的回调函数
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    if (indexPath.section == 0 ) {
        if (indexPath.row == 0 ) {
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            if ((BOOL)[defaults objectForKey:@"offLineSwitch"]) {
                NSString *message = [NSString stringWithFormat:@"离线模式不能更新"];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"版本更新" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [av show];
                return;
            }
            
            [self.uc check];
        }else if(indexPath.row == 1){
            AboutViewController* aboutViewController = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
            [self.navigationController pushViewController:aboutViewController animated:YES];
        }else if(indexPath.row == 2){
            SetttingIMViewController* setttingIMViewController = [[SetttingIMViewController alloc]initWithNibName:@"SetttingIMViewController" bundle:nil];
            [self.navigationController pushViewController:setttingIMViewController animated:YES];
        }
    }
//    else if(indexPath.section == 1){
//        if (indexPath.row ==0 ) {
//            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否上传本机模块信息覆盖服务器配置信息？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"上传", nil];
//            alertView.tag = 101;
//            [alertView show];
//            [alertView release];
//            
//        }else{
//            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否同步服务器的配置信息覆盖本地模块信息？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"同步", nil];
//            alertView.tag = 102;
//            [alertView show];
//            [alertView release];
//        }
//    }
    else{
        CubeModule * module = [[settingSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
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
        
        //植入界面
        if (!cubeWebViewController) {
            cubeWebViewController  = [[CubeWebViewController alloc] init];
        }
        cubeWebViewController.title=module.name;
        
        
        NSString * moduleIndex = [[[module runtimeURL] URLByAppendingPathComponent:@"index.html"] absoluteString];
        cubeWebViewController.startPage = [NSString stringWithFormat:@"%@#%@/settings", moduleIndex, module.identifier];
        
        [cubeWebViewController loadWebPageWithModuleIdentifier:module.identifier didFinishBlock: ^(){
            NSLog(@"finish loading");
            [self.navigationController.navigationBar setHidden:NO];
            
            [self.navigationController pushViewController:cubeWebViewController animated:YES];
            
            
            cubeWebViewController = nil;
        }didErrorBlock:^(){
            NSLog(@"error loading");
            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"模块加载失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            cubeWebViewController = nil;
        }];
    }
    
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if(cell== nil){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyIdentifier"];
    }
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0 || indexPath.section == 1 ) {
        cell.textLabel.text = [[[settingSource objectAtIndex:indexPath.section ] objectAtIndex:indexPath.row] objectAtIndex:0];
        UIImageView* imageview  = [[UIImageView alloc] initWithFrame:CGRectMake(UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 25 : 50, 12.5, 20,20)];
        imageview.image = [UIImage imageNamed: [[[settingSource objectAtIndex:indexPath.section ] objectAtIndex:indexPath.row] objectAtIndex:1]];
        
        [cell addSubview:imageview];
    }else{
        CubeModule* module = [[settingSource objectAtIndex:indexPath.section ] objectAtIndex:indexPath.row];
        cell.textLabel.text =module.name;
        
        AsyncImageView* imageview  = [[AsyncImageView alloc] initWithFrame:CGRectMake(UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 25 : 50, 12.5, 20,20)];
        [imageview loadImageWithURLString:module.iconUrl];
        [cell addSubview:imageview];
        
    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString* title = @"";
    title= [titleArray objectAtIndex:section];
    return  title;
}


-(void)updateUnavailable
{
    NSString *message = [NSString stringWithFormat:@"已是最新版本"];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"版本更新" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [av show];
}

-(void)updateError:(NSError*)aError
{
    NSString *message = [NSString stringWithFormat:@"更新出错，请检查网络"];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"版本更新" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [av show];
}



#pragma mark - 上传用户的配置信息


#pragma mark - 同步用户的配置信息



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 101 ) {
        //上传方法  
        return;
    }else if(alertView.tag == 102 ){
        //下载方法
        return;
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ) {
        return  interfaceOrientation ==  UIInterfaceOrientationPortrait;
    }
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


//========= tableview delegate end   ===============

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    delegate=nil;
}
- (void)viewDidUnload {
    [self setSettingTableView:nil];
    [super viewDidUnload];
}
- (IBAction)exitBtn:(id)sender {
    if ([delegate respondsToSelector:@selector(ExitLogin)]) {
        [delegate ExitLogin];
    }
    
}
@end
