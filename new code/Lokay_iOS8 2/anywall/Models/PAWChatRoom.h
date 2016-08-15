//
//  PAWPost.h
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface PAWChatRoom : NSObject <MKAnnotation>

//@protocol MKAnnotation <NSObject>

// Center latitude and longitude of the annotion view.
// The implementation of this property must be KVO compliant.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

// @optional
// Title and subtitle for use by selection UI.
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic,strong) PFUser *creator;
// @end

// Other properties:
@property (nonatomic, readonly, strong) PFObject *object;
@property (nonatomic, readonly, strong) PFGeoPoint *geopoint;
@property (nonatomic, assign) BOOL animatesDrop;
@property (nonatomic, readonly) MKPinAnnotationColor pinColor;

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) BOOL isUserLocation;
@property (nonatomic,assign) BOOL *isEventBrite;
@property (assign) float distance;


// Designated initializer.
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle andSubtitle:(NSString *)aSubtitle andcreator:(PFUser *)creator;
- (id)initWithPFObject:(PFObject *)object;
- (BOOL)equalToChatRoom:(PAWChatRoom *)aChatRoom;

- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside;
-(id)initWithEBObject:(NSDictionary *)object;
@end
