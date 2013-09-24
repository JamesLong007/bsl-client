//
//  HeadTabView.m
//  
//
//  Created by fanty on 13-8-4.
//  Copyright (c) 2013年 fanty. All rights reserved.
//

#import "HeadTabView.h"

@interface HeadTabView()
-(void)moveTab:(int)index;
-(void)btnTabClick:(UIButton*)button;
@end

@implementation HeadTabView
@synthesize delegate;
@synthesize selectedIndex;
- (id)initWithFrame:(CGRect)frame{
    if(frame.size.height<1){
        frame.size.height=50.0f;
    }
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled=YES;
        self.clipsToBounds=YES;
        self.backgroundColor=[UIColor whiteColor];
        selectedImageView=[[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-4.0f, 0.0f, 4.0f)];
        selectedImageView.backgroundColor=[UIColor colorWithRed:130.0f/255.0f green:181.0f/255.0f blue:236.0f/255.0f alpha:1.0f];
        [self addSubview:selectedImageView];
        
        
        UIView* lineView=[[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height-1.0f, frame.size.width, 1.0f)];
        lineView.backgroundColor=[UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
        [self addSubview:lineView];
        
        labelList=[[NSMutableArray alloc] initWithCapacity:2];
    }
    return self;
}

-(void)setTabNameArray:(NSArray*)array{
    [labelList makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [labelList removeAllObjects];
    
    float left=0.0f;
    float width=self.frame.size.width/[array count];
    int index=0;
    for(NSString* str in array){
        UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(btnTabClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag=index;
        button.frame=CGRectMake(left, 0.0f, width, self.frame.size.height);
        [button setTitle:str forState:UIControlStateNormal];
        button.titleLabel.font=[UIFont systemFontOfSize:16.0f];
        [button setTitleColor:[UIColor colorWithRed:88.0f/255.0f green:88.0f/255.0f blue:88.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];

        [self addSubview:button];
        [labelList addObject:button];
        
        left+=width;
        
        index++;
        
    }
    [self moveTab:0];
}

-(void)setSelectedIndex:(int)value{
    [self moveTab:value];
}

-(void)moveTab:(int)index{
    if([labelList count]<1)return;
    selectedIndex=index;
    CGRect rect=selectedImageView.frame;
    float width=self.frame.size.width/[labelList count];
    
    rect.size.width=width;
    rect.origin.x=(index*width)+(width-rect.size.width)*0.5f;
    selectedImageView.frame=rect;
    
    [labelList enumerateObjectsUsingBlock:^(id obj,NSUInteger __index,BOOL* stop){
        UIButton* button=(UIButton*)obj;
        button.selected=(index==__index);
    }];
}

-(void)btnTabClick:(UIButton*)button{
    
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        [self moveTab:button.tag];

    } completion:^(BOOL finish){
        if([self.delegate respondsToSelector:@selector(tabDidSelected:index:) ])
            [self.delegate tabDidSelected:self index:button.tag];

    }];
}

@end
