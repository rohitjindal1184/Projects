//
//  PAWChooseChatRoomViewController.m
//  LokayMe
//
//  Created by He Fei on 12/26/13.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAWChooseChatRoomViewController.h"
#import "PAWChatRoom.h"
#import <MapKit/MapKit.h>
#import "PAWChatRoomView.h"
#import "PAWWallViewController.h"
#import "PAWEnterChatViewController.h"
#import "SBJSON.h"
#import "PAWPhotoViewController.h"
#import "PAWInboxViewController.h"
#import "PAWStartChatViewController.h"
#import "PAWSettingViewController.h"
#import "PAWWelcomeViewController.h"
#define ACTIVITY_VIEW_TAG		100
#define DETAIL_CHATROOM_TAG		10000

@interface PAWChooseChatRoomViewController () <UIActionSheetDelegate, MKMapViewDelegate, UITextFieldDelegate> {
	CLLocationCoordinate2D		_coordinate;
	NSString *					_prevAddress;
}

@property (nonatomic, strong) NSMutableArray * allChatRoom;
@property (nonatomic, strong) NSMutableArray * allChatRoomMain;
@property (nonatomic, strong) NSMutableArray * allEvent;
@property (strong, nonatomic)  NSMutableArray *arrChatRoom;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet CustomBadge *badgeView;
@property (weak, nonatomic) IBOutlet UISwitch *switchNotifications;
- (IBAction)valueChanged:(id)sender forEvent:(UIEvent *)event;

- (IBAction)onBack:(id)sender;
- (IBAction)onDidEndOnExit:(id)sender;

- (IBAction)onCursor:(id)sender;
- (IBAction)onShare:(id)sender;

@end

@implementation PAWChooseChatRoomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		self.allChatRoom = [[NSMutableArray alloc] init];
		self.allChatRoomMain = [[NSMutableArray alloc] init];

	}
	return self;
}
-(void)filterData
{
	arrBar = [[NSMutableArray alloc]init];
	arrBrunches = [[NSMutableArray alloc]init];
	arrClub = [[NSMutableArray alloc]init];
	arrDayParties = [[NSMutableArray alloc]init];
	 for (PAWChatRoom *chatRoom in self.arrChatRoom)
	 {
		 NSString * pinColor = [chatRoom.object objectForKey:@"type"];
		 if ([pinColor isEqualToString:@"Blue"]) {
			 [arrBrunches addObject:chatRoom];
		 }
		 else if ([pinColor isEqualToString:@"Green"]) {
			 [arrDayParties addObject:chatRoom];
		 }
		 else if ([pinColor isEqualToString:@"Red"]) {
			 [arrBar addObject:chatRoom];
		 }
		 else if ([pinColor isEqualToString:@"Purple"]) {
			 [arrClub addObject:chatRoom];
		 }
	 }
	switch (selectedOption) {
		case 0:
			arrSelectedOption = [[NSArray alloc]initWithArray:arrBar];
			break;
		case 1:
			arrSelectedOption = [[NSArray alloc]initWithArray:arrBrunches];
			
			break;
		case 2:
			arrSelectedOption = [[NSArray alloc]initWithArray:arrClub];
			
			break;
		case 3:
			arrSelectedOption = [[NSArray alloc]initWithArray:arrDayParties];
			
			break;
			
			
		default:
			break;
	}
}
- (IBAction)notificationSwitchValue:(id)sender {
	UISwitch *switchNotification = (UISwitch *)sender;
	if(switchNotification.on)
	{
		NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
		[def setValue:@"1" forKey:@"notifications"];
		[self.view makeToast:@"Notification On"];
		[def synchronize];
	}
	else
	{
		NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
		[def setValue:@"0" forKey:@"notifications"];
		[self.view makeToast:@"Notification Off"];
		[def synchronize];
	}
	
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	//[CLLocationManager requestWhenInUseAuthorization];
	appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	_coordinate = appDelegate.currentLocation.coordinate;
	appDelegate.isShowNetworkError = YES;
	//show loading view
	PAWActivityView *activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
	UILabel *label = activityView.label;
	label.text = @"Loading...";
	label.font = [UIFont boldSystemFontOfSize:20.f];
	[activityView.activityIndicator startAnimating];
	[activityView layoutSubviews];
	activityView.tag = ACTIVITY_VIEW_TAG;
	//[self.view addSubview:activityView];
	NetworkStatus remoteHostStatus = [appDelegate.reachability currentReachabilityStatus];
	
	if(remoteHostStatus == NotReachable) {
		[appDelegate setNoNetworkView];
	}
	//[NSThread detachNewThreadSelector:@selector(getAddressFromLocation:) toTarget:self withObject:appDelegate.currentLocation];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEnterChatRoom:) name:kPAWEnterChatRoomNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPhoto:) name:kPAWShowImagesNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPhotonew:) name:@"SHOWPHOTO" object:nil];

	[_badgeView autoBadgeSizeWithString:@"1"];
	//[self getEvenBriteEvent];
		tabview = [TabView getView];
	tabview.delegate = self;

	tabview.frame = CGRectMake(0,self.view.frame.size.height - 50, 320, 50);
	[self.view addSubview:tabview];
	
	[self.view bringSubviewToFront:tabview];
	
	//_mapView.hidden = YES;
	_txtSearch.layer.borderColor = [UIColor colorWithRed:227.0/255.0 green:120.0/255.0 blue:74.0/255.0 alpha:1.0].CGColor;
	_txtSearch.layer.borderWidth = 1.5;
	UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
	_txtSearch.leftView = paddingView;
	_txtSearch.leftViewMode = UITextFieldViewModeAlways;
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotoNotifications) name:@"gotoNotification" object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotoDetail:) name:@"gotoDetail" object:nil];
	arrPlaces = @[@"Bars",@"Brunches",@"Clubs",@"Day Parties"];
	self.selectionList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
	self.selectionList.delegate = self;
	self.selectionList.dataSource = self;
	[self.view addSubview:self.selectionList];
	chatroomTb.frame = CGRectMake(0, 105, 320, 470);
	_selectionList.frame = CGRectMake(2, 60, 320, 40);
	//_selectionList.backgroundColor = [UIColor blackColor];
	//_selectionList.hidden = YES;


	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editRoom:) name:@"EDITROOM" object:nil];

	
}
-(void)editRoom:(NSNotification *)notification
{
	chatroomEdit = notification.object;
	    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
	                                                              delegate:self
														 cancelButtonTitle:@"Cancel"
													destructiveButtonTitle:nil
														 otherButtonTitles:@"Delete", @"Edit", @"Share", nil];
		[actionSheet showInView:self.view];
	/*
	PAWStartChatViewController * viewController = [[PAWStartChatViewController alloc] initWithNibName:@"PAWStartChatViewController" bundle:nil];
	viewController.chatroom = notification.object;
	[self.navigationController pushViewController:viewController animated:YES];
	 */
}
- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self getAllChatRoom];
	
	viewDisspear = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(setRedeemedButtonOnCall:)
												 name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
	CGRect statusBarFrame = [UIApplication.sharedApplication statusBarFrame];
	if(statusBarFrame.size.height > 20)
	{
		[self setRedeemedButtonOnCall:nil];
	}
	_txtSearch.text = @"";
	NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
	self.arrChatRoom = [[self.allChatRoomMain sortedArrayUsingDescriptors:@[sortDesc]] mutableCopy];
