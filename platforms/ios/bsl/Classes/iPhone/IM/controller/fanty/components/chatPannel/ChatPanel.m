//
//  ChatPanel.m
//  WeChat
//
//  Created by apple2310 on 13-9-5.
//  Copyright (c) 2013年 apple2310. All rights reserved.
//

#import "ChatPanel.h"
#import "UIExpandingTextView.h"

#import "EmoctionPanel.h"
#import "CameraPanel.h"

#define  PANNEL_HEIGHT  43.0f
#define  EC_PANEL_height 216.0f



@interface ChatPanel()<UIExpandingTextViewDelegate,EmoctionPanelDelegate,CameraPanelDelegate>
-(void) keyboardWillShow:(NSNotification *)note;
-(void) keyboardWillHide:(NSNotification *)note;

-(void)showChatOrKeyboard;
-(void)showEmoctionOrNot;
-(void)showCameraOrNot;

-(void)recordTouchDown;
-(void)recordTouchUp;
-(void)recordTouchCancel;

@end

@implementation ChatPanel

@synthesize text;
@synthesize emoctionList;

- (id)initWithFrame:(CGRect)frame{
    
    frame.size.height=PANNEL_HEIGHT+EC_PANEL_height;
    
    self = [super initWithFrame:frame];
    if (self) {
        self.limitMaxNumber=300;
        self.backgroundColor=[UIColor colorWithRed:250.0f/255.0f green:249.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
        self.userInteractionEnabled=YES;
        
        chatPanelBgView=[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, PANNEL_HEIGHT)];
        chatPanelBgView.image=[UIImage imageNamed:@"ToolViewBkg_Black.png"];

        chatPanelBgView.userInteractionEnabled=YES;
        chatPanelBgView.backgroundColor=[UIColor clearColor];
        [self addSubview:chatPanelBgView];
        
        chatButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [chatButton addTarget:self action:@selector(showChatOrKeyboard) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage* bgImg=[UIImage imageNamed:@"field.png"];
        bgImg=[bgImg stretchableImageWithLeftCapWidth:bgImg.size.width*0.5f topCapHeight:bgImg.size.height*0.5f];
        textBgView=[[UIImageView alloc] initWithImage:bgImg];
        textBgView.clipsToBounds=YES;
        textBgView.userInteractionEnabled=YES;
        
        UIImage* recordImg=[UIImage imageNamed:@"UnreadAgreement.png"];
        recordImg=[recordImg stretchableImageWithLeftCapWidth:recordImg.size.width*0.5f topCapHeight:recordImg.size.height*0.5f];
        recordButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [recordButton addTarget:self action:@selector(recordTouchDown) forControlEvents:UIControlEventTouchDown];
        [recordButton addTarget:self action:@selector(recordTouchUp) forControlEvents:UIControlEventTouchUpInside];
        [recordButton addTarget:self action:@selector(recordTouchCancel) forControlEvents:UIControlEventTouchUpOutside];
        
        [recordButton setBackgroundImage:recordImg forState:UIControlStateNormal];
        [recordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        recordButton.titleLabel.font=[UIFont systemFontOfSize:16.0f];
        
        emoctionButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [emoctionButton addTarget:self action:@selector(showEmoctionOrNot) forControlEvents:UIControlEventTouchUpInside];
        
        addButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [addButton addTarget:self action:@selector(showCameraOrNot) forControlEvents:UIControlEventTouchUpInside];

        UIImage* chatImg=[UIImage imageNamed:@"ToolViewInputVoice.png"];
        UIImage* chatHLImg=[UIImage imageNamed:@"ToolViewInputVoiceHL.png"];

        UIImage* emoctionImg=[UIImage imageNamed:@"ToolViewEmotion.png"];
        UIImage* emoctionHLImg=[UIImage imageNamed:@"ToolViewEmotionHL.png"];
        UIImage* addImg=[UIImage imageNamed:@"TypeSelectorBtn_Black.png"];
        UIImage* addHLImg=[UIImage imageNamed:@"TypeSelectorBtnHL_Black.png"];
        
        [chatButton setImage:chatImg forState:UIControlStateNormal];
        [chatButton setImage:chatHLImg forState:UIControlStateHighlighted];

        [emoctionButton setImage:emoctionImg forState:UIControlStateNormal];
        [emoctionButton setImage:emoctionHLImg forState:UIControlStateHighlighted];

        [addButton setImage:addImg forState:UIControlStateNormal];
        [addButton setImage:addHLImg forState:UIControlStateHighlighted];
        
        CGRect rect=chatButton.frame;
        rect.origin.x=2.0f;
        rect.origin.y=(PANNEL_HEIGHT-chatImg.size.height)*0.5f;
        rect.size=chatImg.size;
        chatButton.frame=rect;
        
        rect=addButton.frame;
        rect.origin.x=frame.size.width-addImg.size.width-2.0f;
        rect.origin.y=(PANNEL_HEIGHT-addImg.size.height)*0.5f;
        rect.size=addImg.size;
        addButton.frame=rect;
        
        rect=emoctionButton.frame;
        rect.origin.x=CGRectGetMinX(addButton.frame)-emoctionImg.size.width-2.0f;
        rect.origin.y=(PANNEL_HEIGHT-emoctionImg.size.height)*0.5f;
        rect.size=emoctionImg.size;
        emoctionButton.frame=rect;
        
        rect=textBgView.frame;
        rect.size.height=34.0f;
        rect.origin.x=CGRectGetMaxX(chatButton.frame)+2.0f;
        rect.origin.y=(PANNEL_HEIGHT-rect.size.height)*0.5f;
        
        rect.size.width=CGRectGetMinX(emoctionButton.frame)-rect.origin.x-2.0f;
        textBgView.frame=rect;
        
        recordButton.frame=rect;

        
        rect=textBgView.bounds;
        rect.size.height=28.0f;
        rect.origin.y=(textBgView.frame.size.height-rect.size.height)*0.5f-3.0f;
        
        
        recordButton.hidden=YES;
        
        
        textView = [[UIExpandingTextView alloc]initWithFrame:rect];
        textView.delegate = self;
        textView.clipsToBounds=YES;
        textView.maximumNumberOfLines = 5;
        textView.font = [UIFont systemFontOfSize:16.0f];
        textView.backgroundColor=[UIColor clearColor];
        textView.delegate=self;
        textView.returnKeyType=UIReturnKeySend;
        

        UIImageView* lineView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"h_line.png"]];
        lineView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:lineView];
        rect=lineView.frame;
        rect.size.width=frame.size.width;
        rect.origin.y=PANNEL_HEIGHT;
        lineView.frame=rect;

        
        [chatPanelBgView addSubview:chatButton];
        [chatPanelBgView addSubview:textBgView];
        [chatPanelBgView addSubview:recordButton];
        [textBgView addSubview:textView];
        [chatPanelBgView addSubview:emoctionButton];
        [chatPanelBgView addSubview:addButton];
        [chatPanelBgView addSubview:lineView];
        
        
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];

        
    }
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)resignFirstResponder{
    
    if(emoctionPanel!=nil || camerPanel!=nil){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];

        CGRect containerFrame = self.frame;
        containerFrame.origin.y = self.superview.frame.size.height-chatPanelBgView.frame.size.height;
        self.frame=containerFrame;
        
        // commit animations
        [UIView commitAnimations];
        
        [emoctionPanel removeFromSuperview];
        emoctionPanel=nil;

        [camerPanel removeFromSuperview];
        camerPanel=nil;
    }
    
    [textView resignFirstResponder];
    return YES;
}

