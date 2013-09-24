//
//  CubeApplication.m
//  Cube
//
//  Created by Justin Yip on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CubeApplication.h"
#import "NSFileManager+Extra.h"
#import "JSONKit.h"
#import "AFAppDotNetAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "ServerAPI.h"
#import "DownloadManager.h"
#import "SVProgressHUD.h"
#import "FMDBManager.h"
#import "AutoDownLoadRecord.h"
#import "Reachability.h"

NSString *const CubeSyncStartedNotification = @"CubeSyncStartedNotification";
NSString *const CubeSyncFinishedNotification = @"CubeSyncFinishedNotification";
NSString *const CubeSyncFailedNotification = @"CubeSyncFailedNotification";

NSString *const CubeAppUpdateFinishNotification = @"CubeAppUpdateFinishNotification";

NSString *const CubeTokenTimeOutNotification = @"CubeTokenTimeOutNotification";



@implementation CubeApplication


#define ManagerUsers NO

//运行时配置文件路径
#define RUNTIME_CFG_URL [[NSFileManager applicationDocumentsDirectory] URLByAppendingPathComponent:@"Cube.json"]
#define RUNTIME_CFG_USER_URL(A) [[NSFileManager applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"Cube_%@.json",A]]



#define BUNDLE_CFG_URL [[NSBundle mainBundle] URLForResource:@"Cube" withExtension:@"json"]

@synthesize identifier;
@synthesize name;
@synthesize releaseNote;
@synthesize iconUrl;
@synthesize url;
@synthesize downloadUrl;
@synthesize version;
@synthesize build;


@synthesize modules;
@synthesize updatableModules;
@synthesize availableModules;
@synthesize downloadingModules;

#pragma mark - Init

+(id)currentApplication
{
    static CubeApplication *instance;
    @synchronized(self) {
        if (nil == instance) {
            instance = [[CubeApplication alloc] init];
        }
    }
    
    return instance;
}

+(NSMutableDictionary*)sortByCategroy:(NSMutableArray*)aArr
{
    NSMutableDictionary *tempDic=[NSMutableDictionary dictionary];
    if([aArr count] == 0) return tempDic;
    CubeModule *firstCube=[aArr objectAtIndex:0];
    
    if (!firstCube.category) {
        firstCube.category=@"基本功能";
    }
    
    [tempDic setObject:[NSMutableArray arrayWithObject:[aArr objectAtIndex:0]] forKey:[[aArr objectAtIndex:0] category]];
    for (CubeModule *tempCube in aArr) {
        if (!tempCube.category) {
            tempCube.category=@"基本功能";
        }
        NSAssert(tempCube.category != nil, @"should not");
        
        if ([[tempDic allKeys] containsObject:tempCube.category]) {
            if (![[tempDic objectForKey:tempCube.category] containsObject:tempCube])
            {
                [[tempDic objectForKey:tempCube.category] addObject:tempCube];
            }
        }
        else
        {
            
            [tempDic setObject:[NSMutableArray arrayWithObject:tempCube] forKey:tempCube.category];
            
        }
    }
    
    return tempDic;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        //init collections
        NSMutableArray *tmp_modules = [[NSMutableArray alloc] init];
        self.modules = tmp_modules;
        
        NSMutableArray *tmp_updatable_modules = [[NSMutableArray alloc] init];
        self.updatableModules = tmp_updatable_modules;
        
        NSMutableArray *tmp_available_modules = [[NSMutableArray alloc] init];
        self.availableModules = tmp_available_modules;
        
        NSMutableArray * tmp_downloading_modules = [[NSMutableArray alloc]init];
        self.downloadingModules = tmp_downloading_modules;
        
        //load application
        
        if (!ManagerUsers) {
            NSURL *cubeURL = self.installed ? RUNTIME_CFG_URL : BUNDLE_CFG_URL;
            [self loadApplicatioFromURL:cubeURL];
            
            //merge runtime_config
            //本地模块升级
            if (self.installed) [self mergeNewLocalModules];
        }else{
            if (self.installed) {
                NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                NSString* stringUser = [userDefaults objectForKey:@"LoginUser"];
                NSURL *cubeURL = RUNTIME_CFG_USER_URL(stringUser);
                [self loadApplicatioFromURL:cubeURL];
            }
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moduleDidInstalled:) name:CubeModuleInstallDidFinishNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Cube App[%@|%@] v%@ - build %d, modules:%@", name, identifier, version, build, modules];
}

