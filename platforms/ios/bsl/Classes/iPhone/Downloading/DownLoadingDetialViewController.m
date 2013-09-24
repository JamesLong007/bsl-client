//
//  DownLoadingDetialViewController.m
//  cube-ios
//
//  Created by 东 on 3/5/13.
//
//

#import "DownLoadingDetialViewController.h"
#import "CubeApplication.h"
#import "HTTPRequest.h"
#import "ConfigManager.h"
#import "DownloadManager.h"


#define KDISPALYVIEWWIDTH (320*self.dispayScrollView.frame.size.height/480)
#define kURL_PATH1 @"/m/widget"
#define kURL_PATH2 @"/snapshot"
static const NSString *const kLoadIconOperationKey = @"kLoadIconOperationKey";

@interface DownLoadingDetialViewController ()

@property (strong,nonatomic) NSMutableArray *imageArray;
@end

@implementation DownLoadingDetialViewController



-(void)viewDidLoad{
    [super viewDidLoad];
    
    firstEnter = TRUE;
    self.title=@"模块详情";
    self.identifier=_curCubeModlue.identifier;
    self.functionName.text=_curCubeModlue.name;
    self.iconImage.isShowMode=TRUE;
    [self.iconImage defaultSet];
    self.iconImage.frame=CGRectMake(10, 0, 85 , 113);
    [self.iconImage transformWithWidth:85 andHeight:123];
    self.iconImage.iconLabel.text = @"";
    self.newestVersion.text=_curCubeModlue.version;
    self.describeText.text= [_curCubeModlue.releaseNote stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
    _configButton.hidden=([_curCubeModlue.local length ] > 0);
    self.iconUrlArr = [[NSMutableArray alloc] init];
    
    
    if (_buttonStatus==InstallButtonStateUninstall) {
        _curTitle=EBTNINSTALL;
    }else if (_buttonStatus==InstallButtonStateInstalled){
        _curTitle=EBTNDELETE;
    }else
    {
        _curTitle=EBTNUPDATE;
    }
    
    self.iconImage = [[IconButton alloc]initWithModule:self.curCubeModlue stauts:self.buttonStatus delegate:nil];
    
    if ([_iconImage stauts]==5) {
        self.configButton.btnStatus = InstallButtonStateInstalling;
    }else
    {
        self.configButton.btnStatus = _buttonStatus;
    }
    
    [self.mainScrollView addSubview:_iconImage];//添加图片按钮
    //获取模块快照数据  动态刷新数据
    
    if (self.curCubeModlue.local ) {
        if ([self.curCubeModlue.localImageUrl length]>0) {
            NSArray* imageURL =   [self.curCubeModlue.localImageUrl componentsSeparatedByString:@","];
           for (NSString * str  in imageURL) {
                [self.iconUrlArr addObject: [[[NSBundle mainBundle] URLForResource:str withExtension:nil] absoluteString]];
            }
            [self loadImage];
        }
    }else{
        [self loadImageData];
    }

}


-(void)viewWillAppear:(BOOL)animated
{
    [self enableDetialInfoNotification];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self disableDetialInfoNotification];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self synAppInfo];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[DownloadManager instance] cancelRequestForKey:kLoadIconOperationKey];
    
    
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    self.imageArray=nil;
    self.identifier=nil;
    self.curCubeModlue=nil;
    self.iconImage=nil;
    self.scorllImageView=nil;
    self.pageControl=nil;
    self.functionName=nil;
    self.describeText=nil;
    self.newestVersion=nil;
    self.configButton=nil;
    self.iconUrlArr=nil;
    self.imageScrollView=nil;
    self.mainScrollView=nil;
}




- (IBAction)clickConfigButton:(id)sender {
    firstEnter=FALSE;
    InstallButton * button = sender;
    [button setEnabled:NO];
    if (_curTitle==EBTNSYN) {
        button.btnStatus=InstallButtonStateUninstall;
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请先同步已获取改应用的最新资源" delegate:self cancelButtonTitle:@"同步" otherButtonTitles:@"取消", nil];
        alert.tag=1234;
        [alert show];
    }else if (button.btnStatus == InstallButtonStateSynFailed) {
        //重新同步回去应用信息
        [self synAppInfo];
    }
    else if (button.btnStatus == InstallButtonStateInstalled) {
        button.btnStatus = InstallButtonStateDeleting;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"确认删除该模块?"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:@"取消", nil];
        alert.tag = 5;
        [alert show];
    }else
    {
        //icon状态改变为downloading
        self.iconImage.stauts = IconButtonStautsDownloading;
        
        //点击下载后改变button状态(下载中)
        InstallButton * button = sender;
        button.btnStatus = InstallButtonStateInstalling;
        
        CubeApplication *cubeApp = [CubeApplication currentApplication];
        CubeModule *downloadModule = [cubeApp availableModuleForIdentifier:_curCubeModlue.identifier];
        
        if(!downloadModule){
            
            downloadModule = [cubeApp updatableModuleModuleForIdentifier:_curCubeModlue.identifier];
        }
        //如果已经在下载,返回
        if(downloadModule.isDownloading)
            return;
        
        if (self.delegate&&[self.delegate respondsToSelector:@selector(downloadAtModuleIdentifier:andCategory:)])  {
            [self.delegate downloadAtModuleIdentifier:_curCubeModlue.identifier andCategory:_curCubeModlue.category];
        }
    }
}



