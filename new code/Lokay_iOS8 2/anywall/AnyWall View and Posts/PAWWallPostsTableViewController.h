//
//  PAWWallPostsTableViewController.h
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PAWWallViewController.h"

@interface PAWWallPostsTableViewController : PFQueryTableViewController <PAWWallViewControllerHighlight,UIGestureRecognizerDelegate>

- (void)highlightCellForPost:(PAWPost *)post;
- (void)unhighlightCellForPost:(PAWPost *)post;

@property (nonatomic, retain) NSString * chatroom_id;
@property (nonatomic, retain) PFObject *selecetdObject;

@end