[chatroomTb reloadData];
	self.allChatRoom = [self.allChatRoomMain mutableCopy];
	
}
-(void)gotoDetail:(NSNotification *)notification
{
	[self gotoChat:notification.object];
}

-(void)showPhotonew:(NSNotification *)notification
{
	if(![PFUser currentUser])
	{
		[self onBack:nil];
		return;
	}
	PAWChatRoom *chatroom =  (PAWChatRoom *)notification.object;
	NSLog(@"Char room %@", chatroom.object);
	appDelegate.ChatOwner=[chatroom.object objectForKey:@"creator"];
	PFObject *object = [chatroom object];
	PFFile *theImage = [object objectForKey:@"photo"];
	
	NSString * chatroom_id = [chatroom.object objectId];
	
	PAWPhotoViewController * viewController = [[PAWPhotoViewController alloc] initWithNibName:@"PAWPhotoViewController" bundle:nil];
	viewController.photo = theImage;
	viewController.chatRoomID = chatroom_id;
	viewController.scrolling = YES;
	//viewController.tag = tag;
	viewController.chatroom = chatroom;
	[self.navigationController pushViewController:viewController animated:YES];
	
}

-(void)showPhoto:(NSNotification *)notification
{
	if(![PFUser currentUser])
	{
		[self onBack:nil];
		return;
	}
	NSInteger tag =  [(NSNumber *)notification.object integerValue];
	PAWChatRoom * chatroom = [self.allChatRoomMain objectAtIndex:tag];
	NSLog(@"Char room %@", chatroom.object);
	appDelegate.ChatOwner=[chatroom.object objectForKey:@"creator"];
	PFObject *object = [chatroom object];
	PFFile *theImage = [object objectForKey:@"photo"];
	
	NSString * chatroom_id = [chatroom.object objectId];
	
	PAWPhotoViewController * viewController = [[PAWPhotoViewController alloc] initWithNibName:@"PAWPhotoViewController" bundle:nil];
	viewController.photo = theImage;
	viewController.chatRoomID = chatroom_id;
	viewController.scrolling = YES;
	viewController.tag = tag;
	viewController.chatroom = chatroom;
	[self.navigationController pushViewController:viewController animated:YES];
	
}
- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	
}

- (void) viewWillDisappear:(BOOL)animated {
	
	for (MapPinView *annView in arrAnnView) {
		@try{
			[annView removeObserver:self forKeyPath:@"selected"];
		}@catch(id anException){
   //do nothing, obviously it wasn't attached because an exception was thrown
		}
	}
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"NotificationRecieved" object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
	viewDisspear = YES;
}
-(void)setRedeemedButtonOnCall:(NSNotification *)notification
{
	CGRect statusBarFrame = [UIApplication.sharedApplication statusBarFrame];
	CGRect frame = tabview.frame;
	frame.origin.y = statusBarFrame.size.height > 20?frame.origin.y - 20:frame.origin.y + 20;
	//isSetForCalling = statusBarFrame.size.height > 20?YES:NO;
	tabview.frame = frame;
	
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void) dealloc {
	[self.mapView removeAnnotations:[self.mapView annotations]];
	appDelegate.isShowNetworkError = NO;
	[appDelegate removeNetworkError];
	[self.allChatRoom removeAllObjects];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWEnterChatRoomNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWShowImagesNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"gotoNotification" object:nil];
	
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"gotoDetail" object:nil];

}

#pragma mark - button methods
- (IBAction)valueChanged:(id)sender forEvent:(UIEvent *)event {
	UISegmentedControl *switchobj = (UISegmentedControl *)sender;
	[_txtSearch resignFirstResponder];
	UIView * view = [self.view viewWithTag:DETAIL_CHATROOM_TAG];
	if (view) {
		[view removeFromSuperview];
	}
	if(!switchobj.selectedSegmentIndex)
	{
		_mapView.hidden = NO;
		chatroomTb.hidden = YES;
		//_selectionList.hidden = YES;
	}
	else
	{
		_mapView.hidden = YES;
		chatroomTb.hidden = NO;
		//_selectionList.hidden = NO;

	}
}

- (IBAction)onBack:(id)sender {
	
	if(sender == nil)
	{
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Login" message:@"Please signup to access." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Signup", nil];
		alert.tag = 2;
		[alert show];
		return;
	}
	
	NSArray * pVCs = [self.navigationController viewControllers];
	for (UIViewController * pVC in pVCs) {
		if ([pVC isKindOfClass:[PAWEnterChatViewController class]]) {
			[self.navigationController popToViewController:pVC animated:YES];
			return;
		}
		
	}
	
	for (UIViewController * pVC in pVCs) {
		 if ([pVC isKindOfClass:[PAWWelcomeViewController class]])
		{
			PAWWelcomeViewController *wVC = (PAWWelcomeViewController *)pVC;
			
			wVC.isBack = YES;
			[self.navigationController popToViewController:pVC animated:NO];
			return;
		}
	}
}

- (IBAction)onCursor:(id)sender {
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_coordinate, SEARCH_RADIUS, SEARCH_RADIUS);
	[self.mapView setRegion:region animated:YES];
}

- (IBAction)onShare:(id)sender {
	if(![PFUser currentUser])
	{
		[self onBack:nil];
		return;
	}
	
	    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
	                                                              delegate:self
														 cancelButtonTitle:@"Cancel"
													destructiveButtonTitle:nil
														 otherButtonTitles:@"Twitter", @"Facebook", @"Email", @"SMS", nil];
	actionSheet.tag = 1;
		[actionSheet showInView:self.view];
}

- (IBAction)refreshChat:(id)sender {
	[self.selectionList reloadData];
	[self.selectionList setInitalSelection];
	[self getAllChatRoom];
	
}
-(void)delete
{
	[chatroomEdit.object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		
	} ];
	[self getAllChatRoom];
}

