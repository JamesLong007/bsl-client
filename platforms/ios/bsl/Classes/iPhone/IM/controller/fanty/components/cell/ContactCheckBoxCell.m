//
//  ContactCheckBoxCell.m
//  WeChat
//
//  Created by apple2310 on 13-9-5.
//  Copyright (c) 2013年 apple2310. All rights reserved.
//

#import "ContactCheckBoxCell.h"
#import "ImageDownloadedView.h"

#define   CELL_HEIGHT   53.0f

@implementation ContactCheckBoxCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType=UITableViewCellAccessoryNone;
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        self.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contact_bg.png"]];

        roundImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellNotSelected.png"]];
        checkboxImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBlueSelected.png"]];
        
        [self addSubview:roundImageView];
        [self addSubview:checkboxImageView];
        
        CGRect rect=roundImageView.frame;
        rect.origin.x=10.0f;
        rect.origin.y=(CELL_HEIGHT-rect.size.height)*0.5f;
        roundImageView.frame=rect;
        
        rect=checkboxImageView.frame;
        rect.origin.x=10.0f;
        rect.origin.y=(CELL_HEIGHT-rect.size.height)*0.5f;
        checkboxImageView.frame=rect;
        
        
        imageView=[[ImageDownloadedView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(checkboxImageView.frame)+15.0f, (CELL_HEIGHT-37.0f)*0.5f, 37.0f,37.0f)];
        imageView.radius=3.0f;
        [self addSubview:imageView];
        
        
        nicknameLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+9.0f, 0.0f, 300.0f-CGRectGetMaxX(imageView.frame)-9.0f, CELL_HEIGHT)];
        nicknameLabel.numberOfLines=1;
        nicknameLabel.backgroundColor=[UIColor clearColor];
        nicknameLabel.font=[UIFont fontWithName:@"Helvetica" size:16.0f];
        nicknameLabel.textColor=[UIColor blackColor];

        [self addSubview:nicknameLabel];
        
        lineView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AlbumListLine.png"]];
        rect=lineView.frame;
        rect.origin.y=CELL_HEIGHT-rect.size.height;
        lineView.frame=rect;
        [self addSubview:lineView];
        
        checkboxImageView.alpha=0.0f;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect rect=lineView.frame;
    rect.size.width=self.frame.size.width;
    lineView.frame=rect;

}

-(void)headerUrl:(NSString*)headerUrl nickname:(NSString*)nickname{
    [imageView setUrl:headerUrl];
    nicknameLabel.text=nickname;
}

+(float)height{
    return CELL_HEIGHT;
}

-(void)setChecked:(BOOL)value animate:(BOOL)animate{
    if(animate){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.15f];
    }
    checkboxImageView.alpha=(value?1.0f:0.0f);
    if(animate){
        [UIView commitAnimations];
    }
}


@end
