//
//  PAWAppDelegate.h
//

static NSUInteger const kPAWWallPostMaximumCharacterCount = 140;

static double const kPAWFeetToMeters = 0.3048; // this is an exact value.
static double const kPAWFeetToMiles = 5280.0; // this is an exact value.
static double const kPAWWallPostMaximumSearchDistance = 100.0;
static double const kPAWMetersInAKilometer = 1000.0; // this is an exact value.

static NSUInteger const kPAWWallPostsSearch = 20; // query limit for pins and tableviewcells

// Parse API key constants:
static NSString * const kPAWParsePostsClassKey = @"Posts";
static NSString * const kPAWParseUserKey = @"user";
static NSString * const kPAWParseUsernameKey = @"username";
static NSString * const kPAWParseFullnameKey = @"fullname";
static NSString * const kPAWParseTextKey = @"text";
static NSString * const kPAWParseLocationKey = @"location";
static NSString * const kPAWParseSwearsClassKey = @"swears";

// NSNotification userInfo keys:
static NSString * const kPAWFilterDistanceKey = @"filterDistance";
static NSString * const kPAWLocationKey = @"location";

// Notification names:
static NSString * const kPAWFilterDistanceChangeNotification = @"kPAWFilterDistanceChangeNotification";
static NSString * const kPAWLocationChangeNotification = @"kPAWLocationChangeNotification";
static NSString * const kPAWPostCreatedNotification = @"kPAWPostCreatedNotification";
static NSString * const kPAWEnterChatRoomNotification = @"kPAWEnterChatRoomNotification";
static NSString * const kPAWMessageReceivedNotification = @"kPAWMessageReceivedNotification";
static NSString * const kPAWEraseChatRoomNotification = @"kPAWEraseChatRoomNotification";
static NSString * const kPAWClickPhotoNotification = @"kPAWClickPhotoNotification";
static NSString * const kPAWShowImagesNotification = @"kPAWShowImagesNotification";

// UI strings:
static NSString * const kPAWWallCantViewPost = @"Can’t view post! Get closer.";

#define PAWLocationAccuracy double

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "Reachability.h"
#import "OverlayViewController.h"
@class PAWWelcomeViewController;

@interface PAWAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate> {
	BOOL didBecomeActive;
	PFUser *ChatOwner;
	OverlayViewController *overlayVC;
}
@property (strong, nonatomic) 	Reachability *reachability;
@property (strong, nonatomic) 	NSMutableArray *arrNotification;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;
@property (assign) BOOL isShowNetworkError;
@property (assign) int notifications;
@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, assign) CLLocationAccuracy filterDistance;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, retain) NSString * chatroom_id;
@property (nonatomic, retain) PFUser *ChatOwner;
@property (nonatomic, retain) PFUser *BussinessUserCreation;

@property (nonatomic, retain) NSString *agreementStr;
@property (assign) 	BOOL isSignout;

- (void)presentWelcomeViewController;
- (void)getAllSwearsFromParseDB;
-(void)setNoNetworkView;
-(void)removeNetworkError;
-(void)setupNotification;
-(void)removeNotifiction;
@end
