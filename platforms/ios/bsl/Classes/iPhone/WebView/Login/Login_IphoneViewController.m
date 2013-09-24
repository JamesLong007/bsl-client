//
//  Login_IphoneViewController.m
//  cube-ios
//
//  Created by 东 on 8/2/13.
//
//

#import "Login_IphoneViewController.h"

#import "CubeWebViewController.h"
#import "NSFileManager+Extra.h"



@interface Login_IphoneViewController ()

@end

@implementation Login_IphoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    aCubeWebViewController  = [[CubeWebViewController alloc] init];
    //aCubeWebViewController.title=module.name;
    //加载本地的登录界面页
    //设置启动页面
    aCubeWebViewController.title=@"登录";
    aCubeWebViewController.wwwFolderName = @"www";
    aCubeWebViewController.startPage =   [[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"phone/login.html"] absoluteString];
    
    aCubeWebViewController.view.frame = self.view.bounds;
    NSLog(@"start load WebView date = %@",[NSDate date]);
    [aCubeWebViewController loadWebPageWithUrl: [[[NSFileManager wwwRuntimeDirectory] URLByAppendingPathComponent:@"phone/login.html"] absoluteString] didFinishBlock: ^(){
        aCubeWebViewController.closeButton.hidden = YES;
        [aCubeWebViewController viewWillAppear:NO];
        [self.view addSubview:aCubeWebViewController.view];
        [aCubeWebViewController viewDidAppear:NO];
        aCubeWebViewController.webView.scrollView.bounces=NO;
        NSLog(@"finish load WebView date = %@",[NSDate date]);
    }didErrorBlock:^(){
        aCubeWebViewController.closeButton.hidden = YES;
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"模块加载失败。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
