//
//  RemoteDebuggerViewController.m
//  cube-ios
//
//  Created by apple2310 on 13-9-7.
//
//

#import "RemoteDebuggerViewController.h"
#import "DownloadedAsync.h"
//#import "RemoteDebugWebViewController.h"
#import "NSFileManager+Extra.h"
#import "CubeWebViewController.h"


//#define   TEXT_URL   @"http://localhost:3000/app.zip"

#define   TEXT_URL   @"http://%@/app.zip"

@interface RemoteDebuggerViewController ()<DownloadedAsyncDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
-(void)loadData;
@end

@implementation RemoteDebuggerViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    CGRect rect=self.view.frame;
    rect.size.height-=44.0f;
    self.view.frame=rect;
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 280.0f, 30.0f)];
    titleLabel.text=@"请输入主机域名";
    titleLabel.backgroundColor=[UIColor clearColor];
    [self.view addSubview:titleLabel];
    
    
    textField=[[UITextField alloc] initWithFrame:CGRectMake(20.0f, 60.0f, 280.0f, 30.0f)];
    textField.delegate=self;
    textField.text=@"127.0.0.1:3000";
    textField.borderStyle=UITextBorderStyleRoundedRect;
    textField.returnKeyType=UIReturnKeyDone;
    [self.view addSubview:textField];
    
    loadingView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingView.frame=CGRectMake(0.0f, 0.0f, 32.0f, 32.0f);
    loadingView.color=[UIColor blackColor];
    [self.view addSubview:loadingView];
    loadingView.center=CGPointMake(self.view.center.x, 160.0f);
    
    progrewwView=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [self.view addSubview:progrewwView];
    
    rect=progrewwView.frame;
    rect.origin.x=30.0f;
    rect.origin.y=CGRectGetMaxY(loadingView.frame)+30.0f;
    rect.size.width=self.view.frame.size.width-60.0f;
    progrewwView.frame=rect;

    
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    list=nil;
    [async cancel];
    async=nil;
}

-(void)dealloc{
    [async cancel];
}

#pragma mark  downloaded async  delegate


-(void)process:(DownloadedAsync*)__async now:(BOOL)now{
    progrewwView.progress=__async.downloadSize/__async.totalsize;
}

-(void)unzipBegin:(DownloadedAsync*)async{
    
}

-(void)finish:(DownloadedAsync*)__async success:(BOOL)success{
    
    self.view.userInteractionEnabled=YES;

    NSLog(@"ok now");
    [async cancel];
    async=nil;
    
    
    
    [loadingView stopAnimating];
    loadingView=nil;
    
    progrewwView=nil;
    

    titleLabel=nil;
    textField=nil;
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    list=[[NSMutableArray alloc] initWithCapacity:2];
    NSArray* array = [[NSFileManager defaultManager] subpathsAtPath: rootPath ];
    for(NSString* str in array){
        if([str rangeOfString:@"/"].length<1){
                        
            NSString* url=[rootPath stringByAppendingFormat:@"/%@/index.html",str];

            if([[NSFileManager defaultManager] fileExistsAtPath:url])
                [list addObject:str];
        }
    }
    
    UITableView* tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate=self;
    tableView.dataSource=self;
    [self.view addSubview:tableView];
}

#pragma mark   tableview delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell==nil){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSString* file=[list objectAtIndex:[indexPath row]];
    cell.textLabel.text=file;
    
    return cell;
}



- (NSString*)pathForResource:(NSString*)resourcepath wwwFolderName:(NSString*)wwwFolderName;{
    return [[[[NSFileManager applicationDocumentsDirectory]
              URLByAppendingPathComponent:wwwFolderName isDirectory:YES]
             URLByAppendingPathComponent:resourcepath] relativePath];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* file=[list objectAtIndex:[indexPath row]];

    NSString* url=[rootPath stringByAppendingFormat:@"/%@/index.html",file];
    CubeWebViewController *aCubeWebViewController  = [[CubeWebViewController alloc] init];
    //aCubeWebViewController.alwaysShowNavigationBar=YES;
    aCubeWebViewController.title=file;
    aCubeWebViewController.wwwFolderName = file;
    aCubeWebViewController.startPage = [[NSURL fileURLWithPath:url] absoluteString];
    [aCubeWebViewController loadWebPageWithUrl: [[NSURL fileURLWithPath:url] absoluteString] didFinishBlock: ^(){
       // aCubeWebViewController.view.frame=self.view.bounds;
      //  aCubeWebViewController.closeButton.hidden=YES;
    }didErrorBlock:^(){
    }];

    [self.navigationController pushViewController:aCubeWebViewController animated:YES];
}

#pragma mark  inputfield  delegate

- (BOOL)textFieldShouldReturn:(UITextField *)__textField{
    [__textField resignFirstResponder];
    hostname=__textField.text;
    [self loadData];

    return YES;
}

#pragma mark method

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [textField resignFirstResponder];
}

-(void)loadData{
    self.view.userInteractionEnabled=NO;
    [loadingView startAnimating];

    async=[[DownloadedAsync alloc] init];
    async.downloadUrl=[NSString stringWithFormat:TEXT_URL,hostname];
    
    rootPath=[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"remoteDebug"];
    
    [[NSFileManager defaultManager] removeItemAtPath:rootPath error:nil];
    async.downloadPath=rootPath;
    
    async.delegate=self;
    [async start];

}


@end
