//
//  PAWWallPostCreateViewController.h
//

#import <UIKit/UIKit.h>

@interface PAWWallPostCreateViewController : UIViewController{
	UIView *agreeView;
}

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UILabel *characterCount;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *postButton;

@property (nonatomic, strong) NSString * chatroom_id;

- (IBAction)cancelPost:(id)sender;
- (IBAction)postPost:(id)sender;

@end
