//
//  DropBoxFileView.m
//  lokay
//
//  Created by Mobile Programming on 4/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

#import "DropBoxFileView.h"

@implementation DropBoxFileView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(DropBoxFileView *) getView
{
	return [[[NSBundle mainBundle] loadNibNamed:@"DropBoxFileView"
										  owner:nil
										options:nil] lastObject];
}
-(void)setImage:(UIImage *)btnImage
{
	[self.btnImage setImage:btnImage forState:UIControlStateNormal];
}

-(void)setname:(NSString *)str
{
	self.lblName.text = str;
}
-(void)settag:(int)tag
{
	self.btnImage.tag = tag;
}

- (IBAction)selectphoto:(id)sender {
	UIButton *btn = (UIButton *)sender;
	if([btn currentImage])
	{
		[_delegate btnClicked:btn.tag];
	}
	
}

@end
