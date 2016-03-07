//
//  PAWChatRoomView.m
//  LokayMe
//
//  Created by He Fei on 12/27/13.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAWChatRoomView.h"
#import "PAWChatRoom.h"
#import <QuartzCore/QuartzCore.h>
#import "UIAlertView+Blocks.h"
#import "UnderLineLabel.h"

#define VIEW_WIDTH		160.0f
#define X_OFFSET		10.0f

@implementation PAWChatRoomView
@synthesize selectedObj;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithPFObject:(PFObject *)anObject tag:(NSInteger)tag {
	
	//Mailgun Integration
	mailGun = [Mailgun clientWithDomain:@"sandbox97000bf42754497cab804f769b916919.mailgun.org" apiKey:@"key-71587da92a97174674f9ceda35c6f223"];
	
	float yOffset = 10.0f;
	
	NSString *name = [anObject objectForKey:@"name"];
	UILabel * labelName = nil;
	if (name) {
		labelName = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, yOffset, VIEW_WIDTH - X_OFFSET * 2, 15.0f)];
		labelName.numberOfLines = 0;
		labelName.font = [UIFont systemFontOfSize:16.0f];
		labelName.text = name;
		[labelName sizeToFit];
		yOffset += labelName.frame.size.height;
		yOffset += 10.0f;
	}
	[labelName setTextColor:[UIColor darkGrayColor]];

	PFFile *theImage = [anObject objectForKey:@"photo"];
	NSString * url = [theImage url];
	NSLog(@"image file url = %@", url);
	UIImageView * imageview = nil;
	UIButton *btnImage = nil;
	if (theImage) {
		imageview = [[UIImageView alloc] initWithFrame:CGRectMake(X_OFFSET, yOffset, VIEW_WIDTH - X_OFFSET * 2, 110)];
		imageview.layer.masksToBounds = YES;
		//imageview.layer.cornerRadius = 5.0f;
		//imageview.backgroundColor = [UIColor lightGrayColor];
		
		NSDictionary * arguments = [NSDictionary dictionaryWithObjectsAndKeys:imageview, @"imageView", theImage, @"photo", nil];
		[NSThread detachNewThreadSelector:@selector(loadPhoto:) toTarget:self withObject:arguments];
		
		yOffset += 110;
		yOffset += 10;
		
		btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
		[btnImage addTarget:self action:@selector(showPhoto:) forControlEvents:UIControlEventTouchUpInside];
		btnImage.tag = tag;
		btnImage.frame = imageview.frame;
	}
	
	NSString *desc = [anObject objectForKey:@"description"];
	UILabel * labelDesc = nil;
	if (desc) {
		labelDesc = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, yOffset, VIEW_WIDTH - X_OFFSET * 2, 15.0f)];
		labelDesc.numberOfLines = 0;
		labelDesc.font = [UIFont systemFontOfSize:14.0f];
		labelDesc.textColor = [UIColor grayColor];
		labelDesc.text = desc;
		[labelDesc sizeToFit];
		yOffset += labelDesc.frame.size.height;
		//yOffset += 10.0f;
	}

	
	
	NSString * address = [anObject objectForKey:@"address"];
	UnderLineLabel * labelAddress = [[UnderLineLabel alloc] initWithFrame:CGRectMake(X_OFFSET, yOffset, VIEW_WIDTH - X_OFFSET * 2, 15.0f)];
	labelAddress.numberOfLines = 0;
	labelAddress.textColor = [UIColor blueColor];
	
	labelAddress.font = [UIFont systemFontOfSize:10.0f];
	labelAddress.text = address;
	[labelAddress sizeToFit];
	yOffset += labelAddress.frame.size.height;
	yOffset += 10.0f;
	
	UIButton *btnAddress = [UIButton buttonWithType:UIButtonTypeCustom];
	btnAddress.frame = labelAddress.frame;
	[btnAddress addTarget:self action:@selector(addressBtnClicked) forControlEvents:UIControlEventTouchUpInside];
	
	
	
	
	
	UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setTitle:@"Enter Event" forState:UIControlStateNormal];
	button.tag = tag;
	button.titleLabel.font = [UIFont systemFontOfSize:12.0f];
	button.backgroundColor = [UIColor colorWithRed:80.0/255.0 green:167.0/255.0 blue:184.0/255.0 alpha:1.0];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.layer.cornerRadius = 2.0;
	[button addTarget:self action:@selector(onEnterChat:) forControlEvents:UIControlEventTouchUpInside];
	button.frame = CGRectMake(X_OFFSET, yOffset, VIEW_WIDTH - X_OFFSET * 2, 30);
	yOffset += 40;
	
	UIButton * buttonAbuse = [UIButton buttonWithType:UIButtonTypeSystem];
	[buttonAbuse setTitle:@"Report Abuse" forState:UIControlStateNormal];
	buttonAbuse.layer.cornerRadius = 2.0;
	buttonAbuse.titleLabel.font = [UIFont systemFontOfSize:12.0f];

	buttonAbuse.backgroundColor = [UIColor grayColor];
	[buttonAbuse setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	buttonAbuse.tag = tag;
	[buttonAbuse addTarget:self action:@selector(reportAbuseFunction:) forControlEvents:UIControlEventTouchUpInside];
	buttonAbuse.frame = CGRectMake(X_OFFSET, yOffset, VIEW_WIDTH - X_OFFSET * 2, 30);
	yOffset += 40;
	selectedObj = anObject;
	
	CGRect frame = CGRectMake(320 - VIEW_WIDTH - 10, 150, VIEW_WIDTH, yOffset);
	self = [super initWithFrame:frame];
    if (self) {
		
        // Initialization code
		self.frame = frame;
		self.backgroundColor = [UIColor whiteColor];
		self.layer.masksToBounds = YES;
		self.layer.cornerRadius = 5.0f;
		
		if (labelName) {
			[self addSubview:labelName];
		}
		if (imageview) {
			[self addSubview:imageview];
		}
		if (labelAddress) {
			[self addSubview:labelAddress];
		}
		if (labelDesc) {
			[self addSubview:labelDesc];
		}
		if(btnImage)
		{
			[self addSubview:btnImage];
		}
		
		[self addSubview:button];
		[self addSubview:buttonAbuse];
		[self addSubview:btnAddress];
    }
    return self;
}



