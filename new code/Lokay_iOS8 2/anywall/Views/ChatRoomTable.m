//
//  ChatRoomTable.m
//  lokay
//
//  Created by Rohit Jindal on 10/08/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import "ChatRoomTable.h"
#import "PAWChatRoom.h"

@implementation ChatRoomTable

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (void)awakeFromNib {
	//self.backgroundColor = [UIColor greenColor];
	arrPlaces = @[@"Bar",@"Brunches",@"Clubs",@"Day Parties"];
	self.selectionList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
	self.selectionList.delegate = self;
	self.selectionList.dataSource = self;
	[self addSubview:self.selectionList];

	
}
#pragma Mark - UITableViewDelegate
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(!self.arrChatRoom)
		return 0;
	return self.arrChatRoom.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *simpleTableIdentifier = @"Cell";
	
	ChatRoomTableViewCell *cell ;
	cell = (ChatRoomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	if (cell == nil)
	{
		cell = [[[NSBundle mainBundle] loadNibNamed:@"ChatRoomTableViewCell" owner:self options:nil] objectAtIndex:0];
	}
	PAWChatRoom *chatRoom = [self.arrChatRoom objectAtIndex:0];
	cell.lblName.text = chatRoom.title;
	cell.lblAddress.text = 		cell.lblType.text = [NSString stringWithFormat:@"%@",[chatRoom.object objectForKey:@"address"]];
	PFFile *theImage = [chatRoom.object objectForKey:@"photo"];
	if(theImage)
	{
	NSDictionary * arguments = [NSDictionary dictionaryWithObjectsAndKeys:cell.chatRoomImage, @"imageView", theImage, @"photo", nil];
	[NSThread detachNewThreadSelector:@selector(loadPhoto:) toTarget:self withObject:arguments];
	}
	NSString * pinColor = [chatRoom.object objectForKey:@"type"];
	if ([pinColor isEqualToString:@"Blue"]) {
		cell.lblType.text = [NSString stringWithFormat:@"Restaurant - %1.2f miles",chatRoom.distance];
	}
	else if ([pinColor isEqualToString:@"Green"]) {
		cell.lblType.text = [NSString stringWithFormat:@"Bar - %1.2f miles",chatRoom.distance];
	}
	else if ([pinColor isEqualToString:@"Red"]) {
		cell.lblType.text = [NSString stringWithFormat:@"Social - %1.2f miles",chatRoom.distance];
	}
	else if ([pinColor isEqualToString:@"Purple"]) {
		cell.lblType.text = [NSString stringWithFormat:@"Event - %1.2f miles",chatRoom.distance];
	}
	cell.btnImage.tag = indexPath.row;
	cell.btnReport.tag = indexPath.row;
	cell.chatroom = chatRoom;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 150;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PAWChatRoom *chatRoom = [self.arrChatRoom objectAtIndex:indexPath.row];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"gotoDetail" object:chatRoom];

	
}
+(ChatRoomTable *) getView
{
	return [[[NSBundle mainBundle] loadNibNamed:@"ChatRoomTable"
										  owner:nil
										options:nil] lastObject];
}

-(void)reloadTable
{
	self.tableChat.frame = CGRectMake(0, 0, 320, 470);

	[self.tableChat reloadData];
}
- (void) loadPhoto:(NSDictionary *)arguments {
	UIImageView * imageView = [arguments objectForKey:@"imageView"];
	PFFile * photo = [arguments objectForKey:@"photo"];
	imageView.image = [UIImage imageWithData:[photo getData]];
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
	return arrPlaces.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
	return arrPlaces[index];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
	// update the view for the corresponding index
	//self.selectedItemLabel.text = self.carMakes[index];
}


@end
