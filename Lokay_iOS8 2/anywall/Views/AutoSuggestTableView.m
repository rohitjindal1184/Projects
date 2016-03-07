//
//  AutoSuggestTableView.m
//  lokay
//
//  Created by Rohit Jindal on 11/04/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import "AutoSuggestTableView.h"
#define URl @"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Amoeba&types=geocode&location=37.76999,-122.44696&radius=500&key=AIzaSyBmpzw7m-ekMm9Ey0NYRZ13Cd1yTZTavz8"

@implementation AutoSuggestTableView
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)init {
	if( (self = [super init]) ) {
		
	
	}
	return self;
}
+(AutoSuggestTableView *) getView
{
	return [[[NSBundle mainBundle] loadNibNamed:@"AutoSuggestTableView"
										  owner:nil
										options:nil] lastObject];
}

-(void)setScrollVIew
{
	for (AutoSuggestTableView *vw in _scroll.subviews ) {
		[vw removeFromSuperview];
	}
	
	for (int j = 0; j < arrPlaces.count; j++) {
		NSDictionary *dic = [arrPlaces objectAtIndex:j];
		PlaceView *vw = [PlaceView getView];
		vw.frame = CGRectMake(0, 44*j, _scroll.frame.size.width, 44);
		NSString *str = [dic objectForKey:@"description"];
		
		NSString *strDesc = @"";
		NSArray *arr = [str componentsSeparatedByString:@","];
		if(arr.count > 0)
		{
			vw.name.text = [arr objectAtIndex:0];
			for (int i = 1; i < arr.count; i++) {
				if (i == 1) {
					strDesc = 	[strDesc stringByAppendingString:[NSString stringWithFormat:@"%@",[arr objectAtIndex:i]]];
				}
				else
					strDesc = 	[strDesc stringByAppendingString:[NSString stringWithFormat:@",%@",[arr objectAtIndex:i]]];
			}
			vw.desc.text = strDesc;;
		}
		if([dic objectForKey:@"vicinity"])
		{
		vw.name.text = [dic objectForKey:@"name"];
			vw.desc.text = [dic objectForKey:@"vicinity"];
		}
		vw.btn.tag = j;
		[vw.btn addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
		[_scroll addSubview:vw];
		
	}
	_scroll.contentSize = CGSizeMake(0,  arrPlaces.count * 44);
}
-(void)selected:(UIButton *)btn
{
	if([[arrPlaces objectAtIndex:btn.tag] objectForKey:@"vicinity"])
		[self.delegate placeSelected:[NSString stringWithFormat:@"%@, %@",[[arrPlaces objectAtIndex:btn.tag] objectForKey:@"name"],[[arrPlaces objectAtIndex:btn.tag] objectForKey:@"vicinity"]]];
	else
		[self.delegate placeSelected:[NSString stringWithFormat:@"%@",[[arrPlaces objectAtIndex:btn.tag] objectForKey:@"description"]]];
	
}
-(void)initiate:(NSString *)str
{
	PAWAppDelegate *pawApp = (PAWAppDelegate *)[[UIApplication sharedApplication]delegate];
	NSString *string = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&key=AIzaSyBmpzw7m-ekMm9Ey0NYRZ13Cd1yTZTavz8&rankby=distance&types=bar|restaurant|night_club|street_address|establishment",pawApp.currentLocation.coordinate.latitude,pawApp.currentLocation.coordinate.longitude];
	NSLog(@"URL -- %@",string);
	NSURL *url = [NSURL URLWithString:[string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];

	//NSURL *url = [NSURL URLWithString:string];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
 
	// 2
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	//operation.responseSerializer = [AFJSONResponseSerializer serializer];
 
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError* error;
		NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject
															options:kNilOptions
															  error:&error];
		NSLog(@"Dic -- %@",dic);
		//NSDictionary *dic = (NSDictionary *)responseObject;
		arrPlaces = [dic objectForKey:@"results"];
		int height = arrPlaces.count > 7 ? 44*7 : 44*arrPlaces.count;
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
		
		//tablesuggestion = [[UITableView alloc] init];
		[self setScrollVIew];
		if(arrPlaces.count)
			[self.delegate setField:[NSString stringWithFormat:@"%@, %@",[[arrPlaces objectAtIndex:0] objectForKey:@"name"],[[arrPlaces objectAtIndex:0] objectForKey:@"vicinity"]]];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0);
		arrPlaces = [[NSArray alloc]init];
		[self setScrollVIew];
		
	}];
 
	// 5
	[operation start];
}

-(void)chatacterChanged:(NSString *)str
{
	PAWAppDelegate *pawApp = (PAWAppDelegate *)[[UIApplication sharedApplication]delegate];
	NSString *string = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=establishment&&key=AIzaSyBmpzw7m-ekMm9Ey0NYRZ13Cd1yTZTavz8&radius=1000&location=%f,-%f",str,pawApp.currentLocation.coordinate.latitude,pawApp.currentLocation.coordinate.longitude];

	
	NSURL *url = [NSURL URLWithString:[string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
 
	// 2
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	//operation.responseSerializer = [AFJSONResponseSerializer serializer];
 
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError* error;
		NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject
															 options:kNilOptions
															   error:&error];

		//NSDictionary *dic = (NSDictionary *)responseObject;
		arrPlaces = [dic objectForKey:@"predictions"];
		int height = arrPlaces.count > 7 ? 44*7 : 44*arrPlaces.count;
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
		
		//tablesuggestion = [[UITableView alloc] init];
		[self setScrollVIew];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0);
		arrPlaces = [[NSArray alloc]init];
		[self setScrollVIew];
	
	}];
 
	// 5
	[operation start];
}
-(void)reloadData
{
	//[self.tablesuggestion reloadData];

}
- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
	if(arrPlaces.count > 5)
		return 5;
	return arrPlaces.count;
}
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *str = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
	UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
	cell.textLabel.text = [[arrPlaces objectAtIndex:indexPath.row]objectForKey:@"name"];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([[arrPlaces objectAtIndex:indexPath.row] objectForKey:@"vicinity"])
		[self.delegate placeSelected:[NSString stringWithFormat:@"%@, %@",[[arrPlaces objectAtIndex:indexPath.row] objectForKey:@"name"],[[arrPlaces objectAtIndex:indexPath.row] objectForKey:@"vicinity"]]];
	else
		[self.delegate placeSelected:[NSString stringWithFormat:@"%@",[[arrPlaces objectAtIndex:indexPath.row] objectForKey:@"description"]]];

}
@end