#pragma mark - action sheet delegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(actionSheet.tag == 1)
	{
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
		return;
	}
	switch (buttonIndex) {
		case 0:
			[self delete];
			break;
		case 1:
			[self editRoomMethod];
			break;
		case 2:
			[self onShare:nil];
		default:
			break;
	}
}
-(void)editRoomMethod
{
	PAWStartChatViewController *viewController = [[PAWStartChatViewController alloc] initWithNibName:@"PAWStartChatViewController" bundle:nil];
	viewController.chatroom = chatroomEdit;
	[self.navigationController pushViewController:viewController animated:YES];

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

#pragma mark - text field delegate

- (IBAction)onDidEndOnExit:(id)sender {
}



-(void)reloadTable
{
	/*
	 ACL = "<PFACL: 0x7fcc6f0d2ed0>";
	 address = "701 South Fair Oaks Avenue, Sunnyvale, CA 94086, USA";
	 creator = "<PFUser: 0x7fcc6f0ac7a0, objectId: tz3V6zWH0j>";
	 description = "Looking for farm fresh product around here?";
	 "is_spam" = 1;
	 location = "<PFGeoPoint: 0x7fcc6f0aca90, latitude: 37.363634, longitude: -122.024730>";
	 "lokay_code" = "";
	 name = kylie;
	 photo = "<PFFile: 0x7fcc6f0acb90>";
	 radius = 0;
	 reportedBy = "<PFUser: 0x7fcc6f0ac4c0, objectId: JJUC0BcSZQ>";
	 type = Red;
	 }

	 */
	//[autoSuggestionView.tablesuggestion reloadData];
}
- (void) textFieldDidEndEditing:(UITextField *)textField {
	if(textField.text == nil || [textField.text isEqualToString:@""])
	{
		NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
		self.arrChatRoom = [[self.allChatRoomMain sortedArrayUsingDescriptors:@[sortDesc]] mutableCopy];
		[chatroomTb reloadData];
		self.allChatRoom = [self.allChatRoomMain mutableCopy];
		return;

	}
	NSMutableArray *arr = [[NSMutableArray alloc]init];
	for(int i = 0; i < self.allChatRoomMain.count;i++)
	{
		PAWChatRoom *chat = [self.allChatRoomMain objectAtIndex:i];
		NSString *str = [NSString stringWithFormat:@"%@,%@,%@",[chat.object objectForKey:@"name"],[chat.object objectForKey:@"address"],[chat.object objectForKey:@"lokay_code"]];
		if ([str rangeOfString:textField.text options:NSCaseInsensitiveSearch| NSDiacriticInsensitiveSearch].location != NSNotFound) {
			[arr addObject:chat];
				}
	}
	
	
	NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
	self.arrChatRoom = [[arr sortedArrayUsingDescriptors:@[sortDesc]] mutableCopy];
	[chatroomTb reloadData];
	self.allChatRoom = [arr mutableCopy];
	[self.mapView removeAnnotations:self.mapView.annotations];
	[self.mapView addAnnotations:self.allChatRoom];
	if(self.allEvent.count)
	{
		[self.mapView addAnnotations:self.allEvent];
	}
	PAWChatRoom * userLocation = [[PAWChatRoom alloc] initWithCoordinate:_coordinate andTitle:@"User Location" andSubtitle:nil andcreator:nil];
	userLocation.isUserLocation = YES;
	//[self.mapView addAnnotation:userLocation];
	if(arr.count)
	{
				PAWChatRoom * chatroom = [self.allChatRoom objectAtIndex:0];
			PFGeoPoint * point = [[chatroom object] objectForKey:@"location"];
			CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
			MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, SEARCH_RADIUS, SEARCH_RADIUS);
		//MKMapPoint *point1 = MKMapPointMake(point.latitude, point.latitude);
			[self.mapView setRegion:region animated:YES];
	}
	
	

}

#pragma mark - search chat room methods
- (void) getAllChatRoom {
	PFQuery * query = [PFQuery queryWithClassName:@"ChatRoom"];
	[query whereKeyExists:@"creator"];
	query.limit = 100;
	
	//show loading view
	PAWActivityView *activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
	UILabel *label = activityView.label;
	label.text = @"Loading...";
	label.font = [UIFont boldSystemFontOfSize:20.f];
	[activityView.activityIndicator startAnimating];
	[activityView layoutSubviews];
	[self.view addSubview:activityView];
	
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		
		[activityView.activityIndicator stopAnimating];
		[activityView removeFromSuperview];
		
		if (error) {
			NSLog(@"error in geo query! : %@", error);
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			return ;
		}
		else {
			[self.allChatRoom removeAllObjects];
			int j = 0;
			for (int i = 0; i < objects.count; i++) {
				
				
				PFObject *object = [objects objectAtIndex:i];
				
				NSString *start = [object objectForKey:@"start_time"];
				NSString *end = [object objectForKey:@"close_time"];
				if(start && end)
				{
					NSString *strDate = [object objectForKey:@"date"];
					strDate = [strDate stringByReplacingOccurrencesOfString:@" " withString:@""];
					NSDateFormatter *formater = [[NSDateFormatter alloc]init];
					[formater setDateFormat:@"MM/dd/yyyy"];

					NSDate *date = [formater dateFromString:strDate];
					NSDate *nextdate = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:date];

					if(strDate)
					{
						BOOL today = [[NSCalendar currentCalendar] isDateInToday:date];
						if(!today)
						{
							if(![self checkEnd:end andStartTime:start])
							{
								if(![[NSCalendar currentCalendar] isDateInToday:nextdate] || [self checknextEndDate:end])
								{
									continue;
								}
							}
							else if (![[NSCalendar currentCalendar] isDateInToday:nextdate])
							{
								continue;
							}
						}

					}
					if(!([self checkStartTime:start] ))
					{
						if(![[NSCalendar currentCalendar] isDateInToday:nextdate])
							continue;

					}
					if(![self checkendTime:end])
					{
						if([self checkEnd:end andStartTime:start])
							continue;
					}
				}
				PAWChatRoom * chatRoom = [[PAWChatRoom alloc] initWithPFObject:object];
				if(chatRoom.distance > 50.0)
				{
					continue;
				}
				chatRoom.tag = j;
				[self.allChatRoom addObject:chatRoom];
				j++;
			}
			NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
			self.arrChatRoom = [[self.allChatRoom sortedArrayUsingDescriptors:@[sortDesc]] mutableCopy];
			[self filterData];
			[chatroomTb reloadData];
			self.allChatRoomMain = [self.allChatRoom mutableCopy];
			//chatroomTb.arrRooms = self.allChatRoom;
			//chatroomTb.arrChatRoom = self.allChatRoom;
			[self.mapView removeAnnotations:self.mapView.annotations];
			[self.mapView addAnnotations:arrSelectedOption];
			if(self.allEvent.count)
			{
				[self.mapView addAnnotations:self.allEvent];
			}
			PAWChatRoom * userLocation = [[PAWChatRoom alloc] initWithCoordinate:_coordinate andTitle:@"User Location" andSubtitle:nil andcreator:nil];
			userLocation.isUserLocation = YES;
			//[self.mapView addAnnotation:userLocation];
			
			if (self.chatroom_id) {
				NSInteger index = -1;
				for (PAWChatRoom * chatroom in self.allChatRoom) {
					if ([[chatroom.object objectId] isEqualToString:self.chatroom_id]) {
						index = [self.allChatRoom indexOfObject:chatroom];
						break;
					}
				}
				if (index != -1) {
					PAWChatRoom * chatroom = [self.allChatRoom objectAtIndex:index];
					PFGeoPoint * point = [[chatroom object] objectForKey:@"location"];
					CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
					MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_coordinate, SEARCH_RADIUS, SEARCH_RADIUS);
					[self.mapView setRegion:region animated:YES];
					
					CGPoint basePoint = [UIScreen mainScreen].bounds.size.height > 500 ? CGPointMake(150, 300) : CGPointMake(106, 300);
					[self addDetailChatRoom:index basePoint:basePoint];
				}
			}
			else {
				MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_coordinate, SEARCH_RADIUS, SEARCH_RADIUS);
				[self.mapView setRegion:region animated:YES];
			}
		}
	}];
}
-(NSDate *)setTimeTodate:(NSDate *)date
{
 
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
	NSInteger hour = [components hour];
	NSInteger minute = [components minute];
	NSDate* result;
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setMinute:minute];
	[comps setHour:hour];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	result = [gregorian dateFromComponents:comps];
	return result;
}
- (NSInteger *)minutesBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
	NSUInteger unitFlags = NSMinuteCalendarUnit;
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
	return [components minute];
}
-(NSDate *)setTimeToNextdate:(NSDate *)date
{
 
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
	NSInteger hour = [components hour];
	NSInteger minute = [components minute];
	NSDate* result;
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setMinute:minute];
	[comps setHour:hour];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	result = [gregorian dateFromComponents:comps];
	return result;
}