#pragma mark - Logic

-(CubeModule*)moduleForIdentifier:(NSString*)aIdentifier
{
    for (CubeModule *m in modules) {
        if ([aIdentifier isEqualToString:m.identifier]) {
            return m;
        }
    }
    return nil;
}

-(CubeModule*)availableModuleForIdentifier:(NSString*)aIdentifier{
    for (CubeModule *m in availableModules) {
        if ([aIdentifier isEqualToString:m.identifier]) {
            return m;
        }
    }
    return nil;
}
-(CubeModule*)updatableModuleModuleForIdentifier:(NSString*)aIdentifier{
    for (CubeModule *m in updatableModules) {
        if ([aIdentifier isEqualToString:m.identifier]) {
            return m;
        }
    }
    return nil;
}

#pragma mark - Load Application

//加载配置
-(void)loadApplicatioFromURL:(NSURL*)aurl
{
    //加载应用配置
    NSString *content = [NSString stringWithContentsOfURL:aurl encoding:NSUTF8StringEncoding error:nil];
    NSAssert(content != nil, @"不能解析应用程序描述文件，请检查文件是否存在且语法正确");
    
    NSDictionary *jo_app = [content objectFromJSONString];
    self.identifier = [jo_app objectForKey:@"identifier"];
    self.url = [jo_app objectForKey:@"url"];
    self.name = [jo_app objectForKey:@"name"];
    self.version = [jo_app objectForKey:@"version"];
    self.build = [[jo_app objectForKey:@"build"] integerValue];
    self.releaseNote = [jo_app objectForKey:@"releaseNote"];
    
    
    NSArray *jo_modules = [jo_app objectForKey:@"modules"];
    for (NSDictionary *jo_module in jo_modules) {
        
        CubeModule *module = [CubeModule moduleFromJSONObject:jo_module];
        [modules addObject:module];
    }
    
    NSArray *jo_u_modules = [jo_app objectForKey:@"updatableModules"];
    for (NSDictionary *jo_module in jo_u_modules) {
        
        CubeModule *module = [CubeModule moduleFromJSONObject:jo_module];
        [updatableModules addObject:module];
    }
    
    NSArray *jo_a_modules = [jo_app objectForKey:@"availableModules"];
    for (NSDictionary *jo_module in jo_a_modules) {
        
        CubeModule *module = [CubeModule moduleFromJSONObject:jo_module];
        [availableModules addObject:module];
    }
}

#pragma mark - Install

-(BOOL)installed
{
    if (ManagerUsers) {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* stringUser = [userDefaults objectForKey:@"LoginUser"];
        
        return [FS fileExistsAtPath:[RUNTIME_CFG_USER_URL(stringUser) path]];
    }else{
        return [FS fileExistsAtPath:[RUNTIME_CFG_URL path]];
    }
    
    
}



-(void)install
{
    NSLog(@"开始安装");
    BOOL success = NO;
    NSError *error = nil;
    if (!ManagerUsers) {
        if ([FS fileExistsAtPath:[RUNTIME_CFG_URL path]]) {
            success = [FS removeItemAtURL:RUNTIME_CFG_URL error:&error];
            if (!success) NSLog(@"删除Cube配置文件失败,%@", error);
        }
        success = [FS copyItemAtURL:BUNDLE_CFG_URL toURL:RUNTIME_CFG_URL error:&error];
        if (!success) NSLog(@"复制Cube配置文件失败,%@", error);
    }
    [self installCoreBundle];
    
    NSLog(@"安装完成");
}


