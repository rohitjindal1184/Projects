//
//  PAWWallViewController.m
//

#import "PAWWallViewController.h"

#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <MapKit/MapKit.h>

#import "PAWSettingViewController.h"
#import "PAWWallPostCreateViewController.h"
#import "PAWAppDelegate.h"
#import "PAWWallPostsTableViewController.h"
#import "PAWPost.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "PAWChooseChatRoomViewController.h"
#import "PAWPhotoViewController.h"
#import "PAWChatRoom.h"


#define PHOTO_SIZE		500
#define MAP_HEIGHT      185

// private methods and properties
@interface PAWWallViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, MKMapViewDelegate> {
	
}

@property (weak, nonatomic) IBOutlet UIButton *btnChatHere;
@property (nonatomic, strong) PAWWallPostsTableViewController *wallPostsTableViewController;

// posts:
@property (nonatomic, strong) NSMutableArray *allPosts;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)chatButtonPressed:(id)sender;

- (void)queryForAllPosts:(NSString *)chatroom_id;

// NSNotification callbacks
- (void)distanceFilterDidChange:(NSNotification *)note;
- (void)locationDidChange:(NSNotification *)note;
- (void)postWasCreated:(NSNotification *)note;

- (IBAction)postButtonPressed:(id)sender;
- (IBAction)onBack:(id)sender;

@end

@implementation PAWWallViewController

@synthesize wallPostsTableViewController;
@synthesize allPosts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		allPosts = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(void)hideChatButton
{
	self.btnChatHere.hidden = YES;
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"HideChatButton" object:nil];
}
#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	PAWAppDelegate * delegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	delegate.chatroom_id = self.chatroom_id;
	// Add the wall posts tableview as a subview with view containment (new in iOS 5.0):
	self.wallPostsTableViewController = [[PAWWallPostsTableViewController alloc] initWithStyle:UITableViewStylePlain];
	self.wallPostsTableViewController.chatroom_id = self.chatroom_id;
	[self addChildViewController:self.wallPostsTableViewController];

    self.wallPostsTableViewController.view.frame = CGRectMake(6.0f, 65.0f + MAP_HEIGHT, 308.0f, self.view.bounds.size.height - 70.0f - MAP_HEIGHT);
	[self.view addSubview:self.wallPostsTableViewController.view];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceFilterDidChange:) name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kPAWLocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWasCreated:) name:kPAWPostCreatedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageReceived:) name:kPAWMessageReceivedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEraseChatRoom:) name:kPAWEraseChatRoomNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClickPhoto:) name:kPAWClickPhotoNotification object:nil];
	//save chatroom id as a channel
	/*
	NSString * channel = [NSString stringWithFormat:@"channel_%@", self.chatroom_id];
	PFInstallation * installation = [PFInstallation currentInstallation];
	[installation addObject:channel forKey:@"channels"];
	[installation saveInBackground];
	*/
	[self setupMapView];
	self.btnChatHere.layer.cornerRadius = 3.0;
	[self.view bringSubviewToFront:self.btnChatHere];
	self.btnChatHere.hidden = NO;
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideChatButton) name:@"HideChatButton" object:nil];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWLocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWPostCreatedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWMessageReceivedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWEraseChatRoomNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWClickPhotoNotification object:nil];
}

#pragma mark - NSNotificationCenter notification handlers

- (void)distanceFilterDidChange:(NSNotification *)note {
	
}

- (void)locationDidChange:(NSNotification *)note {
	
}

