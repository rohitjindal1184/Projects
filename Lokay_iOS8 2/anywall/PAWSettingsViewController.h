//
//  PAWSettingsViewController.h
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface PAWSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,
MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSString * chatroom_id;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (IBAction)back:(id)sender;

// - (IBAction)done:(id)sender;

@end