-(void)installJS{
    NSLog(@"安装js文件");
    // [self installCoreBundle];
    NSURL * folderWWWUrl = [[NSFileManager wwwBundleDirectory] URLByAppendingPathComponent:@"cordova.js"];
    NSURL * documentFolderWWWUrl =  [[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"cordova.js"];
    NSError * error = nil;
    if ([FS fileExistsAtPath:[documentFolderWWWUrl path] ]) {
        //如果文件存在  则删除文件
        [FS removeItemAtURL:documentFolderWWWUrl error:nil];
    }
    [FS copyItemAtURL:folderWWWUrl toURL:documentFolderWWWUrl error:&error];
    
    
    NSURL * folderindexWWWUrl = [[NSFileManager wwwBundleDirectory] URLByAppendingPathComponent:@"index.html"];
    NSURL * documentindexFolderWWWUrl =  [[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"index.html"];
    
    if ([FS fileExistsAtPath:[documentindexFolderWWWUrl path] ]) {
        //如果文件存在  则删除文件
        [FS removeItemAtURL:documentindexFolderWWWUrl error:nil];
    }
    [FS copyItemAtURL:folderindexWWWUrl toURL:documentindexFolderWWWUrl error:&error];
    
    
    
    //=======================  替换pad版文件
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //clean install directory
    
    
    if ([FS fileExistsAtPath:[[[NSFileManager wwwRuntimeDirectory] path] stringByAppendingString:@"/pad"] ]) {
        [fm removeItemAtPath:[[[NSFileManager wwwRuntimeDirectory] path] stringByAppendingString:@"/pad"] error:&error];
        if (error) NSLog(@"删除www目录失败,%@", error);
    }
    
    //create directory
    [fm createDirectoryAtPath:[[[NSFileManager wwwRuntimeDirectory] path] stringByAppendingString:@"/pad"] withIntermediateDirectories:YES attributes:nil error:&error];
    
    
    [fm copyFolderAtPath:[[[NSFileManager wwwBundleDirectory] path] stringByAppendingString:@"/pad" ] toPath:[[[NSFileManager wwwRuntimeDirectory] path] stringByAppendingString:@"/pad"]  error:&error];
    
    //=======================
    
    
    //=======================  替换pad版文件
    
    
    
    if ([FS fileExistsAtPath:[[[NSFileManager wwwRuntimeDirectory] path] stringByAppendingString:@"/phone"] ]) {
        [fm removeItemAtPath:[[[NSFileManager wwwRuntimeDirectory] path] stringByAppendingString:@"/phone"] error:&error];
        if (error) NSLog(@"删除www目录失败,%@", error);
    }
    
    //create directory
    [fm createDirectoryAtPath:[[[NSFileManager wwwRuntimeDirectory] path] stringByAppendingString:@"/phone"] withIntermediateDirectories:YES attributes:nil error:&error];
    
    
    [fm copyFolderAtPath:[[[NSFileManager wwwBundleDirectory] path] stringByAppendingString:@"/phone" ] toPath:[[[NSFileManager wwwRuntimeDirectory] path] stringByAppendingString:@"/phone"]  error:&error];
    
    //=======================
    
    
    
    NSLog(@"安装js文件完成");
}

//将安装包立的www复制到Documents目录
-(void)installCoreBundle
{
    BOOL success = NO;
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //clean install directory
    if ([FS fileExistsAtPath:[[NSFileManager wwwRuntimeDirectory] path]]) {
        success = [fm removeItemAtURL:[NSFileManager wwwRuntimeDirectory] error:&error];
        if (!success) NSLog(@"删除www目录失败,%@", error);
    }
    
    //create directory
    success = [fm createDirectoryAtURL:[NSFileManager wwwRuntimeDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) NSLog(@"创建www目录失败,%@", error);
    
    //copy
    success = [fm copyFolderAtURL:[NSFileManager wwwBundleDirectory] toURL:[NSFileManager wwwRuntimeDirectory] error:&error];
    if (!success) NSLog(@"复制www目录失败,%@", error);
    
}


-(void)installModule:(CubeModule*)aModule
{
    [aModule install];
}


-(void)updateModule:(CubeModule *)aModule{
    [aModule update];
}

-(void)uninstallModule:(CubeModule*)aModule
{
    if ([aModule uninstall]) {
        NSLog(@"==1");
        [availableModules addObject:aModule];
        [modules removeObject:aModule];
    }
    
    for (int i=0; i<[updatableModules count]; i++) {
        NSLog(@"==2");
        CubeModule *m = [updatableModules objectAtIndex:i];
        if ([m.identifier isEqualToString:aModule.identifier]) {
            [updatableModules removeObject:m];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DETIALPAGE_DELETESUCCESS object:aModule.identifier];
    
    [self save];
}

-(void)uninstallModule:(CubeModule*)aCubeModule didFinishBlock:(void (^)(void))callBack
{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        //        NSLog(@"deleting",)
        if ([aCubeModule uninstall]) {
            [availableModules addObject:aCubeModule];
            [modules removeObject:aCubeModule];
        }
        
        for (int i=0; i<[updatableModules count]; i++) {
            CubeModule *m = [updatableModules objectAtIndex:i];
            if ([m.identifier isEqualToString:aCubeModule.identifier]) {
                [updatableModules removeObject:m];
            }
        }
        
        [self syncCubeJSONFile];
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DETIALPAGE_DELETESUCCESS object:aCubeModule.identifier];
            callBack();
        });//main
        
        
    });//async
    
}