-(BOOL)checkStartTime:(NSString *)str
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"h:mm a"];
	//[formatter setTimeZone:[NSTimeZone localTimeZone]];
	NSDate *date = [formatter dateFromString:str];
	date  = [self setTimeTodate:date];
	NSDate *dateCurrent = [self setTimeTodate:[NSDate date]];
	
	return [dateCurrent compare:date] == NSOrderedDescending;
}
-(BOOL)checknextEndDate:(NSString *)str
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"h:mm a"];
	//[formatter setTimeZone:[NSTimeZone localTimeZone]];
	NSDate *date = [formatter dateFromString:str];
	date  = [self setTimeTodate:date];
	
	NSDate *dateCurrent = [self setTimeToNextdate:[NSDate dateWithTimeInterval:(24*60*60) sinceDate:[NSDate date]]];
	//BOOL v = [dateCurrent compare:date] == NSOrderedDescending;
	return [dateCurrent compare:date] == NSOrderedDescending;
}


-(BOOL)checkendTime:(NSString *)str
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"h:mm a"];
	//[formatter setTimeZone:[NSTimeZone localTimeZone]];
	NSDate *date = [formatter dateFromString:str];
	date  = [self setTimeTodate:date];
	
	NSDate *dateCurrent = [self setTimeTodate:[NSDate date]];
	
	return [dateCurrent compare:date] == NSOrderedAscending;
}

-(BOOL)checkEnd:(NSString *)str andStartTime:(NSString *)strStart
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"h:mm a"];
	//[formatter setTimeZone:[NSTimeZone localTimeZone]];
	NSDate *date = [formatter dateFromString:str];
	date  = [self setTimeTodate:date];
	
	NSDate *datestart = [formatter dateFromString:strStart];
	datestart = [self setTimeTodate:datestart];
	
	return [datestart compare:date] == NSOrderedAscending;
}
- (void) getNearbyChatRooms:(CLLocationCoordinate2D)coordinate {
	PFQuery * query = [PFQuery queryWithClassName:@"ChatRoom"];
	PFGeoPoint * point = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	[query whereKey:@"location" nearGeoPoint:point withinKilometers:10.0f];
	
	//show loading view
	PAWActivityView *activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
	UILabel *label = activityView.label;
	label.text = @"Loading...";
	label.font = [UIFont boldSystemFontOfSize:20.f];
	[activityView.activityIndicator startAnimating];
	[activityView layoutSubviews];
	[self.view addSubview:activityView];
	
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		
		[activityView.activityIndicator stopAnimating];
		[activityView removeFromSuperview];
		
		if (error) {
			NSLog(@"error in geo query! : %@", error);
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
		}
		else {
			[self.allChatRoom removeAllObjects];
			for (PFObject * object in objects) {
				PAWChatRoom * chatRoom = [[PAWChatRoom alloc] initWithPFObject:object];
				chatRoom.tag = [objects indexOfObject:object];
				[self.allChatRoom addObject:chatRoom];
			}
			
			[self.mapView removeAnnotations:self.mapView.annotations];
			[self.mapView addAnnotations:self.allChatRoom];
			
			PAWChatRoom * userLocation = [[PAWChatRoom alloc] initWithCoordinate:_coordinate andTitle:@"User Location" andSubtitle:nil andcreator:nil];
			userLocation.isUserLocation = YES;
			//[self.mapView addAnnotation:userLocation];
			
			MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_coordinate, SEARCH_RADIUS, SEARCH_RADIUS);
			[self.mapView setRegion:region animated:YES];
		}
	}];
}

- (void) getLOKAYChatRoom:(NSString *)lokay_code {
	PFQuery * query = [PFQuery queryWithClassName:@"ChatRoom"];
	[query whereKey:@"lokay_code" equalTo:lokay_code];
	
	//show loading view
	PAWActivityView *activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
	UILabel *label = activityView.label;
	label.text = @"Loading...";
	label.font = [UIFont boldSystemFontOfSize:20.f];
	[activityView.activityIndicator startAnimating];
	[activityView layoutSubviews];
	[self.view addSubview:activityView];
	
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		
		[activityView.activityIndicator stopAnimating];
		[activityView removeFromSuperview];
		
		if (error) {
			NSLog(@"error in geo query! : %@", error);
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
		}
		else {
			[self.allChatRoom removeAllObjects];
			for (int i = 0; i < objects.count; i++) {
				PFObject *object = [objects objectAtIndex:i];
				PAWChatRoom * chatRoom = [[PAWChatRoom alloc] initWithPFObject:object];
				chatRoom.tag = i;
				[self.allChatRoom addObject:chatRoom];
			}
			
			[self.mapView removeAnnotations:self.mapView.annotations];
			[self.mapView addAnnotations:self.allChatRoom];
			
			PAWChatRoom * first = [self.allChatRoom firstObject];
			PFGeoPoint * point = [first.object objectForKey:@"location"];
			CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
			
			PAWChatRoom * userLocation = [[PAWChatRoom alloc] initWithCoordinate:_coordinate andTitle:@"User Location" andSubtitle:nil andcreator:nil];
			userLocation.isUserLocation = YES;
			//[self.mapView addAnnotation:userLocation];
			
			MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, SEARCH_RADIUS, SEARCH_RADIUS);
			[self.mapView setRegion:region animated:YES];
		}
	}];
}

