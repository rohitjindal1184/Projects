//
//  PAWInboxTableViewCell.m
//  lokay
//
//  Created by Rohit Jindal on 06/05/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import "PAWInboxTableViewCell.h"

@implementation PAWInboxTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setupForNotification:(NSDictionary *)note
{
	NSString *strUser = [note objectForKey:@"user"];
	NSString *strMessage = [note objectForKey:@"message"];
	NSString *strUserStr = [NSString stringWithFormat:@"%@ %@ %@",strUser,@"commented on shout",strMessage];
	UIColor *redColor = [UIColor blueColor];
	NSRange redTextRange = [strUserStr rangeOfString:strUser];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
	NSDictionary *attribs = @{
							  NSForegroundColorAttributeName: _lblUser.textColor,
							  NSFontAttributeName: _lblUser.font
							  };
	NSMutableAttributedString *attributedText =
	[[NSMutableAttributedString alloc] initWithString:strUserStr
										   attributes:attribs];

	[attributedText setAttributes:@{NSForegroundColorAttributeName:redColor}
							range:redTextRange];
	_lblUser.attributedText = attributedText;
	_lblUser.font = [UIFont fontWithName:@"Helvetica" size:17.0];
}
@end
