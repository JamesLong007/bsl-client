//
//  XMPPSqlManager.m
//  cube-ios
//
//  Created by 东 on 13-4-17.
//
//

#import "XMPPSqlManager.h"
sqlite3 * database;

@implementation XMPPSqlManager


+(void)openDataBase
{
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    
    NSUserDefaults * userDefaluts = [NSUserDefaults standardUserDefaults];
    
    NSString* loginUser = [userDefaluts objectForKey:@"LoginUser"];
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent: [NSString stringWithFormat:@"XMPPIM_%@.sqlite",loginUser]];
    
    if (sqlite3_open([databaseFilePath UTF8String], &database)==SQLITE_OK)
    {
        NSLog(@"open sqlite db ok.");
    }
    else
    {
        NSLog( @"can not open sqlite db " );
        
        //close database
        sqlite3_close(database);
    }
}


+(int)getMessageCount{
    int number=0;

    @autoreleasepool {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"RectangleChat" inManagedObjectContext:[ShareAppDelegate xmpp].managedObjectContext];
        [fetchRequest setEntity:entity];
        //排序
        NSSortDescriptor*sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"updateDate"ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1,nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSFetchedResultsController* fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[ShareAppDelegate xmpp].managedObjectContext sectionNameKeyPath:nil cacheName:@"rectangleTalk"];
        
        [fetchedResultsController performFetch:nil];
        NSArray *contentArray = [fetchedResultsController fetchedObjects];
        for(RectangleChat* obj in contentArray){
            number+=[obj.noReadMsgNumber intValue];
        }
    }

    return number;
    
    /*
    if(!database){
        [self openDataBase];
    }
    sqlite3_stmt *statement = nil;
    int success = sqlite3_prepare_v2(database, [@"select sum(ZuserMessageCount) from ZuserInfo  " UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"Error2: failed to excute the sql");
        return 0;
    }
    
    int count = 0;
    while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
    {
        count =sqlite3_column_int(statement, 0);
    
    }
    
    return count;
     */
}

+(int)getMEssageCOuntFromGroup:(NSString *)groupName{
    if(!database){
        [self openDataBase];
    }
    
    sqlite3_stmt *statement = nil;
    int success = sqlite3_prepare_v2(database, [  [ NSString stringWithFormat:@"select sum(ZuserMessageCount) from ZuserInfo where zusergroup = '%@'",groupName ] UTF8String], -1, &statement, NULL);
    if (success != SQLITE_OK) {
        NSLog(@"Error3: failed to excute the sql");
        return 0;
    }
    
    int count = 0;
    while (sqlite3_step(statement)==SQLITE_ROW)//SQLITE_OK SQLITE_ROW
    {
        count =sqlite3_column_int(statement, 0);
        
    }
    
    return count;
}

@end
