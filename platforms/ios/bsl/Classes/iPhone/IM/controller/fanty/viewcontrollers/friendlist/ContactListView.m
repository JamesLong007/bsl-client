//
//  ContactListView.m
//  cube-ios
//
//  Created by apple2310 on 13-9-12.
//
//

#import "ContactListView.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
#import "SVProgressHUD.h"
#import "TouchScroller.h"
#import "ContactCell.h"


NSInteger contactListViewSort(id obj1, id obj2,void* context){
    UserInfo* info=(UserInfo*)obj1;
    if([info.userStatue length]>0)
        return (NSComparisonResult)NSOrderedAscending;
    else
    return (NSComparisonResult)NSOrderedDescending;
};


@interface ContactListView()<UITableViewDataSource,UITableViewDelegate,ChatDelegate,NSFetchedResultsControllerDelegate,UISearchBarDelegate,TouchScrollerDelegate>{

    BOOL isLoadingUserInfo;
    BOOL isFirstLoadData;

    NSManagedObjectContext *managedObjectContext;
    
    NSFetchedResultsController *fetchedResultsController;
    
    NSMutableDictionary *friendsListDict;
    
    NSArray*  headerArray;
    NSArray* friendList;

    
    int selectedIndex;
}

-(void)getFriendsUserInfo;
-(void)headerClick:(UIButton*)button;
-(void)showLoadData;
-(void)delayReloadTimeEvent;

@end

@implementation ContactListView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        selectedIndex=0;
        isFirstLoadData=YES;
        self.userInteractionEnabled=YES;
        friendsListDict=[[NSMutableDictionary alloc] initWithCapacity:2];
        managedObjectContext = [ShareAppDelegate xmpp].managedObjectContext;
        
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:20];
        //排序
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userGroup" ascending:YES] ;
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"userStatue" ascending:NO];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"userName" ascending:NO];
        
        NSArray *sortDescriptors = @[sortDescriptor,sortDescriptor1,sortDescriptor2];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"userGroup" cacheName:@"userGroup"];
        fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }

        searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 44.0f)];
        searchBar.barStyle=UIBarStyleBlackTranslucent;
        searchBar.delegate=self;
        [self addSubview:searchBar];
        
        tableView=[[TouchTableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(searchBar.frame), frame.size.width, frame.size.height-CGRectGetMaxY(searchBar.frame)) style:UITableViewStylePlain];
        tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        tableView.dataSource=self;
        tableView.delegate=self;
        tableView.touchDelegate=self;
        [self addSubview:tableView];

        AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        del.xmpp.chatDelegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(starRefresh) name:@"STARTRREFRESHTABLEVIEW" object:nil];

        [self delayReloadTimeEvent];
    }
    return self;
}

- (void)dealloc{
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }

    managedObjectContext=nil;
    fetchedResultsController.delegate=nil;
    fetchedResultsController=nil;
    [laterReloadTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    del.xmpp.chatDelegate = nil;
}

-(NSDictionary*)friendsList{
    return  friendsListDict;
}

-(void)loadData{
    if(isFirstLoadData || [[fetchedResultsController sections] count]== 0){
        isFirstLoadData=NO;
        if ([[ShareAppDelegate xmpp] isConnected]) {
            [[ShareAppDelegate xmpp] findFriendsList];
            [SVProgressHUD showWithStatus:@"正在获取好友列表..."];
        }else{
            [SVProgressHUD showErrorWithStatus:@"即时通讯没有连接！"];
        }
        
    }
}

-(void)showLoadData{
    NSString* searchText=searchBar.text;
    headerArray=nil;
    friendList=nil;
    if([searchText length]<1){
        headerArray=[friendsListDict allKeys] ;
        if(selectedIndex>-1 && selectedIndex<[headerArray count]){
            NSString* key=[headerArray objectAtIndex:selectedIndex];
            friendList=[friendsListDict objectForKey:key] ;
        }
    }
    else{
        headerArray=[NSArray arrayWithObjects:@"搜索结果", nil] ;
        NSMutableArray* list=[[NSMutableArray alloc] initWithCapacity:2];
        for(NSArray* array in [friendsListDict allValues]){
            for(UserInfo* userInfo in array){
                if([[[userInfo name] lowercaseString] rangeOfString:searchText].length>0){
                    [list addObject:userInfo];
                }
            }
        }
        friendList=[list sortedArrayUsingFunction:contactListViewSort context:nil];
    }
    [tableView reloadData];
}

-(void)starRefresh{
    if(isLoadingUserInfo)return;
    
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
    [self showLoadData];
    [self getFriendsUserInfo];
}

