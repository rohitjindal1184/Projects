//
//  PAWForgotPwdViewController.m
//

#import "PAWForgotPwdViewController.h"

#import <Parse/Parse.h>

@interface PAWForgotPwdViewController ()

- (void)processFieldEntries;
- (void)textInputChanged:(NSNotification *)note;
- (BOOL)shouldEnableDoneButton;

@end

@implementation PAWForgotPwdViewController

@synthesize createButton;
@synthesize mailaddressField;


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:mailaddressField];

	createButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:mailaddressField];
}

#pragma mark - ()

- (BOOL)shouldEnableDoneButton {
	BOOL enableDoneButton = NO;
	if (mailaddressField.text != nil &&
		mailaddressField.text.length > 0) {
		enableDoneButton = YES;
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
	[mailaddressField resignFirstResponder];
	[self processFieldEntries];
}

- (void)processFieldEntries {
	// Check that we have a non-zero username and passwords.
	// Compare password and passwordAgain for equality
	// Throw up a dialog that tells them what they did wrong if they did it wrong.

	NSString *mailaddress = mailaddressField.text;
	NSString *errorText = @"enter a valid email";
	
	BOOL textError = NO;

	// Messaging nil will return 0, so these checks implicitly check for nil text.
	if (![self validateEmail:mailaddress]) {
		textError = YES;

		if (textError) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorText message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			return;
		}
	}
	mailaddress = [mailaddress lowercaseString];
	[PFUser requestPasswordResetForEmailInBackground:mailaddress block:^(BOOL succeeded, NSError *error) {
		if(error)
		{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alertView show];
		}
		else
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your mail box." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
		}
	}];
	//[PFUser requestPasswordResetForEmailInBackground:mailaddress];
	
	
	return;
}

#pragma mark - check mail address
- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	
    return [emailTest evaluateWithObject:candidate];
}

#pragma mark - keyboard methods
- (void) scrollForTextField: (UITextField *)textField {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, textField.frame.origin.y - 10 )  animated: YES];
    }
}

- (void) dismissKeyboard {
    [self.mailaddressField resignFirstResponder];
}

#pragma mark - textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == mailaddressField) {
		[mailaddressField becomeFirstResponder];
	}
	
	return YES;
}

- (IBAction)onDidEndOnExit:(id)sender {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
	[self done:nil];
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
