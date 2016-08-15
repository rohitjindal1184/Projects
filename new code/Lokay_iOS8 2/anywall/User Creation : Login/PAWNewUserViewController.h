//
//  PAWNewUserViewController.h
//

#import <UIKit/UIKit.h>
#import "Mailgun.h"
@interface PAWNewUserViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>
{
	BOOL isBussiness;
	Mailgun *mailGun;
	
}

@property (strong, nonatomic) IBOutlet UIButton *createButton;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *mailaddressField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UITextField *passwordAgainField;

@property (weak, nonatomic) IBOutlet UITextField *txtBusinessName;
@property (nonatomic, readwrite)    CGFloat animatedDistance;
@property (weak, nonatomic) IBOutlet UITextField *BpasswordAgainField;
@property (weak, nonatomic) IBOutlet UITextField *BpasswordField;
@property (weak, nonatomic) IBOutlet UITextField *BPNo;

@property (weak, nonatomic) IBOutlet UITextField *BmailaddressField;
@property (weak, nonatomic) IBOutlet UITextField *location;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;


@property (weak, nonatomic) IBOutlet UIView *personalView;
@property (weak, nonatomic) IBOutlet UIView *businessView;

- (IBAction)segmentChanged:(id)sender;
- (IBAction)onDidEndOnExit:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