- (void)postWasCreated:(NSNotification *)note {
	[self queryForAllPosts:self.chatroom_id];
	PFObject *obj = [note.userInfo objectForKey:@"object"];
	
	NSString * message = [obj objectForKey:@"text"];
	if(message == nil)
	{
		message = @"share a photo";
	}
	else
	{
		if(message.length > 30)
		{
			message = [message substringToIndex:29];
		}
	}
	NSString * channel = [NSString stringWithFormat:@"channel_%@", self.chatroom_id];
	
	NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:
						   [[PFUser currentUser] username], @"user",
						   @"Increment", @"badge",
						   self.chatroom_id, @"chatroom_id",
						   message, @"message",
						[NSString stringWithFormat:@"%@ sent message '%@\'",[[PFUser currentUser] username],message], @"alert",
						   nil];
	
	/*NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"Increment", @"badge",
						   [NSString stringWithFormat:@"%@ sent message '%@\'",[[PFUser currentUser] username],message], @"alert",
						   nil];*/
	
	
	PFPush * push = [[PFPush alloc] init];
	[push setChannel:channel];
	[push setData:data];
	[push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * __nullable error) {
		
	}];
}

- (void)onMessageReceived:(NSNotification *)note {
	[self queryForAllPosts:self.chatroom_id];
}

- (void)onEraseChatRoom:(NSNotification *)note {
	[self dismissViewControllerAnimated:YES completion:^{
		[self.navigationController popViewControllerAnimated:NO];
	}];
}

- (void) onClickPhoto:(NSNotification *)note {
	PFFile * photo = [note.userInfo objectForKey:@"photo"];
	
	PAWPhotoViewController * viewController = [[PAWPhotoViewController alloc] initWithNibName:@"PAWPhotoViewController" bundle:nil];
	viewController.photo = photo;
	[self.navigationController pushViewController:viewController animated:YES];
}
#pragma mark - Fetch map pins

- (IBAction)chatButtonPressed:(id)sender {
	[self postButtonPressed:sender];
}

- (void)queryForAllPosts:(NSString *)chatroom_id {
	PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
    [query whereKey:@"chatroom_id" equalTo:chatroom_id];
	[query orderByDescending:@"createdAt"];
	query.limit = 50;

	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (error) {
			NSLog(@"error in geo query!"); // todo why is this ever happening?
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
		} else {
            [allPosts removeAllObjects];
			if(objects.count)
			{
				self.btnChatHere.hidden = YES;
			}
			else
			{
				self.btnChatHere.hidden = NO;
			}
			for (PFObject *object in objects) {
				[self.allPosts addObject:object];
			}
		}
	}];
}

- (IBAction)postButtonPressed:(id)sender
{
	UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															  delegate:self
													 cancelButtonTitle:@"Cancel"
												destructiveButtonTitle:nil
													 otherButtonTitles:@"Text", @"Photo", @"Share", @"Setting", nil];
	actionSheet.tag = 1;
	[actionSheet showInView:self.view];
}

- (IBAction)onBack:(id)sender {
	/*PFInstallation * installation = [PFInstallation currentInstallation];
	NSArray * channels = installation.channels;
	if (channels) {
		[installation removeObjectsInArray:channels forKey:@"channels"];
		[installation saveInBackground];
	}
	*/
	NSArray * pVCs = [self.navigationController viewControllers];
	for (UIViewController * pVC in pVCs) {
		if ([pVC isKindOfClass:[PAWChooseChatRoomViewController class]]) {
			[self.navigationController popToViewController:pVC animated:YES];
			return;
		}
	}
	
	PAWAppDelegate * delegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	delegate.chatroom_id = nil;
	
	PAWChooseChatRoomViewController * viewController = [[PAWChooseChatRoomViewController alloc] initWithNibName:@"PAWChooseChatRoomViewController" bundle:nil];
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - action sheet delegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 1) {
		switch (buttonIndex) {
			case 0:
				[self onText];
				break;
			case 1:
				[self onPhoto];
				break;
			case 2:
				[self onShare];
				break;
			case 3:
				[self onSetting];
				break;
			default:
				break;
		}
	}
	else if (actionSheet.tag == 2) {
		switch (buttonIndex) {
			case 0:
				[self onTakePhoto];
				break;
			case 1:
				[self onSelectPhoto];
				break;
			default:
				break;
		}
	}
	else if (actionSheet.tag == 3) {
		switch (buttonIndex) {
			case 0:
				[self onTwitter];
				break;
			case 1:
				[self onFacebook];
				break;
			case 2:
				[self onEmail];
				break;
			case 3:
				[self onSMS];
				break;
			default:
				break;
		}
	}
}