#pragma mark - map view delegate
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(PAWChatRoom *)annotation
{
	if (annotation == self.mapView.userLocation){
		return nil; //default to blue dot
	}
	
	
	static NSString *PinIdentifier = @"LokayChatRoomIdentifier";
	
	MapPinView *annView = nil;
	if (annView == nil)
	{
		annView = [[MapPinView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
		//annView.animatesDrop = NO;
		annView.canShowCallout = YES;
		annView.calloutOffset = CGPointMake(0, 0);
		annView.enabled = YES;
		
		if (!annotation.isUserLocation) {
			UIButton * item = [UIButton buttonWithType:UIButtonTypeInfoLight];
			item.tag = annotation.tag;
			if (item.tag == 37) {
				PAWChatRoom *room = [self.allChatRoom objectAtIndex:item.tag];
			}
			[item addTarget:self action:@selector(onDetailChatRoom:) forControlEvents:UIControlEventTouchUpInside];
			annView.rightCalloutAccessoryView = item;
		}
		
		[annView addObserver:self
				  forKeyPath:@"selected"
					 options:NSKeyValueObservingOptionNew
					 context:@"ANSELECTED"];
		if (arrAnnView == nil) {
			arrAnnView = [[NSMutableArray alloc]init];
		}
		[arrAnnView addObject:annView];
	}
	if (annotation.isUserLocation) {
	}
	else {
		if(annotation.isEventBrite)
		{
			annView.image = [UIImage imageNamed:@"purplepin.png"];
			
		}
		else
		{
			NSString * pinColor = [annotation.object objectForKey:@"type"];
			if ([pinColor isEqualToString:@"Blue"]) {
				annView.image = [UIImage imageNamed:@"bluepin"];
			}
			else if ([pinColor isEqualToString:@"Green"]) {
				annView.image = [UIImage imageNamed:@"greenpin"];
			}
			else if ([pinColor isEqualToString:@"Red"]) {
				annView.image = [UIImage imageNamed:@"redpin"];
			}
			else if ([pinColor isEqualToString:@"Purple"]) {
				annView.image = [UIImage imageNamed:@"purplepin"];
			}
		}
	}
	
	//annView.centerOffset = CGPointMake(0, - 43 / 2);
	
	return annView;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSString *action = (__bridge NSString*)context;
	
	
	MapPinView *annotationView = (MapPinView *)object;
	//if (annotationView.pinColor != MKPinAnnotationColorGreen)
	//{
		if ([action isEqualToString:@"ANSELECTED"])
		{
			BOOL annotationSelected = [[change valueForKey:@"new"] boolValue];
			if (annotationSelected)
			{
				// Annotation selected
				NSLog(@"Annotation selected!");
			}
			else
			{
				// Annotation deselected
				NSLog(@"Annotation deselected!");
				
				UIView * view = [self.view viewWithTag:DETAIL_CHATROOM_TAG];
				if (view) {
					[view removeFromSuperview];
				}
			}
		}
	//}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	NSLog(@"tapped!");
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	UIView * view = [self.view viewWithTag:DETAIL_CHATROOM_TAG];
	if (view) {
		[view removeFromSuperview];
	}
}

- (void) onDetailChatRoom:(UIButton *)sender {
	
	CGPoint pt = [sender convertPoint:sender.center toView:self.view];
	
	[self addDetailChatRoom:sender.tag basePoint:pt];
}

- (void) addDetailChatRoom:(NSInteger)index basePoint:(CGPoint)basePoint {
	PAWChatRoom * chatroom = nil;
	PAWChatRoomView * view = (PAWChatRoomView *)[self.view viewWithTag:DETAIL_CHATROOM_TAG];
	if (view) {
		[view removeFromSuperview];
	}
	
	if(index/2000 > 0)
	{
		chatroom =[self.allEvent objectAtIndex:index - 2000];
		view = [[PAWChatRoomView alloc] initWithEBObject:chatroom.object tag:chatroom.tag];
		
		
	}
	else
	{
		chatroom = [self.allChatRoomMain objectAtIndex:index] ;
		view = [[PAWChatRoomView alloc] initWithPFObject:chatroom.object tag:chatroom.tag];
		
	}
	
	view.tag = DETAIL_CHATROOM_TAG;
	
	CGRect frame = view.frame;
	
	if (basePoint.y < 65 + frame.size.height / 2 + 10) {
		basePoint.y = 65 + frame.size.height / 2 + 10;
	}
	if (basePoint.y > SCREEN_HEIGHT - frame.size.height / 2 - 50) {
		basePoint.y = SCREEN_HEIGHT - frame.size.height / 2 - 50;
	}
	
	frame = CGRectMake(frame.origin.x, basePoint.y - frame.size.height / 2, frame.size.width, frame.size.height);
	[view setFrame:frame];
	
	[self.view addSubview:view];
}

- (void) onEnterChatRoom:(NSNotification *)notification {
	PAWChatRoomView * view = (PAWChatRoomView *)[self.view viewWithTag:DETAIL_CHATROOM_TAG];
	if (view) {
		[view removeFromSuperview];
	}
	
	NSInteger tag =  [(NSNumber *)notification.object integerValue];
	if(tag < 2000){
		
		
		
		PAWChatRoom * chatroom = [self.allChatRoomMain objectAtIndex:tag];
		[self gotoChat:chatroom];
			
		
	}
	else
	{
		PAWChatRoom * chatroom = [self.allEvent objectAtIndex:tag - 2000];
		
		[self checkChatRoom:chatroom.object];
	}
	
	//save chat roon id as a channel
	/*
	 PFInstallation * installation = [PFInstallation currentInstallation];
	 NSArray * channels = installation.channels;
	 if (channels) {
		[installation removeObjectsInArray:channels forKey:@"channels"];
		[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
	 if (succeeded) {
	 PAWWallViewController * viewController = [[PAWWallViewController alloc] initWithNibName:@"PAWWallViewController" bundle:nil];
	 viewController.chatroom_id = chatroom_id;
	 viewController.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
	 viewController.mainTitle = chatroom_name;
	 viewController.subTitle = chatroom_address;
	 viewController.type = type;
	 [self.navigationController pushViewController:viewController animated:YES];
	 }
	 else {
	 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter Chat : Remove Channel" message:[[error userInfo] objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
	 [alertView show];
	 }
		}];
	 }
	 else {
		*/
	//}
}
-(void)gotoChat:(PAWChatRoom *)chatroom
{
	
	if(![PFUser currentUser])
	{
		[self onBack:nil];
		return;
	}
	NSLog(@"Char room %@", chatroom.object);
	appDelegate.ChatOwner=[chatroom.object objectForKey:@"creator"];
	
	NSString * chatroom_id = [chatroom.object objectId];
	PFGeoPoint * point = [chatroom.object objectForKey:@"location"];
	CLLocation * chatroom_location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
	CLLocation * userLocation = [[CLLocation alloc] initWithLatitude:_coordinate.latitude longitude:_coordinate.longitude];
	double distance = [userLocation distanceFromLocation:chatroom_location];
	NSString * chatroom_name = [chatroom.object objectForKey:@"name"];
	NSString * chatroom_address = [chatroom.object objectForKey:@"address"];
	NSString * type = [chatroom.object objectForKey:@"type"];
	
	NSInteger radius = [[chatroom.object objectForKey:@"radius"] integerValue];
	//NSString *chatOwnerUsername = appDelegate.ChatOwner.username;
	NSString *ownerID = [appDelegate.ChatOwner objectId];
	if (radius && distance > radius && ![ownerID isEqualToString:[[PFUser currentUser] objectId]]) {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
														 message:@"You can not enter chat room out of radius"
														delegate:nil
											   cancelButtonTitle:@"Ok"
											   otherButtonTitles:nil, nil];
		[alert show];
		return;
	}
	PAWWallViewController * viewController = [[PAWWallViewController alloc] initWithNibName:@"PAWWallViewController" bundle:nil];
	viewController.chatroom_id = chatroom_id;
	viewController.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
	viewController.mainTitle = chatroom_name;
	viewController.subTitle = chatroom_address;
	viewController.type = type;
	[self.navigationController pushViewController:viewController animated:YES];
}

-(void)checkChatRoom:(PFObject *)object
{
	PFQuery * query = [PFQuery queryWithClassName:@"ChatRoom"];
	[query whereKey:@"eventbrite_id" equalTo:[object objectForKey:@"id"]];
	//query.limit = 100;
	
	//show loading view
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
	HUD.labelText = @"Checking Evenbrite ChatRoom...";
	HUD.detailsLabelText = @"Please Wait";
	//HUD.mode = MBProgressHUDModeAnnularDeterminate;
	[self.view addSubview:HUD];
	[HUD show:YES];
	
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		if(objects.count)
		{
			PAWChatRoom *chatroom = [[PAWChatRoom alloc]initWithPFObject:[objects objectAtIndex:0]];
			[self gotoChat:chatroom];
		}
		else
		{
			objectSelected = object;
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"There is no chatroom for this Eventbrite event. Do you want to creat a chatroom for this event?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
			[alert show];
		}
		
	}];
	
}
- (void) uploadChatRoomData:(CLLocationCoordinate2D)location
					address:(NSString *)address
				 lokay_code:(NSString *)lokay_code
					 radius:(NSInteger)radius
				   pinColor:(NSString *)pinColor
					   name:(NSString *)name
				description:(NSString *)description
					  photo:(NSData *)photo
			   eventBriteId:(NSString *)eID{
	
	//Data perp :
	PFUser * user = [PFUser currentUser];
	PFGeoPoint * point = [PFGeoPoint geoPointWithLatitude:location.latitude longitude:location.longitude];
	
	//create chat room object to post
	//cSpBf5dCR0
	PFObject * chatroom = [PFObject objectWithClassName:@"ChatRoom"];
	[chatroom setObject:user forKey:@"creator"];
	[chatroom setObject:point forKey:@"location"];
	[chatroom setObject:address forKey:@"address"];
	[chatroom setObject:lokay_code forKey:@"lokay_code"];
	[chatroom setObject:[NSNumber numberWithInteger:0] forKey:@"radius"];
	[chatroom setObject:pinColor forKey:@"type"];
	[chatroom setObject:name forKey:@"name"];
	[chatroom setObject:description forKey:@"description"];
	[chatroom setObject:eID forKey:@"eventbrite_id"];
	
	// Use PFACL to restrict future modifications to this object.
	PFACL *readOnlyACL = [PFACL ACL];
	[readOnlyACL setPublicReadAccess:YES];
	[readOnlyACL setPublicWriteAccess:YES];
	[chatroom setACL:readOnlyACL];
	
	PAWAppDelegate * appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.ChatOwner=user;
	
	
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
	HUD.labelText = @"Building Chat...";
	HUD.detailsLabelText = @"Please Wait";
	//HUD.mode = MBProgressHUDModeAnnularDeterminate;
	[self.view addSubview:HUD];
	[HUD show:YES];
	[chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		//[activityView.activityIndicator stopAnimating];
		//[activityView removeFromSuperview];
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		if (error) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Start Screen : Save Chat Room" message:[[error userInfo] objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			return;
		}
		if (succeeded) {
			
			NSString * chatroom_id = [chatroom objectId];
			
			//send push to nearby user
			
			PAWWallViewController * viewController = [[PAWWallViewController alloc] initWithNibName:@"PAWWallViewController" bundle:nil];
			viewController.chatroom_id = chatroom_id;
			viewController.coordinate = _coordinate;
			viewController.mainTitle = name;
			viewController.subTitle = address;
			viewController.type = pinColor;
			[self.navigationController pushViewController:viewController animated:YES];
			//}
		} else {
			NSLog(@"Failed to save.");
		}
	}];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	if (alertView.tag == 2)
	{
		if(buttonIndex == 1)
		{
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[self onBack:btn];
		}
		return;
	}

	
	if(buttonIndex == 0)
	{
		CLLocationCoordinate2D location;
		NSString *address = @"";
		NSString *name = @"";
		NSString *discription = @"";
		if(![[objectSelected objectForKey:@"venue"] isEqual:[NSNull null]])
		{
		 location = CLLocationCoordinate2DMake([[[objectSelected objectForKey:@"venue"] objectForKey:@"latitude"] doubleValue], [[[objectSelected objectForKey:@"venue"] objectForKey:@"longitude"] doubleValue]);
			address = [NSString stringWithFormat:@"%@ %@ %@ %@",[[objectSelected objectForKey:@"venue"] objectForKey:@"address_1"],[[objectSelected objectForKey:@"venue"] objectForKey:@"address_2"],[[objectSelected objectForKey:@"venue"] objectForKey:@"city"],[[objectSelected objectForKey:@"venue"] objectForKey:@"postal_code"]];
		}
		NSString *pincolor = @"Purple";
		if(![[objectSelected objectForKey:@"name"] isEqual:[NSNull null]])
			name = [[objectSelected objectForKey:@"name"] objectForKey:@"text"];
		if(![[objectSelected objectForKey:@"description"] isEqual:[NSNull null]])
			discription = [[objectSelected objectForKey:@"description"] objectForKey:@"text"];
		NSString *eventID = [objectSelected objectForKey:@"id"];
		
		[self uploadChatRoomData:location address:address lokay_code:@"" radius:0 pinColor:pincolor name:name description:discription photo:nil eventBriteId:eventID];
		
		/*
		 uploadChatRoomData:(CLLocationCoordinate2D)location
		 address:(NSString *)address
		 lokay_code:(NSString *)lokay_code
		 radius:(NSInteger)radius
		 pinColor:(NSString *)pinColor
		 name:(NSString *)name
		 description:(NSString *)description
		 photo:(NSData *)photo {
		 */
		
	}
    	objectSelected = nil;
}

