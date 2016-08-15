//
//  PAWForgotPwdViewController.h
//

#import <UIKit/UIKit.h>

@interface PAWForgotPwdViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *createButton;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITextField *mailaddressField;

@property (nonatomic, readwrite)    CGFloat animatedDistance;

- (IBAction)onDidEndOnExit:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
