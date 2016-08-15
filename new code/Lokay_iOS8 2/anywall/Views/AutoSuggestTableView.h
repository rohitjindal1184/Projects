//
//  AutoSuggestTableView.h
//  lokay
//
//  Created by Rohit Jindal on 11/04/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "PlaceView.h"
#import "PAWAppDelegate.h"
@protocol PlaceSelected<NSObject>
-(void)placeSelected:(NSString *)place;
-(void)reloadTable;
-(void)setField:(NSString *)place;
@end
@interface AutoSuggestTableView : UIView 
{
	NSArray *arrPlaces;
}
@property (nonatomic,strong) IBOutlet UIScrollView *scroll;
@property (nonatomic,strong)  id<PlaceSelected> delegate;
-(void)initiate:(NSString *)str;
-(void)chatacterChanged:(NSString *)str;
+(AutoSuggestTableView *) getView;
@end
