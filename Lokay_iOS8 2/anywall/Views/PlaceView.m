//
//  PlaceView.m
//  lokay
//
//  Created by Rohit Jindal on 12/04/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import "PlaceView.h"

@implementation PlaceView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(PlaceView *) getView
{
	return [[[NSBundle mainBundle] loadNibNamed:@"PlaceView"
										  owner:nil
										options:nil] lastObject];
}

@end
