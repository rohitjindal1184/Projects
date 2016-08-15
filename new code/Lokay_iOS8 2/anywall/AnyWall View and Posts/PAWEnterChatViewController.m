//
//  PAWEnterChatViewController.m
//  LokayMe
//
//  Created by He Fei on 12/26/13.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAWEnterChatViewController.h"
#import "PAWStartChatViewController.h"
#import "PAWChooseChatRoomViewController.h"

@interface PAWEnterChatViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnCreateChat;
@property (weak, nonatomic) IBOutlet UIView *cameraView;

- (IBAction)onCreateChat:(id)sender;
- (IBAction)onEnterChat:(id)sender;
- (IBAction)onSignout:(id)sender;

@end

@implementation PAWEnterChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[self uploadUserLocation];
	/*
	PFInstallation * installation = [PFInstallation currentInstallation];
	[installation setObject:[PFUser currentUser] forKey:@"user"];
	[installation saveInBackground];*/
	if([[PFUser currentUser] objectForKey:@"bussiness_name"] == nil)
	{
		_btnCreateChat.hidden = YES;
	}
	
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCreateChat:(id)sender {
	PAWStartChatViewController * viewController = [[PAWStartChatViewController alloc] initWithNibName:@"PAWStartChatViewController" bundle:nil];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)onEnterChat:(id)sender {
	PAWChooseChatRoomViewController * viewController = [[PAWChooseChatRoomViewController alloc] initWithNibName:@"PAWChooseChatRoomViewController" bundle:nil];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)onSignout:(id)sender {
    [PFUser logOut];
	
	PFInstallation * installation = [PFInstallation currentInstallation];
	[installation setObject:[NSNull null] forKey:@"user"];
	[installation saveInBackground];
	
	PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate removeNotifiction];
	[appDelegate presentWelcomeViewController];
}

- (void)uploadUserLocation {
	PFUser * user = [PFUser currentUser];
	PAWAppDelegate * appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	CLLocationCoordinate2D coordinate = appDelegate.locationManager.location.coordinate;
	if (FEQUALZERO(coordinate.latitude) && FEQUALZERO(coordinate.longitude)) {
		return;
	}
	PFGeoPoint * geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	[user setObject:geoPoint forKey:@"location"];
	[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		NSLog(@"=============== user location updated ==============");
	}];
}

@end
