//
//  TabView.m
//  lokay
//
//  Created by Rohit Jindal on 8/8/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import "TabView.h"
#import "PAWInboxViewController.h"
@implementation TabView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(TabView *) getView
{
	return [[[NSBundle mainBundle] loadNibNamed:@"TabView"
										  owner:nil
										options:nil] lastObject];
}
- (IBAction)tabselected:(id)sender {
	UIButton *btn = (UIButton *)sender;
	[self.delegate tabselectedwithIndex:btn.tag];
}
-(void)awakeFromNib
{
	appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshNotification) name:@"NotificationRecieved" object:nil];
	badge5 = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d",appDelegate.notifications]];
	badge5.frame = CGRectMake(_badgeView.frame.origin.x, _badgeView.frame.origin.y, 20, 20);
	[self addSubview:badge5];
	if(appDelegate.notifications == 0){
		badge5.hidden = YES;
	}
	else
	{
		badge5.hidden = NO;
		
	}
	badge5.userInteractionEnabled = NO;
	
//	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//	_switchNotifications.on = [[def valueForKey:@"notifications"] boolValue];
}
-(void)refreshNotification
{
	if(badge5.hidden)
	{
		badge5.hidden = NO;
	}
	[badge5 autoBadgeSizeWithString:[NSString stringWithFormat:@"%d",appDelegate.notifications]];
}
- (IBAction)gotoNotifications:(id)sender {
	appDelegate.notifications = 0;
	badge5.hidden = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"gotoNotification" object:nil];
	
}
@end