-(void)syncCubeJSONFile{
    NSString *jsonString = [[self dictionary] JSONString];
    
    BOOL success = false;
    NSError *error = nil;
    if (ManagerUsers) {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* stringUser = [userDefaults objectForKey:@"LoginUser"];
        success = [jsonString writeToURL:RUNTIME_CFG_USER_URL(stringUser) atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }else{
        success = [jsonString writeToURL:RUNTIME_CFG_URL atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    if (!success) NSLog(@"保存Cube配置文件到[%@]失败,%@", RUNTIME_CFG_URL, error);
}


-(void)moduleDidInstalled:(NSNotification*)note
{
    CubeModule *newModule = [note object];
    NSAssert(newModule.installed, @"Module not installed");
    
    if ([availableModules containsObject:newModule]) {
        
        //install
        [availableModules removeObject:newModule];
        //add it to installed list
        [modules addObject:newModule];
    } else {
        
        //update
        /*remove old module*/
        CubeModule *oldModule = nil;
        for (CubeModule *m in modules) {
            if ([m.identifier isEqualToString:newModule.identifier]) {
                oldModule = m;
            }
        }
        //        [oldModule uninstall];
        [modules removeObject:oldModule];
        
        //move new module form updatable to installed
        [updatableModules removeObject:newModule];
        [modules addObject:newModule];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DETIALPAGE_INSTALLSUCCESS object:nil];
    [self save];
}




-(BOOL)judgeArray:(NSMutableArray*)tempArr ContainsModule:(CubeModule*)aModule
{
    for (CubeModule *tempModule in tempArr) {
        if ([tempModule.identifier isEqualToString:aModule.identifier]) {
            return TRUE;
        }
    }
    return FALSE;
}

#pragma mark - Sync
-(void)sync
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *token =  [defaults objectForKey:@"token"];
    
    NSString *userName = [defaults objectForKey:@"LoginUser"];
    
    NSString *urlString = [ServerAPI urlForSync] ;
    urlString = [urlString stringByAppendingString:@"?username="];
    urlString = [urlString stringByAppendingString:userName];
    if (token) {
        urlString = [urlString stringByAppendingString:@"&sessionKey="];
        urlString = [urlString stringByAppendingString:token];
    }
    [self syncWithString:urlString token:token];
}

-(void)syncWithString:(NSString*)aURL token:(NSString *)token{
   //判断网络是否可以使用
    if (([Reachability reachabilityForInternetConnection].currentReachabilityStatus != NotReachable) &&
        ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus != NotReachable)) {
            if(!syncing){
            [[AFAppDotNetAPIClient sharedClient]getPath:aURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                syncing = false;
                int statusCode =operation.response.statusCode;
                if (statusCode== 400 ) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:CubeTokenTimeOutNotification object:self];
                    return;
                }
               
                if ([[responseObject objectForKey:@"result"]isEqualToString:@"error"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:CubeTokenTimeOutNotification object:self];
                    return;
                }
                [self getmodulesFromJson:responseObject ];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                syncing = false;
                [[NSNotificationCenter defaultCenter] postNotificationName:CubeSyncFailedNotification object:self];
            }];
            [self syncStarted];
        }
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:CubeTokenTimeOutNotification object:nil];
    }
}