-(void)getFriendsUserInfo{
    if(isLoadingUserInfo)return;
    isLoadingUserInfo=YES;
    NSLog(@"读取数组");
    NSMutableArray* userArray = [[NSMutableArray alloc]init];
    for ( id <NSFetchedResultsSectionInfo> sectionInfo in [fetchedResultsController sections]) {
        for (UserInfo* userInfo in [sectionInfo objects]) {
            if (!userInfo.userSex || userInfo.userSex.length == 0) {
                [userArray addObject:userInfo];
            }
        }
    }
    NSLog(@"读取数组完成 条数为%d",[userArray count]);
    if([userArray count]>0){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{            
            //开异步读取好友VCard
            AppDelegate *del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            for (UserInfo* userInfo in userArray) {
                if(self.superview==nil)break;
                if (!del.xmpp.xmppvCardTempModule) {
                    [del.xmpp newvCard];
                }
                XMPPvCardTemp * xmppvCardTemp =[ del.xmpp.xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:userInfo.userJid]];
                NSString*useSex =  [[[xmppvCardTemp elementForName:@"N"] elementForName:@"MIDDLE"] stringValue];
                userInfo.userSex = useSex;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [managedObjectContext save:nil];
//                userArray=nil;
                [self showLoadData];
                isLoadingUserInfo=NO;
            });
        });
    }
    else{
        userArray=nil;
        isLoadingUserInfo=NO;
    }
    
    
}


- (UIImage *)imageTransform:(UIImage *)image rotation:(UIImageOrientation)orientation{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newPic;
}

-(void)headerClick:(UIButton*)button{
    if(selectedIndex==button.tag)
        selectedIndex=-1;
    else
        selectedIndex=button.tag;
    [self showLoadData];
}

-(void)delayReloadTimeEvent{
    [laterReloadTimer invalidate];
    laterReloadTimer=nil;
    [friendsListDict removeAllObjects];
    
    for(id<NSFetchedResultsSectionInfo> sectionInfo in [fetchedResultsController sections]){
        NSString* key=NSLocalizedString([sectionInfo name],nil);
        
        NSMutableArray* array=[[NSMutableArray alloc] initWithCapacity:2];
        for(UserInfo* info in [fetchedResultsController fetchedObjects]){
            if([info.userGroup isEqualToString:key]){
                [array addObject:info];
            }
        }
        
        NSArray* __array=[array sortedArrayUsingFunction:contactListViewSort context:nil];
        [friendsListDict setObject:__array forKey:key];
    }
    [self showLoadData];
}

#pragma mark  catdelegate

-(void)showFriends:(NSXMLElement*)element{
    
    NSArray *items = [element elementsForName:@"item"];
    for (int textIndex=0 ; textIndex < [items count] ; textIndex ++){
        NSXMLElement *item=(NSXMLElement *)[items objectAtIndex:textIndex];
        NSString *group=[[item elementForName:@"group"] stringValue];
        if (group == nil || [group isEqualToString:@""]) {
            group = @"好友列表";
        }
        //先判断jid是否存在
        NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
        NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
        
        NSEntityDescription *entityDescription = [[fetchedResultsController fetchRequest] entity];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(userJid = %@ )",[[item attributeForName:@"jid"] stringValue],[[item attributeForName:@"group"] stringValue]];
        [request setPredicate:pred];
        NSError *error = nil;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        if (objects != nil && [objects count] != 0) {
        }else{
            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
            [newManagedObject setValue:group forKey:@"userGroup"];
            [newManagedObject setValue:[[item attributeForName:@"name"] stringValue] forKey:@"userName"];
            [newManagedObject setValue:[[item attributeForName:@"jid"] stringValue] forKey:@"userJid"];
            [newManagedObject setValue:[[item attributeForName:@"subscription"] stringValue] forKey:@"userSubscription"];
            // Save the context.
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        
    }
}

#pragma mark  fetchedresultscontroller  delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath{
    
    [laterReloadTimer invalidate];
    laterReloadTimer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayReloadTimeEvent) userInfo:nil repeats:NO];
}


#pragma mark  tableview delegate

