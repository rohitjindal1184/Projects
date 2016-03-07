//
//  PAWLoginViewController.m
//

#import "PAWLoginViewController.h"

#import "PAWAppDelegate.h"
#import <Parse/Parse.h>
#import "PAWEnterChatViewController.h"

@interface PAWLoginViewController ()

- (void)processFieldEntries;
- (void)textInputChanged:(NSNotification *)note;
- (BOOL)shouldEnableDoneButton;

@end

@implementation PAWLoginViewController

@synthesize signinButton;
@synthesize usernameField;
@synthesize passwordField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:usernameField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:passwordField];

	signinButton.enabled = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
//	[usernameField becomeFirstResponder];
	[super viewWillAppear:animated];
}

-  (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:usernameField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:passwordField];
}

#pragma mark - IBActions

- (IBAction)cancel:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
	[usernameField resignFirstResponder];
	[passwordField resignFirstResponder];

	[self processFieldEntries];
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

- (IBAction)twitter:(id)sender {
	[PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
		if (!user) {
			NSLog(@"Uh oh. The user cancelled the Twitter login.");
			return;
		} else {
			
			if (user.isNew) {
				NSLog(@"User signed up and logged in with Twitter!");
				NSString * name = [PFTwitterUtils twitter].screenName;
				[user setObject:name forKey:@"fullname"];
				[user setObject:name forKey:@"username"];
				[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
					if (succeeded) {
						[self loginSucceed];
					}
					else {
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
						[alert show];
					}
				}];
			} else {
				[self loginSucceed];
			}
		}
	}];
}

#pragma mark - UITextField text field change notifications and helper methods

- (BOOL)shouldEnableDoneButton {
	BOOL enableDoneButton = NO;
	if (usernameField.text != nil &&
		usernameField.text.length > 0 &&
		passwordField.text != nil &&
		passwordField.text.length > 0) {
		enableDoneButton = YES;
	}
	return enableDoneButton;
}

- (void)textInputChanged:(NSNotification *)note {
	signinButton.enabled = [self shouldEnableDoneButton];
}

#pragma mark - Private methods:

#pragma mark Field validation

- (void)processFieldEntries {
	// Get the username text, store it in the app delegate for now
	NSString *username = usernameField.text;
	NSString *password = passwordField.text;
	NSString *noUsernameText = @"username";
	NSString *noPasswordText = @"password";
	NSString *errorText = @"No ";
	NSString *errorTextJoin = @" or ";
	NSString *errorTextEnding = @" entered";
	BOOL textError = NO;
	username = [username lowercaseString];
	// Messaging nil will return 0, so these checks implicitly check for nil text.
	if (username.length == 0 || password.length == 0) {
		textError = YES;

		// Set up the keyboard for the first field missing input:
		if (password.length == 0) {
			[passwordField becomeFirstResponder];
		}
		if (username.length == 0) {
			[usernameField becomeFirstResponder];
		}
	}

	if (username.length == 0) {
		textError = YES;
		errorText = [errorText stringByAppendingString:noUsernameText];
	}

	if (password.length == 0) {
		textError = YES;
		if (username.length == 0) {
			errorText = [errorText stringByAppendingString:errorTextJoin];
		}
		errorText = [errorText stringByAppendingString:noPasswordText];
	}

	if (textError) {
		errorText = [errorText stringByAppendingString:errorTextEnding];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorText message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alertView show];
		return;
	}

	// Everything looks good; try to log in.
	// Disable the done button for now.
	signinButton.enabled = NO;

	PAWActivityView *activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
	UILabel *label = activityView.label;
	label.text = @"Logging in";
	label.font = [UIFont boldSystemFontOfSize:20.f];
	[activityView.activityIndicator startAnimating];
	[activityView layoutSubviews];

	[self.view addSubview:activityView];

	[PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
		// Tear down the activity view in all cases.
		[activityView.activityIndicator stopAnimating];
		[activityView removeFromSuperview];

		if (user) {
			
			
//			if ([[user objectForKey:@"EULA"] integerValue] == 0) {
//				[[NSUserDefaults standardUserDefaults] setBool:NO forKey:[user objectId]];
//			}else if ([[user objectForKey:@"EULA"] integerValue] == 1){
//				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[user objectId]];
//			}
			

			[self loginSucceed];
		} else {
			// Didn't get a user.
			NSLog(@"%s didn't get a user!", __PRETTY_FUNCTION__);

			// Re-enable the done button if we're tossing them back into the form.
			signinButton.enabled = [self shouldEnableDoneButton];
			UIAlertView *alertView = nil;

			if (error == nil) {
				// the username or password is probably wrong.
				alertView = [[UIAlertView alloc] initWithTitle:@"Couldn’t log in:\nThe username or password were wrong." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			} else {
				// Something else went horribly wrong:
				alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			}
			[alertView show];
			// Bring the keyboard back up, because they'll probably need to change something.
			[usernameField becomeFirstResponder];
		}
	}];
}

#pragma mark - keyboard methods
- (void) scrollForTextField: (UITextField *)textField {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, textField.frame.origin.y + 100 )  animated: YES];
    }
}

- (void) dismissKeyboard {
    [self.usernameField resignFirstResponder];
	[self.passwordField resignFirstResponder];
}

#pragma mark - go to next screen
- (void) loginSucceed {
	NSLog(@"rohit1184");
	PAWAppDelegate *appd = (PAWAppDelegate *)[[UIApplication sharedApplication]delegate];
	[appd setupNotification];
	PAWEnterChatViewController *wallViewController = [[PAWEnterChatViewController alloc] initWithNibName:@"PAWEnterChatViewController" bundle:nil];
	[(UINavigationController *)self.presentingViewController pushViewController:wallViewController animated:NO];
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == usernameField) {
		[passwordField becomeFirstResponder];
	}
	if (textField == passwordField) {
		[passwordField resignFirstResponder];
		[self processFieldEntries];
	}
	
	return YES;
}

- (IBAction)onDidEndOnExit:(id)sender {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.scrollView setContentSize:CGSizeMake(320, 635)];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self scrollForTextField:textField];
}

#pragma mark - scroll view delegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView_ {
    if (scrollView_.contentOffset.y == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.scrollView setContentSize:CGSizeMake(320, SCREEN_HEIGHT - 64)];
        }
    }
}

@end
