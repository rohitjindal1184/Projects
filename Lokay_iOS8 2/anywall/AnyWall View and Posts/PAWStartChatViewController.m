//
//  PAWStartChatViewController.m
//  LokayMe
//
//  Created by He Fei on 12/26/13.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAWStartChatViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import "PAWWallViewController.h"
#import "SBJSON.h"

#define ACTIVITY_VIEW_TAG		100
#define PICKER_VIEW_HEIGHT		162

@interface PAWStartChatViewController () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
	BOOL		_isSelectedPhoto;
    
    __weak IBOutlet UILabel *lblPinColor;
    enum PAWChatRoomRadius		_radius;
	
	CLLocationCoordinate2D		_coordinate;
}
- (IBAction)actionTime:(id)sender;

- (IBAction)actionOpenTime:(id)sender;
- (IBAction)dateChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;

@property (weak, nonatomic) IBOutlet UIImageView *imgPin;
@property (weak, nonatomic) IBOutlet UIDatePicker *ewDatePicker;
@property (weak, nonatomic) IBOutlet UITextField *txtdate;
- (IBAction)actionDone:(id)sender;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *btnCloseTime;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet PFImageView *photoImage;
@property (strong, nonatomic) IBOutlet UIView *pickerView;
@property (strong, nonatomic) IBOutlet UITextField *txtAddress;
@property (strong, nonatomic) IBOutlet UITextField *txtLokayCode;
@property (strong, nonatomic) IBOutlet UITextField *txtName;
@property (strong, nonatomic) IBOutlet UITextField *txtRadius;
@property (strong, nonatomic) IBOutlet UITextView *txtDesc;
@property (strong, nonatomic) IBOutlet UILabel *labelChoosePhoto;
@property (strong, nonatomic) IBOutlet UITextField *txtType;
@property (weak, nonatomic) IBOutlet UIButton *btnlokaycode;

@property (strong, nonatomic) IBOutlet UIView *radiusPickerContainer;
@property (strong, nonatomic) IBOutlet UIPickerView *radiusPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *typePickerView;

@property (weak, nonatomic) IBOutlet UIButton *btnaddress;

@property (strong, nonatomic) IBOutlet UIButton *btnDone;
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnOpenTime;

- (IBAction)onBack:(id)sender;
- (IBAction)onCreate:(id)sender;
- (IBAction)onDone:(id)sender;
- (IBAction)onSkip:(id)sender;
- (IBAction)onPhoto:(id)sender;
- (IBAction)onDidEndOnExit:(id)sender;

@end

