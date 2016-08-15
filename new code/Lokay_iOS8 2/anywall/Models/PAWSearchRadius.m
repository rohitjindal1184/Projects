//
//  PAWSearchRadius.m
//

#import "PAWSearchRadius.h"

@implementation PAWSearchRadius

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate radius:(CLLocationDistance)aRadius {
	self = [super init];
	if (self) {
		self.coordinate = aCoordinate;
		self.radius = aRadius;
	}
	return self;
}

- (MKMapRect)boundingMapRect {
	return MKMapRectWorld;
}

@end
