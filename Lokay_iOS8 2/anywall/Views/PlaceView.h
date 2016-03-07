//
//  PlaceView.h
//  lokay
//
//  Created by Rohit Jindal on 12/04/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceView : UIView
@property (nonatomic,weak)IBOutlet UILabel *name;
@property (nonatomic,weak)IBOutlet UILabel *desc;
@property (nonatomic,weak)IBOutlet UIButton	*btn;
+(PlaceView *) getView;

@end