@implementation PAWStartChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)actionaddress:(id)sender {
	if(_btnaddress.selected)
		return;
	
	_btnlokaycode.selected = NO;
	_btnaddress.selected = YES;
	_txtAddress.hidden = NO;
	_txtLokayCode.hidden = YES;

}
- (IBAction)actionLokay:(id)sender {
	if(_btnlokaycode.selected)
		return;
	_btnlokaycode.selected = YES;
	_btnaddress.selected = NO;
	_txtLokayCode.hidden = NO;
	_txtAddress.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.photoImage.layer.masksToBounds = YES;
	self.photoImage.layer.cornerRadius = 5.0f;
	
    self.txtDesc.layer.masksToBounds = YES;
	self.txtDesc.layer.cornerRadius = 5.0f;
	[self.txtAddress becomeFirstResponder];
	_isSelectedPhoto = NO;
    
    _radius = PAWChatRoomRadiusNoLimit;
    [self.txtRadius setText:@"No Limit"];
	
	//show loading view
	if(!_chatroom)
	{
	PAWActivityView *activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
	UILabel *label = activityView.label;
	label.text = @"Loading...";
	label.font = [UIFont boldSystemFontOfSize:20.f];
	[activityView.activityIndicator startAnimating];
	[activityView layoutSubviews];
	activityView.tag = ACTIVITY_VIEW_TAG;
	//[self.view addSubview:activityView];
	if(autoSuggestionView == nil)
	{
		autoSuggestionView = [AutoSuggestTableView getView];
		autoSuggestionView.frame = CGRectMake(_txtAddress.frame.origin.x, _txtAddress.frame.origin.y + _txtAddress.frame.size.height, _txtAddress.frame.size.width, 0);
		autoSuggestionView.delegate = self;
	}
	[self.scrollView addSubview:autoSuggestionView];
	[autoSuggestionView initiate:@""];
	}
	else{
		[self setChatroomValues];
	}
	PAWAppDelegate * appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[NSThread detachNewThreadSelector:@selector(getAddressFromLocation:) toTarget:self withObject:appDelegate.currentLocation];
	[self setViewforBussinees];
	mailGun = [Mailgun clientWithDomain:@"sandbox97000bf42754497cab804f769b916919.mailgun.org" apiKey:@"key-71587da92a97174674f9ceda35c6f223"];
	NSDate *date = [NSDate date];
	NSDateFormatter *formater = [[NSDateFormatter alloc]init];
	[formater setDateFormat:@"MM/dd/yyyy"];
	self.txtdate.text =[NSString stringWithFormat:@"     %@", [formater stringFromDate:date]];
	type = @"Red";

}
-(void)setChatroomValues
{
	_txtName.text = _chatroom.title;
	//_txtName.userInteractionEnabled = NO;
	_txtAddress.text = 	[NSString stringWithFormat:@"%@",[_chatroom.object objectForKey:@"address"]];
//	_txtAddress.userInteractionEnabled = NO;
	PFFile *theImage = [_chatroom.object objectForKey:@"photo"];
	NSLog(@"%@",theImage.url);
	
	if(theImage)
	{
		//NSDictionary * arguments = [NSDictionary dictionaryWithObjectsAndKeys:cell.chatRoomImage, @"imageView", theImage, @"photo", nil];
		//[NSThread detachNewThreadSelector:@selector(loadPhoto:) toTarget:self withObject:arguments];
		_photoImage.file = theImage;
		[_photoImage loadInBackground];
	}
	int strRadius = [[_chatroom.object objectForKey:@"radius"] intValue];
	if(strRadius == 0)
	{
		_txtRadius.text = @"No Limit";
	}
	else
	{
		_txtRadius.text = [NSString stringWithFormat:@"%d ft",strRadius];
	}
	//_txtRadius.userInteractionEnabled = NO;
	
	NSString *strType = [_chatroom.object objectForKey:@"type"];
	
	if([strType isEqualToString:@"Red"])
	{
		self.txtType.text = @"Bar";
		_imgPin.image = [UIImage imageNamed:@"redpin"];
	}
	else if([strType isEqualToString:@"Purple"])
	{
		self.txtType.text = @"Club";
		_imgPin.image = [UIImage imageNamed:@"purplepin"];

	}
	else if([strType isEqualToString:@"Green"])
	{
		self.txtType.text = @"Daytime Parties";
		_imgPin.image = [UIImage imageNamed:@"greenpin"];

	}
	else if([strType isEqualToString:@"Blue"])
	{
		self.txtType.text = @"Brunch";
		_imgPin.image = [UIImage imageNamed:@"bluepin"];

	}
	//self.txtType.userInteractionEnabled = NO;
	self.txtdate.text = [_chatroom.object objectForKey:@"date"];
	//self.txtdate.userInteractionEnabled = NO;
	
	[self.btnOpenTime setTitle:[_chatroom.object objectForKey:@"start_time"] forState:UIControlStateNormal];
	[self.btnCloseTime setTitle:[_chatroom.object objectForKey:@"close_time"] forState:UIControlStateNormal];
	self.txtDesc.text = [_chatroom.object objectForKey:@"description"];
	PFGeoPoint *point = [_chatroom.object objectForKey:@"location"];
	_coordinate.latitude = point.latitude;
	_coordinate.longitude = point.longitude;

}
-(void)setViewforBussinees
{
	if([[PFUser currentUser] objectForKey:@"bussiness_name"] != nil)
	{
		//lblPinColor.hidden = YES;
		//_txtType.hidden = YES;
		//_viewTime.hidden = NO;
	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	viewDisaaper = NO;
}
-(void)viewWillDisappear:(BOOL)animated
{
	viewDisaaper = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button methods
- (IBAction)onBack:(id)sender {
    [self dismissKeyboard];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCreate:(id)sender {
	NSString * errorText = nil;
	if ([self.txtAddress.text length] == 0 || (FEQUALZERO(_coordinate.latitude) && FEQUALZERO(_coordinate.longitude))) {
		errorText = @"Enter a valid address of chat room.";
	}
	else if ([self.txtName.text length] == 0) {
		errorText = @"Enter name";
	}
	else if ([self.txtType.text length] == 0) {
        errorText = @"Select pin color";
    }
    
	if (errorText) {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
														 message:errorText
														delegate:nil
											   cancelButtonTitle:@"Dismiss"
											   otherButtonTitles:nil, nil];
		[alert show];
		return;
	}
	if(!alertShowed)
	{
		alertShowed = YES;
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
													 message:@"Please wait 5 minutes to view build."
													delegate:self
										   cancelButtonTitle:@"Ok"
										   otherButtonTitles:nil, nil];
		alert.tag = 9;
	[alert show];
		return;
	}
	//Data Prep :
	PAWAppDelegate * appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSString * lokay_code = self.txtLokayCode.text;
	NSString * name = self.txtName.text;
	NSString * desc = self.txtDesc.text;
	NSData * imageData = nil;
	
	if (_isSelectedPhoto) {
		imageData = UIImageJPEGRepresentation(self.photoImage.image, 1.0f);
	}
	
	[self uploadChatRoomData:_coordinate
					 address:self.txtAddress.text
				  lokay_code:lokay_code
					  radius:_radius
                    pinColor:type
						name:name
				 description:desc
					   photo:imageData];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == 9)
	{
		[self onCreate:nil];
	}
}

