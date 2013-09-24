//
//  EmoctionPanel.h
//  cube-ios
//
//  Created by apple2310 on 13-9-7.
//
//

#import <UIKit/UIKit.h>
@class SwipeView;
@class EmoctionPanel;

@protocol EmoctionPanelDelegate <NSObject>

-(void)sendEmoction:(EmoctionPanel*)emoction;
-(void)addEmoction:(EmoctionPanel*)emoction text:(NSString*)text;

-(void)deleteEmoction:(EmoctionPanel*)emoction;

@end

@interface EmoctionPanel : UIView{
    SwipeView* swipeView;
    UIPageControl* pager;    
    EmoctionPanel* emoctionPanel;
    
    UIButton* confirmButton;
}

- (id)initWithFrame:(CGRect)frame emoctionList:(NSDictionary*)__emoctionList;
@property(nonatomic,strong) NSDictionary* emoctionList;

@property(nonatomic,weak) id<EmoctionPanelDelegate> delegate;

@end
