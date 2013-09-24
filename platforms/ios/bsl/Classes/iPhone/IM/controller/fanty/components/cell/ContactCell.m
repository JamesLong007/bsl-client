//
//  ContactCell.m
//  WeChat
//
//  Created by apple2310 on 13-9-4.
//  Copyright (c) 2013年 apple2310. All rights reserved.
//

#import "ContactCell.h"
#import "ImageDownloadedView.h"

#define   CELL_HEIGHT   53.0f

@implementation ContactCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType=UITableViewCellAccessoryNone;
        self.selectionStyle=UITableViewCellSelectionStyleBlue;
        self.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contact_bg.png"]];

        
        imageView=[[ImageDownloadedView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 37.0f,37.0f)];
        imageView.radius=4.0f;
        [self addSubview:imageView];
        
        
        nicknameLabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+9.0f, 0.0f, 300.0f-CGRectGetMaxX(imageView.frame)-9.0f, CELL_HEIGHT)];
        nicknameLabel.numberOfLines=1;
        nicknameLabel.backgroundColor=[UIColor clearColor];
        nicknameLabel.textColor=[UIColor blackColor];
        nicknameLabel.font=[UIFont fontWithName:@"Helvetica" size:16.0f];
        
        [self addSubview:nicknameLabel];
        
        lineView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AlbumListLine.png"]];
        CGRect rect=lineView.frame;
        rect.origin.y=CELL_HEIGHT-rect.size.height;
        lineView.frame=rect;
        [self addSubview:lineView];

    }
    return self;
}

-(void)headerUrl:(NSString*)headerUrl nickname:(NSString*)nickname{
    [imageView setUrl:headerUrl];
    nicknameLabel.text=nickname;
}

+(float)height{
    return CELL_HEIGHT;
}

-(void)loadingImage:(NSString*)imageName{
    imageView.loadingImageName=imageName;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if(self.editing){
        imageView.frame=CGRectMake(50.0f, 10.0f, 37.0f,37.0f);
        if(self.showingDeleteConfirmation){
            nicknameLabel.frame=CGRectMake(CGRectGetMaxX(imageView.frame)+9.0f, 0.0f, 230.0f-CGRectGetMaxX(imageView.frame)-9.0f, CELL_HEIGHT);
        }
        else{
            nicknameLabel.frame=CGRectMake(CGRectGetMaxX(imageView.frame)+9.0f, 0.0f, 260.0f-CGRectGetMaxX(imageView.frame)-9.0f, CELL_HEIGHT);

        }
    }
    else{
        
        imageView.frame=CGRectMake(10.0f, 10.0f, 37.0f,37.0f);
        nicknameLabel.frame=CGRectMake(CGRectGetMaxX(imageView.frame)+9.0f, 0.0f, 300.0f-CGRectGetMaxX(imageView.frame)-9.0f, CELL_HEIGHT);
    }

    
    CGRect rect=lineView.frame;
    rect.size.width=self.frame.size.width;
    lineView.frame=rect;

}

-(void)layoutUI:(BOOL)isEdit  animated:(BOOL)animate{
    self.editing=isEdit;
    if(animate){
        [UIView beginAnimations:nil context:nil];
    }
    
    if(self.editing){
        imageView.frame=CGRectMake(50.0f, 10.0f, 37.0f,37.0f);
        nicknameLabel.frame=CGRectMake(CGRectGetMaxX(imageView.frame)+9.0f, 0.0f, 260.0f-CGRectGetMaxX(imageView.frame)-9.0f, CELL_HEIGHT);
    }
    else{
        
        imageView.frame=CGRectMake(10.0f, 10.0f, 37.0f,37.0f);
        nicknameLabel.frame=CGRectMake(CGRectGetMaxX(imageView.frame)+9.0f, 0.0f, 300.0f-CGRectGetMaxX(imageView.frame)-9.0f, CELL_HEIGHT);
    }
    
    if(animate)
        [UIView commitAnimations];
}

@end