-(void)syncStarted
{
    syncing = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:CubeSyncStartedNotification object:self];
}
//解析json数据 转成cubemodule
-(void)getmodulesFromJson:(id)remote_json{
    
    NSArray *remote_modules_json = [remote_json objectForKey:@"modules"];
    
    NSMutableArray *deleteArr=[NSMutableArray array];
    //保留性移除数组内容
    for (CubeModule *tempAvaliableModule in availableModules) {
        if (tempAvaliableModule.isDownloading) {
            NSLog(@"Downloading modlues,%@,%d",tempAvaliableModule.identifier,tempAvaliableModule.build);
            continue;
        }
        [deleteArr addObject:tempAvaliableModule];
    }
    [availableModules removeObjectsInArray:deleteArr];
    [deleteArr removeAllObjects];
    
     
    
    if(![[FMDBManager getInstance].database tableExists:@"AutoDownLoadRecord"])
    {
        AutoDownLoadRecord *record = [[AutoDownLoadRecord alloc]init];
        [[FMDBManager getInstance] createTable:(@"AutoDownLoadRecord") withObject:record];
    }
    for (CubeModule *tempUpdateModule in updatableModules) {
        if (tempUpdateModule.isDownloading) {
            NSLog(@"Downloading modlues,%@,%d",tempUpdateModule.identifier,tempUpdateModule.build);
            continue;
        }
        [deleteArr addObject:tempUpdateModule];
    }
    [updatableModules removeObjectsInArray:deleteArr];
    [deleteArr removeAllObjects];
    
    for (id remote_module_json in remote_modules_json) {
        //获取网络版本CubeModule
        CubeModule *remote_module = [CubeModule moduleFromJSONObject:remote_module_json];
        //获取网络版本CubeModule
        CubeModule *local_module = [self moduleForIdentifier:remote_module.identifier];
        if (local_module != nil)
        {
            //同步的时候同步权限
            local_module.privileges = remote_module.privileges;
            //同步的时候同步分类
            local_module.category = remote_module.category;
            //同步的时候同步隐藏
            local_module.hidden = remote_module.hidden;
            
            //check version
            if (remote_module.build > local_module.build)
            {
                
                //put into updatableModule
                if (![self judgeArray:updatableModules ContainsModule:remote_module]) {
                    [updatableModules addObject:remote_module];
                    NSLog(@"发现模块更新:%@-%d", remote_module.identifier, remote_module.build);
                }
                
                
            }else if(remote_module.build == local_module.build){
                
                [modules removeObject:local_module];
                
                [modules addObject:remote_module];
            }
            
            
        }
        else
        {
            
            //puto into available module
            if (![self judgeArray:availableModules ContainsModule:remote_module]) {
                [availableModules addObject:remote_module];
                remote_module.autoDownload = YES;
                if (remote_module.autoDownload) {
                    //优化自动下载 zhoujn begin-----
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSString *userName = [defaults valueForKey:@"username"];
                    if(![[FMDBManager getInstance] recordIsExist:@"identifier" withtableName:@"AutoDownLoadRecord" withConditios:userName])
                    {
                        remote_module.isDownloading =YES;
                        [downloadingModules addObject:remote_module];
                    }
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CubeSyncFinishedNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DETIALPAGE_SYNSUCCESS object:nil];
    
    [self save];
}

- (void)mergeNewLocalModules
{
    //删除所有本地模块
    [modules filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        CubeModule *m = (CubeModule *)evaluatedObject;
        
        return ([m.local length]<1);
    }]];
    
    //重新添加本地模块
    NSString *content = [NSString stringWithContentsOfURL:BUNDLE_CFG_URL encoding:NSUTF8StringEncoding error:nil];
    id remote_json= [content objectFromJSONString];
    NSArray *modules_json = [remote_json objectForKey:@"modules"];
    for (id module_json in modules_json) {
        CubeModule *module = [CubeModule moduleFromJSONObject:module_json];
        [modules addObject:module];
    }
    
    [self save];
}



#pragma mark - Serialization

-(NSMutableDictionary*)dictionary
{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    [json setValue:self.identifier forKey:@"identifier"];
    [json setValue:self.name forKey:@"name"];
    [json setValue:self.releaseNote forKey:@"releaseNote"];
    [json setValue:self.iconUrl forKey:@"iconUrl"];
    [json setValue:self.url forKey:@"url"];
    [json setValue:self.version forKey:@"version"];
    [json setValue:[NSNumber numberWithInteger:self.build] forKey:@"build"];
    
    NSMutableArray *moduleArray = [[NSMutableArray alloc] initWithCapacity:[modules count]];
    for (CubeModule *module in modules) {
        [moduleArray addObject:[module dictionary]];
    }
    [json setObject:moduleArray forKey:@"modules"];
    
    NSMutableArray *updatableModuleArray = [[NSMutableArray alloc] initWithCapacity:[updatableModules count]];
    for (CubeModule *module in updatableModules) {
        [updatableModuleArray addObject:[module dictionary]];
    }
    [json setObject:updatableModuleArray forKey:@"updatableModules"];
    
    NSMutableArray *availableModuleArray = [[NSMutableArray alloc] initWithCapacity:[updatableModules count]];
    for (CubeModule *module in availableModules) {
        [availableModuleArray addObject:[module dictionary]];
    }
    [json setObject:availableModuleArray forKey:@"availableModules"];
    
    return json;
}

-(void)save
{
    [self syncCubeJSONFile];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CubeAppUpdateFinishNotification object:self];
    
}

