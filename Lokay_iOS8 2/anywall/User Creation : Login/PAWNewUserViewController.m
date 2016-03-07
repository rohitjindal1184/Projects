//
//  PAWNewUserViewController.m
//

#import "PAWNewUserViewController.h"

#import <Parse/Parse.h>
#import "PAWEnterChatViewController.h"

@interface PAWNewUserViewController ()

- (void)processFieldEntries;
- (void)textInputChanged:(NSNotification *)note;
- (BOOL)shouldEnableDoneButton;

@end

@implementation PAWNewUserViewController

@synthesize createButton;
@synthesize usernameField, mailaddressField;
@synthesize passwordField, passwordAgainField;


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:usernameField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:mailaddressField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:passwordField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:passwordAgainField];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:_BPNo];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:_BpasswordField
	 ];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:_BpasswordAgainField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:_BmailaddressField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:_location];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:_txtBusinessName];	
	createButton.enabled = NO;
	mailGun = [Mailgun clientWithDomain:@"sandbox97000bf42754497cab804f769b916919.mailgun.org" apiKey:@"key-71587da92a97174674f9ceda35c6f223"];
	PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(appDelegate.isSignout)
	{
		self.segment.selectedSegmentIndex = 1;
		_personalView.hidden = YES;
		_businessView.hidden = NO;
		isBussiness = YES;
		
	}
}

- (void)viewWillAppear:(BOOL)animated {
	//[usernameField becomeFirstResponder];
	[super viewWillAppear:animated];
	PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(appDelegate.isSignout)
		_BmailaddressField.text = [[PFUser currentUser]email];

}
-(void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:usernameField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:mailaddressField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:passwordField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:passwordAgainField];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_BPNo];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_BpasswordAgainField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_BpasswordField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_BmailaddressField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_txtBusinessName];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_location];


	[[NSNotificationCenter defaultCenter]removeObserver:self];
	PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(appDelegate.isSignout)
	{
	appDelegate.isSignout = NO;
	appDelegate.BussinessUserCreation = nil;
		[PFUser logOut];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
}

#pragma mark - ()

- (BOOL)shouldEnableDoneButton {
	BOOL enableDoneButton = NO;
	if(isBussiness)
	{
		if(_BmailaddressField.text != nil && _BmailaddressField.text.length > 0 &&_BpasswordAgainField.text != nil && _BpasswordAgainField.text.length > 0 &&_BpasswordField.text != nil && _BpasswordField.text.length > 0 && _BPNo.text != nil && _BPNo.text.length > 0  && _txtBusinessName.text != nil && _txtBusinessName.text.length > 0)
		{
			enableDoneButton = YES;

		}
	}
	else
	{
	if (usernameField.text != nil &&
		usernameField.text.length > 0 &&
		mailaddressField.text != nil &&
		mailaddressField.text.length > 0 &&
		passwordField.text != nil &&
		passwordField.text.length > 0 &&
		passwordAgainField.text != nil &&
		passwordAgainField.text.length > 0) {
		enableDoneButton = YES;
	}
	}
	return enableDoneButton;
}

- (void)textInputChanged:(NSNotification *)note {
	createButton.enabled = [self shouldEnableDoneButton];
}

