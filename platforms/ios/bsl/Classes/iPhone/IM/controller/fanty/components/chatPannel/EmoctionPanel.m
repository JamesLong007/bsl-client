//
//  EmoctionPanel.m
//  cube-ios
//
//  Created by apple2310 on 13-9-7.
//
//

#import "EmoctionPanel.h"
#import "SwipeView.h"
#import "MySelfView.h"


@interface EmoctionPanel()<SwipeViewDataSource,SwipeViewDelegate>
-(void)showEmotion:(MySelfView*)sender;
-(void)deleteEmotion;
-(void)sendEmotion;
@end

@implementation EmoctionPanel

@synthesize delegate;
@synthesize emoctionList;
- (id)initWithFrame:(CGRect)frame emoctionList:(NSDictionary*)__emoctionList{
    self = [self initWithFrame:frame];
    if (self) {
        swipeView = [[SwipeView alloc]initWithFrame:self.bounds];
        swipeView.alignment = SwipeViewAlignmentCenter;
        swipeView.pagingEnabled = YES;
        swipeView.wrapEnabled = NO;
        swipeView.itemsPerPage = 1;
        swipeView.truncateFinalPage = YES;
        swipeView.delegate = self;
        swipeView.dataSource = self;
        self.emoctionList=__emoctionList;
        int count = 0;
        int number = self.emoctionList.count;
        if(number % 29 == 0){
            count = number/29;
        }
        else{
            count = number /29  + 1;
        }
        
        pager = [[UIPageControl alloc]initWithFrame:CGRectMake(0, frame.size.height-20.0f, frame.size.width, 20.0f)];
        pager.backgroundColor= [UIColor grayColor];
        [pager setNumberOfPages:count];
        [pager setCurrentPage:0];
        
        
        confirmButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [confirmButton addTarget:self action:@selector(sendEmotion) forControlEvents:UIControlEventTouchUpInside];
        UIImage* btnSelImg=[UIImage imageNamed:@"RightBarButtonBkg_Blue.png"];
        btnSelImg=[btnSelImg stretchableImageWithLeftCapWidth:btnSelImg.size.width*0.5f topCapHeight:btnSelImg.size.height*0.5f];
        [confirmButton setTitle:@"发送" forState:UIControlStateNormal];
        [confirmButton setBackgroundImage:btnSelImg forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        confirmButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:13.0f];
        confirmButton.frame=CGRectMake(frame.size.width-64.0f-8.0f, frame.size.height-btnSelImg.size.height-25.0f, 64.0f, btnSelImg.size.height);

        
        [self addSubview:pager];
        [self addSubview:swipeView];

        [self addSubview:confirmButton];
    }
    return self;
}

-(void)dealloc{
    ;
}


#pragma mark - SwipeView Delegate

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView{
    return pager.numberOfPages;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipe
{
    [pager setCurrentPage:swipe.currentItemIndex];
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index{
    NSLog(@"selected item at index %i", index);
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view{
    UIView *myView=view;
    if(view==nil){
        myView = [[UIView alloc]initWithFrame:self.bounds];
    }
    [myView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int j= 0;j<3;j++){
        for(int i=0;i<10;i++){
            MySelfView *pView = [[MySelfView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            
            int tag = index * 29 + 10*j +i;
            NSString *name = [NSString stringWithFormat:@"%d",tag];
            if(name.length == 1){
                name = [NSString stringWithFormat:@"f00%@",name ];
            }
            else if(name.length == 2){
                name = [NSString stringWithFormat:@"f0%@",name ];
            }
            else{
                name = [NSString stringWithFormat:@"f%@",name ];
            }
            [pView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",name]] forState:UIControlStateNormal];
            [pView setFileName:name];
            CGRect frame = pView.frame;
            if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPad) {
                frame.origin.x = 52*i;
                
            }else{
                frame.origin.x = 32*i;
            }
            frame.origin.y = 20.0f+50.0f*j;
            pView.frame = frame;
            pView.userInteractionEnabled = YES;
            
            [pView removeTarget:self action:@selector(showEmotion:) forControlEvents:UIControlEventTouchUpInside];
            [pView removeTarget:self action:@selector(deleteEmotion) forControlEvents:UIControlEventTouchUpInside];
            
            
            if(10*j +i == 29){
                [pView setImage:[UIImage imageNamed:@"del_icon_dafeult.png"] forState:UIControlStateNormal];

                [pView addTarget:self action:@selector(deleteEmotion) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [pView addTarget:self action:@selector(showEmotion:) forControlEvents:UIControlEventTouchUpInside];
            }
            [myView addSubview:pView];
            
        }
    }

    
    return myView;
}

#pragma mark method

-(void)showEmotion:(MySelfView*)sender{
    if([self.delegate respondsToSelector:@selector(addEmoction:text:)])
        [self.delegate addEmoction:self text:[NSString stringWithFormat:@"[/:%@]",[self.emoctionList valueForKey:sender.fileName] ]];
    
    
    /*
    UITapGestureRecognizer *gs = (UITapGestureRecognizer*)sender;
    MySelfView *view  = (MySelfView*)gs.view;

    NSString *text = inputView.text;
    inputView.text = [text stringByAppendingString:[NSString stringWithFormat:@"[/:%@]",[dictionary valueForKey:view.fileName] ]];
    */
}


-(void)deleteEmotion{
    if([self.delegate respondsToSelector:@selector(deleteEmoction:)])
        [self.delegate deleteEmoction:self ];

    /*
    NSString *text = inputView.text;
    
    if(text.length >0)
    {
        inputView.text = [text substringWithRange:NSMakeRange(0, text.length -1)];
    }
     */
}

-(void)sendEmotion{
    if([self.delegate respondsToSelector:@selector(sendEmoction:)])
        [self.delegate sendEmoction:self ];
}

@end
