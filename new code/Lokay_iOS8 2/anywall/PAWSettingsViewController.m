//
//  PAWSettingsViewController.m
//

#import "PAWSettingsViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "PAWAppDelegate.h"
#import <Parse/Parse.h>

@interface PAWSettingsViewController ()

- (NSString *)distanceLabelForCell:(NSIndexPath *)indexPath;
- (PAWLocationAccuracy)distanceForCell:(NSIndexPath *)indexPath;

@property (nonatomic, assign) CLLocationAccuracy filterDistance;

@end

// UITableView enum-based configuration via Fraser Speirs: http://speirs.org/blog/2008/10/11/a-technique-for-using-uitableview-and-retaining-your-sanity.html
typedef enum {
//	kPAWSettingsTableViewDistance = 0,
	
	kPAWSettingsTableViewEraseChatRoom = 0,
	kPAWSettingsTableViewLogout,
	kPAWSettingsTableViewterms,
	kPAWSettingsTableViewreport,
	kPAWSettingsTableViewNumberOfSections
} kPAWSettingsTableViewSections;

typedef enum {
	kPAWSettingsLogoutDialogLogout = 0,
	kPAWSettingsLogoutDialogCancel,
	kPAWSettingsLogoutDialogNumberOfButtons
} kPAWSettingsLogoutDialogButtons;

typedef enum {
	kPAWSettingsTableViewDistanceSection250FeetRow = 0,
	kPAWSettingsTableViewDistanceSection1000FeetRow,
	kPAWSettingsTableViewDistanceSection4000FeetRow,
	kPAWSettingsTableViewDistanceNumberOfRows
} kPAWSettingsTableViewDistanceSectionRows;

static uint16_t const kPAWSettingsTableViewEraseChatRoomNumberOfRows = 1;
static uint16_t const kPAWSettingsTableViewLogoutNumberOfRows = 1;
static uint16_t const kPAWSettingsTableViewtermNumberOfRows = 1;
static uint16_t const kPAWSettingsTableViewreportNumberOfRows = 1;

@implementation PAWSettingsViewController

@synthesize tableView;
@synthesize filterDistance;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.filterDistance = appDelegate.filterDistance;
    }
    return self;
}


#pragma mark - Custom setters