#pragma mark method

-(NSString*)text{
    return textView.text;
}

-(void)setText:(NSString *)value{
    textView.text=value;
}

-(void)hideAllControlPanel{
    chatButton.hidden=YES;
    textBgView.hidden=YES;
    recordButton.hidden=YES;
    textView.hidden=YES;
    emoctionButton.hidden=YES;
    addButton.hidden=YES;
    

    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, PANNEL_HEIGHT)];
    label.text=@"你已退出该群组";
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor blackColor];
    label.font=[UIFont systemFontOfSize:18.0f];
    label.textAlignment=NSTextAlignmentCenter;
    [chatPanelBgView addSubview:label];
}

-(void)showChatOrKeyboard{

    recordButton.hidden=!recordButton.hidden;
    textBgView.hidden=!recordButton.hidden;
    UIImage* chatImg=nil;
    UIImage* chatHLImg=nil;
    if(recordButton.hidden){
        chatImg=[UIImage imageNamed:@"ToolViewInputVoice.png"];
        chatHLImg=[UIImage imageNamed:@"ToolViewInputVoiceHL.png"];
    }
    else{
        chatImg=[UIImage imageNamed:@"ToolViewInputText.png"];
        chatHLImg=[UIImage imageNamed:@"ToolViewInputTextHL.png"];
    }
    
    [chatButton setImage:chatImg forState:UIControlStateNormal];
    [chatButton setImage:chatHLImg forState:UIControlStateHighlighted];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect rect=chatPanelBgView.frame;
        if(!recordButton.hidden){
            rect.size.height=PANNEL_HEIGHT;
        }
        else{
            rect.size.height=textBgView.frame.origin.y*2.0f+textBgView.frame.size.height;
            
        }
        chatPanelBgView.frame=rect;
        rect=self.frame;
        rect.size.height=chatPanelBgView.frame.size.height+EC_PANEL_height;
        self.frame=rect;
    
    } completion:^(BOOL finish){

    }];

    if(recordButton.hidden){
        [emoctionPanel removeFromSuperview];
        emoctionPanel=nil;
        
        [camerPanel removeFromSuperview];
        camerPanel=nil;

        [textView becomeFirstResponder];
    }
    else{
        [textView resignFirstResponder];
        if(emoctionPanel!=nil || camerPanel!=nil){
            [emoctionPanel removeFromSuperview];
            emoctionPanel=nil;
            [camerPanel removeFromSuperview];
            camerPanel=nil;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.3f];
            
            CGRect containerFrame = self.frame;
            containerFrame.origin.y = self.superview.frame.size.height-chatPanelBgView.frame.size.height;
            self.frame=containerFrame;
            
            // commit animations
            [UIView commitAnimations];

        }
    }
    
}

