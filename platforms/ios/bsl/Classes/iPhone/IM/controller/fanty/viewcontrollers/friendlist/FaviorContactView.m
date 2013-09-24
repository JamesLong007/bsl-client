//
//  FaviorContactView.m
//  cube-ios
//
//  Created by apple2310 on 13-9-12.
//
//

#import "FaviorContactView.h"

#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
#import "SVProgressHUD.h"
#import "TouchScroller.h"
#import "ContactCell.h"


@interface FaviorContactView()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>{
    NSManagedObjectContext *managedObjectContext;
    
    NSFetchedResultsController *fetchedResultsController;
    
}

-(void)delayReloadTimeEvent;
@end

@implementation FaviorContactView
@synthesize faviorDelegate;
@synthesize isEdit;
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        // Initialization code
        self.dataSource=self;
        self.delegate=self;
        self.separatorStyle=UITableViewCellSeparatorStyleNone;
        
        list=[[NSMutableArray alloc] initWithCapacity:2];
        managedObjectContext = [ShareAppDelegate xmpp].managedObjectContext;
        
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FaviorUserInfo" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:20];
        //排序
        
        NSSortDescriptor*sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"userJid"ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1,nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"faviorUserInfo"];
        fetchedResultsController.delegate = self;
        
        [fetchedResultsController performFetch:nil];
        NSArray *contentArray = [fetchedResultsController fetchedObjects];
        for(id obj in contentArray){
            [list addObject:obj];
        }
        
        
    }
    return self;
}

- (void)dealloc{
    [laterReloadTimer invalidate];
    fetchedResultsController.delegate=nil;
}

#pragma mark method

-(void)loadData{
    
}

-(void)delayReloadTimeEvent{
    [laterReloadTimer invalidate];
    laterReloadTimer=nil;
    [self reloadData];
}

-(void)layoutTableCell{
    
    for(int i=0;i<[list count];i++){
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        ContactCell* cell = (ContactCell*)[self cellForRowAtIndexPath:indexPath];
        [cell layoutUI:self.editing animated:YES];
    }
     
}


#pragma mark tableview delegate  datasource

-(NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexpath{
    return @"删除";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [list count];
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ContactCell height];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ContactCell *cell = (ContactCell*)[_tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    UserInfo* model=[list objectAtIndex:[indexPath row]];
    [cell headerUrl:@"" nickname:[model name]];
    cell.editing=self.editing;
    return cell;
}


-(void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserInfo* model=[list objectAtIndex:[indexPath row]];
    
    if([self.faviorDelegate respondsToSelector:@selector(faviorContactViewDidSelected:userInfo:)])
        [self.faviorDelegate faviorContactViewDidSelected:self userInfo:model];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.editing)
        return UITableViewCellEditingStyleDelete;
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        if([self.faviorDelegate respondsToSelector:@selector(faviorContactViewDidDelete:userInfo:)])
            [self.faviorDelegate faviorContactViewDidDelete:self userInfo: [list objectAtIndex:[indexPath row]]];
    }
    
}



#pragma mark  fetchedresultscontroller  delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    if(![anObject isKindOfClass:[UserInfo class]])return;
    if (type==NSFetchedResultsChangeInsert) {
        
        UserInfo* removeInfo=(UserInfo*)anObject;
        for(UserInfo* info in list){
            if([info.userJid isEqualToString:removeInfo.userJid]){
                [list removeObject:info];
                break;
            }
        }
        
        [list insertObject:anObject atIndex:0];        
        [laterReloadTimer invalidate];
        laterReloadTimer=[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(delayReloadTimeEvent) userInfo:nil repeats:NO];
        
    }else if (type==NSFetchedResultsChangeUpdate) {
        UserInfo* updateInfo=(UserInfo*)anObject;
        [list enumerateObjectsUsingBlock:^(id obj,NSUInteger index,BOOL* stop){
            UserInfo* info=obj;
            if([info.userJid isEqualToString:updateInfo.userJid]){
                *stop=YES;
                [list removeObject:info];
                [list insertObject:updateInfo atIndex:index];
                return ;
            }
        }];
        [laterReloadTimer invalidate];
        laterReloadTimer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayReloadTimeEvent) userInfo:nil repeats:NO];
    }
    else if(type==NSFetchedResultsChangeDelete){
        int index=0;
        BOOL isDel=NO;
        UserInfo* removeInfo=(UserInfo*)anObject;
        for(UserInfo* info in list){
            if([info.userJid isEqualToString:removeInfo.userJid]){
                isDel=YES;
                [list removeObject:info];
                break;
            }
            index++;
        }
        [laterReloadTimer invalidate];
        laterReloadTimer=nil;
        if(isDel){
            [self deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:index inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else if(type==NSFetchedResultsChangeMove){
        
    }
}

@end
