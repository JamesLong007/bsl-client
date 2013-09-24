//
//  AnnouncementTableViewController.m
//  Cube-iOS
//
//  Created by chen shaomou on 2/5/13.
//
//

#import "AnnouncementTableViewController.h"
#import "AnnouncementTableViewCell.h"
#import "Announcement.h"
#import "NSManagedObject+Repository.h"
#import "MessageRecord.h"


#define RECORD_DELETE @"RECORD_DELETE"
@interface AnnouncementTableViewController ()

@end

@implementation AnnouncementTableViewController

@synthesize list,editing;
@synthesize recordId;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        [self.navigationItem setTitle:@"公告"];
        //覆盖屏蔽右边控制
        
        if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad) {
            self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleBordered target:self action:@selector(edit)];
        }
        else{
            UIButton *navRightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 43, 30)];
            [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn.png"] forState:UIControlStateNormal];
            [navRightButton setBackgroundImage:[UIImage imageNamed:@"nav_add_btn_active.png"] forState:UIControlStateSelected];
            [navRightButton setTitle:@"编辑" forState:UIControlStateNormal];
            [[navRightButton titleLabel] setFont:[UIFont systemFontOfSize:13]];
            [navRightButton addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
            
        }
        
        //[self.navigationItem setRightBarButtonItem:rightItem animated:YES];
        
        
        editing = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData:) name:ANNOUNCEMENT_DID_SAVE_NOTIFICATION object:nil];

    }
    return self;
}


