//
//  PAWInboxViewController.h
//  lokay
//
//  Created by Rohit Jindal on 06/05/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAWAppDelegate.h"
#import "PAWInboxTableViewCell.h"
#import "PAWChatRoom.h"
#import "PAWWallViewController.h"
@interface PAWInboxViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
	
}
@property (nonatomic,strong) NSMutableArray *arrChatRoom;
@end