//请求快照图片地址数据
-(void)loadImageData{
    
    self.iconImage.badgeView.hidden = YES;
    
    HTTPRequest* request = [HTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/%d%@?appKey=%@",kServerURLString,kURL_PATH1,self.identifier,self.curCubeModlue.build,kURL_PATH2, kAPPKey]]];
    __block HTTPRequest*  __request=request;


    [request setCompletionBlock:^{
        [__request setFailedBlock:nil];
        [self getResult:__request];
    }];
    [request setFailedBlock:^{
        [__request setCompletionBlock:nil];
        [self getFailMessage:__request];
    }];
    
    [[DownloadManager instance] addOperation:request forIdentifier:kLoadIconOperationKey];
}

//取得请求数据 提醒scrollview更新
-(void)getResult:(HTTPRequest *)request{
    NSData *data = [request responseData];
    NSArray *array = [data objectFromJSONData];
    for(NSDictionary *dict in array){
        NSString *attachment = [dict objectForKey:@"snapshot"];
        NSString *urlStr  = [NSString stringWithFormat:@"%@/storage/attachments/%@",kServerURLString,attachment];
        [self.iconUrlArr addObject:urlStr];
    }
    [self loadImage];
}

-(void)loadImage{
    if ([self.iconUrlArr count]!= 0 ) {
        //计算图片的高度
        if (CDV_IsIPhone5()) {
            self.pageControl = [[NativePageControl alloc]initWithFrame:CGRectMake(0,568*0.9 + 169, 320, 20)];
            [self.mainScrollView setContentSize: CGSizeMake(self.view.frame.size.width, 568 *0.9 +20 + 169 )];
            self.scorllImageView.frame = CGRectMake(self.scorllImageView.frame.origin.x, self.scorllImageView.frame.origin.y, 320, 568 *0.9 +30) ;
            
            self.imageScrollView.frame = CGRectMake(0, 169, 320, 568 *0.9 );
            [self.imageScrollView setContentSize:CGSizeMake(self.view.frame.size.width * [self.iconUrlArr count],568 *0.9 )];
            
        }else{
            self.pageControl = [[NativePageControl alloc]initWithFrame:CGRectMake(0, 480*0.9 + 169, 320, 20)];
            //设置竖向滚动范围
            [self.mainScrollView setContentSize: CGSizeMake(self.view.frame.size.width,480 *0.9 +20 +169)];
            //设置图片滚动底图
            self.scorllImageView.frame = CGRectMake(self.scorllImageView.frame.origin.x, self.scorllImageView.frame.origin.y, 320, 480 *0.9 +30) ;
            //设置图片滚动的大小 还有滚动大小
            self.imageScrollView.frame = CGRectMake(0, 169, 320, 480*0.9);
            [self.imageScrollView setContentSize:CGSizeMake(self.view.frame.size.width * [self.iconUrlArr count], 480*0.9 )];
        }
        
        self.scorllImageView.image =  [self.scorllImageView.image stretchableImageWithLeftCapWidth:0 topCapHeight:40];
    }
    self.pageControl.numberOfPages=[self.iconUrlArr count];
    self.pageControl.currentPage=0;
    self.pageControl.imagePageStateNormal=[UIImage imageNamed:@"scorllview_dot_unchoose.png"];
    self.pageControl.imagePageStateHightlighted=[UIImage imageNamed:@"scorllview_dot_choose.png"];
    NSArray *subView = self.pageControl.subviews;     // UIPageControl的每个点
	for (int i = 0; i < [subView count]; i++) {
		UIImageView *dot = [subView objectAtIndex:i];
		dot.image = (self.pageControl.currentPage == i ? [UIImage imageNamed:@"scorllview_dot_choose.png"] : [UIImage imageNamed:@"scorllview_dot_unchoose.png"]);
	}
    [self addImageViewInScrollView];
}


-(void)addImageViewInScrollView{
    //图片左右间距
    float space = self.view.frame.size.width*0.1 /2;
    //图片宽度
    float imageWidth = self.view.frame.size.width * 0.9;
    float imageHeight;
    if (CDV_IsIPhone5()) {
        imageHeight = 0.9 * 568;
    }else{
        imageHeight = 0.9 * 480;
    }
   
    int i = 1;
    
    for (NSString * imageUrl in self.iconUrlArr) {
        //添加一个异步图片
        AsyncImageView *tempAsyncImageView=[[AsyncImageView alloc] init];
        CGFloat offsetX = space + (i-1)*space*2 + imageWidth * (i-1);
        
        tempAsyncImageView.frame = CGRectMake(offsetX,0,imageWidth,imageHeight);
        
        [tempAsyncImageView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [tempAsyncImageView.layer setBorderWidth:2.0];
        [tempAsyncImageView.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [tempAsyncImageView.layer setShadowOffset:CGSizeMake(0, 0)];
        [tempAsyncImageView.layer setShadowOpacity:0.5];
        [tempAsyncImageView.layer setShadowRadius:3.0];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString *token =  [defaults objectForKey:@"token"];
        NSString* url = [[self.iconUrlArr objectAtIndex:i-1] stringByAppendingFormat:@"?sessionKey=%@&appKey=%@",token,kAPPKey];
        [tempAsyncImageView loadImageWithURLString:url];
        [self.imageScrollView addSubview:tempAsyncImageView];
        
        i++;
    }
}

//请求数据失败
-(void)getFailMessage:(HTTPRequest *)request{
    /*UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"连接失败" message:@"网络问题或者服务器连接失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
     [alert show];
     [alert release];*/
}

-(NSMutableArray *)urlArrayForImages{
    return self.iconUrlArr;
}

#pragma mark -- alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1234) {
        if (buttonIndex==0) {
            [self synAppInfo];
        }
    }
    if(alertView.tag == 5){
        if(buttonIndex == 0){
            if (self.delegate&&[self.delegate respondsToSelector:@selector(deleteAtModuleIdentifier:)])  {
                [self.delegate deleteAtModuleIdentifier:_curCubeModlue.identifier];
                self.configButton.btnStatus = InstallButtonStateUninstall;
            }
        }
        self.configButton.btnStatus = InstallButtonStateInstalled;
    }
}




#pragma mark --- notification method
-(void)finishDownload:(id)sender
{
    //     kAlert(@"安装成功");
    _curTitle=EBTNDELETE;
    self.configButton.btnStatus = InstallButtonStateInstalled;
    
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(inStalledModuleIdentifierr:)] ) {
        [self.delegate inStalledModuleIdentifierr:self.curCubeModlue.identifier];
    }
}