- (void) onText {
	PAWWallPostCreateViewController *postDetailViewController = [[PAWWallPostCreateViewController alloc] initWithNibName:@"PAWWallPostCreateViewController" bundle:nil];
	postDetailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	postDetailViewController.chatroom_id = self.chatroom_id;
	
    [self.navigationController presentViewController:postDetailViewController animated:YES completion:nil];
}

- (void) onPhoto {
	UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															  delegate:self
													 cancelButtonTitle:@"Cancel"
												destructiveButtonTitle:nil
													 otherButtonTitles:@"Take Photo", @"Choose from Libray", nil];
	actionSheet.tag = 2;
	[actionSheet showInView:self.view];
}

- (void) onShare {
	UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
													 cancelButtonTitle:@"Cancel"
												destructiveButtonTitle:nil
													 otherButtonTitles:@"Twitter", @"Facebook", @"Email", @"SMS", nil];
	actionSheet.tag = 3;
	[actionSheet showInView:self.view];
}

- (void) onSetting {
	PAWSettingViewController *settingsDetailViewController = [[PAWSettingViewController alloc] initWithNibName:@"PAWSettingViewController" bundle:nil];
	settingsDetailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	//settingsDetailViewController.chatroom_id = self.chatroom_id;
	
    [self.navigationController pushViewController:settingsDetailViewController animated:YES];
}

