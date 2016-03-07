//
//  PAWAppDelegate.m
//  


static NSString * const defaultsFilterDistanceKey = @"filterDistance";
static NSString * const defaultsLocationKey = @"currentLocation";

#import "PAWAppDelegate.h"

#import <Parse/Parse.h>
#import "PAWChatRoom.h"
#import "PAWGetStartVC.h"
#import "PAWEnterChatViewController.h"
#import "PAWChooseChatRoomViewController.h"
#define kSwearsArr @"swearsArr"

@interface PAWAppDelegate ()

@end

@implementation PAWAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize filterDistance;
@synthesize currentLocation;
@synthesize locationManager;
@synthesize ChatOwner;
@synthesize agreementStr;


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
	
	self.reachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
	if (remoteHostStatus == NotReachable) {
		[self setNoNetworkView];
	}
	[self.reachability startNotifier];
	didBecomeActive = NO;
	_arrNotification = [[NSMutableArray alloc]init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Override point for customization after application launch.
	if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
		UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
														UIUserNotificationTypeBadge |
														UIUserNotificationTypeSound);
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
																				 categories:nil];
		[application registerUserNotificationSettings:settings];
		[application registerForRemoteNotifications];
	} else {
		// Register for Push Notifications before iOS 8
		[application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
														 UIRemoteNotificationTypeAlert |
														 UIRemoteNotificationTypeSound)];
	}
	
	[Parse setApplicationId:@"03srxQBHZvTF2Wkp8Vm3f2lexPnjbVZlUQm3Gxka"
				  clientKey:@"7UU9dHtOrDBIlRu4KidP7CtJBrL7mOnrsLNxEa4i"];
	
	// ****************************************************************************
    // Your Facebook application id is configured in Info.plist.
    // ****************************************************************************
    [PFFacebookUtils initializeFacebook];
	
	[PFTwitterUtils initializeWithConsumerKey:@"cCsKjLCQaTItWaS6Hr2kfw" consumerSecret:@"ZecRAT3UourjY9P2ACeoHLG7L7AQGaSk5CkHld3Mq8s"];
	
	// Grab values from NSUserDefaults:
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	// Set the global tint on the navigation bar
	[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:200.0f/255.0f green:83.0f/255.0f blue:70.0f/255.0f alpha:1.0f]];
	[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:nil] forBarMetrics:UIBarMetricsDefault];
	
	// Desired search radius:
	if ([userDefaults doubleForKey:defaultsFilterDistanceKey]) {
		// use the ivar instead of self.accuracy to avoid an unnecessary write to NAND on launch.
		filterDistance = [userDefaults doubleForKey:defaultsFilterDistanceKey];
	} else {
		// if we have no accuracy in defaults, set it to 1000 feet.
		self.filterDistance = 1000 * kPAWFeetToMeters;
	}

	UINavigationController *navController = nil;

	if ([PFUser currentUser]) {
		
		NSDictionary * remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (remoteNotif) {
			NSString * chatroom_id = [remoteNotif objectForKey:@"chatroom_id"];
			
			PAWEnterChatViewController *wallViewController = [[PAWEnterChatViewController alloc] initWithNibName:@"PAWEnterChatViewController" bundle:nil];
			PAWChooseChatRoomViewController * chooseViewController = [[PAWChooseChatRoomViewController alloc] initWithNibName:@"PAWChooseChatRoomViewController" bundle:nil];
			chooseViewController.chatroom_id = chatroom_id;
			navController = [[UINavigationController alloc] initWithRootViewController:wallViewController];
			navController.viewControllers = @[wallViewController, chooseViewController];
			navController.navigationBarHidden = YES;
			self.viewController = navController;
			self.window.rootViewController = self.viewController;
		}
		else {
			PAWEnterChatViewController *wallViewController = [[PAWEnterChatViewController alloc] initWithNibName:@"PAWEnterChatViewController" bundle:nil];
			navController = [[UINavigationController alloc] initWithRootViewController:wallViewController];
			navController.navigationBarHidden = YES;
			self.viewController = navController;
			self.window.rootViewController = self.viewController;
		}
		// Skip straight to the main view.
		
	} else {
		// Go to the welcome screen and have them log in or create an account.
		[self presentWelcomeViewController];
	}
	
	[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
	
	//start location manager
	[self startStandardUpdates];
	
    [self.window makeKeyAndVisible];
	
	[self getAllSwearsFromParseDB];
	
//	if (![[NSUserDefaults standardUserDefaults] valueForKey:@"isAgree"]) {
//		[self getAgreementFromDB];
//	}
	
    return YES;
}