- (void) getAddressFromLocation:(CLLocation *)location {
	NSString * url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%.6f,%.6f&sensor=true", location.coordinate.latitude, location.coordinate.longitude];
	NSLog(@"url = %@", url);
	NSData * rcvData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	NSString * jsonString = [[NSString alloc] initWithData:rcvData encoding:NSStringEncodingConversionExternalRepresentation];
	SBJSON * parser = [[SBJSON alloc] init];
	NSDictionary * jsonData = [parser objectWithString:jsonString error:nil];
	NSArray * results = [jsonData objectForKey:@"results"];
	if ([results count]) {
		self.txtSearch.text = [[results firstObject] objectForKey:@"formatted_address"];
		_coordinate = location.coordinate;
	}
	
	UIView * view = [self.view viewWithTag:ACTIVITY_VIEW_TAG];
	if (view) [view removeFromSuperview];
}

- (void) getAddressFromAddress:(NSString *)param {
	NSString * url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", param];
	url = [url stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
	NSLog(@"url = %@", url);
	NSData * rcvData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	NSString * jsonString = [[NSString alloc] initWithData:rcvData encoding:NSStringEncodingConversionExternalRepresentation];
	SBJSON * parser = [[SBJSON alloc] init];
	NSDictionary * jsonData = [parser objectWithString:jsonString error:nil];
	NSArray * results = [jsonData objectForKey:@"results"];
	if ([results count]) {
		self.txtSearch.text = [[results firstObject] objectForKey:@"formatted_address"];
		NSDictionary * dict = [[[results firstObject] objectForKey:@"geometry"] objectForKey:@"location"];
		_coordinate.latitude = [[dict objectForKey:@"lat"] doubleValue];
		_coordinate.longitude = [[dict objectForKey:@"lng"] doubleValue];
		
		[self.mapView removeAnnotations:self.mapView.annotations];
		[self.mapView addAnnotations:self.allChatRoom];
		
		PAWChatRoom * userLocation = [[PAWChatRoom alloc] initWithCoordinate:_coordinate andTitle:@"User Location" andSubtitle:nil andcreator:nil];
		userLocation.isUserLocation = YES;
		//[self.mapView addAnnotation:userLocation];
		
		MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_coordinate, SEARCH_RADIUS, SEARCH_RADIUS);
		[self.mapView setRegion:region animated:YES];
	}
	else {
		if(!viewDisspear)
		{
			self.txtSearch.text = @"";
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Input valid address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[alert show];
		}
	}
	
	UIView * view = [self.view viewWithTag:ACTIVITY_VIEW_TAG];
	if (view) [view removeFromSuperview];
}
-(void)placeSelected:(NSString *)place
{
	_txtSearch.text = place;
	[_txtSearch resignFirstResponder];
}