// Always fault our filter distance through to the app delegate. We just cache it locally because it's used in the tableview's cells.
- (void)setFilterDistance:(CLLocationAccuracy)aFilterDistance {
	PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.filterDistance = aFilterDistance;
	filterDistance = aFilterDistance;
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private helper methods

- (NSString *)distanceLabelForCell:(NSIndexPath *)indexPath {
	NSString *cellText = nil;
	switch (indexPath.row) {
		case kPAWSettingsTableViewDistanceSection250FeetRow:
			cellText = @"250 feet";
			break;
		case kPAWSettingsTableViewDistanceSection1000FeetRow:
			cellText = @"1000 feet";
			break;
		case kPAWSettingsTableViewDistanceSection4000FeetRow:
			cellText = @"4000 feet";
			break;
		case kPAWSettingsTableViewDistanceNumberOfRows: // never reached.
		default:
			cellText = @"The universe";
			break;
	}
	return cellText;
}

- (PAWLocationAccuracy)distanceForCell:(NSIndexPath *)indexPath {
	PAWLocationAccuracy distance = 0.0;
	switch (indexPath.row) {
		case kPAWSettingsTableViewDistanceSection250FeetRow:
			distance = 250;
			break;
		case kPAWSettingsTableViewDistanceSection1000FeetRow:
			distance = 1000;
			break;
		case kPAWSettingsTableViewDistanceSection4000FeetRow:
			distance = 4000;
			break;
		case kPAWSettingsTableViewDistanceNumberOfRows: // never reached.
		default:
			distance = 10000 * kPAWFeetToMiles;
			break;
	}

	return distance;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return kPAWSettingsTableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch ((kPAWSettingsTableViewSections)section) {
//		case kPAWSettingsTableViewDistance:
//			return kPAWSettingsTableViewDistanceNumberOfRows;
//			break;
		case kPAWSettingsTableViewEraseChatRoom:
			return kPAWSettingsTableViewEraseChatRoomNumberOfRows;
			break;
				case kPAWSettingsTableViewLogout:
			return kPAWSettingsTableViewLogoutNumberOfRows;
			break;
		case kPAWSettingsTableViewterms:
					return kPAWSettingsTableViewtermNumberOfRows;
						break;
		case kPAWSettingsTableViewreport:
			return kPAWSettingsTableViewreportNumberOfRows;
			break;

		case kPAWSettingsTableViewNumberOfSections:
			return 0;
			break;
	};
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"SettingsTableView";
//	if (indexPath.section == kPAWSettingsTableViewDistance) {
//		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
//		if ( cell == nil )
//		{
//			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//		}
//
//		// Configure the cell.
//		cell.textLabel.text = [self distanceLabelForCell:indexPath];
//
//		if (self.filterDistance == 0.0) {
//			NSLog(@"We have a zero filter distance!");
//		}
//
//		PAWLocationAccuracy filterDistanceInFeet = self.filterDistance * ( 1 / kPAWFeetToMeters);
//		PAWLocationAccuracy distanceForCell = [self distanceForCell:indexPath];
//		if (abs(distanceForCell - filterDistanceInFeet) < 0.001 ) {
//			cell.accessoryType = UITableViewCellAccessoryCheckmark;
//		} else {
//			cell.accessoryType = UITableViewCellAccessoryNone;
//		}
//
//		return cell;
//	} else
		
		if (indexPath.section == kPAWSettingsTableViewEraseChatRoom) {
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
		if ( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}

		// Configure the cell.
		cell.textLabel.text = @"Erase chat room";
		cell.textLabel.textAlignment = NSTextAlignmentCenter;

		return cell;
	} else if (indexPath.section == kPAWSettingsTableViewLogout) {
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
		if ( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}
		
		// Configure the cell.
		cell.textLabel.text = @"Log out of Lokay";
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		
		return cell;
	}
	else if (indexPath.section == kPAWSettingsTableViewterms) {
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
		if ( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}
		
		// Configure the cell.
		cell.textLabel.text = @"Terms and Conditions";
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		
		return cell;
	}
	else if (indexPath.section == kPAWSettingsTableViewreport) {
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
		if ( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}
		
		// Configure the cell.
		cell.textLabel.text = @"Report User";
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		
		return cell;
	}


	else {
		return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch ((kPAWSettingsTableViewSections)section) {
//		case kPAWSettingsTableViewDistance:
//			return @"Search Distance";
//			break;
		case kPAWSettingsTableViewEraseChatRoom:
			return @"";
			break;
		case kPAWSettingsTableViewLogout:
			return @"";
			break;
		case kPAWSettingsTableViewterms:
			return @"";
			break;
		case kPAWSettingsTableViewreport:
			return @"";
			break;
		case kPAWSettingsTableViewNumberOfSections:
			return @"";
			break;
	}
}

#pragma mark - UITableViewDelegate methods

// Called after the user changes the selection.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	if (indexPath.section == kPAWSettingsTableViewDistance) {
//		[aTableView deselectRowAtIndexPath:indexPath animated:YES];
//
//		// if we were already selected, bail and save some work.
//		UITableViewCell *selectedCell = [aTableView cellForRowAtIndexPath:indexPath];
//		if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark) {
//			return;
//		}
//
//		// uncheck all visible cells.
//		for (UITableViewCell *cell in [aTableView visibleCells]) {
//			if (cell.accessoryType != UITableViewCellAccessoryNone) {
//				cell.accessoryType = UITableViewCellAccessoryNone;
//			}
//		}
//		selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
//
//		PAWLocationAccuracy distanceForCellInFeet = [self distanceForCell:indexPath];
//		self.filterDistance = distanceForCellInFeet * kPAWFeetToMeters;
//	} else
	if (indexPath.section == kPAWSettingsTableViewEraseChatRoom) {
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Do you want to erase this chat room?" message:nil delegate:self cancelButtonTitle:@"Erase" otherButtonTitles:@"Cancel", nil];
		alertView.tag = kPAWSettingsTableViewEraseChatRoom;
		[alertView show];
	} else if (indexPath.section == kPAWSettingsTableViewLogout) {
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log out of Lokay?" message:nil delegate:self cancelButtonTitle:@"Log out" otherButtonTitles:@"Cancel", nil];
		alertView.tag = kPAWSettingsTableViewLogout;
		[alertView show];
		
	}
	else if (indexPath.section == kPAWSettingsTableViewterms) {
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Do you want to open terms in browser?" message:nil delegate:self cancelButtonTitle:@"Open" otherButtonTitles:@"Cancel", nil];
		alertView.tag = kPAWSettingsTableViewterms;
		[alertView show];
	}
	else if (indexPath.section == kPAWSettingsTableViewreport) {
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Do you want to report this room / user?" message:nil delegate:self cancelButtonTitle:@"Report" otherButtonTitles:@"Cancel", nil];
		alertView.tag = kPAWSettingsTableViewreport;
		[alertView show];
	}


}

#pragma mark - UIAlertViewDelegate methods

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == kPAWSettingsTableViewEraseChatRoom) {
		if (buttonIndex == 0) {
			//Erase chat room
			PFObject *object = [PFObject objectWithoutDataWithClassName:@"ChatRoom"
															   objectId:self.chatroom_id];
			
			PAWActivityView *activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
			UILabel *label = activityView.label;
			label.text = @"Logging in";
			label.font = [UIFont boldSystemFontOfSize:20.f];
			
			
			
			NSLog(@"PFObject %@", [PFUser currentUser].objectId);
			//NSLog(@"PFObject %@", [object objectForKey:@"creator"]);
			PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
			if ([[PFUser currentUser].objectId isEqualToString:appDelegate.ChatOwner.objectId])
			{
				[activityView.activityIndicator startAnimating];
				[activityView layoutSubviews];
				[self.view addSubview:activityView];
				[object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
					
					// Tear down the activity view in all cases.
					[activityView.activityIndicator stopAnimating];
					[activityView removeFromSuperview];
					
					if (succeeded) {
						[[NSNotificationCenter defaultCenter] postNotificationName:kPAWEraseChatRoomNotification object:nil];
					}
					else {
						UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
						[alertView show];
					}
				}];
			}
			else
			{
				UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"You are not the owner of the chat room." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
			}
			
			
		} else if (buttonIndex == 1) {
			return;
		}
	}
	else if (alertView.tag == kPAWSettingsTableViewLogout)
	{
		if (buttonIndex == 0) {
			// Log out.
			[PFUser logOut];
			
			[self.presentingViewController dismissViewControllerAnimated:NO completion:^{
				PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
				[appDelegate presentWelcomeViewController];
			}];
			
		} else if (buttonIndex == 1) {
			return;
		}
	}
	else if (alertView.tag == kPAWSettingsTableViewterms)
	{
		if (buttonIndex == 0) {
		NSString *Report_url=[NSString stringWithFormat:@"http://lokayme.com/Terms.html"];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:Report_url]];
		}
	}
	   
	else if (alertView.tag == kPAWSettingsTableViewreport)
	{
		if (buttonIndex == 0) {
		
		PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		NSArray *toRecipients = [NSArray arrayWithObjects:@"info@lokayme.com", nil];
        [picker setToRecipients:toRecipients];
		// Set the subject of email
		[picker setSubject:@"Report user for Lokay app!"];
		
		// Add email addresses
		// Notice three sections: "to" "cc" and "bcc"
		
		// Fill out the email body text
		NSString *emailBody = [NSString stringWithFormat:@"Report this chat room  user id   '  %@  'for violating the terms for content ",appDelegate.chatroom_id];
		
		// This is not an HTML formatted email
		[picker setMessageBody:emailBody isHTML:YES];
		
		// Create NSData object as PNG image data from camera image
		
		
		// Attach image data to the email
		// 'CameraImage.png' is the file name that will be attached to the email
		
		
		// Show email view
		if ([MFMailComposeViewController canSendMail]) {
			[self presentViewController:picker animated:YES completion:nil];
		}else{
			NSLog(@"can not send mail");
		}
		}
	}

}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult: (MFMailComposeResult)result error:(NSError*)error {
	[self dismissViewControllerAnimated:YES completion:NULL];
}


// Nil implementation to avoid the default UIAlertViewDelegate method, which says:
// "Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button"
// Since we have "Log out" at the cancel index (to get it out from the normal "Ok whatever get this dialog outta my face"
// position, we need to deal with the consequences of that.
- (void)alertViewCancel:(UIAlertView *)alertView {
	return;
}

- (IBAction)back:(id)sender
{
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}
@end
