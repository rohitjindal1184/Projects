//
//  PAWViewController.h
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZBarSDK.h"

@interface PAWWelcomeViewController : UIViewController{
	ZBarReaderViewController *reader;

}
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (assign) BOOL isBack;

// - (IBAction)loginButtonSelected:(id)sender;
// - (IBAction)createButtonSelected:(id)sender;
- (IBAction)skipButtonSelected:(id)sender;
- (IBAction)loginButtonSelected:(id)sender;
- (IBAction)signupButtonSelected:(id)sender;
- (IBAction)forgotButtonSelected:(id)sender;
- (IBAction)facebook:(id)sender;
@end