- (id)initWithEBObject:(NSDictionary *)object tag:(NSInteger)tag {
	
	//Mailgun Integration
	mailGun = [Mailgun clientWithDomain:@"sandbox97000bf42754497cab804f769b916919.mailgun.org" apiKey:@"key-71587da92a97174674f9ceda35c6f223"];
	
	float yOffset = 10.0f;
	
	
	NSString *name;
	if(![[object objectForKey:@"name"] isEqual:[NSNull null]])
		name = [[object objectForKey:@"name"] objectForKey:@"text"];
	NSString *desc;
	if(![[object objectForKey:@"description"] isEqual:[NSNull null]])
		desc = [[object objectForKey:@"description"] objectForKey:@"text"];
	if(desc.length > 150)
	{
		desc = [desc substringToIndex:149];
	}
	
	
	UILabel * labelName = nil;
	if (name) {
		labelName = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, yOffset, VIEW_WIDTH - X_OFFSET * 2, 15.0f)];
		labelName.numberOfLines = 0;
		labelName.font = [UIFont systemFontOfSize:14.0f];
		labelName.text = name;
		[labelName sizeToFit];
		yOffset += labelName.frame.size.height;
		yOffset += 10.0f;
	}
	

	UIButton *btnImage = nil;
	
	NSString * address;
	if(![[object objectForKey:@"venue"] isEqual:[NSNull null]])
	{
	address = @"";
	}
	UILabel * labelAddress = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, yOffset, VIEW_WIDTH - X_OFFSET * 2, 15.0f)];
	labelAddress.numberOfLines = 0;
	labelAddress.font = [UIFont systemFontOfSize:10.0f];
	labelAddress.textColor = [UIColor blueColor];
	labelAddress.text = address;
	[labelAddress sizeToFit];
	yOffset += labelAddress.frame.size.height;
	yOffset += 10.0f;
	
	UILabel * labelDesc = nil;
	if (desc) {
		labelDesc = [[UILabel alloc] initWithFrame:CGRectMake(X_OFFSET, yOffset, VIEW_WIDTH - X_OFFSET * 2, 15.0f)];
		labelDesc.numberOfLines = 0;
		labelDesc.font = [UIFont systemFontOfSize:10.0f];
		labelDesc.textColor = [UIColor blueColor];
		labelDesc.text = desc;
		[labelDesc sizeToFit];
		yOffset += labelDesc.frame.size.height;
		yOffset += 10.0f;
	}
	
	UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setTitle:@"Enter Event" forState:UIControlStateNormal];
	button.tag = tag;
	[button addTarget:self action:@selector(onEnterChat:) forControlEvents:UIControlEventTouchUpInside];
	button.frame = CGRectMake(X_OFFSET, yOffset, VIEW_WIDTH - X_OFFSET * 2, 30);
	yOffset += 40;
	
	UIButton * buttonAbuse = [UIButton buttonWithType:UIButtonTypeSystem];
	[buttonAbuse setTitle:@"Report Abuse" forState:UIControlStateNormal];
	buttonAbuse.tag = tag;
	[buttonAbuse addTarget:self action:@selector(reportAbuseFunction:) forControlEvents:UIControlEventTouchUpInside];
	buttonAbuse.frame = CGRectMake(X_OFFSET, yOffset, VIEW_WIDTH - X_OFFSET * 2, 30);
	yOffset += 40;
	selectedObj = object;
	
	CGRect frame = CGRectMake(320 - VIEW_WIDTH - 10, 150, VIEW_WIDTH, yOffset);
	self = [super initWithFrame:frame];
	if (self) {
		
		// Initialization code
		self.frame = frame;
		self.backgroundColor = [UIColor whiteColor];
		self.layer.masksToBounds = YES;
		self.layer.cornerRadius = 5.0f;
		
		if (labelName) {
			[self addSubview:labelName];
		}
		
		if (labelAddress) {
			[self addSubview:labelAddress];
		}
		if (labelDesc) {
			[self addSubview:labelDesc];
		}
		if(btnImage)
		{
			[self addSubview:btnImage];
		}
		
		[self addSubview:button];
		[self addSubview:buttonAbuse];
	}
	return self;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)showPhoto:(UIButton *)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kPAWShowImagesNotification object:[NSNumber numberWithInteger:sender.tag]];

}
- (void)onEnterChat:(UIButton *)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:kPAWEnterChatRoomNotification object:[NSNumber numberWithInteger:sender.tag]];
}