-(void)showEmoctionOrNot{
    if(emoctionPanel==nil){
        [camerPanel removeFromSuperview];
        camerPanel=nil;
        
        recordButton.hidden=YES;
        textBgView.hidden=!recordButton.hidden;
        UIImage* chatImg=nil;
        UIImage* chatHLImg=nil;
        chatImg=[UIImage imageNamed:@"ToolViewInputVoice.png"];
        chatHLImg=[UIImage imageNamed:@"ToolViewInputVoiceHL.png"];
        
        [chatButton setImage:chatImg forState:UIControlStateNormal];
        [chatButton setImage:chatHLImg forState:UIControlStateHighlighted];

        
        
        emoctionPanel=[[EmoctionPanel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, EC_PANEL_height) emoctionList:self.emoctionList];
        emoctionPanel.emoctionList=self.emoctionList;
        emoctionPanel.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        emoctionPanel.delegate=self;
        [self addSubview:emoctionPanel];
        
        [textView resignFirstResponder];
        
        
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect rect=emoctionPanel.frame;
            rect.origin.y=chatPanelBgView.frame.size.height;
            emoctionPanel.frame=rect;
            
            rect=self.frame;
            rect.origin.y=self.superview.frame.size.height-self.frame.size.height;
            self.frame=rect;
            
        } completion:^(BOOL finish){
        
        }];
        
    }
    else{
        [textView becomeFirstResponder];
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect rect=emoctionPanel.frame;
            rect.origin.y=self.frame.size.height;
            emoctionPanel.frame=rect;
        } completion:^(BOOL finish){
            [emoctionPanel removeFromSuperview];
            emoctionPanel=nil;
            
        }];
    }
}

-(void)showCameraOrNot{
    if([self.delegate respondsToSelector:@selector(chatPanelDidSelectedAdd:)])
        [self.delegate chatPanelDidSelectedAdd:self];
    /*
    if(camerPanel==nil){
        [emoctionPanel removeFromSuperview];
        emoctionPanel=nil;
        
        recordButton.hidden=YES;
        textBgView.hidden=!recordButton.hidden;
        UIImage* chatImg=nil;
        UIImage* chatHLImg=nil;
        chatImg=[UIImage imageNamed:@"ToolViewInputVoice.png"];
        chatHLImg=[UIImage imageNamed:@"ToolViewInputVoiceHL.png"];
        
        [chatButton setImage:chatImg forState:UIControlStateNormal];
        [chatButton setImage:chatHLImg forState:UIControlStateHighlighted];
        
        
        
        camerPanel=[[CameraPanel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, EC_PANEL_height)];
        camerPanel.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
        camerPanel.delegate=self;
        [self addSubview:camerPanel];
        [camerPanel release];
        
        [textView resignFirstResponder];
        
        
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect rect=camerPanel.frame;
            rect.origin.y=chatPanelBgView.frame.size.height;
            camerPanel.frame=rect;
            
            rect=self.frame;
            rect.origin.y=self.superview.frame.size.height-self.frame.size.height;
            self.frame=rect;
            
        } completion:^(BOOL finish){
            
        }];
        
    }
    else{
        [textView becomeFirstResponder];
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect rect=camerPanel.frame;
            rect.origin.y=self.frame.size.height;
            camerPanel.frame=rect;
        } completion:^(BOOL finish){
            [camerPanel removeFromSuperview];
            camerPanel=nil;
            
        }];
    }
     */
}


