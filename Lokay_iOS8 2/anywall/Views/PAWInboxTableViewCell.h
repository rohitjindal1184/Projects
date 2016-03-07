//
//  PAWInboxTableViewCell.h
//  lokay
//
//  Created by Rohit Jindal on 06/05/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAWInboxTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgChatRoom;
@property (weak, nonatomic) IBOutlet UILabel *lblUser;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
-(void)setupForNotification:(NSDictionary *)note;
@end