- (IBAction)cancel:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
	[usernameField resignFirstResponder];
	[mailaddressField resignFirstResponder];
	[passwordField resignFirstResponder];
	[passwordAgainField resignFirstResponder];
	
	[_BmailaddressField resignFirstResponder];
	[_BpasswordAgainField resignFirstResponder];
	[_BpasswordField resignFirstResponder];
	[_BPNo resignFirstResponder];
	[_location resignFirstResponder];
	[_txtBusinessName resignFirstResponder];
	if(isBussiness)
	{
		[self processFieldEntriesforBusiness];
	}
	else
	{
		[self processFieldEntries];
	}
}
-(void)processFieldEntriesforBusiness
{
	
		// Check that we have a non-zero username and passwords.
		// Compare password and passwordAgain for equality
		// Throw up a dialog that tells them what they did wrong if they did it wrong.
		
		NSString *username = _BmailaddressField.text;
		NSString *mailaddress = _BmailaddressField.text;
		NSString *password = _BpasswordField.text;
		NSString *passwordAgain = _BpasswordAgainField.text;
		NSString *location = _location.text;
		NSString *bussinessName = _txtBusinessName.text;
		NSString *pno = _BPNo.text;

		BOOL textError = NO;
		
		// Messaging nil will return 0, so these checks implicitly check for nil text.
		if (username.length == 0 || password.length == 0 || passwordAgain.length == 0) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error" message:@"All fields Required" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			return;
		}else if ([password compare:passwordAgain] != NSOrderedSame) {
			// We have non-zero strings.
			// Check for equal password strings.
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error" message:@"enter the same password twice" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			return;
		}
		
		
		
		// Everything looks good; try to log in.
		// Disable the done button for now.
		createButton.enabled = NO;
		PAWActivityView *activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
		UILabel *label = activityView.label;
		label.text = @"Signing You Up";
		label.font = [UIFont boldSystemFontOfSize:20.f];
		[activityView.activityIndicator startAnimating];
		[activityView layoutSubviews];
		
		[self.view addSubview:activityView];
		
		// Call into an object somewhere that has code for setting up a user.
		// The app delegate cares about this, but so do a lot of other objects.
		// For now, do this inline.
		username = [username lowercaseString];
		PFUser *user;
		PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
		if (appDelegate.isSignout) {
			
			[PFUser currentUser].username = username;
			[PFUser currentUser].email = mailaddress;
			[PFUser currentUser].password = password;
			//[user setObject:location forKey:@"bussiness_location"];
			[[PFUser currentUser] setObject:bussinessName forKey:@"bussiness_name"];
			[[PFUser currentUser] setObject:pno forKey:@"phone_no"];
		}
		else
		{
			user = [PFUser user];
		
		user.username = username;
		user.email = mailaddress;
		user.password = password;
		//[user setObject:location forKey:@"bussiness_location"];
		[user setObject:bussinessName forKey:@"bussiness_name"];
		[user setObject:pno forKey:@"phone_no"];
		}
		// Use PFACL to restrict future modifications to this object.
		//	PFACL *readWriteACL = [PFACL ACL];
		////	[readWriteACL setPublicReadAccess:YES];
		////	[readWriteACL setPublicWriteAccess:YES];
		//	[PFACL setDefaultACL:readWriteACL withAccessForCurrentUser:YES];
		//	[user setACL:readWriteACL];
		if(!appDelegate.isSignout)
		{
		[user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			if (error) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
				[alertView show];
				createButton.enabled = [self shouldEnableDoneButton];
				[activityView.activityIndicator stopAnimating];
				[activityView removeFromSuperview];
				// Bring the keyboard back up, because they'll probably need to change something.
				[usernameField becomeFirstResponder];
				return;
			}
			PAWAppDelegate *appd = (PAWAppDelegate *)[[UIApplication sharedApplication]delegate];
			[appd setupNotification];

			[user setObject:username forKey:@"fullname"];
			
			[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				[activityView.activityIndicator stopAnimating];
				[activityView removeFromSuperview];
				if (succeeded) {
					NSString *body = [NSString stringWithFormat:@"New Business User Created - %@",[[PFUser currentUser] username]];
					[mailGun sendMessageTo:@"LokeyMe <info@lokayme.com>"
									  from:@"New user Reporter <alert@lokay.com>"
								   subject:@"New Business User Created!"
									  body:body];
					
					PAWEnterChatViewController *wallViewController = [[PAWEnterChatViewController alloc] initWithNibName:@"PAWEnterChatViewController" bundle:nil];
					[(UINavigationController *)self.presentingViewController pushViewController:wallViewController animated:NO];
					[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
				}
				else {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email Signup : Register full name" message:[[error userInfo] objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
					[alertView show];
				}
			}];
		}];
		}
		else
			
		{
			[[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				[activityView.activityIndicator stopAnimating];
				[activityView removeFromSuperview];
				if (succeeded) {
					if(appDelegate.isSignout)
					{
						appDelegate.isSignout = NO;
						appDelegate.BussinessUserCreation = nil;
					}
					NSString *body = [NSString stringWithFormat:@"New Business User Created - %@",[[PFUser currentUser] username]];
					[mailGun sendMessageTo:@"LokeyMe <info@lokayme.com>"
									  from:@"New user Reporter <alert@lokay.com>"
								   subject:@"New Business User Created!"
									  body:body];
					
					PAWEnterChatViewController *wallViewController = [[PAWEnterChatViewController alloc] initWithNibName:@"PAWEnterChatViewController" bundle:nil];
					[(UINavigationController *)self.presentingViewController pushViewController:wallViewController animated:NO];
					[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
				}
				else {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email Signup : Register full name" message:[[error userInfo] objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
					[alertView show];
				}
			}];
		
		}
	
}
- (void)processFieldEntries {
	// Check that we have a non-zero username and passwords.
	// Compare password and passwordAgain for equality
	// Throw up a dialog that tells them what they did wrong if they did it wrong.

	NSString *username = usernameField.text;
	NSString *mailaddress = mailaddressField.text;
	NSString *password = passwordField.text;
	NSString *passwordAgain = passwordAgainField.text;
	NSString *errorText = @"Please ";
	NSString *usernameBlankText = @"enter a username";
	NSString *mailBlankText = @"enter a mail address";
	NSString *passwordBlankText = @"enter a password";
	NSString *joinText = @", and ";
	NSString *passwordMismatchText = @"enter the same password twice";

	BOOL textError = NO;

	// Messaging nil will return 0, so these checks implicitly check for nil text.
	if (username.length == 0 || password.length == 0 || passwordAgain.length == 0) {
		textError = YES;

		// Set up the keyboard for the first field missing input:
		if (passwordAgain.length == 0) {
			[passwordAgainField becomeFirstResponder];
		}
		if (password.length == 0) {
			[passwordField becomeFirstResponder];
		}
		if (mailaddress.length == 0) {
			[mailaddressField becomeFirstResponder];
		}
		if (username.length == 0) {
			[usernameField becomeFirstResponder];
		}

		if (mailaddress.length == 0) {
			errorText = [errorText stringByAppendingString:mailBlankText];
		}
		if (username.length == 0) {
			errorText = [errorText stringByAppendingString:usernameBlankText];
		}

		if (password.length == 0 || passwordAgain.length == 0) {
			if (username.length == 0) { // We need some joining text in the error:
				errorText = [errorText stringByAppendingString:joinText];
			}
			errorText = [errorText stringByAppendingString:passwordBlankText];
		}
	} else if ([password compare:passwordAgain] != NSOrderedSame) {
		// We have non-zero strings.
		// Check for equal password strings.
		textError = YES;
		errorText = [errorText stringByAppendingString:passwordMismatchText];
		[passwordField becomeFirstResponder];
	}

	if (textError) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorText message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alertView show];
		return;
	}

	// Everything looks good; try to log in.
	// Disable the done button for now.
	createButton.enabled = NO;
	PAWActivityView *activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
	UILabel *label = activityView.label;
	label.text = @"Signing You Up";
	label.font = [UIFont boldSystemFontOfSize:20.f];
	[activityView.activityIndicator startAnimating];
	[activityView layoutSubviews];

	[self.view addSubview:activityView];

	// Call into an object somewhere that has code for setting up a user.
	// The app delegate cares about this, but so do a lot of other objects.
	// For now, do this inline.
	username = [username lowercaseString];
	PFUser *user = [PFUser user];
	user.username = username;
	user.email = mailaddress;
	user.password = password;
	// Use PFACL to restrict future modifications to this object.
