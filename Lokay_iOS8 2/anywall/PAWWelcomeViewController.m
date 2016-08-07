//
//  PAWViewController.m
//

#import "PAWWelcomeViewController.h"

#import "PAWWallViewController.h"
#import "PAWLoginViewController.h"
#import "PAWNewUserViewController.h"
#import "PAWForgotPwdViewController.h"
#import "PAWAppDelegate.h"
#import "PAWEnterChatViewController.h"
#import "PAWChooseChatRoomViewController.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@implementation PAWWelcomeViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad{
	
	PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(appDelegate.isSignout)
	{
		
		PAWNewUserViewController *newUserViewController = [[PAWNewUserViewController alloc] initWithNibName:nil bundle:nil];
		[self.navigationController presentViewController:newUserViewController animated:NO completion:^{}];	}

}

-(void)viewWillAppear:(BOOL)animated
{
	reader = [ZBarReaderViewController new];
	reader.supportedOrientationsMask = ZBarOrientationMaskAll;
	
	ZBarImageScanner *scanner = reader.scanner;
	
	[scanner setSymbology: ZBAR_QRCODE
				   config: ZBAR_CFG_POSITION
					   to: 0];
	[reader.readerView start];
	reader.view.frame = CGRectMake(0, 0, 320,640);
	reader.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
	[self.cameraView addSubview:reader.view];
}
-(void)viewWillDisappear:(BOOL)animated
{
	[reader.view removeFromSuperview];
	reader = nil;
}
#pragma mark - Transition methods

//- (IBAction)loginButtonSelected:(id)sender {
//	PAWLoginViewController *loginViewController = [[PAWLoginViewController alloc] initWithNibName:nil bundle:nil];
//	[self.navigationController presentViewController:loginViewController animated:YES completion:^{}];
//}


//- (IBAction)createButtonSelected:(id)sender {
//	PAWNewUserViewController *newUserViewController = [[PAWNewUserViewController alloc] initWithNibName:nil bundle:nil];
//	[self.navigationController presentViewController:newUserViewController animated:YES completion:^{}];
//}


#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)skipButtonSelected:(id)sender {
	PAWEnterChatViewController *wallViewController = [[PAWEnterChatViewController alloc] initWithNibName:@"PAWEnterChatViewController" bundle:nil];
	[(UINavigationController *)self.presentingViewController pushViewController:wallViewController animated:NO];
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	
}

- (IBAction)loginButtonSelected:(id)sender
{
	UIButton *btn = (UIButton *)sender;
	if(btn.tag == 1)
	{
		PAWChooseChatRoomViewController * viewController = [[PAWChooseChatRoomViewController alloc] initWithNibName:@"PAWChooseChatRoomViewController" bundle:nil];
		[self.navigationController pushViewController:viewController animated:YES];
		return;
	}
	PAWLoginViewController *loginViewController = [[PAWLoginViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController presentViewController:loginViewController animated:YES completion:^{}];
}

- (IBAction)signupButtonSelected:(id)sender
{
	PAWNewUserViewController *newUserViewController = [[PAWNewUserViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController presentViewController:newUserViewController animated:YES completion:^{}];
}

- (IBAction)forgotButtonSelected:(id)sender {
	PAWForgotPwdViewController *forgotPwdViewController = [[PAWForgotPwdViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController presentViewController:forgotPwdViewController animated:YES completion:^{}];
}

- (IBAction)facebook:(id)sender {
	NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location",@"email"];
	
	// Login PFUser using facebook
	[PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
		
		if (!user) {
			if (!error) {
				NSLog(@"Uh oh. The user cancelled the Facebook login.");
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
				[alert show];
			} else {
				NSLog(@"Uh oh. An error occurred: %@", error);
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
				[alert show];
			}
		} else {
			
			if (user.isNew) {
				NSLog(@"User with facebook signed up and logged in!");
				
				if([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){ //<-
					FBRequest *request = [FBRequest requestForMe];
					[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
						if (!error) {
							NSDictionary *userData = (NSDictionary *)result;
							NSLog(@"resulet -- %@",userData);
							NSString *name = [userData valueForKeyPath:@"first_name"]; //[@"username"];
							NSString *fullName = [NSString stringWithFormat:@"%@ %@",[userData valueForKey:@"first_name"],[userData valueForKey:@"last_name"]];
							
							[user setObject:fullName forKey:@"fullname"];
							[user setObject:name forKey:@"username"];
							[user setObject:[userData valueForKey:@"email"] forKey:@"email"];
							
							PAWAppDelegate * appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
							CLLocationCoordinate2D coordinate = appDelegate.locationManager.location.coordinate;
							if (!FEQUALZERO(coordinate.latitude) || !FEQUALZERO(coordinate.longitude)) {
								PFGeoPoint * geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
								[user setObject:geoPoint forKey:@"location"];
							}
							
							[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
								if (succeeded) {
									[self loginSucceed];
								}
								else {
									UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
									[alert show];
								}
							}];
						}}];
				}
				
			} else {
				NSLog(@"User with facebook logged in!");
				[self loginSucceed];
			}
			
		}
	}];
}
- (void) loginSucceed {
	NSLog(@"rohit1184");
	PAWAppDelegate *appd = (PAWAppDelegate *)[[UIApplication sharedApplication]delegate];
	[appd setupNotification];
	PAWEnterChatViewController *wallViewController = [[PAWEnterChatViewController alloc] initWithNibName:@"PAWEnterChatViewController" bundle:nil];
	[self.navigationController pushViewController:wallViewController animated:NO];
	//[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
