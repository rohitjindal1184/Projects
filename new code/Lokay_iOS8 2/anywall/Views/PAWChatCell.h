//
//  CDialogCell.h
//  MiRecipeShare
//
//  Created by Optiplex790 on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PAWWallViewController.h"

@interface CChatCell : UITableViewCell <AVAudioPlayerDelegate, UITextViewDelegate, ChatCellDelegate> {
    CChatViewController     * _parentVC;
    
    AVAudioPlayer           * _audioPlayer;
    NSTimer                 * _meterTimer;
    
    CGRect                  _rtPhoto;
}

@property (retain, nonatomic) IBOutlet UILabel *labelTime;
@property (retain, nonatomic) IBOutlet UILabel *labelExpire;
@property (retain, nonatomic) IBOutlet UILabel *labelName;
@property (retain, nonatomic) NSDictionary * dicData;
@property (retain, nonatomic) IBOutlet UIImageView *imageCha;
@property (retain, nonatomic) IBOutlet UIImageView *imageChaBack;

- (void) setCellData:(NSDictionary *)dic row:(int)row parnetVC:(CChatViewController*)parentVC_;

@end
