//
//  SkinView.h
//  cube-ios
//
//  Created by 东 on 6/25/13.
//
//

#import <UIKit/UIKit.h>
#import "AAPanelView.h"

@protocol SkinViewDelegate
- (void)onclick:(int)index source:(NSArray *)source;
@end

@interface SkinView : UIView{
    id<SkinViewDelegate> delegate;
    
@private;
    NSArray *_activityItems;
    AAPanelView *_panelView;
    UIScrollView* imageScrollView;
}

@property (assign, nonatomic) id<SkinViewDelegate> delegate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, strong) NSArray *_activityItems;

- (id)initWithActivityItems:(NSArray *)activityItems;
// Attempt automatically use top of hierarchy view.

- (void)show;
- (void)showInView:(UIView *)view;
- (void)dismissActionSheet;


@end