- (IBAction)onSkip:(id)sender {
    
}

- (IBAction)onPhoto:(id)sender {
    [self dismissKeyboard];
	
	UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"Take Photo", @"Choose from Library",@"Pull From DropBox", nil];
    [actionsheet showInView:self.view];
}

- (IBAction)onDone:(id)sender {
    [self dismissKeyboard];
    [self hidePickerView];
}

#pragma mark - keyboard methods

- (void) scrollForTextField: (UIView *)textField {
    if (textField == self.txtAddress || textField == self.txtLokayCode) {
        [self.scrollView setContentOffset:CGPointMake(0, 0.5)  animated: YES];
    }
    else {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, textField.frame.origin.y - 80 )  animated: YES];
    }
    
    self.btnDone.hidden = NO;
    self.btnEdit.hidden = YES;
}

- (void) dismissKeyboard {
    [self.txtAddress resignFirstResponder];
    [self.txtLokayCode resignFirstResponder];
    [self.txtName resignFirstResponder];
    [self.txtDesc resignFirstResponder];
}

#pragma mark - text field delegate
- (IBAction)onDidEndOnExit:(UITextField *)sender {
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
    self.btnDone.hidden = YES;
    self.btnEdit.hidden = NO;
	
	if (textField == self.txtLokayCode) {
		NSString * lokay_code = self.txtLokayCode.text;
		NSRange range = [lokay_code rangeOfString:@"Lokay/"];
		if ([lokay_code length]
			&& range.location != 0) {
			self.txtLokayCode.text = [NSString stringWithFormat:@"Lokay/%@", lokay_code];
		}
	}
	else if (textField == self.txtAddress) {
		//show loading view
		
			[autoSuggestionView removeFromSuperview];
		
		PAWActivityView *activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
		UILabel *label = activityView.label;
		label.text = @"Loading...";
		label.font = [UIFont boldSystemFontOfSize:20.f];
		[activityView.activityIndicator startAnimating];
		[activityView layoutSubviews];
		activityView.tag = ACTIVITY_VIEW_TAG;
		[self.view addSubview:activityView];
		
		[NSThread detachNewThreadSelector:@selector(getAddressFromAddress:) toTarget:self withObject:textField.text];
	}
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
	_dateToolbar.hidden = YES;
    if (textField == self.txtRadius) {
        self.typePickerView.hidden = YES;
        self.radiusPickerView.hidden = NO;
		self.ewDatePicker.hidden = YES;

        [self dismissKeyboard];
        [self showPickerView];
        return NO;
    }
    else if (textField == self.txtType) {
        self.typePickerView.hidden = NO;
        self.radiusPickerView.hidden = YES;
		self.ewDatePicker.hidden = YES;

        [self dismissKeyboard];
        [self showPickerView];
        return NO;
    }
	else if (textField == self.txtAddress)
	{
		if(autoSuggestionView == nil)
		{
			autoSuggestionView = [AutoSuggestTableView getView];
			autoSuggestionView.frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y + textField.frame.size.height, textField.frame.size.width, 0);
			autoSuggestionView.delegate = self;
		}
		[self.scrollView addSubview:autoSuggestionView];
	}
	else if (textField == self.txtdate)
	{
		_dateToolbar.hidden = NO;
		self.typePickerView.hidden = YES;
		self.radiusPickerView.hidden = YES;
		self.ewDatePicker.hidden = NO;
		[self dismissKeyboard];
		[self showPickerView];
		return NO;
	}
	
    [self.scrollView setContentSize:CGSizeMake(320, SCREEN_HEIGHT - 65 + 216)];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	
    [self scrollForTextField:textField];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    [self.scrollView setContentSize:CGSizeMake(320, SCREEN_HEIGHT - 65 + 216)];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self scrollForTextField:textView];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSLog(@"string - %@",string);
	if([string isEqualToString:@"\n"])
		return YES;
	if(textField == self.txtAddress)
	{
		if([string isEqualToString:@""])
		{
			[autoSuggestionView chatacterChanged:[textField.text substringToIndex:textField.text.length - 1]];

		}
		else
		{
			[autoSuggestionView chatacterChanged:[NSString stringWithFormat:@"%@%@",textField.text,string]];
		}
	}
	return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
    self.btnDone.hidden = YES;
    self.btnEdit.hidden = NO;
}

