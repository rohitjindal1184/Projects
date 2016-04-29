//
//  PAWStartChatViewController.h
//  LokayMe
//
//  Created by He Fei on 12/26/13.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoSuggestTableView.h"
#import "MBProgressHUD.h"
#import "Mailgun.h"
#import "DropboxBrowserViewController.h"
@interface PAWStartChatViewController : UIViewController<PlaceSelected,DropboxBrowserDelegate>
{
	AutoSuggestTableView *autoSuggestionView;
	BOOL viewDisaaper;
	BOOL openPicker;
	Mailgun *mailGun;
	NSString *type;
	BOOL alertShowed;
	CLGeocoder *geocoder;
	__weak IBOutlet UIButton *btnphoto;
}
- (IBAction)actionEnlargePhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewTime;
@property (weak, nonatomic) IBOutlet UIToolbar *dateToolbar;
- (IBAction)actionDatedone:(id)sender;

@end
