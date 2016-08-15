//
//  PAWGetStartVC.m
//  lokay
//
//  Created by Rohit Jindal on 30/07/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import "PAWGetStartVC.h"

@implementation PAWGetStartVC

- (IBAction)getSatrt:(id)sender {
	
	[self presentWelcomeViewController];
}
- (void)presentWelcomeViewController {
	// Go to the welcome screen and have them log in or create an account.
	PAWWelcomeViewController *welcomeViewController = [[PAWWelcomeViewController alloc] initWithNibName:@"PAWWelcomeViewController" bundle:nil];
	welcomeViewController.title = @"Welcome to Anywall";
	
[self.navigationController pushViewController:welcomeViewController animated:NO];
}
-(void)viewDidLoad
{
	PAWAppDelegate *appDelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];

	if(appDelegate.isSignout)
	{
		[self presentWelcomeViewController];
	}
}
@end
