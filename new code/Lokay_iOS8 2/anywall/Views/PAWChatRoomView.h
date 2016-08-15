//
//  PAWChatRoomView.h
//  LokayMe
//
//  Created by He Fei on 12/27/13.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mailgun.h"

@interface PAWChatRoomView : UIView{
	Mailgun *mailGun;
}

@property (nonatomic,strong)PFObject *selectedObj;
- (id)initWithPFObject:(PFObject *)anObject tag:(NSInteger)tag;
- (id)initWithEBObject:(NSDictionary *)object tag:(NSInteger)tag;
@end