- (void)getAllSwearsFromParseDB{
	PFQuery *swearsQuery = [PFQuery queryWithClassName:@"swears"];
	[swearsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
			// The find succeeded. The first 100 objects are available in objects
			NSLog(@"all -- %@",[objects valueForKey:@"word"]);
			NSArray *all = [objects valueForKey:@"word"];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:kSwearsArr];
			[[NSUserDefaults standardUserDefaults] setObject:all forKey:kSwearsArr];
			[[NSUserDefaults standardUserDefaults] synchronize];
			//			[swearsArr addObjectsFromArray:all];
		} else {
			// Log details of the failure
			NSLog(@"Error: %@ %@", error, [error userInfo]);
		}
	}];
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	if([def valueForKey:@"notifications"] == nil)
	{
		[def setValue:@"1" forKey:@"notifications"];
		[def synchronize];
	}

}


#pragma mark - push delegate
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	
	NSLog(@"device token = %@", deviceToken);
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (succeeded) {
			
		}
		else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"AppDelegate : Register Device" message:[[error userInfo] objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
		}
	}];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	if(![[def valueForKey:@"notifications"] boolValue])
	{
		return;
	}

	NSLog(@"Push received : %@", userInfo);
//    [PFPush handlePush:userInfo];
	//[[[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"my dictionary is %@", userInfo] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
	application.applicationIconBadgeNumber = 0;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kPAWMessageReceivedNotification object:nil];
	
	if (didBecomeActive) {
		//didBecomeActive = NO;
		
		NSString * chatroom_id = [userInfo objectForKey:@"chatroom_id"];
		if ([chatroom_id isEqualToString:self.chatroom_id]) {
			return;
		}
		_notifications++;
		[_arrNotification insertObject:userInfo atIndex:0];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationRecieved" object:nil];
		/*
		PAWEnterChatViewController *wallViewController = [[PAWEnterChatViewController alloc] initWithNibName:@"PAWEnterChatViewController" bundle:nil];
		PAWChooseChatRoomViewController * chooseViewController = [[PAWChooseChatRoomViewController alloc] initWithNibName:@"PAWChooseChatRoomViewController" bundle:nil];
		chooseViewController.chatroom_id = chatroom_id;
		
		UINavigationController * navController = (UINavigationController *)self.viewController;
		navController.viewControllers = @[wallViewController, chooseViewController];
		 */
	}
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
	application.applicationIconBadgeNumber = 0;
	/*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	if([PFUser currentUser] != nil)
		[self setupNotification];
	didBecomeActive = YES;
    
    [FBSession.activeSession handleDidBecomeActive];
	
	
}
-(void)applicationDidEnterBackground:(UIApplication *)application
{
	//[self removeNotifiction];

}

- (void)applicationWillResignActive:(UIApplication *)application;
{
}
// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [FBSession.activeSession close];
}

#pragma mark - PAWAppDelegate

- (void)setFilterDistance:(CLLocationAccuracy)aFilterDistance {
	filterDistance = aFilterDistance;

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setDouble:filterDistance forKey:defaultsFilterDistanceKey];
	[userDefaults synchronize];

	// Notify the app of the filterDistance change:
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:filterDistance] forKey:kPAWFilterDistanceKey];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kPAWFilterDistanceChangeNotification object:nil userInfo:userInfo];
	});
}

- (void)setCurrentLocation:(CLLocation *)aCurrentLocation {
	currentLocation = aCurrentLocation;

	// Notify the app of the location change:
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:currentLocation forKey:kPAWLocationKey];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kPAWLocationChangeNotification object:nil userInfo:userInfo];
	});
}

#pragma mark - CLLocationManagerDelegate methods and helpers

- (void)startStandardUpdates {
	if (nil == self.locationManager) {
		self.locationManager = [[CLLocationManager alloc] init];
	}
	
	self.locationManager.delegate = self;
	//locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// Set a movement threshold for new events.
	//locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
	//[locationManager requestWhenInUseAuthorization];
	if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
	{
		[self.locationManager requestWhenInUseAuthorization];
	}
	[self.locationManager startUpdatingLocation];
	
	CLLocation *_currentLocation = self.locationManager.location;
	if (_currentLocation) {
		currentLocation = _currentLocation;
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	switch (status) {
		case kCLAuthorizationStatusAuthorized:
			NSLog(@"kCLAuthorizationStatusAuthorized");
			break;
		case kCLAuthorizationStatusDenied:
			NSLog(@"kCLAuthorizationStatusDenied");
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Anywall can’t access your current location.\n\nTo view nearby posts or create a post at your current location, turn on access for Anywall to your location in the Settings app under Location Services." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
		}
			break;
		case kCLAuthorizationStatusNotDetermined:
			NSLog(@"kCLAuthorizationStatusNotDetermined");
			
			break;
		case kCLAuthorizationStatusRestricted:
			NSLog(@"kCLAuthorizationStatusRestricted");
			break;
	}
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	PFInstallation * installation = [PFInstallation currentInstallation];
	NSArray * channels = installation.channels;
	if (channels.count ==0) {
		[self setupNotification];
	}
	currentLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"Error: %@", [error description]);
	
	if (error.code == kCLErrorDenied) {
		[locationManager stopUpdatingLocation];
	} else if (error.code == kCLErrorLocationUnknown) {
		// todo: retry?
		// set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
		                                                message:[error description]
		                                               delegate:nil
		                                      cancelButtonTitle:nil
		                                      otherButtonTitles:@"Ok", nil];
		[alert show];
	}
}


- (void)presentWelcomeViewController {
	// Go to the welcome screen and have them log in or create an account.
	PAWGetStartVC *welcomeViewController = [[PAWGetStartVC alloc] initWithNibName:@"PAWGetStartVC" bundle:nil];
	//welcomeViewController.title = @"Welcome to Anywall";
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
	navController.navigationBarHidden = YES;
	self.viewController = navController;
	self.window.rootViewController = self.viewController;
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
	[self getAllSwearsFromParseDB];
	[self setupNotification];
}
- (void)networkChanged:(NSNotification *)notification
{
	
	NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
	
	if(remoteHostStatus == NotReachable) {
		if(self.isShowNetworkError)
			[self setNoNetworkView];
	}
	else
	{
		[self removeNetworkError];
		//[overlayVC dismissViewControllerAnimated:YES completion:nil];
	}
}
-(void)setNoNetworkView
{
	if(overlayVC == nil)
	{
		overlayVC = [[OverlayViewController alloc]init];
		overlayVC.view.frame = CGRectMake(0, 64, self.window.frame.size.width, overlayVC.view.frame.size.height);
	}
	[self.window addSubview:overlayVC.view];

}
-(void)removeNetworkError
{
	[overlayVC.view removeFromSuperview];

}

-(void)setupNotification
{
	/*
	 PFInstallation * installation = [PFInstallation currentInstallation];
	 [installation setObject:[PFUser currentUser] forKey:@"user"];
	 [installation saveInBackground];*/
	[self removeNotifiction];
	PFQuery * query = [PFQuery queryWithClassName:@"ChatRoom"];
	[query whereKeyExists:@"creator"];
	//query.limit = 100;
	
	
	
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		

		
		if (error) {
			NSLog(@"error in geo query! : %@", error);
			
		}
		else {
			for (PFObject * object in objects) {
				
				
				NSString * chatroom_id = [object objectId];
				PFGeoPoint * point = [object objectForKey:@"location"];
				CLLocation * chatroom_location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
				CLLocation * userLocation = [[CLLocation alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
				double distance = [userLocation distanceFromLocation:chatroom_location];
				
				NSInteger radius = [[object objectForKey:@"radius"] integerValue];
				//NSString *chatOwnerUsername = appDelegate.ChatOwner.username;
				NSString *ownerID = [[object objectForKey:@"creator"]objectId ];
				if (radius && distance > radius && ![ownerID isEqualToString:[[PFUser currentUser] objectId]]) {
				}
				else
				{
					PFInstallation * installation = [PFInstallation currentInstallation];

					NSString * channel = [NSString stringWithFormat:@"channel_%@", chatroom_id];
					[installation addObject:channel forKey:@"channels"];
					[installation saveInBackground];

				}
				
				
			}
		
			NSLog(@"rohit1185");

			//[self.mapView addAnnotation:userLocation];
			
			
		}

	}];
}

-(void)removeNotifiction
{
	PFInstallation * installation = [PFInstallation currentInstallation];
	NSArray * channels = installation.channels;
	if (channels) {
		[installation removeObjectsInArray:channels forKey:@"channels"];
		[installation saveInBackground];
	}
	
}

@end
