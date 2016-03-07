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
// - (IBAction)loginButtonSelected:(id)sender;
// - (IBAction)createButtonSelected:(id)sender;
- (IBAction)loginButtonSelected:(id)sender;
- (IBAction)signupButtonSelected:(id)sender;
- (IBAction)forgotButtonSelected:(id)sender;
- (IBAction)facebook:(id)sender;
@end
