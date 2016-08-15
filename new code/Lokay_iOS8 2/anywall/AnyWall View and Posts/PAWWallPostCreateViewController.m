//
//  PAWWallPostCreateViewController.m
//

#import "PAWWallPostCreateViewController.h"

#import "PAWAppDelegate.h"
#import <Parse/Parse.h>

#define kSwearsArr @"swearsArr"

/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/*
 *  Usage
 */

@interface PAWWallPostCreateViewController ()

- (void)updateCharacterCount:(UITextView *)aTextView;
- (BOOL)checkCharacterCount:(UITextView *)aTextView;
- (void)textInputChanged:(NSNotification *)note;

@end

@implementation PAWWallPostCreateViewController

@synthesize textView;
@synthesize characterCount;
@synthesize postButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSString *)repeatTimes:(NSUInteger)times {
	return [@"" stringByPaddingToLength:times withString:@"*" startingAtIndex:0];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	// Do any additional setup after loading the view from its nib.
	
	self.characterCount = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 154.0f, 21.0f)];
	self.characterCount.backgroundColor = [UIColor clearColor];
	self.characterCount.textColor = [UIColor lightGrayColor];
	// self.characterCount.shadowColor = [UIColor lightGrayColor];
	// self.characterCount.shadowOffset = CGSizeMake(0.0f, -1.0f);
	self.characterCount.text = @"0/140";

	[self.textView setInputAccessoryView:self.characterCount];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextViewTextDidChangeNotification object:textView];
	[self updateCharacterCount:textView];
	[self checkCharacterCount:textView];

	// Show the keyboard/accept input.
	[textView becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:textView];
}

#pragma mark UINavigationBar-based actions

- (IBAction)cancelPost:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postPost:(id)sender {
	NSLog(@"usr -- %hhd",[[[PFUser currentUser] objectForKey:@"EULA"] boolValue]);
	if ([[[PFUser currentUser] objectForKey:@"EULA"] boolValue]) {
	// Resign first responder to dismiss the keyboard and capture in-flight autocorrect suggestions
	[textView resignFirstResponder];

	// Capture current text field contents:
	[self updateCharacterCount:textView];
	BOOL isAcceptableAfterAutocorrect = [self checkCharacterCount:textView];

	if (!isAcceptableAfterAutocorrect) {
		[textView becomeFirstResponder];
		return;
	}
	
	//swears comparison stuff
	NSArray *swearsArr = [[NSUserDefaults standardUserDefaults] valueForKey:kSwearsArr];
	NSString *stringToSearchWithin = textView.text;
	
	
	for (NSString *s in swearsArr)
	{
		NSString *replaceStr = [self repeatTimes:s.length];
		stringToSearchWithin = [stringToSearchWithin stringByReplacingOccurrencesOfString:s
																			   withString:replaceStr options:NSCaseInsensitiveSearch range:NSMakeRange(0, stringToSearchWithin.length)];
		
		NSLog(@"string -- %@",stringToSearchWithin);
	}

	// Data prep:
	PFUser *user = [PFUser currentUser];

	// Stitch together a postObject and send this async to Parse
	PFObject *postObject = [PFObject objectWithClassName:@"Posts"];
	[postObject setObject:self.chatroom_id forKey:@"chatroom_id"];
	[postObject setObject:stringToSearchWithin forKey:@"text"];
	[postObject setObject:user forKey:@"user"];
	
	if (![textView.text isEqualToString:stringToSearchWithin]) {
		[postObject setObject:textView.text forKey:@"text_actual"];
	}
	
	// Use PFACL to restrict future modifications to this object.
	PFACL *readOnlyACL = [PFACL ACL];
	[readOnlyACL setPublicReadAccess:YES];
	[readOnlyACL setPublicWriteAccess:YES];
	[postObject setACL:readOnlyACL];
	[postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (error) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Post Message" message:[[error userInfo] objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			return;
		}
		if (succeeded) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:kPAWPostCreatedNotification object:nil userInfo:@{@"object":postObject}];
			});
		} else {
			NSLog(@"Failed to save.");
		}
	}];

	[self dismissViewControllerAnimated:YES completion:nil];
		
	}else{
		[textView resignFirstResponder];
		[self agreementMethod];
	}
}

#pragma mark UITextView notification methods

- (void)textInputChanged:(NSNotification *)note {
	// Listen to the current text field and count characters.
	UITextView *localTextView = [note object];
	[self updateCharacterCount:localTextView];
	[self checkCharacterCount:localTextView];
}

#pragma mark Private helper methods

- (void)updateCharacterCount:(UITextView *)aTextView {
	NSUInteger count = aTextView.text.length;
	self.characterCount.text = [NSString stringWithFormat:@"%i/140", count];
	if (count > kPAWWallPostMaximumCharacterCount || count == 0) {
		self.characterCount.font = [UIFont boldSystemFontOfSize:self.characterCount.font.pointSize];
	} else {
		self.characterCount.font = [UIFont systemFontOfSize:self.characterCount.font.pointSize];
	}
}

- (BOOL)checkCharacterCount:(UITextView *)aTextView {
	NSUInteger count = aTextView.text.length;
	if (count > kPAWWallPostMaximumCharacterCount || count == 0) {
		postButton.enabled = NO;
		return NO;
	} else {
		postButton.enabled = YES;
		return YES;
	}
}

