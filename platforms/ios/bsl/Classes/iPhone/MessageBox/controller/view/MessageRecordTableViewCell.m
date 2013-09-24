//
//  MessageRecordTableViewCell.m
//  Cube-iOS
//
//  Created by chen shaomou on 2/1/13.
//
//

#import "MessageRecordTableViewCell.h"
#import "UIColor+expanded.h"

@implementation MessageRecordTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)configureWithModuleName:(NSString *)moduleName reviceTime:(NSDate *)reviceTime alert:(NSString *)alert{
    if(!_moduleNameLabel){
        
        UILabel *moduleNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(14,13, 203, 16)];
        
        self.moduleNameLabel = moduleNameLabel;
        
        
    }
    
    [_moduleNameLabel setText:moduleName];
    _moduleNameLabel.backgroundColor = [UIColor clearColor];
    [_moduleNameLabel setTextColor:[UIColor darkGrayColor]];
    
    [_moduleNameLabel setFont:[UIFont systemFontOfSize:15]];
    
    [self addSubview:_moduleNameLabel];
    
    if(!_reviceTimeLabel){
        UILabel *reviceTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone ? 239:439, 15, 61, 11)];
        self.reviceTimeLabel = reviceTimeLabel;
    }
    
    [_reviceTimeLabel setFont:[UIFont systemFontOfSize:13]];
    
    [_reviceTimeLabel setTextColor:[UIColor darkGrayColor]];
    
    [_reviceTimeLabel setTextAlignment:NSTextAlignmentRight];
    
    //NSTimeInterval timeGap = [reviceTime timeIntervalSinceNow];
    
    NSTimeInterval timeGap = [[NSDate date] timeIntervalSinceDate:reviceTime];
    
    if(timeGap < 60){
        
        [_reviceTimeLabel setText:[NSString stringWithFormat:@"%d 秒前",(int)timeGap]];
    }
    
    else if(timeGap > 60 && timeGap < 60*60){
        
        [_reviceTimeLabel setText:[NSString stringWithFormat:@"%d 分钟前",(int)(timeGap/60)]];
    }
    
    else if(timeGap >  60*60 && timeGap < 60*60*24){
        
        [_reviceTimeLabel setText:[NSString stringWithFormat:@"%d 小时前",(int)(timeGap/(60*60))]];
    }
    
    else if(timeGap >  60*60*24 && timeGap < 60*60*24*30){
        
        [_reviceTimeLabel setText:[NSString stringWithFormat:@"%d 天前",(int)(timeGap/(60*60*24))]];
    }
    
    else if(timeGap >  60*60*24*30 && timeGap < 60*60*24*30*365){
        
        [_reviceTimeLabel setText:[NSString stringWithFormat:@"%d 月前",(int)(timeGap/(60*60*24*30))]];
    }
    
    else if(timeGap > 60*60*24*30*365){
        
        [_reviceTimeLabel setText:[NSString stringWithFormat:@"%d 年前",(int)(timeGap/(60*60*24*30*365))]];
    }
    
    if(!self.isReadLabel)
    {
        UILabel *readLabel = [[UILabel alloc]initWithFrame:CGRectMake(255, 28, 40, 20)];
        self.isReadLabel = readLabel;
        self.isReadLabel.font =[UIFont systemFontOfSize:12];
        self.isReadLabel.backgroundColor =[UIColor clearColor];
        self.isReadLabel.textColor =[UIColor redColor];
    }
    [self addSubview:self.isReadLabel];
    
    [self addSubview:_reviceTimeLabel];
    
    if(!_alertLabel){
        UILabel *alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 34, 222, 28)];
        self.alertLabel = alertLabel;
    }
    
    [_alertLabel setNumberOfLines:0];
    
    [_alertLabel setFont:[UIFont boldSystemFontOfSize:13]];
    
    [_alertLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [_alertLabel setText:alert];
    
    //一行高度
    CGFloat oneLineHeight = [_alertLabel.text sizeWithFont:_alertLabel.font
                                                  forWidth:CGRectGetWidth(_alertLabel.frame)
                                             lineBreakMode:NSLineBreakByTruncatingTail].height;
    //多行高度
    CGFloat multiLineHeight = [_alertLabel.text sizeWithFont:_alertLabel.font
                                           constrainedToSize:CGSizeMake(CGRectGetWidth(_alertLabel.frame), 99999)
                                               lineBreakMode:NSLineBreakByTruncatingTail].height;
    //重设caption高度
    CGFloat finalCaptionHeight = (_alertLabel.numberOfLines == 1) ? oneLineHeight : multiLineHeight;
    
    [_alertLabel setFrame:CGRectMake(_alertLabel.frame.origin.x, _alertLabel.frame.origin.y, _alertLabel.frame.size.width, finalCaptionHeight)];
    
    [self addSubview:_alertLabel];
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 82.0 + finalCaptionHeight - 28)];
}

@end