-(void)startUpdateChecker
{
    
}


-(CubeModule *)judgeArrayForResult:(NSMutableArray*)tempArr ContainsModule:(CubeModule*)aModule
{
    for (CubeModule *tempModule in tempArr) {
        if ([tempModule.identifier isEqualToString:aModule.identifier]) {
            return tempModule;
        }
    }
    return nil;
}

-(NSMutableArray *)modules{
    NSMutableArray *visibleModules = [[NSMutableArray alloc] init];
    for(int i = 0; i < modules.count; i++){
        CubeModule *module=[modules objectAtIndex:i];
        if((module.privileges && ![module.privileges isEqual:[NSNull null]]) || [module.local length]>0)
            [visibleModules addObject:module];
    }
    return visibleModules;
}

-(NSMutableArray *)availableModules{
    NSMutableArray *visibleModules = [[NSMutableArray alloc] init];
    for(int i = 0; i < availableModules.count; i++){
        CubeModule *module=[availableModules objectAtIndex:i];
        if((module.privileges && ![module.privileges isEqual:[NSNull null]]) && ([module.local length]<1))
            [visibleModules addObject:module];
    }
    return visibleModules;
}

-(NSMutableArray *)updatableModules{
    NSMutableArray *visibleModules = [[NSMutableArray alloc] init];
    for(int i = 0; i < updatableModules.count; i++){
        CubeModule *module=[updatableModules objectAtIndex:i];
        if((module.privileges && ![module.privileges isEqual:[NSNull null]]) && ([module.local length]<1))
            [visibleModules addObject:module];
    }
    return visibleModules;
}

@end