- (void)onTakePhoto {
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
    
	controller.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [controller setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"Camera Not Available for This Device" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alertView show];
        
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)onSelectPhoto {
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
	controller.delegate = self;
    [controller setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [controller setMediaTypes:[NSArray arrayWithObject:(NSString*)kUTTypeImage]];
    controller.allowsEditing = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void) onTwitter {
	if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Can not post card to facebook at the moment. Please confirm facebook login in setting." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    
    SLComposeViewController * twitterComposeSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    NSString * strMsg = @"http://www.lokayme.com/";
    
    [twitterComposeSheet setInitialText:strMsg];
    
    [twitterComposeSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSString * title = @"Tweet";
        NSString * msg;
        if (result == SLComposeViewControllerResultCancelled) {
        }
        else if (result == SLComposeViewControllerResultDone) {
            msg = @"Posted successfully!";
        }
        else {
            msg = @"";
        }
        
        if ([msg length]) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self presentViewController:twitterComposeSheet animated:YES completion:nil];
}

- (void) onFacebook {
	if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Can not post card to facebook at the moment. Please confirm facebook login in setting." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    
    SLComposeViewController * facebookComposeSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    NSString * strMsg = @"http://www.lokayme.com/";
    
    [facebookComposeSheet setInitialText:strMsg];
    
    [facebookComposeSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSString * title = @"Facebook";
        NSString * msg;
        if (result == SLComposeViewControllerResultCancelled) {
        }
        else if (result == SLComposeViewControllerResultDone) {
            msg = @"Posted successfully!";
        }
        else {
            msg = @"";
        }
        
        if ([msg length]) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self presentViewController:facebookComposeSheet animated:YES completion:nil];
}

- (void) onEmail {
	if (![MFMailComposeViewController canSendMail]) {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"You can not send mail because you did not set mail address on your phone." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    
    // Email Subject
    NSString *emailTitle = @"LokayMe";
    NSString *emailBody = @"http://www.lokayme.com";
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) onSMS {
	if (![MFMessageComposeViewController canSendText]) {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"SMS" message:@"You can not send text message on your phone." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    
    NSString *emailBody = @"http://www.lokayme.com";
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
    controller.body = emailBody;
    controller.messageComposeDelegate = self;
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MessageComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MessageComposeResultFailed:
            NSLog(@"Mail sent failure");
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - image picker controller delegate
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    UIImage * image = [info objectForKey: UIImagePickerControllerOriginalImage];
	image = [self cropImage:image toRect:CGRectMake(0, 0, PHOTO_SIZE, PHOTO_SIZE)];
	image = [self resizeImage:image toSize:CGSizeMake(PHOTO_SIZE, PHOTO_SIZE)];
	NSData * imageData = UIImageJPEGRepresentation(image, 1.0f);
	[self uploadPhoto:imageData];
	[self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - manipulate photo methods
-(UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size
{
    float width = size.width;
    float height = size.height;
    
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    float widthRatio = image.size.width / width;
    float heightRatio = image.size.height / height;
    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    width = image.size.width / divisor;
    height = image.size.height / divisor;
    
    rect.size.width  = width;
    rect.size.height = height;
    
    if(height < width)
        rect.origin.y = height / 3;
    
    [image drawInRect: rect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}

- (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect  {
    
    CGSize size = image.size;
    if (size.width < size.height) {
        rect = CGRectMake(0, (size.height - size.width) / 2, size.width, size.width);
    }
    else {
        rect = CGRectMake((size.width - size.height) / 2, 0, size.height, size.height);
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height);
    
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    [image drawInRect:drawRect];
    
    UIImage * subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
}

- (void) uploadPhoto:(NSData *)imageData {
	PFUser *user = [PFUser currentUser];
	
	// Stitch together a postObject and send this async to Parse
	PFObject *postObject = [PFObject objectWithClassName:@"Posts"];
	[postObject setObject:self.chatroom_id forKey:@"chatroom_id"];
	[postObject setObject:user forKey:@"user"];
	
	PFFile * photo = [PFFile fileWithName:@"Image.jpg" data:imageData];
	[postObject setObject:photo forKey:@"photo"];
	
	// Use PFACL to restrict future modifications to this object.
	PFACL *readOnlyACL = [PFACL ACL];
	[readOnlyACL setPublicReadAccess:YES];
	[readOnlyACL setPublicWriteAccess:NO];
	[postObject setACL:readOnlyACL];
	
	//show loading view
	PAWActivityView *activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
	UILabel *label = activityView.label;
	label.text = @"Loading...";
	label.font = [UIFont boldSystemFontOfSize:20.f];
	[activityView.activityIndicator startAnimating];
	[activityView layoutSubviews];
	[self.view addSubview:activityView];
	
	[postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		
		[activityView.activityIndicator stopAnimating];
		[activityView removeFromSuperview];
		
		if (error) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Chat Screen : Post Photo" message:[[error userInfo] objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
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
}

#pragma mark - setupMapView
- (void) setupMapView {
	PAWChatRoom * chatroom = [[PAWChatRoom alloc] initWithCoordinate:self.coordinate andTitle:self.mainTitle andSubtitle:self.subTitle andcreator:nil];
	[self.mapView addAnnotation:chatroom];
	
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.coordinate, SEARCH_RADIUS, SEARCH_RADIUS);
	[self.mapView setRegion:region animated:YES];
}

#pragma mark - map view delegate
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(PAWChatRoom *)annotation
{
    static NSString *PinIdentifier = @"LokayChatRoomIdentifier";
	
	MKPinAnnotationView *annView = nil;
	if (annView == nil)
	{
		annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
		annView.animatesDrop = NO;
		annView.canShowCallout = YES;
		annView.calloutOffset = CGPointMake(0, 0);
		annView.enabled = YES;
	}
    
    if ([self.type isEqualToString:@"Blue"]) {
        annView.image = [UIImage imageNamed:@"bluepin.png"];
    }
    else if ([self.type isEqualToString:@"Green"]) {
        annView.image = [UIImage imageNamed:@"greenpin.png"];
    }
    else if ([self.type isEqualToString:@"Red"]) {
        annView.image = [UIImage imageNamed:@"redpin.png"];
    }
    else if ([self.type isEqualToString:@"Purple"]) {
        annView.image = [UIImage imageNamed:@"purplepin.png"];
    }
	
	annView.centerOffset = CGPointMake(0, - 43 / 2);
	
	return annView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	NSLog(@"tapped!");
}

@end
