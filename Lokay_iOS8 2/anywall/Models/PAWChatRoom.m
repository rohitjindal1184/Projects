//
//  PAWPost.m
//

#import "PAWChatRoom.h"
#import "PAWAppDelegate.h"

@interface PAWChatRoom ()

// Redefine these properties to make them read/write for internal class accesses and mutations.
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFGeoPoint *geopoint;
@property (nonatomic, assign) MKPinAnnotationColor pinColor;

@end

@implementation PAWChatRoom

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle andSubtitle:(NSString *)aSubtitle andcreator:(PFUser *)creator {
	self = [super init];
	if (self) {
		self.coordinate = aCoordinate;
		self.title = aTitle;
		self.subtitle = aSubtitle;
		self.animatesDrop = NO;
		self.creator = creator;
	}
	return self;
}

- (id)initWithPFObject:(PFObject *)anObject {
	self.isUserLocation = NO;
	self.object = anObject;
	self.geopoint = [anObject objectForKey:@"location"];

	[anObject fetchIfNeeded];
	CLLocationCoordinate2D aCoordinate = CLLocationCoordinate2DMake(self.geopoint.latitude, self.geopoint.longitude);
	CLLocation *locA = [[CLLocation alloc] initWithLatitude:self.geopoint.latitude longitude:self.geopoint.longitude];
	PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.distance = [locA distanceFromLocation:appDelegate.locationManager.location]/1609.344;
	NSString *aTitle = [anObject objectForKey:@"name"];
	NSString *aSubtitle = [anObject objectForKey:@"title"];
	PFUser *creator = [anObject objectForKey:@"creator"];
	PFObject *yy = [anObject objectForKey:@"creator"];
	return [self initWithCoordinate:aCoordinate andTitle:aTitle andSubtitle:aSubtitle andcreator:creator];
}
-(id)initWithEBObject:(NSDictionary *)object
{
	self.isEventBrite = YES;
	self.isUserLocation = NO;
	self.object = object;
	self.geopoint = [PFGeoPoint geoPoint];
	CLLocationCoordinate2D aCoordinate;
	if(![[object objectForKey:@"venue"] isEqual:[NSNull null]])
	{
	self.geopoint.latitude = [[[object objectForKey:@"venue"] objectForKey:@"latitude"] doubleValue];
	self.geopoint.longitude = [[[object objectForKey:@"venue"] objectForKey:@"longitude"] doubleValue];
	aCoordinate = CLLocationCoordinate2DMake(self.geopoint.latitude, self.geopoint.longitude);
		CLLocation *locA = [[CLLocation alloc] initWithLatitude:self.geopoint.latitude longitude:self.geopoint.longitude];
		PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.distance = [locA distanceFromLocation:appDelegate.locationManager.location]/1609.344;
	}
	NSString *aTitle;
	if(![[object objectForKey:@"name"] isEqual:[NSNull null]])
		aTitle = [[object objectForKey:@"name"] objectForKey:@"text"];
	NSString *aSubtitle;
	if(![[object objectForKey:@"description"] isEqual:[NSNull null]])
		 aSubtitle = [[object objectForKey:@"description"] objectForKey:@"text"];
	PFUser *creator = [[PFUser alloc]init];
	creator.username = @"EvenBrite";
	PFObject *yy = creator;
	return [self initWithCoordinate:aCoordinate andTitle:aTitle andSubtitle:aSubtitle andcreator:creator];
}
- (BOOL)equalToChatRoom:(PAWChatRoom *)aChatRoom {
	if (aChatRoom == nil) {
		return NO;
	}

	if (aChatRoom.object && self.object) {
		// We have a PFObject inside the PAWPost, use that instead.
		if ([aChatRoom.object.objectId compare:self.object.objectId] != NSOrderedSame) {
			return NO;
		}
		return YES;
	} else {
		// Fallback code:

		if ([aChatRoom.title compare:self.title] != NSOrderedSame ||
			[aChatRoom.subtitle compare:self.subtitle] != NSOrderedSame ||
			aChatRoom.coordinate.latitude != self.coordinate.latitude ||
			aChatRoom.coordinate.longitude != self.coordinate.longitude ) {
			return NO;
		}

		return YES;
	}
}

- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside {
	if (outside) {
		self.subtitle = nil;
		self.title = kPAWWallCantViewPost;
		self.pinColor = MKPinAnnotationColorPurple;
	} else {
		self.title = [self.object objectForKey:kPAWParseTextKey];
		self.subtitle = [[self.object objectForKey:kPAWParseUserKey] objectForKey:kPAWParseUsernameKey];
		self.pinColor = MKPinAnnotationColorRed;
	}
}

@end
