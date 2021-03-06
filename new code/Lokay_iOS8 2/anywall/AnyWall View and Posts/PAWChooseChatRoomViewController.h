//
//  PAWChooseChatRoomViewController.h
//  LokayMe
//
//  Created by He Fei on 12/26/13.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAWAppDelegate.h"
#import "MapPinView.h"
#import <Parse/Parse.h>
#import "AutoSuggestTableView.h"
#import "CustomBadge.h"
#import "UIView+Toast.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "ChatRoomTable.h"
#import "TabView.h"
#import "ChatRoomTableViewCell.h"
#import "HTHorizontalSelectionList.h"
#import <Parse/Parse.h>
#import <Social/Social.h>
@interface PAWChooseChatRoomViewController : UIViewController<PlaceSelected,TabViewDelegate,HTHorizontalSelectionListDelegate,HTHorizontalSelectionListDataSource>
{
	PAWAppDelegate *appDelegate;
	CLLocationManager *locationManager;
	NSMutableArray *arrAnnView;
	AutoSuggestTableView *autoSuggestionView;
	BOOL viewDisspear;
	//CustomBadge *badge5;
	PFObject *objectSelected;
	TabView *tabview;
    __weak IBOutlet UITableView *chatroomTb;
	NSArray *arrPlaces;
	NSMutableArray *arrBar;

	NSMutableArray *arrClub;

	NSMutableArray *arrDayParties;

	NSMutableArray *arrBrunches;
	int selectedOption;
	NSArray *arrSelectedOption;
	PAWChatRoom *chatroomEdit;

//	ChatRoomTable *chatroomTb;
}
@property (nonatomic, strong) HTHorizontalSelectionList *selectionList;

@property (nonatomic, retain) NSString * chatroom_id;
- (void)gotoNotifications;
@end