-(void)getEvenBriteEvent
{
	NSString *string =[NSString stringWithFormat:@"https://www.eventbriteapi.com/v3/events/search/?popular=on&location.latitude=%f&token=VU6WI2LR2QHRWR6RMVS7&page=1&location.longitude=%f",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude];
	NSURL *url = [NSURL URLWithString:string];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
 
	// 2
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
 
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError* error;
		NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
															 options:kNilOptions
															   error:&error];
		NSArray *arrEvents = [json objectForKey:@"events"];
		NSLog(@"Event Count ---- %lu",(unsigned long)arrEvents.count);
		NSLog(@"%@",arrEvents);
		if(!self.allEvent)
			self.allEvent = [[NSMutableArray alloc]init];
		else
			[self.allEvent removeAllObjects];
		for (int i = 0; i< arrEvents.count; i++) {
			NSDictionary *dic = [arrEvents objectAtIndex:i];
			PAWChatRoom *chartroom = [[PAWChatRoom alloc] initWithEBObject:dic];
			chartroom.tag = 2000 + i;
			[self.allEvent addObject:chartroom];
			
		}
		[self.mapView addAnnotations:self.allEvent];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		
		// 4
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
															message:[error localizedDescription]
														   delegate:nil
												  cancelButtonTitle:@"Ok"
												  otherButtonTitles:nil];
		[alertView show];
	}];
 
	// 5
	[operation start];
}



#pragma Mark - UITableViewDelegate
#pragma mark - UITableViewDelegate
/*
 -(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
	
	return 5;
 }
 -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
	static NSString *simpleTableIdentifier = @"Cell";
	
	NearBy_Cell *cell ;
	cell = (NearBy_Cell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	if (cell == nil)
	{
 cell = [[[NSBundle mainBundle] loadNibNamed:@"NearBy_Cell" owner:self options:nil] objectAtIndex:0];
	}
	
	Offers_data *objOffer = [[[UserData dataManager] nearByOffers] objectAtIndex:indexPath.row];
	cell.lblTitle.text = objOffer.strTitle;
	
	cell.lblOfferNo.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
	cell.lblSubCategory.text = objOffer.strSubCategory;
	
	
	
	float distance = objOffer.distance;
	if (distance > 1000.0)
	{
 cell.lblDistance.text = [NSString stringWithFormat:@"1000+"];
 
	}
	else if(distance > 99.0)
	{
 cell.lblDistance.text = [NSString stringWithFormat:@"%1.0f",distance];
	}
	
	else
	{
 cell.lblDistance.text = [NSString stringWithFormat:@"%1.1f",distance];
	}
	
	cell.lblDesc.text = objOffer.strDesc;
	cell.lblTime.text = [NSString stringWithFormat:@"Use Now Untill %@!",objOffer.strTime];
	
	cell.controler = self;
	cell.offer = objOffer;
	cell.scroll.delegate = self;
	[SetLabelHight setLabelHight:cell.lblDesc];
	if (self.isViewLoaded && self.view.window) {
 if(likedMerchant == [objOffer.MerchantId integerValue])
 {
 [self performSelector:@selector(setLikeIndicatorValue) withObject:nil afterDelay:1.0];
 [cell showLikeIndicator];
 }
 
	}
	if([Offers_data checkpopularOffer:objOffer])
	{
 [cell showFire];
	}
	return cell;
 }
 -(void)setLikeIndicatorValue
 {
	likedMerchant = -1;
	
 }
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
	if([[UserData dataManager] nearByOffers].count == indexPath.row)
 return 20;
	return cellHeight;
 }
 -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
	if(indexPath.row == [[UserData dataManager] nearByOffers].count)
 return;
	NSLog(@"Table -  %@",self.navigationController);
	
	[self performSegueWithIdentifier:@"GoToDetail" sender:[[[UserData dataManager] nearByOffers] objectAtIndex:indexPath.row]];
 }
 
 */
