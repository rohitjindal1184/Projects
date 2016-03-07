//
//  PAWPhotoViewController.m
//  LokayMe
//
//  Created by He Fei on 1/6/14.
//  Copyright (c) 2014 Parse. All rights reserved.
//

#import "PAWPhotoViewController.h"
#import "PAWActivityView.h"
#import "RIButtonItem.h"
@interface PAWPhotoViewController () <UIAlertViewDelegate> {
	int pageVisible;

}

@property (strong, nonatomic) IBOutlet UIImageView *imagePhoto;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (strong,nonatomic) NSMutableArray *allPosts;
@property (weak, nonatomic) IBOutlet UIButton *btnReport;
@property (weak, nonatomic) IBOutlet UIButton *btnEnterChat;
@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
- (IBAction)onBack:(id)sender;
- (IBAction)onSave:(id)sender;

@end

@implementation PAWPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)forwardSwap:(id)sender {
	pageVisible++;
	[_scroll setContentOffset:CGPointMake(_scroll.frame.size.width*pageVisible, 0.0f) animated:YES];

}
- (IBAction)backwardSwap:(id)sender {
	pageVisible--;
	[_scroll setContentOffset:CGPointMake(_scroll.frame.size.width*pageVisible, 0.0f) animated:YES];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   // CGRect frame = CGRectMake(0, 64 + (SCREEN_HEIGHT - 64 - SCREEN_WIDTH) / 2, SCREEN_WIDTH, SCREEN_WIDTH);
  //  [self.imagePhoto setFrame:frame];
	self.allPosts = [[NSMutableArray alloc]init];
    [NSThread detachNewThreadSelector:@selector(loadPhoto) toTarget:self withObject:nil];
	if (_scrolling) {
		
		_btnSave.hidden = YES;
	}
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showbutton:)];
	[_scroll addGestureRecognizer:singleTap];
	_lblDesc.text = [self.chatroom.object objectForKey:@"description"];
	_lblAddress.text = [self.chatroom.object objectForKey:@"address"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSave:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:Nil
                                                     message:@"Do you want to save this photo to your camera roll?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Cancel", @"Save", nil];
    [alert setTag:100];
    [alert show];
}

- (IBAction)showbutton:(id)sender {
	
	
	if (_scrolling) {
		
		if(_btnEnterChat.hidden)
		{
		_btnEnterChat.hidden = NO;
		_btnReport.hidden = NO;
		}
		else
		{
			_btnEnterChat.hidden = YES;
			_btnReport.hidden = YES;
		}
	}
}

- (void) loadPhoto {
    NSData * data = [self.photo getData];
    self.imagePhoto.image = [UIImage imageWithData:data];
	if(_scrolling)
		[self queryForAllPosts:self.chatRoomID];
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        switch (buttonIndex) {
            case 1:
                [self savePhoto];
                break;
                
            default:
                break;
        }
    }
}
- (void)queryForAllPosts:(NSString *)chatroom_id {
	PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
	[query whereKey:@"chatroom_id" equalTo:chatroom_id];
	[query orderByDescending:@"createdAt"];
	query.limit = 50;
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (error) {} else {
			[_allPosts removeAllObjects];
			[_allPosts addObject:self.photo];
			for (PFObject *object in objects) {
				PFFile *theImage = [object objectForKey:@"photo"];
				if(theImage)
				{
					[self.allPosts addObject:theImage];
				}
			}
			[self setScrollView];
		}
	}];
}
- (IBAction)EneterChat:(id)sender {
	[self.navigationController popViewControllerAnimated:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"gotoDetail" object:self.chatroom];

}
- (IBAction)ReportAbuse:(id)sender {
	
	[[[UIAlertView alloc] initWithTitle:@"Report Abuse?"
								message:@"Are you sure you want to report this post as abuse?"
					   cancelButtonItem:[RIButtonItem itemWithLabel:@"Yes" action:^{
		
		PFQuery *query = [PFQuery queryWithClassName:@"ChatRoom"];
		
		// Retrieve the object by id
		[query getObjectInBackgroundWithId:_chatRoomID block:^(PFObject *object, NSError *error) {
			
			object[@"is_spam"] = @YES;
			object[@"reportedBy"] = [PFUser currentUser];
			
			[object saveInBackground];
			
			NSString *body = [NSString stringWithFormat:@"Report Abuse chat room - %@ , Reporter - %@",_chatRoomID,[[PFUser currentUser] username]];
			[mailGun sendMessageTo:@"LokeyMe <info@lokayme.com>"
							  from:@"Abuse Reporter <alert@lokay.com>"
						   subject:@"Report Abuse!"
							  body:body];
			
			NSString *message = [NSString stringWithFormat:@"This Chat Room is report as abused."];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lokay!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alert show];
		}];
	}]
					   otherButtonItems:[RIButtonItem itemWithLabel:@"No" action:^{
		// Handle "Delete"
	}], nil] show];
	
	
	
}
-(void)setScrollView
{
	for (id vw in _scroll.subviews) {
		if(![vw isKindOfClass:[UIButton class]]){
		[vw removeFromSuperview];
		}
	}
	int i = 0;
	for (PFFile *file in _allPosts) {
		UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(self.imagePhoto.frame.size.width*i, 0, self.imagePhoto.frame.size.width, self.imagePhoto.frame.size.height)];
		[_scroll addSubview:imgView];
		
	//	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	//	[btn addTarget:self action:@selector(showbutton:) forControlEvents:UIControlEventTouchDragInside];
		//btn.frame = imgView.frame;
	//	[_scroll addSubview:btn];
		
		[self loadPhoto:file in:imgView ];
		i++;
		
	}
	_scroll.contentSize = CGSizeMake(self.imagePhoto.frame.size.width * i, 0);
	_scroll.scrollEnabled = YES;
	if(_allPosts.count > 1)
	{
		_btnRight.hidden = NO;
	}
	[_scroll bringSubviewToFront:_btnRight];
	[_scroll bringSubviewToFront:_btnLeft];
}
-(void)loadPhoto:(PFFile *)file in:(UIImageView *)imgView
{
	NSData * data = [file getData];
	imgView.image = [UIImage imageWithData:data];

}
- (void) savePhoto {
    //show loading view
	PAWActivityView *activityView = [[PAWActivityView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
	UILabel *label = activityView.label;
	label.text = @"Loading...";
	label.font = [UIFont boldSystemFontOfSize:20.f];
	[activityView.activityIndicator startAnimating];
	[activityView layoutSubviews];
	activityView.tag = 1000;
	[self.view addSubview:activityView];
	
    UIImageWriteToSavedPhotosAlbum(self.imagePhoto.image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)savedPhotoImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	PAWActivityView * activityView = (PAWActivityView *)[self.view viewWithTag:1000];
	if (activityView) {
		[activityView.activityIndicator stopAnimating];
		[activityView removeFromSuperview];
	}
    if (error == nil) {
        [self.btnSave setHidden:YES];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                         message:[[error userInfo] description] delegate:nil cancelButtonTitle:@"Dismiss"
                                               otherButtonTitles:nil, nil];
        [alert show];
    }
}
#pragma mark - UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	int page = scrollView.contentOffset.x / scrollView.frame.size.width;
	if(page == 0)
	{
		_btnLeft.hidden = YES;
	}
	else
	{
		_btnLeft.hidden = NO;
	}
	if(page < _allPosts.count - 1)
	{
		_btnRight.hidden = NO;
	}
	else
	{
		_btnRight.hidden = YES;
	}
	pageVisible = page;
}
@end
