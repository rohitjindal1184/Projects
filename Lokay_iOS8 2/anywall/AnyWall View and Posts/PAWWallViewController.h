//
//  PAWWallViewController.h
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "PAWPost.h"

@interface PAWWallViewController : UIViewController

@property (nonatomic, retain) NSString * chatroom_id;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString * mainTitle;
@property (nonatomic, retain) NSString * subTitle;
@property (nonatomic, retain) NSString * type;

@end

@protocol PAWWallViewControllerHighlight <NSObject>

- (void)highlightCellForPost:(PAWPost *)post;
- (void)unhighlightCellForPost:(PAWPost *)post;

@end
