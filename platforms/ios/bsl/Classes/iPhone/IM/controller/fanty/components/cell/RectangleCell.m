//
//  RectangleCell.m
//  WeChat
//
//  Created by apple2310 on 13-9-4.
//  Copyright (c) 2013年 apple2310. All rights reserved.
//

#import "RectangleCell.h"
#import "ImageDownloadedView.h"
#import "NumberView.h"
#define   CELL_HEIGHT   65.0f

@implementation RectangleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType=UITableViewCellAccessoryNone;
        self.selectionStyle=UITableViewCellSelectionStyleBlue;
        UIImageView* bgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contact_bg.png"]];
        self.backgroundView=bgView;
        

        imageView=[[ImageDownloadedView alloc] initWithFrame:CGRectMake(9.0f, 10.0f, 45.0f,45.0f)];
        imageView.radius=5.0f;
        [self addSubview:imageView];
        
        numberView=[[NumberView alloc] init];
        [imageView addSubview:numberView];
        
        CGRect rect=numberView.frame;
        rect.origin.x=imageView.frame.size.width-rect.size.width*0.6f;
        rect.origin.y=-rect.size.height*0.5f;
        numberView.frame=rect;


        
        dateLabel=[[UILabel alloc] initWithFrame:CGRectMake(320.0f-9.0f-80.0f, CGRectGetMinY(imageView.frame), 80.0f, 20.0f)];
        dateLabel.numberOfLines=1;
        dateLabel.textAlignment=NSTextAlignmentRight;
        dateLabel.font=[UIFont fontWithName:@"Helvetica" size:12.0f];
        dateLabel.textColor=[UIColor grayColor];
        dateLabel.backgroundColor=[UIColor clearColor];
        
        
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+12.0f, CGRectGetMinY(imageView.frame), CGRectGetMinX(dateLabel.frame)-CGRectGetMaxX(imageView.frame), 20.0f)];
        titleLabel.numberOfLines=1;
        titleLabel.font=[UIFont fontWithName:@"Helvetica" size:17.0f];
        titleLabel.textColor=[UIColor blackColor];
        titleLabel.backgroundColor=[UIColor clearColor];

        [self addSubview:titleLabel];
        
        contentLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+12.0f, 35.0f, 0.0f, 18.0f)];
        contentLabel.numberOfLines=1;
        contentLabel.font=[UIFont fontWithName:@"Helvetica" size:15.0f];
        contentLabel.textColor=[UIColor grayColor];
        contentLabel.backgroundColor=[UIColor clearColor];

        [self addSubview:contentLabel];
        
        contentImageView=[[UIImageView alloc] init];
        [self addSubview:contentImageView];
        

        [self addSubview:dateLabel];
        
        lineView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AlbumListLine.png"]];
        rect=lineView.frame;
        rect.origin.y=CELL_HEIGHT-rect.size.height;
        lineView.frame=rect;
        [self addSubview:lineView];
    }
    return self;
}

+(float)height{
    return CELL_HEIGHT;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect rect=lineView.frame;
    rect.size.width=self.frame.size.width;
    lineView.frame=rect;
    
    dateLabel.frame=CGRectMake(self.frame.size.width-9.0f-100.0f, CGRectGetMinY(imageView.frame), 100.0f, 20.0f);

    contentLabel.frame=CGRectMake(CGRectGetMaxX(imageView.frame)+12.0f, 35.0f, CGRectGetMinX(dateLabel.frame)-CGRectGetMaxX(imageView.frame), 18.0f);

    rect=lineView.frame;
    rect.size.width=self.frame.size.width;
    lineView.frame=rect;

}


-(void)headerUrl:(NSString*)headerUrl title:(NSString*)title content:(NSString*)content date:(NSDate*)date{
    [imageView setUrl:headerUrl];
    titleLabel.text=title;
    contentLabel.text=content;
    
    NSDateFormatter* formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-m-d hh:mm"];
    dateLabel.text=[formatter stringFromDate:date];
}

-(void)rectangleType:(RectangleCellType)type{
//    contentImageView.hidden=(type==RectangleCellTypeMessage);
//    contentLabel.hidden=(type!=RectangleCellTypeMessage);
    
    if(type==RectangleCellTypeImage)
        contentLabel.text=@"[图片]";
    else if(type==RectangleCellTypeVoice)
        contentLabel.text=@"[语音]";
    
}

-(void)number:(int)number{
    [numberView number:number];
}

@end
