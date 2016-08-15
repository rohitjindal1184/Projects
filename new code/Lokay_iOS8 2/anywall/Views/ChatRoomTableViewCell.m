//
//  ChatRoomTableViewCell.m
//  lokay
//
//  Created by Rohit Jindal on 8/8/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import "ChatRoomTableViewCell.h"

@implementation ChatRoomTableViewCell

- (void)awakeFromNib {
	_viewRAtings.backgroundColor  = [UIColor whiteColor];
	_viewRAtings.starImage = [UIImage imageNamed:@"stargrey"];
	_viewRAtings.starHighlightedImage = [UIImage imageNamed:@"starcolor"] ;
	_viewRAtings.maxRating = 5.0;
	_viewRAtings.horizontalMargin = 0;
	_viewRAtings.editable=YES;
	_viewRAtings.rating = 3.5;
	_viewRAtings.displayMode=EDStarRatingDisplayHalf;
	[_viewRAtings  setNeedsDisplay];
	
	_viewDollarRarting.backgroundColor  = [UIColor whiteColor];
	_viewDollarRarting.starImage = [UIImage imageNamed:@"dollargrey"];
	_viewDollarRarting.starHighlightedImage = [UIImage imageNamed:@"dollarblack"] ;
	_viewDollarRarting.maxRating = 5.0;
	_viewDollarRarting.horizontalMargin = 0;
	_viewDollarRarting.editable=YES;
	_viewDollarRarting.rating = 4.0;
	_viewDollarRarting.displayMode=EDStarRatingDisplayHalf;
	[_viewDollarRarting  setNeedsDisplay];

	_chatRoomImage.layer.borderColor = _lblName.textColor.CGColor;
	_chatRoomImage.layer.borderWidth = 2.0;
	UIButton *btnAddress = [UIButton buttonWithType:UIButtonTypeCustom];
	btnAddress.frame = _lblAddress.frame;
	[btnAddress addTarget:self action:@selector(addressBtnClicked) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:btnAddress];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

- (IBAction)actionEdit:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EDITROOM" object:self.chatroom];
	
}

- (IBAction)showImage:(id)sender {
	UIButton *btn = (UIButton *)sender;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOWPHOTO" object:self.chatroom];

}

- (IBAction)reportUser:(id)sender {
	UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															  delegate:self
													 cancelButtonTitle:@"Cancel"
												destructiveButtonTitle:nil
													 otherButtonTitles:@"Enter Chat", @"Report User", nil];
	[actionSheet showInView:self.superview.superview];

}
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(actionSheet.tag == 1)
	{
		switch (buttonIndex) {
			case 0:
				[self openGoogleMaps];
				break;
			case 1:
				[self openAppleMaps];
				break;
			default:
				break;
		}
		return;
	}
		switch (buttonIndex) {
			case 0:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"gotoDetail" object:self.chatroom];
				break;
			case 1:
				[self reportAbuseFunction:nil];
				break;
						default:
				break;
		}
}
- (void)reportAbuseFunction:(UIButton *)sender{
	
	[[[UIAlertView alloc] initWithTitle:@"Report Abuse?"
								message:@"Are you sure you want to report this post as abuse?"
					   cancelButtonItem:[RIButtonItem itemWithLabel:@"Yes" action:^{
		
		PFQuery *query = [PFQuery queryWithClassName:@"ChatRoom"];
		
		// Retrieve the object by id
		[query getObjectInBackgroundWithId:[self.chatroom.object objectId] block:^(PFObject *object, NSError *error) {
			
			object[@"is_spam"] = @YES;
			object[@"reportedBy"] = [PFUser currentUser];
			
			[object saveInBackground];
			mailGun = [Mailgun clientWithDomain:@"sandbox97000bf42754497cab804f769b916919.mailgun.org" apiKey:@"key-71587da92a97174674f9ceda35c6f223"];

			NSString *body = [NSString stringWithFormat:@"Report Abuse chat room - %@ , Reporter - %@",[self.chatroom.object objectId],[[PFUser currentUser] username]];
			[mailGun sendMessageTo:@"LokeyMe <info@lokayme.com>"
							  from:@"Abuse Reporter <alert@lokay.com>"
						   subject:@"Report Abuse!"
							  body:body];
			
			NSString *message = [NSString stringWithFormat:@"This Chat Room is report as abused."];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lokay!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alert show];
		}];
	}]
					   otherButtonItems:[RIButtonItem itemWithLabel:@"No" action:^{
		// Handle "Delete"
	}], nil] show];
	
	
	
}


-(void)addressBtnClicked
{
	NSString *strAddress = _lblAddress.text;
	strAddress = [strAddress stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	if ([[UIApplication sharedApplication] canOpenURL:
		 [NSURL URLWithString:@"comgooglemaps://"]]) {
		UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																  delegate:self
														 cancelButtonTitle:@"Cancel"
													destructiveButtonTitle:nil
														 otherButtonTitles:@"Google Maps", @"iMaps", nil];
		actionSheet.tag = 1;
		[actionSheet showInView:self.superview.superview];
  
	} else {
		[self openAppleMaps];
		NSLog(@"Can't use comgooglemaps://");
	}
}
-(void)openAppleMaps
{
	PFGeoPoint * point = [[_chatroom object] objectForKey:@"location"];
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
	MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
												   addressDictionary:nil];
	MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
	[mapItem setName:_lblAddress.text];
	// Pass the map item to the Maps app
	[mapItem openInMapsWithLaunchOptions:nil];
}

-(void)openGoogleMaps
{
	NSString *strAddress = _lblAddress.text;
	strAddress = [strAddress stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	NSString *strUrl = [NSString stringWithFormat:@"comgooglemaps://?q=%@",strAddress];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];

}
@end