//	PFACL *readWriteACL = [PFACL ACL];
////	[readWriteACL setPublicReadAccess:YES];
////	[readWriteACL setPublicWriteAccess:YES];
//	[PFACL setDefaultACL:readWriteACL withAccessForCurrentUser:YES];
//	[user setACL:readWriteACL];
	[user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (error) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			createButton.enabled = [self shouldEnableDoneButton];
			[activityView.activityIndicator stopAnimating];
			[activityView removeFromSuperview];
			// Bring the keyboard back up, because they'll probably need to change something.
			[usernameField becomeFirstResponder];
			return;
		}
		PAWAppDelegate *appd = (PAWAppDelegate *)[[UIApplication sharedApplication]delegate];
		[appd setupNotification];

		
		[user setObject:username forKey:@"fullname"];
		
		[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			[activityView.activityIndicator stopAnimating];
			[activityView removeFromSuperview];
			if (succeeded) {
				
				PAWEnterChatViewController *wallViewController = [[PAWEnterChatViewController alloc] initWithNibName:@"PAWEnterChatViewController" bundle:nil];
				[(UINavigationController *)self.presentingViewController pushViewController:wallViewController animated:NO];
				[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
			}
			else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email Signup : Register full name" message:[[error userInfo] objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
				[alertView show];
			}
		}];
	}];
}

#pragma mark - keyboard methods
- (void) scrollForTextField: (UITextField *)textField {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, textField.frame.origin.y - 10 )  animated: YES];
    }
}

- (void) dismissKeyboard {
    [self.usernameField resignFirstResponder];
    [self.mailaddressField resignFirstResponder];
	[self.passwordField resignFirstResponder];
    [self.passwordAgainField resignFirstResponder];
}

#pragma mark - textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == usernameField) {
		[passwordField becomeFirstResponder];
	}
	if (textField == mailaddressField) {
		[mailaddressField becomeFirstResponder];
	}
	if (textField == passwordField) {
		[passwordAgainField becomeFirstResponder];
	}
	if (textField == passwordAgainField) {
		[passwordAgainField resignFirstResponder];
		[self processFieldEntries];
	}
	
	
	if (textField == _txtBusinessName) {
		[_location becomeFirstResponder];
	}
	if (textField == _location) {
		[_BPNo becomeFirstResponder];
	}
	if (textField == _BPNo) {
		[_BmailaddressField becomeFirstResponder];
	}
	if (textField == _BmailaddressField) {
		[_BpasswordField becomeFirstResponder];
	}
	if (textField == _BpasswordField) {
		[_BpasswordAgainField becomeFirstResponder];
	}
	if(textField == _BpasswordAgainField)
	{
		[_BpasswordAgainField resignFirstResponder];
	}
	

	return YES;
}

- (IBAction)segmentChanged:(id)sender {
	
	UISegmentedControl *segmented = (UISegmentedControl *)sender;
	if(segmented.selectedSegmentIndex == 0)
	{
		_personalView.hidden = NO;
		_businessView.hidden = YES;
		isBussiness = NO;
	}
	else
	{
		_personalView.hidden = YES;
		_businessView.hidden = NO;
		isBussiness = YES;
	}
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
	if(_BPNo == textField)
	{
		UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
		[keyboardDoneButtonView sizeToFit];
		UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
																	   style:UIBarButtonItemStyleBordered target:self
																	  action:@selector(doneClicked:)];
		[keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
		textField.inputAccessoryView = keyboardDoneButtonView;
	}
    return YES;
}
- (IBAction)doneClicked:(id)sender
{
	[_BmailaddressField becomeFirstResponder];
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