#pragma mark - scroll view delegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView_ {
    if (![self getFirstResponser]) {
        [self.scrollView setContentSize:CGSizeMake(320, SCREEN_HEIGHT - 65)];
    }
}

- (id) getFirstResponser {
    id firstResponser = nil;
    if ([self.txtAddress isFirstResponder]) {
        firstResponser = self.txtAddress;
    }
    if ([self.txtLokayCode isFirstResponder]) {
        firstResponser = self.txtLokayCode;
    }
    if ([self.txtName isFirstResponder]) {
        firstResponser = self.txtName;
    }
    if ([self.txtDesc isFirstResponder]) {
        firstResponser = self.txtDesc;
    }
    return firstResponser;
}

#pragma mark - show / hide picker vie w
- (void) showPickerView {
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.radiusPickerContainer setFrame:CGRectMake(0, SCREEN_HEIGHT - PICKER_VIEW_HEIGHT - 44, SCREEN_WIDTH, PICKER_VIEW_HEIGHT + 44)];
                     }];
	
	self.btnDone.hidden = NO;
	self.btnEdit.hidden = YES;
}

- (void) hidePickerView {
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.radiusPickerContainer setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, PICKER_VIEW_HEIGHT+44)];
                     }];
	
	self.btnDone.hidden = YES;
	self.btnEdit.hidden = NO;
}

#pragma mark - picker view delegate
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 4;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.radiusPickerView) {
        switch (row) {
            case 0:
                return @"No Limit";
                break;
            case 1:
                return @"250 ft";
                break;
            case 2:
                return @"1000 ft";
                break;
            case 3:
                return @"4000 ft";
                break;
            default:
                break;
        }
    }
    else if (pickerView == self.typePickerView) {
        switch (row) {
            case 0:
                return @"Red - Bar";
                break;
            case 1:
                return @"Purple - Club";
                break;
            case 2:
                return @"Yellow - Brunch";
                break;
            case 3:
                return @"Blue - Daytime Parties";
                break;
            default:
                break;
        }
    }
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.radiusPickerView) {
        switch (row) {
            case 0:
                _radius = PAWChatRoomRadiusNoLimit;
                [self.txtRadius setText:@"No Limit"];
                break;
            case 1:
                _radius = PAWChatRoomRadiusSmall;
                [self.txtRadius setText:@"250 ft"];
                break;
            case 2:
                _radius = PAWChatRoomRadiusMedium;
                [self.txtRadius setText:@"1000 ft"];
                break;
            case 3:
                _radius = PAWChatRoomRadiusLarge;
                [self.txtRadius setText:@"4000 ft"];
                break;
            default:
                break;
        }
    }
    else if (pickerView == self.typePickerView) {
		[self.imgPin setImage:[UIImage imageNamed:[self getImage:row]]];
        switch (row) {
            case 0:
                //_radius = PAWChatRoomRadiusNoLimit;
                [self.txtType setText:@"Bar"];
				type = @"Red";
                break;
            case 1:
               // _radius = PAWChatRoomRadiusSmall;
                [self.txtType setText:@"Club"];
				type = @"Purple";

                break;
            case 2:
                //_radius = PAWChatRoomRadiusMedium;
                [self.txtType setText:@"Brunch"];
				type = @"Blue";

                break;
            case 3:
               // _radius = PAWChatRoomRadiusLarge;
                [self.txtType setText:@"Daytime Parties"];
				type = @"Green";

                break;
            default:
                break;
        }
    }
	[self hidePickerView];

}