- (void)reportAbuseFunction:(UIButton *)sender{
	
	[[[UIAlertView alloc] initWithTitle:@"Report Abuse?"
	                            message:@"Are you sure you want to report this post as abuse?"
		               cancelButtonItem:[RIButtonItem itemWithLabel:@"Yes" action:^{
		
		PFQuery *query = [PFQuery queryWithClassName:@"ChatRoom"];
		
		// Retrieve the object by id
		[query getObjectInBackgroundWithId:[selectedObj objectId] block:^(PFObject *object, NSError *error) {
			
			object[@"is_spam"] = @YES;
			object[@"reportedBy"] = [PFUser currentUser];
			
			[object saveInBackground];
			
			NSString *body = [NSString stringWithFormat:@"Report Abuse chat room - %@ , Reporter - %@",[selectedObj objectId],[[PFUser currentUser] username]];
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

#pragma mark - load photo thread method
- (void) loadPhoto:(NSDictionary *)arguments {
	UIImageView * imageView = [arguments objectForKey:@"imageView"];
	PFFile * photo = [arguments objectForKey:@"photo"];
	imageView.image = [UIImage imageWithData:[photo getData]];
}
-(void)addressBtnClicked
{
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
	PFGeoPoint * point = [selectedObj objectForKey:@"location"];
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
	MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
												   addressDictionary:nil];
	MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
	[mapItem setName:[selectedObj objectForKey:@"address"]];
	// Pass the map item to the Maps app
	[mapItem openInMapsWithLaunchOptions:nil];
}

-(void)openGoogleMaps
{
	NSString *strAddress = [selectedObj objectForKey:@"address"];
	strAddress = [strAddress stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	NSString *strUrl = [NSString stringWithFormat:@"comgooglemaps://?q=%@",strAddress];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
	
}
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
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
@end