-(void)recordTouchDown{
    if([self.delegate respondsToSelector:@selector(chatPanelRecordTouch:isTouch:)])
        [self.delegate chatPanelRecordTouch:self isTouch:YES];
}

-(void)recordTouchUp{
    if([self.delegate respondsToSelector:@selector(chatPanelRecordTouch:isTouch:)])
        [self.delegate chatPanelRecordTouch:self isTouch:NO];

}

-(void)recordTouchCancel{
    if([self.delegate respondsToSelector:@selector(chatPanelRecordCancel:)])
        [self.delegate chatPanelRecordCancel:self];

}


-(float)panelHeight{
    return PANNEL_HEIGHT;
}



#pragma mark textview delegate

- (BOOL)expandingTextViewShouldBeginEditing:(UIExpandingTextView *)expandingTextView{
    [emoctionPanel removeFromSuperview];
    emoctionPanel=nil;
    [camerPanel removeFromSuperview];
    camerPanel=nil;

    return YES;
}

- (BOOL)expandingTextView:(UIExpandingTextView *)expandingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)__text{
    if(range.location>=self.limitMaxNumber)
        return NO;
    return YES;
    
}

- (BOOL)expandingTextViewShouldReturn:(UIExpandingTextView *)expandingTextView{
    [emoctionPanel removeFromSuperview];
    emoctionPanel=nil;
    [camerPanel removeFromSuperview];
    camerPanel=nil;
    
    [expandingTextView resignFirstResponder];
    
    if([self.delegate respondsToSelector:@selector(chatPanelDidSend:)])
        [self.delegate chatPanelDidSend:self];

    return NO;
}


- (void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height{
    float diff = (expandingTextView.frame.size.height - height);
    CGRect rect=self.frame;
    rect.size.height-=diff;
    rect.origin.y+=diff;
	self.frame = rect;
    
    rect=chatPanelBgView.frame;
    rect.size.height-=diff;
    chatPanelBgView.frame=rect;
    
    CGRect textBgViewFrame=textBgView.frame;
    textBgViewFrame.size.height-=diff;
    textBgViewFrame.origin.y=(rect.size.height-textBgViewFrame.size.height)*0.5f;
    textBgView.frame=textBgViewFrame;
    
}

#pragma mark emoctionpanel  delegate
-(void)addEmoction:(EmoctionPanel*)emoction text:(NSString*)___text{

    textView.text = [textView.text stringByAppendingString:___text];

}

-(void)deleteEmoction:(EmoctionPanel*)emoction{
    if([textView.text length] >0){
        textView.text = [textView.text substringWithRange:NSMakeRange(0, [textView.text length] -1)];
    }

}

-(void)sendEmoction:(EmoctionPanel *)emoction{
    
    [textView resignFirstResponder];
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        
        CGRect containerFrame = self.frame;
        containerFrame.origin.y = self.superview.frame.size.height-chatPanelBgView.frame.size.height;
        
        self.frame=containerFrame;

    } completion:^(BOOL finish){
        [emoctionPanel removeFromSuperview];
        emoctionPanel=nil;
        [camerPanel removeFromSuperview];
        camerPanel=nil;

    }];
    
    if([self.delegate respondsToSelector:@selector(chatPanelDidSend:)])
        [self.delegate chatPanelDidSend:self];

}

#pragma mark  camerapanel delegate

-(void)cameraPanelDidClick:(CameraPanel *)cameraPanel clickType:(CameraPanelClickType)cameraPanelClickType{
    
}





#pragma mark  notification
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    
    
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
        
	CGRect containerFrame = self.frame;
    
    containerFrame.origin.y = self.superview.frame.size.height - (keyboardBounds.size.height + chatPanelBgView.frame.size.height);
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	self.frame=containerFrame;
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    if(emoctionPanel!=nil || camerPanel!=nil)return;
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	CGRect containerFrame = self.frame;
    containerFrame.origin.y = self.superview.frame.size.height-chatPanelBgView.frame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	self.frame=containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}


@end
