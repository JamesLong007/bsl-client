//
//  MessageRecordHeaderView.m
//  Cube-iOS
//
//  Created by chen shaomou on 2/1/13.
//
//

#import "MessageRecordHeaderView.h"
#import "Cache.h"

@implementation MessageRecordHeaderView
@synthesize isDeleteStatue;
@synthesize deleteBtn;
@synthesize delegate;
@synthesize moduleId;
@synthesize section;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_record_header_bg.png"]];
        
        [bg setFrame:self.frame];
        
        [self addSubview:bg];
        
        UIButton *button = [[UIButton alloc] initWithFrame:self.bounds];
        
        [button setBackgroundColor:[UIColor clearColor]];
        
        [button addTarget:self action:@selector(onshow) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)onshow{
    
//    NSLog(@"hello world");

    if(delegate){

        [delegate shouldShowCellInModule:moduleId atIndex:section];
    }
}


-(void)configureWithIconUrl:(NSString *)iconurl moduleName:(NSString *)name messageCount:(NSString *)count  sectionIndenx:(int)index{
    
//    if(iconurl){
//        NSData *iconImageData = [[Cache instance] dataForKey:iconurl];
//        if(iconImageData){
//            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:iconImageData]];
//            [imageView setFrame:CGRectMake(12, 6,25, 25)];
//            self.iconImageView = imageView;
//            [self addSubview:imageView];
//            [imageView setBackgroundColor:[UIColor clearColor]];
//            [imageView release];
//        }
//        
//    }
    //
    UILabel *moduleNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(43,6, 100, 25)];
    moduleNameLabel.text = name;
    [moduleNameLabel setFont:[UIFont systemFontOfSize:16]];
    self.moduleNameLabel = moduleNameLabel;
    [self addSubview:moduleNameLabel];
    [moduleNameLabel setBackgroundColor:[UIColor clearColor]];
   
    
    CGSize numSize = [count sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];
    numSize.width = numSize.width +4;
    UIImageView *countBg = [[UIImageView alloc] init];
    if (numSize.width >25) {
        countBg.image =  [UIImage imageNamed:@"messageDeleteSelect.png"];
    }else{
        countBg.image =   [UIImage imageNamed:@"message_record_header_count_bg.png"];
    }
    
    
    [countBg setFrame:CGRectMake(UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 228:428- (numSize.width>25?numSize.width:25),6,(numSize.width>25? numSize.width:25)+2, 25)];
    
    [self addSubview:countBg];
    
    UILabel *messageCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(1,0,numSize.width>25? numSize.width:25, 25)];
    
    [messageCountLabel setTextAlignment:NSTextAlignmentCenter];
    
    [messageCountLabel setTextColor:[UIColor whiteColor]];
    
    messageCountLabel.text = count;
    
    [messageCountLabel setFont:[UIFont systemFontOfSize:16]];
    
    self.messageCountLabel = messageCountLabel;
    
    [countBg addSubview:messageCountLabel];
    
    
    //
    [messageCountLabel setBackgroundColor:[UIColor clearColor]];
    //添加删除模块功能
    deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake( UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 268:468, 6, 25, 25)];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"messageDelete.png"] forState:UIControlStateNormal];
    [deleteBtn setTitle:@"清除" forState:UIControlStateSelected];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"messageDeleteSelect.png"] forState:UIControlStateSelected];
    
    //[deleteBtn addTarget:self action:@selector(deleteModule:) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.tag = index;
    [self addSubview:deleteBtn];
    
    
    UIControl* btnControl = [[UIControl alloc]initWithFrame:CGRectMake(countBg.frame.origin.x + countBg.frame.size.width, 0, UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 320:510 - countBg.frame.origin.x-countBg.frame.size.width, 36)];
    [btnControl addTarget:self action:@selector(deleteControl) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: btnControl];
}

