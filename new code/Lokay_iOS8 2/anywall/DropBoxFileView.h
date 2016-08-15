//
//  DropBoxFileView.h
//  lokay
//
//  Created by Mobile Programming on 4/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol btnclick
-(void)btnClicked:(int)tag;
@end

@interface DropBoxFileView : UIView
@property (weak, nonatomic) IBOutlet UIButton *btnImage;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) id <btnclick> delegate;
+(DropBoxFileView *) getView;
-(void)setname:(NSString *)str;
-(void)setImage:(UIImage *)btnImage;
-(void)settag:(int)tag;
- (IBAction)selectphoto:(id)sender;

@end