#pragma mark - action sheet delegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[self onTakePhoto];
			break;
		case 1:
			[self onSelectPhoto];
			break;
		case 2:
			[self fromDropBox];
			break;
		default:
			break;
	}
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didDownloadFile:(NSString *)fileName didOverwriteFile:(BOOL)isLocalFileOverwritten {
	if (isLocalFileOverwritten == YES) {
		NSLog(@"Downloaded %@ by overwriting local file", fileName);
	} else {
		NSLog(@"Downloaded %@ without overwriting", fileName);
	}
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didFailToDownloadFile:(NSString *)fileName {
	NSLog(@"Failed to download %@", fileName);
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser fileConflictWithLocalFile:(NSURL *)localFileURL withDropboxFile:(DBMetadata *)dropboxFile withError:(NSError *)error {
	NSLog(@"File conflict between %@ and %@\n%@ last modified on %@\nError: %@", localFileURL.lastPathComponent, dropboxFile.filename, dropboxFile.filename, dropboxFile.lastModifiedDate, error);
}
- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didSelectFile:(DBMetadata *)file
{
	NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
	NSString *localPath = [documentsPath stringByAppendingPathComponent:browser.currentFileName];
	self.photoImage.image = [UIImage imageWithContentsOfFile:localPath];
	_isSelectedPhoto = YES;
	
	[self.labelChoosePhoto setHidden:YES];
	btnphoto.hidden = NO;
	
	[browser dismissViewControllerAnimated:YES completion:nil];

}
- (void)dropboxBrowserDismissed:(DropboxBrowserViewController *)browser {
	// This method is called after Dropbox Browser is dismissed. Do NOT dismiss DropboxBrowser from this method
	// Perform any UI updates here to display any new data from Dropbox Browser
	// ex. Update a UITableView that shows downloaded files or get the name of the most recently selected file:
	//     NSString *fileName = [DropboxBrowserViewController currentFileName];
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser deliveredFileDownloadNotification:(UILocalNotification *)notification {
	
}


-(void)fromDropBox
{
	DropboxBrowserViewController *dropboxBrowser = [[DropboxBrowserViewController alloc]init];
	
	dropboxBrowser.allowedFileTypes = @[@"png", @"jpg",@"jpeg"]; // Uncomment to filter file types. Create an array of allowed types. To allow all file types simply don't set the property
	// dropboxBrowser.tableCellID = @"DropboxBrowserCell"; // Uncomment to use a custom UITableViewCell ID. This property is not required
	
	// When a file is downloaded (either successfully or unsuccessfully) you can have DBBrowser notify the user with Notification Center. Default property is NO.
	 // dropboxBrowser.deliverDownloadNotifications = YES;
	
	// Dropbox Browser can display a UISearchBar to allow the user to search their Dropbox for a file or folder. Default property is NO.
	dropboxBrowser.shouldDisplaySearchBar = YES;
	
	// Set the delegate property to recieve delegate method calls
	dropboxBrowser.rootViewDelegate = self;
	
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:dropboxBrowser];

	//[self.navigationController pushViewController:nav animated:YES];
	[self presentViewController:nav animated:YES completion:nil];
}
- (void)onTakePhoto {
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
    
	controller.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [controller setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"Camera Not Available for This Device" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alertView show];
        
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)onSelectPhoto {
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
	controller.delegate = self;
    [controller setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [controller setMediaTypes:[NSArray arrayWithObject:(NSString*)kUTTypeImage]];
    controller.allowsEditing = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - image picker controller delegate
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    UIImage * image = [info objectForKey: UIImagePickerControllerOriginalImage];
	image = [self cropImage:image toRect:CGRectMake(0, 0, 500, 500)];
	self.photoImage.image = [self resizeImage:image toSize:CGSizeMake(500, 500)];
	_isSelectedPhoto = YES;
	[self dismissViewControllerAnimated:NO completion:nil];
    
    [self.labelChoosePhoto setHidden:YES];
	btnphoto.hidden = NO;
}

#pragma mark - manipulate photo methods
-(UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size
{
    float width = size.width;
    float height = size.height;
    
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    float widthRatio = image.size.width / width;
    float heightRatio = image.size.height / height;
    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    width = image.size.width / divisor;
    height = image.size.height / divisor;
    
    rect.size.width  = width;
    rect.size.height = height;
    
    if(height < width)
        rect.origin.y = height / 3;
    
    [image drawInRect: rect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}

- (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect  {
    
    CGSize size = image.size;
    if (size.width < size.height) {
        rect = CGRectMake(0, (size.height - size.width) / 2, size.width, size.width);
    }
    else {
        rect = CGRectMake((size.width - size.height) / 2, 0, size.height, size.height);
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height);
    
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    [image drawInRect:drawRect];
    
    UIImage * subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
}

#pragma mark - upload chat room data
- (void) uploadChatRoomData:(CLLocationCoordinate2D)location
					address:(NSString *)address
				 lokay_code:(NSString *)lokay_code
					 radius:(NSInteger)radius
                   pinColor:(NSString *)pinColor
					   name:(NSString *)name
				description:(NSString *)description
					  photo:(NSData *)photo {
	
	//Data perp :
	PFUser * user = [PFUser currentUser];
	PFGeoPoint * point = [PFGeoPoint geoPointWithLatitude:location.latitude longitude:location.longitude];
	
	//create chat room object to post
//cSpBf5dCR0
	PFObject * chatroom;
	if(!_chatroom)
		chatroom = [PFObject objectWithClassName:@"ChatRoom"];
	else
		chatroom = _chatroom.object;
	[chatroom setObject:user forKey:@"creator"];
	[chatroom setObject:point forKey:@"location"];
	[chatroom setObject:address forKey:@"address"];
	[chatroom setObject:lokay_code forKey:@"lokay_code"];
	[chatroom setObject:[NSNumber numberWithInteger:_radius] forKey:@"radius"];
    [chatroom setObject:pinColor forKey:@"type"];
	[chatroom setObject:name forKey:@"name"];
	[chatroom setObject:description forKey:@"description"];
	[chatroom setObject:self.txtdate.text forKey:@"date"];

	if([[PFUser currentUser] objectForKey:@"bussiness_name"] != nil)
	{
		[chatroom setObject:_btnCloseTime.titleLabel.text forKey:@"close_time"];
		[chatroom setObject:_btnOpenTime.titleLabel.text forKey:@"start_time"];

	}
	// Use PFACL to restrict future modifications to this object.
	PFACL *readOnlyACL = [PFACL ACL];
	[readOnlyACL setPublicReadAccess:YES];
	[readOnlyACL setPublicWriteAccess:YES];
	[chatroom setACL:readOnlyACL];
	
	PAWAppDelegate * appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.ChatOwner=user;
	
	if (photo) {
		PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:photo];
		[chatroom setObject:imageFile forKey:@"photo"];
	}
	
	//show loading view
	/*
	PAWActivityView *activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
	UILabel *label = activityView.label;
	label.text = @"Loading...";
	label.font = [UIFont boldSystemFontOfSize:20.f];
	[activityView.activityIndicator startAnimating];
	[activityView layoutSubviews];
	[self.view addSubview:activityView];
	*/
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
	HUD.labelText = @"Building Event...";
	HUD.detailsLabelText = @"Please Wait";
	//HUD.mode = MBProgressHUDModeAnnularDeterminate;
	[self.view addSubview:HUD];
	[HUD show:YES];
	
	[chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		//[activityView.activityIndicator stopAnimating];
		//[activityView removeFromSuperview];
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		if (error) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Start Screen : Save Chat Room" message:[[error userInfo] objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			return;
		}
		if (succeeded) {
			
			NSString * chatroom_id = [chatroom objectId];
			NSString *body = [NSString stringWithFormat:@"New Chat Created - %@ by - %@" ,[chatroom objectId],[[PFUser currentUser] username]];
			[mailGun sendMessageTo:@"LokeyMe <info@lokayme.com>"
							  from:@"New chat Reporter <alert@lokay.com>"
						   subject:@"New Chat Created!"
							  body:body];
			//send push to nearby user
			[self sendPushtoWithinRadius:_radius geoPoint:point title:name chatroom_id:chatroom_id];
			
			//save chat roon id as a channel
			/*
			PFInstallation * installation = [PFInstallation currentInstallation];
			NSArray * channels = installation.channels;
			if (channels) {
				[installation removeObjectsInArray:channels forKey:@"channels"];
				[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
					if (succeeded) {
						PAWWallViewController * viewController = [[PAWWallViewController alloc] initWithNibName:@"PAWWallViewController" bundle:nil];
						viewController.chatroom_id = chatroom_id;
						viewController.coordinate = _coordinate;
						viewController.mainTitle = name;
						viewController.subTitle = address;
						viewController.type = pinColor;
						[self.navigationController pushViewController:viewController animated:YES];
					}
					else {
						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Start Screen : Remove Channel" message:[[error userInfo] objectForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
						[alertView show];
					}
				}];
			}
			else {*/
				PAWWallViewController * viewController = [[PAWWallViewController alloc] initWithNibName:@"PAWWallViewController" bundle:nil];
				viewController.chatroom_id = chatroom_id;
				viewController.coordinate = _coordinate;
				viewController.mainTitle = name;
				viewController.subTitle = address;
				viewController.type = pinColor;
				[self.navigationController pushViewController:viewController animated:YES];
			//}
		} else {
			NSLog(@"Failed to save.");
		}
	}];
}

- (void) sendPushtoWithinRadius:(NSInteger)radius geoPoint:(PFGeoPoint *)point title:(NSString *)title chatroom_id:(NSString *)chatroom_id {
	
	if (!radius) {
		radius = 4000;
	}
	
	NSLog(@"point = (%.2f, %.2f)  chatroom id = %@", point.latitude, point.longitude, chatroom_id);
	
	PFQuery *innerQuery = [PFUser query];
	[innerQuery whereKey:@"email" notEqualTo:[[PFUser currentUser] objectForKey:@"email"]];
	[innerQuery whereKey:@"location" nearGeoPoint:point withinKilometers:radius / 1000];
	
	PFQuery *query = [PFInstallation query];
	[query whereKey:@"user" matchesQuery:innerQuery];
	
	// Send the notification.
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSString stringWithFormat:@"'%@' chatroom created nearby.", title], @"alert",
						  @1, @"badge",
						  chatroom_id, @"chatroom_id",
						  nil];
	PFPush *push = [[PFPush alloc] init];
	[push setQuery:query];
	[push setData:data];
	[push sendPushInBackground];
}

- (void) getAllChatRooms {
	
}

- (void) getAddressFromLocation:(CLLocation *)location {
    NSString * url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%.6f,%.6f&sensor=true", location.coordinate.latitude, location.coordinate.longitude];
    NSLog(@"url = %@", url);
    NSData * rcvData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	NSString * jsonString = [[NSString alloc] initWithData:rcvData encoding:NSStringEncodingConversionExternalRepresentation];
	SBJSON * parser = [[SBJSON alloc] init];
	NSDictionary * jsonData = [parser objectWithString:jsonString error:nil];
	NSArray * results = [jsonData objectForKey:@"results"];
	if ([results count]) {
		self.txtAddress.text = [[results firstObject] objectForKey:@"formatted_address"];
		_coordinate = location.coordinate;
	}
	
	UIView * view = [self.view viewWithTag:ACTIVITY_VIEW_TAG];
	if (view) [view removeFromSuperview];
}

- (void) getAddressFromAddress:(NSString *)param {
	geocoder = [[CLGeocoder alloc] init];
	[geocoder geocodeAddressString:param completionHandler:^(NSArray *placemarks, NSError *error)
	 {
		 if(!error)
		 {
			 CLPlacemark *placemark = [placemarks objectAtIndex:0];
			  _coordinate.latitude  = placemark.location.coordinate.latitude;
			 _coordinate.longitude=placemark.location.coordinate.longitude;
			 NSLog(@"%@",[NSString stringWithFormat:@"%@",[placemark description]]);
		 }
		 else
		 {
			 if(!_txtLokayCode.isFirstResponder && !viewDisaaper)
			 {
				 self.txtAddress.text = @"";
				 _coordinate.latitude = _coordinate.longitude = 0;
				 UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Input valid address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
				 [alert show];
			 }
		 }
	 }
	 ];
	UIView * view = [self.view viewWithTag:ACTIVITY_VIEW_TAG];
	if (view) [view removeFromSuperview];

	return;
    NSString * url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", param];
	url = [url stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
    NSLog(@"url = %@", url);
    NSData * rcvData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	NSString * jsonString = [[NSString alloc] initWithData:rcvData encoding:NSStringEncodingConversionExternalRepresentation];
	SBJSON * parser = [[SBJSON alloc] init];
	NSDictionary * jsonData = [parser objectWithString:jsonString error:nil];
	NSArray * results = [jsonData objectForKey:@"results"];
	if ([results count]) {
		self.txtAddress.text = [[results firstObject] objectForKey:@"formatted_address"];
		NSDictionary * dict = [[[results firstObject] objectForKey:@"geometry"] objectForKey:@"location"];
		_coordinate.latitude = [[dict objectForKey:@"lat"] doubleValue];
		_coordinate.longitude = [[dict objectForKey:@"lng"] doubleValue];
	}
	else {
		if(!_txtLokayCode.isFirstResponder && !viewDisaaper)
		{
		self.txtAddress.text = @"";
		_coordinate.latitude = _coordinate.longitude = 0;
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Input valid address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
		[alert show];
		}
	}
	
	//UIView * view = [self.view viewWithTag:ACTIVITY_VIEW_TAG];
	//if (view) [view removeFromSuperview];
}
-(void)placeSelected:(NSString *)place
{
	self.txtAddress.text = place;
	[self.txtAddress resignFirstResponder];
}
-(void)setField:(NSString *)place
{
	self.txtAddress.text = place;

}
- (IBAction)actionTime:(id)sender {
	openPicker = NO;
	[self openPicker];
}

- (IBAction)actionOpenTime:(id)sender {
	openPicker = YES;
	[self hidePickerView];
	[self openPicker];
}

- (IBAction)dateChanged:(id)sender {
	NSDate *date = self.ewDatePicker.date;
	NSDateFormatter *formater = [[NSDateFormatter alloc]init];
	[formater setDateFormat:@"MM/dd/yyyy"];
	self.txtdate.text =[NSString stringWithFormat:@"     %@", [formater stringFromDate:date]];
	
}
-(void)openPicker
{
	self.txtDesc.hidden = YES;
	self.lblDesc.hidden = YES;
	CGRect frame = _pickerView.frame;
	frame.origin.y = 0;
	[UIView animateWithDuration:0.3
						  delay:0.0
						options:UIViewAnimationCurveEaseOut
					 animations:^{
						 _pickerView.frame = frame;
					 }
					 completion:^(BOOL finished) {
					 }];
}
- (IBAction)actionDone:(id)sender {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"h:mm a"];
	NSString *time = [formatter stringFromDate:_datePicker.date];
	if(openPicker)
	{
		[_btnOpenTime setTitle:time forState:UIControlStateNormal];
	}
	else
	{
		[_btnCloseTime setTitle:time forState:UIControlStateNormal];

	}
	self.txtDesc.hidden = NO;
	self.lblDesc.hidden = NO;
	CGRect frame = _pickerView.frame;
	frame.origin.y = 568;
	[UIView animateWithDuration:0.3
						  delay:0.0
						options:UIViewAnimationCurveEaseOut
					 animations:^{
						 _pickerView.frame = frame;
					 }
					 completion:^(BOOL finished) {
					 }];
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
	UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 60)];

	if(pickerView == self.typePickerView)
	{
	UIImage *img = [UIImage imageNamed:[self getImage:row]];
	UIImageView *temp = [[UIImageView alloc] initWithImage:img];
	temp.frame = CGRectMake(-70, 10, 30, 37);
	[tmpView insertSubview:temp atIndex:0];
	}
	int x = pickerView == self.typePickerView?0:-20;
	int w = pickerView == self.typePickerView?200:110;

	UILabel *channelLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, -5, w, 60)];
	channelLabel.text = [NSString stringWithFormat:@"%@", [self pickerView:pickerView titleForRow:row forComponent:component]];
	channelLabel.textAlignment = pickerView == self.typePickerView?UITextAlignmentLeft:UITextAlignmentCenter;
	channelLabel.backgroundColor = [UIColor clearColor];
	
		[tmpView insertSubview:channelLabel atIndex:1];
	
	return tmpView;
	
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return (pickerView == self.typePickerView)?50:30;
}
-(NSString *)getImage:(int)row
{
	switch (row) {
		case 0:
			return @"redpin";
			break;
		case 1:
			return @"purplepin";
			break;
		case 2:
			return @"bluepin";
			break;
		case 3:
			return @"greenpin";
			break;
		default:
			break;
	}
return @"redpin";
}
- (IBAction)actionDatedone:(id)sender {
	[self onDone:sender];
}
- (IBAction)actionEnlargePhoto:(id)sender {
	if(_photoImage.image == nil)
	{
		return;
	}
	UIView *photoView = [[UIView alloc]initWithFrame:self.view.frame];
	UIButton *btnHidePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
	btnHidePhoto.frame = self.view.frame;
	[btnHidePhoto addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
	btnHidePhoto.backgroundColor = [UIColor blackColor];
	btnHidePhoto.alpha = 0.5;
	UIImageView *imgVW = [[UIImageView alloc]initWithImage:_photoImage.image];
	float width = imgVW.image.size.width;
	float hieght = imgVW.image.size.height;
	if(width > 320)
	{
		float f = (320/width);
		hieght = hieght * f;

		width = 320;
	}
	imgVW.frame = CGRectMake(0, 0, width, hieght);
	imgVW.center = photoView.center;
	[photoView addSubview:btnHidePhoto];
	[photoView addSubview:imgVW];
	imgVW.userInteractionEnabled = NO;
	[self.view addSubview:photoView];
	
	
	
}
-(void)closeView:(UIButton *)btn
{
	[btn.superview removeFromSuperview];
}
@end
