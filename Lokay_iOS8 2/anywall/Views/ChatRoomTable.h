//
//  ChatRoomTable.h
//  lokay
//
//  Created by Rohit Jindal on 10/08/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatRoomTableViewCell.h"
#import "HTHorizontalSelectionList.h"

@interface ChatRoomTable : UIView<UITableViewDataSource,UITableViewDelegate,HTHorizontalSelectionListDelegate,HTHorizontalSelectionListDataSource>
{
	NSArray *arrPlaces;
}
@property (weak, nonatomic) IBOutlet UITextField *txtSerach;
@property (strong, nonatomic)  NSMutableArray *arrChatRoom;
@property (strong, nonatomic)  NSMutableArray *arrRooms;
@property (nonatomic, strong) HTHorizontalSelectionList *selectionList;

@property (weak, nonatomic) IBOutlet UITableView *tableChat;
-(void)reloadTable;
+(ChatRoomTable *) getView;
@end
