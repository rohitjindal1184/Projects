//
//  ChatRoomTableViewCell.h
//  lokay
//
//  Created by Rohit Jindal on 8/8/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"
#import "PAWChatRoom.h"
#import "Mailgun.h"
#import "UIAlertView+Blocks.h"
#import <ParseUI/ParseUIConstants.h>


@interface ChatRoomTableViewCell : UITableViewCell<UIActionSheetDelegate>
{
	Mailgun *mailGun;
}
@property (weak, nonatomic) IBOutlet EDStarRating *viewRAtings;
@property (weak, nonatomic) IBOutlet EDStarRating *viewDollarRarting;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblReview;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UIButton *btnImage;
@property (strong, nonatomic)   PAWChatRoom *chatroom;
@property (weak, nonatomic) IBOutlet UIImageView *imgtype;

- (IBAction)showImage:(id)sender;
- (IBAction)reportUser:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnReport;
@property (weak, nonatomic) IBOutlet PFImageView *chatRoomImage;

@end