- (void)gotoNotifications{
	if(![PFUser currentUser])
	{
		[self onBack:nil];
		return;
	}
	PAWInboxViewController *inboxVC = [[PAWInboxViewController alloc]init];
	inboxVC.arrChatRoom = _allChatRoomMain;
	[self.navigationController pushViewController:inboxVC animated:YES];
}
-(void)tabselectedwithIndex:(int)selectedIndex
{
	switch (selectedIndex) {
  case 0:
			[self actionsearch];
			break;
		case 1:
			break;
		case 2:
			[self plusIconAction];
			break;
		case 3:
			break;
			
  case 4:
			[self settingAction];
			break;
			
  default:
			break;
	}
}
-(void)settingAction
{
	if(![PFUser currentUser])
	{
		[self onBack:nil];
		return;
	}
	
	PAWSettingViewController *objSetting = [[PAWSettingViewController alloc]initWithNibName:@"PAWSettingViewController" bundle:nil];
	[self.navigationController pushViewController:objSetting animated:YES];

}
-(void)plusIconAction
{
	if([[PFUser currentUser] objectForKey:@"bussiness_name"] != nil)
	{
		PAWStartChatViewController * viewController = [[PAWStartChatViewController alloc] initWithNibName:@"PAWStartChatViewController" bundle:nil];
		[self.navigationController pushViewController:viewController animated:YES];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"In order to create an event you must sign up for the business account." cancelButtonItem:[RIButtonItem itemWithLabel:@"Yes" action:^{
			appDelegate.BussinessUserCreation = [PFUser currentUser];

		//	[PFUser logOut];
			
			PFInstallation * installation = [PFInstallation currentInstallation];
			[installation setObject:[NSNull null] forKey:@"user"];
			[installation saveInBackground];
			appDelegate.isSignout = YES;
			[appDelegate removeNotifiction];
			[appDelegate presentWelcomeViewController];
			
		}] otherButtonItems:[RIButtonItem itemWithLabel:@"No" action:^{
			
		}], nil];
		[alert show];
	}

}
-(void)actionsearch
{
	if(self.txtSearch.hidden)
	{
						_txtSearch.hidden = NO;

				_mapView.frame = CGRectMake(0, 145, 320, 410);
				chatroomTb.frame = CGRectMake(0, 145, 320, 410);
		_selectionList.frame = CGRectMake(0, 110, 320, 40);
		
		
	}
	else
	{
						_txtSearch.hidden = YES;

				_mapView.frame = CGRectMake(0, 115, 320, 470);
				chatroomTb.frame = CGRectMake(0, 105, 320, 470);
		_selectionList.frame = CGRectMake(0, 60, 320, 40);


	
	}
}
#pragma Mark - UITableViewDelegate
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(!arrSelectedOption)
		return 0;
	return arrSelectedOption.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *simpleTableIdentifier = [NSString stringWithFormat:@"Cell%d",indexPath.row];
	
	ChatRoomTableViewCell *cell ;
	cell = (ChatRoomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	if (cell == nil)
	{
		cell = [[[NSBundle mainBundle] loadNibNamed:@"ChatRoomTableViewCell" owner:self options:nil] objectAtIndex:0];
	}
	PAWChatRoom *chatRoom = [arrSelectedOption objectAtIndex:indexPath.row];
	cell.lblName.text = chatRoom.title;
	cell.lblAddress.text = 	cell.lblType.text = [NSString stringWithFormat:@"%@",[chatRoom.object objectForKey:@"address"]];
	PFFile *theImage = [chatRoom.object objectForKey:@"photo"];
	NSLog(@"%@",theImage.url);

	if(theImage)
	{
		//NSDictionary * arguments = [NSDictionary dictionaryWithObjectsAndKeys:cell.chatRoomImage, @"imageView", theImage, @"photo", nil];
		//[NSThread detachNewThreadSelector:@selector(loadPhoto:) toTarget:self withObject:arguments];
		cell.chatRoomImage.file = theImage;
		[cell.chatRoomImage loadInBackground];
	}
	
	NSString * pinColor = [chatRoom.object objectForKey:@"type"];
	if ([pinColor isEqualToString:@"Blue"]) {
		cell.lblType.text = [NSString stringWithFormat:@"Brunch - %1.2f miles",chatRoom.distance];
	}
	else if ([pinColor isEqualToString:@"Green"]) {
		cell.lblType.text = [NSString stringWithFormat:@"Daytime Parties - %1.2f miles",chatRoom.distance];
	}
	else if ([pinColor isEqualToString:@"Red"]) {
		cell.lblType.text = [NSString stringWithFormat:@"Bar - %1.2f miles",chatRoom.distance];
	}
	else if ([pinColor isEqualToString:@"Purple"]) {
		cell.lblType.text = [NSString stringWithFormat:@"Club - %1.2f miles",chatRoom.distance];
	}
	
	if ([pinColor isEqualToString:@"Blue"]) {
		cell.imgtype.image = [UIImage imageNamed:@"bluepin"];
	}
	else if ([pinColor isEqualToString:@"Green"]) {
		cell.imgtype.image = [UIImage imageNamed:@"greenpin"];
	}
	else if ([pinColor isEqualToString:@"Red"]) {
		cell.imgtype.image = [UIImage imageNamed:@"redpin"];
	}
	else if ([pinColor isEqualToString:@"Purple"]) {
		cell.imgtype.image = [UIImage imageNamed:@"purplepin"];
	}
	PFUser *user = [PFUser currentUser];
	if(!([[chatRoom.creator valueForKey:@"objectId"] isEqualToString:[user valueForKey:@"objectId"]]))
	{
		cell.btnEdit.hidden = YES;
	}
	
	cell.btnImage.tag = indexPath.row;
	cell.btnReport.tag = indexPath.row;
	cell.chatroom = chatRoom;
	cell.lblReview.text = [chatRoom.object objectForKey:@"description"];

	//NSLog(@"%d",indexPath.row);
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 150;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PAWChatRoom *chatRoom = [arrSelectedOption objectAtIndex:indexPath.row];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"gotoDetail" object:chatRoom];
	
	
}

- (void) loadPhoto:(NSDictionary *)arguments {
	UIImageView * imageView = [arguments objectForKey:@"imageView"];

	PFFile * photo = [arguments objectForKey:@"photo"];
	NSLog(@"%@",imageView);

	if(imageView)
		imageView.image = [UIImage imageWithData:[photo getData]];
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
	return arrPlaces.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
	return arrPlaces[index];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
	selectedOption = index;
	switch (index) {
		case 0:
			arrSelectedOption = [[NSArray alloc]initWithArray:arrBar];
			break;
		case 1:
			arrSelectedOption = [[NSArray alloc]initWithArray:arrBrunches];
			
			break;
		case 2:
			arrSelectedOption = [[NSArray alloc]initWithArray:arrClub];
			
			break;
		case 3:
			arrSelectedOption = [[NSArray alloc]initWithArray:arrDayParties];
			
			break;
			
			
		default:
			break;
	}
	[chatroomTb reloadData];
	[self.mapView removeAnnotations:self.mapView.annotations];
	[self.mapView addAnnotations:arrSelectedOption];

	
}



@end
