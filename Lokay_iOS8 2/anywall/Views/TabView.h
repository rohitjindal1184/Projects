//
//  TabView.h
//  lokay
//
//  Created by Rohit Jindal on 8/8/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//
@protocol TabViewDelegate <NSObject>

-(void)tabselectedwithIndex:(int)selectedIndex;

@end
#import <UIKit/UIKit.h>
#import "CustomBadge.h"
@interface TabView : UIView
{
	CustomBadge *badge5;
	
	PAWAppDelegate *appDelegate;
}
@property (weak, nonatomic) IBOutlet CustomBadge *badgeView;
@property (weak, nonatomic)  id<TabViewDelegate> delegate;
//@property (strong, nonatomic) PAWChooseChatRoomViewController *controller;

+(TabView *) getView;
@end