-(void)edit{
    
    if(editing){
        editing = NO;
        [self.tableView setEditing:NO animated:YES];
        [self.tableView  reloadData];
    }else{
        editing = YES;
        [self.tableView setEditing:YES animated:YES];
        [self.tableView  reloadData];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:246/256.0 green:246/256.0 blue:246/256.0 alpha:1.0]];
    self.slideIndex = -1;
    self.list = [NSMutableArray arrayWithArray:[Announcement findAllOrderByReviceTime]];
    
    UIImageView* backgroundView  = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backgroundView.image = [UIImage imageNamed:@"homebackImg.png"];
    
    [self.tableView setBackgroundView:backgroundView];
    [self.tableView reloadData];
    //跳转到对应的公告记录
    if(self.recordId){
        for (Announcement *annouce in self.list)
        {
            if([annouce.announcementId isEqualToString:self.recordId])
            {
                self.slideIndex = [list indexOfObject:annouce];
                break;
            }
            
        }//公告不存在去服务器上获取
        if(self.slideIndex <= -1)
        {
            MessageRecord *messageRecord = [MessageRecord findMessageRecordByAnounceId:self.recordId];
            
            if(messageRecord && ![messageRecord.faceBackId isEqualToString:@""] && messageRecord.faceBackId)
            {
                UIActivityIndicatorView * indicator = [[UIActivityIndicatorView alloc]initWithFrame:self.view.frame];
                indicator.backgroundColor = [UIColor grayColor];
                [indicator hidesWhenStopped];
                [self.view addSubview:indicator];
                [Announcement requestAnnouncement:self.recordId withRecordId:messageRecord.faceBackId];
            }
            
        }
        else
        {
            self.isSliding = YES;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:self.slideIndex];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
        }
        
    }
}
//如果是最后一条公告不知道为什么总是显示不出来，所以做了一个判断如果是最后一条公告
//就把tableView 滑动到最低端让记录显示，这种情况只会出现在最后一条记录
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
	
	CGPoint offset = aScrollView.contentOffset;
	CGRect bounds = aScrollView.bounds;
	CGSize size = aScrollView.contentSize;
	UIEdgeInsets inset = aScrollView.contentInset;
	float y = offset.y + bounds.size.height - inset.bottom;
	float h = size.height;
    
    if(self.isSliding)
    {
        if(self.slideIndex == list.count -1)
        {
            self.isSliding = NO;
            float reload_distance = 10;
            if(y <= h + reload_distance) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:self.slideIndex];
                float he = [self.tableView cellForRowAtIndexPath:path].frame.size.height;
                float yh = self.tableView.contentOffset.y + he + 20;
                [self.tableView setContentOffset:CGPointMake(0, yh) animated:YES];
            }
        }
    }
    
	
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadData:(NSNotification*)notification{
    
    self.list = [NSMutableArray arrayWithArray:[Announcement findAllOrderByReviceTime]];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [list count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    AnnouncementTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AnnouncementTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    
    [cell configoure:[list objectAtIndex:indexPath.section]  isEdit:editing];
    
    Announcement* announcement = [list objectAtIndex:indexPath.section];
    
    cell.titleLabel.text = announcement.title;
   
    cell.contentLabel.text = announcement.content;
    
    CGFloat oneLineHeight = [announcement.content sizeWithFont:cell.contentLabel.font
                                                      forWidth:320-40
                                                 lineBreakMode:NSLineBreakByTruncatingTail].height;
    
    //多行高度
    CGFloat multiLineHeight = [announcement.content sizeWithFont:cell.contentLabel.font
                                               constrainedToSize:CGSizeMake(320-40, 99999)
                                                   lineBreakMode:NSLineBreakByTruncatingTail].height;
    
    //重设caption高度
    CGFloat finalCaptionHeight = (cell.contentLabel.numberOfLines == 1) ? oneLineHeight : multiLineHeight;
    [cell.contentLabel setFrame:CGRectMake(cell.contentLabel.frame.origin.x, cell.contentLabel.frame.origin.y, cell.contentLabel.frame.size.width, finalCaptionHeight)];
    
    cell.timeLabel.frame = CGRectMake(180+(UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 0:150),cell.contentLabel.frame.origin.y+ finalCaptionHeight+10, 166, 17);
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    [cell.timeLabel setText:[df stringFromDate:announcement.reviceTime]];
    if(announcement.isRead == 0){
        [cell.isReadLabel setText:@"未读"];
        cell.isReadLabel.textColor = [UIColor blueColor];
    }else{
        [cell.isReadLabel setText:@"已读"];
        cell.isReadLabel.textColor = [UIColor blackColor];
    }
    finalCaptionHeight = finalCaptionHeight + cell.contentLabel.frame.origin.y +34+5+10-17;
    
     [cell setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width,finalCaptionHeight)];

    
    return cell;
    
}



- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    //连续删除会导致公告里面的内容向右边便宜
//    AnnouncementTableViewCell *cell  = (AnnouncementTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//    if (editing) {
//        [cell moveView];
//    }
    return UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Announcement *announcement = [list objectAtIndex:indexPath.section];
        NSString *announceId = [announcement announcementId];
        [list removeObjectAtIndex:indexPath.section];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [announcement remove];
        
        //删除消息中心对应的记录
        MessageRecord *messageRecord = [MessageRecord findMessageRecordByAnounceId:announceId];
        if(messageRecord)
        {
            NSString *sendId = messageRecord.faceBackId;
            [messageRecord remove];
            [[NSNotificationCenter defaultCenter] postNotificationName:RECORD_DELETE object:sendId];
            self.recordId=nil;
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
       
    }
}


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Announcement *announcement = [list objectAtIndex:indexPath.section];
    
    [announcement setIsRead:[NSNumber numberWithBool:YES]];
    
    [announcement save];
    
    AnnouncementTableViewCell *cell = (AnnouncementTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [cell.isReadLabel setText:@"已读"];
    cell.isReadLabel.textColor = [UIColor blackColor];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    //更新消息为已读这种实现方式比较挫，更换FMDB后直接用sql语句更新效率更高
    for (Announcement * announcement in list) {
        [announcement setIsRead:[NSNumber numberWithBool:YES]];
        [announcement save];
    }
    
}
@end
