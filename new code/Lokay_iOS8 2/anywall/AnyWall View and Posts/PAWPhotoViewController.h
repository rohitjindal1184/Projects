//
//  PAWPhotoViewController.h
//  LokayMe
//
//  Created by He Fei on 1/6/14.
//  Copyright (c) 2014 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAlertView+Blocks.h"
#import "Mailgun.h"
#import "PAWChatRoom.h"
@interface PAWPhotoViewController : UIViewController<UIScrollViewDelegate>{
	Mailgun *mailGun;
}

@property (nonatomic, strong) PFFile * photo;
@property (assign) BOOL scrolling;
@property (nonatomic, strong) NSString * chatRoomID;
@property (assign) int tag;
@property (nonatomic, strong) PAWChatRoom * chatroom;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;

@property (weak, nonatomic) IBOutlet UIScrollView *scroll;


@end
