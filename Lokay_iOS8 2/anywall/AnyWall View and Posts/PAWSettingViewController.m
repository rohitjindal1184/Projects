//
//  PAWSettingViewController.m
//  lokay
//
//  Created by Rohit Jindal on 18/08/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import "PAWSettingViewController.h"
#import <Social/Social.h>

@interface PAWSettingViewController ()

@end

@implementation PAWSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)actionTerms:(id)sender {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Do you want to open terms in browser?" message:nil delegate:self cancelButtonTitle:@"Open" otherButtonTitles:@"Cancel", nil];
	alertView.tag = 100;
	[alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag == 100)
	{
		if (buttonIndex == 0) {
			NSString *Report_url=[NSString stringWithFormat:@"http://lokayme.com/Terms.html"];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:Report_url]];
		}
	}
	if(alertView.tag == 101)
	{
		if (buttonIndex == 0) {
			[self logoutUser];
		}
	}

}
- (IBAction)actionBack:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];

}
- (IBAction)actionFeedback:(id)sender {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
		controller.mailComposeDelegate = self;
		[controller setSubject:@"Lokay Feedback"];
		[controller setToRecipients:[[NSArray alloc] initWithObjects:@"support@lokayme.com", nil]];
		//[controller setMessageBody:@"Hello there." isHTML:NO];
		 [self presentViewController:controller animated:YES completion:nil];
	} else {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"You can not send mail because you did not set mail address on your phone." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alert show];

	}
}
- (IBAction)actionLogout:(id)sender {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log out of Lokay?" message:nil delegate:self cancelButtonTitle:@"Log out" otherButtonTitles:@"Cancel", nil];
	alertView.tag = 101;
	[alertView show];

	
}
-(void)logoutUser
{
	[PFUser logOut];
	
	PFInstallation * installation = [PFInstallation currentInstallation];
	[installation setObject:[NSNull null] forKey:@"user"];
	[installation saveInBackground];
	PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate removeNotifiction];
	[appDelegate presentWelcomeViewController];
}
- (IBAction)actionShareFB:(id)sender {
	if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Can not post card to facebook at the moment. Please confirm facebook login in setting." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alert show];
		return;
	}
	
	SLComposeViewController * facebookComposeSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
	
	NSString * strMsg = @"http://www.lokayme.com/";
	
	[facebookComposeSheet setInitialText:strMsg];
	
	[facebookComposeSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
		NSString * title = @"Facebook";
		NSString * msg;
		if (result == SLComposeViewControllerResultCancelled) {
		}
		else if (result == SLComposeViewControllerResultDone) {
			msg = @"Posted successfully!";
		}
		else {
			msg = @"";
		}
		
		if ([msg length]) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alert show];
		}
		
		[self dismissViewControllerAnimated:YES completion:nil];
	}];
	
	[self presentViewController:facebookComposeSheet animated:YES completion:nil];
}
- (IBAction)actionShareTwitter:(id)sender {
	if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:@"Can not post card to Twitter at the moment. Please confirm Twitter login in setting." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alert show];
		return;
	}
	
	SLComposeViewController * twitterComposeSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
	
	NSString * strMsg = @"http://www.lokayme.com/";
	
	[twitterComposeSheet setInitialText:strMsg];
	
	[twitterComposeSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
		NSString * title = @"Tweet";
		NSString * msg;
		if (result == SLComposeViewControllerResultCancelled) {
		}
		else if (result == SLComposeViewControllerResultDone) {
			msg = @"Posted successfully!";
		}
		else {
			msg = @"";
		}
		
		if ([msg length]) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alert show];
		}
		
		[self dismissViewControllerAnimated:YES completion:nil];
	}];
	
	[self presentViewController:twitterComposeSheet animated:YES completion:nil];
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Mail cancelled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail sent failure: %@", [error localizedDescription]);
			break;
		default:
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:NULL];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