-(void)configureWithIconUrl:(NSString *)iconurl moduleName:(NSString *)name messageCount:(NSString *)count  sectionIndenx:(int)index withUnReadCount:(NSString *)unReadCount{
    
    UILabel *moduleNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(43,6, 100, 25)];
    moduleNameLabel.text = name;
    [moduleNameLabel setFont:[UIFont systemFontOfSize:16]];
    self.moduleNameLabel = moduleNameLabel;
    [self addSubview:moduleNameLabel];
    [moduleNameLabel setBackgroundColor:[UIColor clearColor]];
    
    
    CGSize numSize = [count sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];
    numSize.width = numSize.width +4;
    UIImageView *countBg = [[UIImageView alloc] init];
    if (numSize.width >25) {
        countBg.image =  [UIImage imageNamed:@"messageDeleteSelect.png"];
    }else{
        countBg.image =   [UIImage imageNamed:@"message_record_header_count_bg.png"];
    }
    
    [countBg setFrame:CGRectMake(240- (numSize.width>25?numSize.width:25),6,(numSize.width>25? numSize.width:25)+2, 25)];
    
    [self addSubview:countBg];
    
    UILabel *messageCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(1,0,numSize.width>25? numSize.width:25, 25)];
    
    [messageCountLabel setTextAlignment:NSTextAlignmentCenter];
    
    [messageCountLabel setTextColor:[UIColor whiteColor]];
    
    messageCountLabel.text = count;
    messageCountLabel.backgroundColor =[UIColor clearColor];
    [messageCountLabel setFont:[UIFont systemFontOfSize:16]];
    
    self.messageCountLabel = messageCountLabel;
    
    [countBg addSubview:messageCountLabel];
    
    if([unReadCount intValue] > 0)
    {
        CGSize unReadnumSize = [unReadCount sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];
        unReadnumSize.width = unReadnumSize.width +4;
        UIImageView *unReadCountBg = [[UIImageView alloc] init];
        if (unReadnumSize.width >25) {
            unReadCountBg.image =  [UIImage imageNamed:@"messageDeleteSelect.png"];
        }else{
            unReadCountBg.image =   [UIImage imageNamed:@"message_record_header_count_bg.png"];
        }
        
        [unReadCountBg setFrame:CGRectMake(180- (unReadnumSize.width>25?unReadnumSize.width:25),6,(unReadnumSize.width>25? unReadnumSize.width:25)+2, 25)];
        unReadCountBg.backgroundColor = [UIColor clearColor];
        [self addSubview:unReadCountBg];
        
        
        UILabel *unReadmessageCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(1,0,unReadnumSize.width>25? unReadnumSize.width:25, 25)];
        
        [unReadmessageCountLabel setTextAlignment:NSTextAlignmentCenter];
        
        [unReadmessageCountLabel setTextColor:[UIColor redColor]];
        
        unReadmessageCountLabel.text = unReadCount;
        
        [unReadmessageCountLabel setFont:[UIFont systemFontOfSize:16]];
        unReadmessageCountLabel.backgroundColor = [UIColor clearColor];
        
        //    self.messageCountLabel = messageCountLabel;
        
        [unReadCountBg addSubview:unReadmessageCountLabel];
        
        
        //
        [unReadmessageCountLabel setBackgroundColor:[UIColor clearColor]];
        
    }
    
    
    
    //添加删除模块功能
    deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake( 268, 6, 25, 25)];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"messageDelete.png"] forState:UIControlStateNormal];
    [deleteBtn setTitle:@"清除" forState:UIControlStateSelected];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"messageDeleteSelect.png"] forState:UIControlStateSelected];
    
    //[deleteBtn addTarget:self action:@selector(deleteModule:) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.tag = index;
    [self addSubview:deleteBtn];
    
    
    UIControl* btnControl = [[UIControl alloc]initWithFrame:CGRectMake(countBg.frame.origin.x+countBg.frame.size.width, 0, 320 - countBg.frame.origin.x-countBg.frame.size.width, 36)];
    [btnControl addTarget:self action:@selector(deleteControl) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: btnControl];
}



-(void)deleteControl{
    if (deleteBtn.selected) {
        [delegate deleteModuleData:moduleId];
    }else{
        [UIView animateWithDuration:0.2 delay:0 options:0 animations:^(){
           [deleteBtn setSelected:YES];
            deleteBtn.frame = CGRectMake(deleteBtn.frame.origin.x-37+18, deleteBtn.frame.origin.y, 37, deleteBtn.frame.size.height);
        } completion:^(BOOL finished)
         {
             
         }];
        
    }
    
}

-(void)deleteModule:(id)sender{
    UIButton *button = (UIButton *)sender;
    if (button.selected) {
        button.enabled = NO;
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"messageDeleteSelect.png"] forState:UIControlStateNormal];
        [delegate deleteModuleData:moduleId];
    }else{
        [UIView animateWithDuration:0.2 delay:0 options:0 animations:^(){
            button.selected = !button.selected;
            button.frame = CGRectMake(button.frame.origin.x-37+18, button.frame.origin.y, 37, button.frame.size.height);
        } completion:^(BOOL finished)
        {
            
        }];
    }
}

@end
