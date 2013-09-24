//
//  GroupPanel.m
//  cube-ios
//
//  Created by 肖昶 on 13-9-18.
//
//

#import "GroupPanel.h"
#import "ImageDownloadedView.h"

@implementation GroupSubPanel

-(id)initWithTitle:(NSString*)value imageUrl:(NSString*)imageUrl{
    
    self=[self initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
    if(self){
        imageDownloadedView=[[ImageDownloadedView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 40.0f, 40.0f)];
        [imageDownloadedView setUrl:imageUrl];
        [self addSubview:imageDownloadedView];

        

        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 40.0f,60.0f,30.0f)];
        titleLabel.font=[UIFont systemFontOfSize:12.0f];
        titleLabel.textColor=[UIColor blackColor];
        titleLabel.backgroundColor=[UIColor clearColor];
        titleLabel.text=value;
        titleLabel.numberOfLines=0;
        [titleLabel sizeToFit];
        
        CGRect rect=titleLabel.frame;
        if(rect.size.height>30.0f){
            rect.size.height=30.0f;
        }
        rect.origin.x=(self.frame.size.width-rect.size.width)*0.5f;
        titleLabel.frame=rect;
        
        [self addSubview:titleLabel];
    }
    return self;
}

@end

@interface GroupPanel()
-(void)btnUploadClick:(UIButton*)button;
@end

@implementation GroupPanel

@synthesize delegate;


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        list=[[NSMutableArray alloc] initWithCapacity:2];
        
        UIImage* img=[UIImage imageNamed:@"addphotoHL.png"];
        uploadButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [uploadButton addTarget:self action:@selector(btnUploadClick:) forControlEvents:UIControlEventTouchUpInside];

        uploadButton.frame=CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
        [uploadButton setBackgroundImage:img forState:UIControlStateNormal];
        [self addSubview:uploadButton];

    }
    return self;
}

-(void)dealloc{
}


-(void)setArray:(NSArray*)_tags{
    [list makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [list removeAllObjects];
    
    float left=10.0f;
    float top=10.0f;
    float width=self.frame.size.width-20.0f;

    int index=0;
    
    for(NSDictionary* dict in _tags){
        NSString* username=[dict objectForKey:@"username"];
        GroupSubPanel* subView=[[GroupSubPanel alloc] initWithTitle:username imageUrl:@""];
        subView.tag=index;
        [self addSubview:subView];
        [list addObject:subView];
        
        CGRect rect=subView.frame;
        if(left+rect.size.width>width){
            left=10.0f;
            top+=rect.size.height+10.0f;
        }
        rect.origin.x=left;
        rect.origin.y=top;
        subView.frame=rect;
        
        left+=rect.size.width+10.0f;

    }
    
    [self bringSubviewToFront:uploadButton];
    CGRect rect=uploadButton.frame;
    if(left+rect.size.width>width){
        left=17.0f;
        top+=rect.size.height+10.0f;
    }
    rect.origin.x=left;
    rect.origin.y=top;
    uploadButton.frame=rect;

    
    rect=self.frame;
    rect.size=CGSizeMake(self.frame.size.width, top+50.0f);
    self.frame=rect;
}

-(void)btnUploadClick:(GroupSubPanel*)subView{

    if([self.delegate respondsToSelector:@selector(addGroupClick:)])
        [self.delegate addGroupClick:self];
}

-(void)hideAddButton{
    uploadButton.hidden=YES;
}

@end
