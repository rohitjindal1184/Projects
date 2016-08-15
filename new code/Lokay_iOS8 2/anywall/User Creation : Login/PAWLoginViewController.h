//
//  PAWLoginViewController.h
//

#import <UIKit/UIKit.h>
#import "PAWActivityView.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PAWAppDelegate.h"
@interface PAWLoginViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *signinButton;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)facebook:(id)sender;
- (IBAction)twitter:(id)sender;

- (IBAction)onDidEndOnExit:(id)sender;

@end