#pragma mark Agreement method
- (void)agreementMethod{
	
	PFQuery *swearsQuery = [PFQuery queryWithClassName:@"Agreement"];
	[swearsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
			// The find succeeded. The first 100 objects are available in objects
			NSArray *all = [objects valueForKey:@"AgreementText"];
			
			agreeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
			agreeView.backgroundColor = [UIColor whiteColor];
			PAWAppDelegate *appDel = (PAWAppDelegate*)[UIApplication sharedApplication].delegate;
			
			UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
			navView.backgroundColor = [UIColor colorWithRed:227.0f/255.0f green:120.0f/255.0f blue:74.0f/255.0f alpha:1.0f];
			
			UILabel *title = [[UILabel alloc] init];
			title.backgroundColor = [UIColor clearColor];
			title.text = @"End User License Agreement";
			title.font = [UIFont fontWithName:@"Avenir" size:17];
			CGRect labelRect;
			if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
				labelRect = [@"End User License Agreement"
									boundingRectWithSize:navView.frame.size
									options:NSStringDrawingUsesLineFragmentOrigin
									attributes:@{
												 NSFontAttributeName : [UIFont systemFontOfSize:17]
												 }
									context:nil];
			}else{
				labelRect = CGRectMake(self.view.frame.size.width/2 - labelRect.size.width/2, 35, 222.819031, 20.281000);
			}
			
			title.frame = CGRectMake(self.view.frame.size.width/2 - labelRect.size.width/2, 35, labelRect.size.width + 100, labelRect.size.height + 5);
			[navView addSubview:title];
			
			[agreeView addSubview:navView];
			
			UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 55, self.view.frame.size.width, 64)];
			toolView.backgroundColor = [UIColor colorWithRed:227.0f/255.0f green:120.0f/255.0f blue:74.0f/255.0f alpha:1.0f];
			[agreeView addSubview:toolView];
			
//			UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
//			bar.backgroundColor = [UIColor colorWithRed:227/255 green:120/255 blue:74/255 alpha:1];
//			bar.tintColor =[UIColor colorWithRed:227/255 green:120/255 blue:74/255 alpha:1];
//			
//			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
//			label.font = [UIFont fontWithName:@"YOURFONTNAME" size:20.0];
//			label.shadowColor = [UIColor clearColor];
//			label.textColor =[UIColor whiteColor];
//			label.text = self.title;
//			[bar addSubview:label];
//			
//			[agreeView addSubview:bar];
			UIScrollView *scrollView = [[UIScrollView alloc] init];
			UITextView *agreemrntTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, agreeView.frame.size.width - 50, agreeView.frame.size.height - 50)];
			
			agreemrntTextView.font = [UIFont fontWithName:@"Avenir" size:15];
			agreemrntTextView.text = [NSString stringWithFormat:@"%@",[all objectAtIndex:0]];
			[scrollView addSubview:agreemrntTextView];
			
			NSAttributedString *displayText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[all objectAtIndex:0]]];
			
			
			
			CGSize textViewSize = [agreemrntTextView sizeThatFits:CGSizeMake(agreemrntTextView.frame.size.width, FLT_MAX)];
			agreemrntTextView.frame = CGRectMake(0, 0, agreeView.frame.size.width - 50, textViewSize.height);
			agreemrntTextView.userInteractionEnabled = NO;
			//				[agreeView addSubview:agreemrntTextView];
			//				[self.view addSubview:agreeView];
			
			
			
			scrollView.frame = CGRectMake(25, 64, agreeView.frame.size.width - 50, agreeView.frame.size.height - 119);
			[scrollView setShowsHorizontalScrollIndicator:NO];
			[scrollView setShowsVerticalScrollIndicator:NO];
			scrollView.contentSize = CGSizeMake(agreemrntTextView.frame.size.width,MAX(agreemrntTextView.frame.size.height, agreeView.frame.size.height - 100) );
			NSLog(@"size -- %f",scrollView.contentSize.height);
			[agreeView addSubview:scrollView];
			
			[self.view addSubview:agreeView];
			
			UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			agreeBtn.backgroundColor = [UIColor clearColor];
			agreeBtn.tag = 0;
			[agreeBtn addTarget:self
						 action:@selector(AgreeAction:)
			   forControlEvents:UIControlEventTouchUpInside];
			[agreeBtn setTitle:@"I ACCEPT" forState:UIControlStateNormal];
			agreeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
			agreeBtn.frame = CGRectMake(-10.0,agreeView.frame.size.height - 50, 140.0, 40.0);
			[agreeView addSubview:agreeBtn];
			
			UIButton *disAgreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[disAgreeBtn setBackgroundColor:[UIColor clearColor]];
			disAgreeBtn.tag = 1;
			[disAgreeBtn addTarget:self
							action:@selector(AgreeAction:)
				  forControlEvents:UIControlEventTouchUpInside];
			[disAgreeBtn setTitle:@"I DO NOT ACCEPT" forState:UIControlStateNormal];
			disAgreeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
			disAgreeBtn.frame = CGRectMake(agreeView.frame.size.width - 190,agreeView.frame.size.height - 50, 180.0, 40.0);
			[agreeView addSubview:disAgreeBtn];
			
		} else {
			// Log details of the failure
			NSLog(@"Error: %@ %@", error, [error userInfo]);
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
		}
	}];
}

- (void)AgreeAction:(id)sender{
	UIButton *senderBtn = (UIButton*)sender;
	senderBtn.enabled = NO;
	if (senderBtn.tag == 0) {
		
		PFUser *user = [PFUser currentUser];NSLog(@"user -- %@",[PFUser currentUser]);
		[user setObject:@YES forKey:@"EULA"];
		[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[[PFUser currentUser] objectId]];
			[agreeView removeFromSuperview];
			[[PFUser currentUser] refresh];
			[self postPost:self];
		}];
		
	}else{
		[agreeView removeFromSuperview];
	}
}

@end