- (void)tableView:(UIScrollView *)tableView
     touchesBegan:(NSSet *)touches
        withEvent:(UIEvent *)event{
    [searchBar resignFirstResponder];
    
    if([self.delegate respondsToSelector:@selector(contactListDidTouch:)])
        [self.delegate contactListDidTouch:self];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [searchBar resignFirstResponder];
    if([self.delegate respondsToSelector:@selector(contactListDidTouch:)])
        [self.delegate contactListDidTouch:self];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  [headerArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    if([searchBar.text length]<1){
        NSString* key=[headerArray objectAtIndex:section];
        UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(0.0f, 0.0f, self.frame.size.width, 40.0f);
        button.tag=section;
        [button addTarget:self action:@selector(headerClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"table_header.png"] forState:UIControlStateNormal];
        
        UIImageView* arrowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"xmpp_arrow.png"]];
        CGRect rect=arrowImageView.frame;
        rect.size.width=13.0f;
        rect.size.height=13.0f;
        rect.origin.x=10.0f;
        rect.origin.y=(button.frame.size.height-rect.size.height)*0.5f-6.0f;
        arrowImageView.frame= rect;
        [button addSubview:arrowImageView];
        if (selectedIndex == section) {
            arrowImageView.image  = [self imageTransform:arrowImageView.image rotation:UIImageOrientationRight];
        }
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(arrowImageView.frame)+10.0f, 0, button.frame.size.width-CGRectGetMaxX(arrowImageView.frame)-10.0f, 24.0f)];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.shadowColor=[UIColor blackColor];
        titleLabel.shadowOffset=CGSizeMake(0.0f, 0.5f);
        titleLabel.font=[UIFont boldSystemFontOfSize:15.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text=key;
        [button addSubview:titleLabel];
        return button;
    }
    else{
        NSString* key=[headerArray objectAtIndex:section];
        UIImageView* view =[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 40.0f)];
        view.image=[UIImage imageNamed:@"table_header.png"];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0, view.frame.size.width-20.0f, 24.0f)];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.shadowColor=[UIColor blackColor];
        titleLabel.shadowOffset=CGSizeMake(0.0f, 0.5f);
        titleLabel.font=[UIFont boldSystemFontOfSize:15.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text=key;
        [view addSubview:titleLabel];
        
        return view;

    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ContactCell height];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([searchBar.text length]<1 && section==selectedIndex)
        return [friendList count];
    else if([searchBar.text length]>0)
        return [friendList count];
    return 0.0f;
}

-(UITableViewCell*)tableView:(UITableView *)__tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContactCell *cell = (ContactCell*)[__tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] ;
    }
    UserInfo* user=[friendList objectAtIndex:[indexPath row]];
    [cell headerUrl:@"" nickname:[user name]];
    
    if ([user.userSex isEqualToString:@"female"]) {
        if ([user.userStatue length] > 0 ) {
            [cell loadingImage:@"chatroom_female_online.jpg"];
        }else{
            [cell loadingImage:@"chatroom_female_outline.jpg"];
        }
        
    }else if([user.userSex isEqualToString:@"male"]){
        if ([user.userStatue length] > 0 ) {
            [cell loadingImage:@"chatroom_male_online.jpg"];

        }else{
            [cell loadingImage:@"chatroom_male_outline.jpg"];

        }
    }else{
        if ([user.userStatue length] > 0 ) {
            [cell loadingImage:@"chatroom_unknow_online.jpg"];
        }
        else{
            [cell loadingImage:@"NoHeaderImge.png"];
        }
    }

    
    
    return cell;

}

-(void)tableView:(UITableView *)__tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [__tableView deselectRowAtIndexPath:indexPath animated:YES];
    [searchBar resignFirstResponder];    
    UserInfo* user=[friendList objectAtIndex:[indexPath row]];
    if([self.delegate respondsToSelector:@selector(contactListDidSelected:userInfo:)])
        [self.delegate contactListDidSelected:self userInfo:user];
}


#pragma mark searchbar delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)_searchBar{
    //  [searchBar setShowsCancelButton:YES animated:YES];
    
    if([self.delegate respondsToSelector:@selector(contactListDidSearchShouldBeginEditing:searchBar:)])
        [self.delegate contactListDidSearchShouldBeginEditing:self searchBar:searchBar];
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)__searchBar{
    for(id cc in [__searchBar subviews]){
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
        }
    }
}

- (void)searchBar:(UISearchBar *)__searchBar textDidChange:(NSString *)searchText{
    
    if([self.delegate respondsToSelector:@selector(contactListSearchBarTextChanged:searchBar:)])
        [self.delegate contactListSearchBarTextChanged:self searchBar:searchBar];

    [self showLoadData];
    [searchBar becomeFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar{
    if([self.delegate respondsToSelector:@selector(contactListSearchBarSearchButtonClicked:searchBar:)])
        [self.delegate contactListSearchBarSearchButtonClicked:self searchBar:searchBar];

}
- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar{
    searchBar.text=nil;
    [self showLoadData];
    if([self.delegate respondsToSelector:@selector(contactListSearchBarCancelButtonClicked:searchBar:)])
        [self.delegate contactListSearchBarCancelButtonClicked:self searchBar:searchBar];
}


@end
