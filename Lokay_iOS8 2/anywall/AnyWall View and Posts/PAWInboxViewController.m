//
//  PAWInboxViewController.m
//  lokay
//
//  Created by Rohit Jindal on 06/05/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import "PAWInboxViewController.h"

@interface PAWInboxViewController ()

@end

@implementation PAWInboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	PAWAppDelegate *appdelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSLog(@"Array -- %@",appdelegate.arrNotification);
	return appdelegate.arrNotification.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PAWAppDelegate *appdelegate = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];

	static NSString *simpleTableIdentifier = @"SimpleTableCell";
	
	PAWInboxTableViewCell *cell = (PAWInboxTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	if (cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PAWInboxTableViewCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	PAWAppDelegate *appdelegate1 = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];

	[cell setupForNotification:[appdelegate.arrNotification objectAtIndex:indexPath.row]];
	for (PAWChatRoom *chatRoom in _arrChatRoom) {
		if([chatRoom.object.objectId isEqualToString:[[appdelegate1.arrNotification objectAtIndex:indexPath.row] objectForKey:@"chatroom_id"]])
		{
			//[[[UIAlertView alloc]initWithTitle:@"" message:@"Matched" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
			PFFile *theImage = [chatRoom.object objectForKey:@"photo"];
			cell.imgChatRoom.image = [UIImage imageWithData:[theImage getData]];
			//cell.imageView.frame = CGRectMake(272, 6, 42, 42);

		}
	}
	return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 55;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	PAWAppDelegate *appdelegate1 = (PAWAppDelegate *)[[UIApplication sharedApplication] delegate];

	PAWChatRoom * chatroom ;
	for (PAWChatRoom *chatRoom in _arrChatRoom) {
		if([chatRoom.object.objectId isEqualToString:[[appdelegate1.arrNotification objectAtIndex:indexPath.row] objectForKey:@"chatroom_id"]])
		{
			chatroom = chatRoom;
		}
	}
	NSLog(@"Char room %@", chatroom.object);
	appdelegate1.ChatOwner=[chatroom.object objectForKey:@"creator"];
	
	NSString * chatroom_id = [chatroom.object objectId];
	PFGeoPoint * point = [chatroom.object objectForKey:@"location"];
	CLLocation * chatroom_location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
	CLLocation * userLocation = [[CLLocation alloc] initWithLatitude:appdelegate1.currentLocation.coordinate.latitude longitude:appdelegate1.currentLocation.coordinate.longitude];
	double distance = [userLocation distanceFromLocation:chatroom_location];
	NSString * chatroom_name = [chatroom.object objectForKey:@"name"];
	NSString * chatroom_address = [chatroom.object objectForKey:@"address"];
	NSString * type = [chatroom.object objectForKey:@"type"];
	
	NSInteger radius = [[chatroom.object objectForKey:@"radius"] integerValue];
	//NSString *chatOwnerUsername = appDelegate.ChatOwner.username;
	NSString *ownerID = [appdelegate1.ChatOwner objectId];
	if (radius && distance > radius && ![ownerID isEqualToString:[[PFUser currentUser] objectId]]) {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
														 message:@"You can not enter chat room out of radius"
														delegate:nil
											   cancelButtonTitle:@"Ok"
											   otherButtonTitles:nil, nil];
		[alert show];
		return;
	}

	PAWWallViewController * viewController = [[PAWWallViewController alloc] initWithNibName:@"PAWWallViewController" bundle:nil];
	viewController.chatroom_id = chatroom_id;
	viewController.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude);
	viewController.mainTitle = chatroom_name;
	viewController.subTitle = chatroom_address;
	viewController.type = type;
	[self.navigationController pushViewController:viewController animated:YES];
	//}
}
@end
