//
//  GroupPanel.h
//  cube-ios
//
//  Created by 肖昶 on 13-9-18.
//
//

#import <UIKit/UIKit.h>

@class ImageDownloadedView;
@class GroupPanel;

@protocol GroupPanelDelegate <NSObject>

-(void)addGroupClick:(GroupPanel*)groupPanel;

@end

@interface GroupSubPanel : UIButton{
    ImageDownloadedView* imageDownloadedView;
    UILabel* titleLabel;
}
@end

@interface GroupPanel : UIView{
    NSMutableArray*  list;
    
    UIButton* uploadButton;

}

@property(nonatomic,weak) id<GroupPanelDelegate> delegate;

-(void)setArray:(NSArray*)userInfos;

-(void)hideAddButton;
@end