-(void)finishDelete:(id)sender
{
    //    kAlert(@"删除成功");
    _curTitle=EBTNSYN;
    self.configButton.btnStatus = InstallButtonStateUninstall;
    [self synAppInfo];
    
}

-(void)failedDownload:(id)sender
{
    _curTitle=EBTNINSTALL;
    self.configButton.btnStatus = InstallButtonStateUninstall;
}

-(void)failedDelete:(id)sender
{
    kAlert(@"删除失败");
    _curTitle=EBTNSYN;
    self.configButton.btnStatus = InstallButtonStateInstalled;
    [self synAppInfo];
    
}

-(void)failedSyn:(id)sender
{
    if (!firstEnter) {
        kAlert(@"同步失败，请重试");
        
        _curTitle=EBTNSYN;
        //        self.configButton.btnStatus = InstallButtonStateSynFailed;
    }
}

-(void)finishSyn:(id)sender
{
    if (!firstEnter) {
        _curTitle=EBTNINSTALL;
        self.configButton.btnStatus = InstallButtonStateUninstall;
        //主要解决删除后，安装队列里面没有东东问题
        if (_curTitle==EBTNINSTALL) {
            for (CubeModule *tempModule in [[CubeApplication currentApplication] availableModules]) {
                if ([tempModule.identifier isEqualToString:_identifier]) {
                    self.curCubeModlue=tempModule;
                    break;
                }
            }
        }
        else if (_curTitle==EBTNUPDATE)
        {
            for (CubeModule *tempModule in [[CubeApplication currentApplication] updatableModules]) {
                if ([tempModule.identifier isEqualToString:_identifier]) {
                    self.curCubeModlue=tempModule;
                    break;
                }
            }
        }else
        {
            NSLog(@"do nothing");
        }
        
    }
}


#pragma mark ---  private method
//应用同步并刷新队列
- (void)synAppInfo
{
    [[CubeApplication currentApplication] sync];
}


//开启消息通知
-(void)enableDetialInfoNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishDelete:) name:KNOTIFICATION_DETIALPAGE_DELETESUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishDownload:) name:KNOTIFICATION_DETIALPAGE_INSTALLSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedDownload:) name:KNOTIFICATION_DETIALPAGE_INSTALLFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedDelete:) name:KNOTIFICATION_DETIALPAGE_DELETEFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishSyn:) name:KNOTIFICATION_DETIALPAGE_SYNSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedSyn:) name:KNOTIFICATION_DETIALPAGE_SYNFAILED object:nil];
}

//关闭消息通知
-(void)disableDetialInfoNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
