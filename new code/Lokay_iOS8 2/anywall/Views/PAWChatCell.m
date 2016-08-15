//
//  CDialogCell.m
//  MiRecipeShare
//
//  Created by Optiplex790 on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PAWChatCell.h"

#define PHOTO_BACK_TAG      20
#define PLAY_BTN_TAG        21
#define PROGRESS_TAG        22

@implementation CChatCell

@synthesize dicData;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) dealloc {
    [dicData release];
    [_labelTime release];
    [_imageCha release];
    
    if (_audioPlayer) {
        [_audioPlayer stop];
        [_audioPlayer release];
    }
    
    [_labelExpire release];
    [_labelName release];
    [_imageChaBack release];
    [super dealloc];
}

- (void) setCellData:(NSDictionary *)dic row:(int)row parnetVC:(CChatViewController*)parentVC_ {
    _dataKeeper  = [DataKeeper sharedInstance];
    _delegate = APPDELEGATE;
    _parentVC = parentVC_;
    
    float iPadWidthOffset = 0;
    
    self.dicData = dic;
    
    NSString * stringBackground = @"chat_cell_background.png";
    
    if ([_dataKeeper.name isEqualToString:[dic objectForKey:@"username"]]) {
        self.imageCha.image = [UIImage imageNamed:@"chat_default_cha0.png"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            stringBackground = @"chat_cell_background0-iPad.png";
        }
    }
    else {
        
        self.imageCha.image = [UIImage imageNamed:@"chat_default_cha1.png"];
        
        if (!isPhone) {
            self.imageCha.center = CGPointMake(self.frame.size.width - self.imageCha.center.x, self.imageCha.center.y);
            self.imageChaBack.center = CGPointMake(self.frame.size.width - self.imageChaBack.center.x, self.imageChaBack.center.y);
            self.labelName.center = CGPointMake(self.frame.size.width - self.labelName.center.x, self.labelName.center.y);
            stringBackground = @"chat_cell_background1-iPad.png";
            iPadWidthOffset = 74;
        }
    }
    
    _rtPhoto = isPhone ? CGRectMake(81, 13, 221, 148) : CGRectMake(97 + iPadWidthOffset, 13, 313, 216);
    
    UIImage * backgroundImage = [[UIImage imageNamed:stringBackground] stretchableImageWithLeftCapWidth:150 topCapHeight:40];
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:self.frame];
    imageView.image = backgroundImage;
    self.backgroundView = imageView;
    
    if (!_parentVC.isAnonymous) {
        [NSThread detachNewThreadSelector:@selector(getAvatar:) toTarget:self withObject:[self.dicData objectForKey:@"avatar"]];
    }
    
    if (_parentVC.isGroupChat) {
        NSString * username = [self.dicData objectForKey:@"username"];
        NSArray * temp = [username componentsSeparatedByString:@" "];
        if ([temp count] > 0) {
            username = [NSString stringWithFormat:@"%@ %@", [temp objectAtIndex:0], [[temp objectAtIndex:1] substringToIndex:1]];
        }
        self.labelName.text = username;
    }
    
    NSString * type = [self.dicData objectForKey:@"type"];
    if ([type isEqualToString:@"msg"]) {
        
        NSString * unicodeString = [dic objectForKey:@"contents"];
        NSData * data = [unicodeString dataUsingEncoding:NSUTF8StringEncoding];
        NSString * message = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        int messageFont = 15;
        
        float width = isPhone ? 240 : 328;
        
        CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:messageFont]
                                constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
        
        float height = (_parentVC.isGroupChat) ? MAX(size.height + 3.0f, 35.0f) : MAX(size.height + 3.0f, 20.0f);
        
        CGRect rt = isPhone ? CGRectMake(75, 7, width + 16, height) : CGRectMake(93 + iPadWidthOffset, 7, width + 16, height);
        
        UITextView * textView = [[UITextView alloc] initWithFrame:rt];
        textView.editable = NO;
        textView.scrollEnabled = NO;
        textView.contentInset = UIEdgeInsetsMake(-8, -8, -8, -8);
        textView.backgroundColor = [UIColor clearColor];
        textView.font = [UIFont systemFontOfSize:messageFont];
        textView.text = message;
        textView.dataDetectorTypes = UIDataDetectorTypeAll;
        [textView setDelegate:self];
        [self addSubview:textView];
        [textView release];
                
        [self.labelTime setFrame:CGRectMake(self.labelTime.frame.origin.x + iPadWidthOffset, height + 10, self.labelTime.frame.size.width, self.labelTime.frame.size.height)];
        
        [self.labelExpire setFrame:CGRectMake(self.labelExpire.frame.origin.x + iPadWidthOffset, height + 10, self.labelExpire.frame.size.width, self.labelExpire.frame.size.height)];
                
        [message release];
    }
    else if ([type isEqualToString:@"photo"]) {
        
        CGRect rtBack = isPhone ? CGRectMake(75, 7, 233, 160) : CGRectMake(91 + iPadWidthOffset, 7, 325, 228);
        CGSize photoSize = _rtPhoto.size;
        float height = isPhone ? 164.0f : 232;
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:rtBack];
        imageView.image = [[UIImage imageNamed:@"chat_cell_photo_back.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        imageView.tag = PHOTO_BACK_TAG;
        [self addSubview:imageView];
        [imageView release];
        
        UIActivityIndicatorView * indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.center = CGPointMake(_rtPhoto.origin.x + photoSize.width / 2, _rtPhoto.origin.y + photoSize.height / 2);
        [indicator startAnimating];
        [self addSubview:indicator];
        [indicator release];
        
        [self.labelTime setFrame:CGRectMake(self.labelTime.frame.origin.x + iPadWidthOffset, height + 10, self.labelTime.frame.size.width, self.labelTime.frame.size.height)];
        
        [self.labelExpire setFrame:CGRectMake(self.labelExpire.frame.origin.x + iPadWidthOffset, height + 10, self.labelExpire.frame.size.width, self.labelExpire.frame.size.height)];
                
        NSString * image_link = [self.dicData objectForKey:@"thumb"];
        [NSThread detachNewThreadSelector:@selector(getPhotoImage:) toTarget:self withObject:image_link];
    }
    else if ([type isEqualToString:@"video"]) {
        CGRect rtBack = isPhone ? CGRectMake(75, 7, 233, 160) : CGRectMake(91 + iPadWidthOffset, 7, 325, 228);
        CGSize photoSize = _rtPhoto.size;
        float height = isPhone ? 164.0f : 232;
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:rtBack];
        imageView.image = [[UIImage imageNamed:@"chat_cell_photo_back.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        imageView.tag = PHOTO_BACK_TAG;
        [self addSubview:imageView];
        [imageView release];
        
        UIActivityIndicatorView * indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.center = CGPointMake(_rtPhoto.origin.x + photoSize.width / 2, _rtPhoto.origin.y + photoSize.height / 2);
        [indicator startAnimating];
        [self addSubview:indicator];
        [indicator release];
        
        [self.labelTime setFrame:CGRectMake(self.labelTime.frame.origin.x + iPadWidthOffset, height + 10, self.labelTime.frame.size.width, self.labelTime.frame.size.height)];
        
        [self.labelExpire setFrame:CGRectMake(self.labelExpire.frame.origin.x + iPadWidthOffset, height + 10, self.labelExpire.frame.size.width, self.labelExpire.frame.size.height)];
        
        
        NSString * image_link = [self.dicData objectForKey:@"thumb"];
        [NSThread detachNewThreadSelector:@selector(getPhotoImage:) toTarget:self withObject:image_link];
    }
    else if ([type isEqualToString:@"audio"]) {
        float height = 50.0f;
        CGRect rtButton = isPhone ? CGRectMake(75, 10, 40, 40) : CGRectMake(91 + iPadWidthOffset, 10, 40, 40);
        UIButton * playButton = [[UIButton alloc] initWithFrame:rtButton];
        [playButton setImage:[UIImage imageNamed:@"chat_cell_play.png"] forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageNamed:@"chat_cell_pause.png"] forState:UIControlStateSelected];
        [playButton addTarget:self action:@selector(onAudioPlay:) forControlEvents:UIControlEventTouchUpInside];
        playButton.tag = PLAY_BTN_TAG;
        [self addSubview:playButton];
        [playButton release];
        
        CGRect rtProgress = isPhone ? CGRectMake(130, 25, 170, 10) : CGRectMake(146 + iPadWidthOffset, 25, 258, 10);
        UIProgressView * progress = [[UIProgressView alloc] initWithFrame:rtProgress];
        progress.progress = 0.0;
        progress.progressImage = [UIImage imageNamed:@"chat_cell_progress.png"];
        progress.trackTintColor = [UIColor colorWithRed:215.0f green:215.0f blue:215.0f alpha:1.0f];
        progress.tag = PROGRESS_TAG;
        [self addSubview:progress];
        [progress release];
        
        [self.labelTime setFrame:CGRectMake(self.labelTime.frame.origin.x + iPadWidthOffset, height + 10, self.labelTime.frame.size.width, self.labelTime.frame.size.height)];        
        
        [self.labelExpire setFrame:CGRectMake(self.labelExpire.frame.origin.x + iPadWidthOffset, height + 10, self.labelExpire.frame.size.width, self.labelExpire.frame.size.height)];
    }
    
    self.labelTime.text = [self.dicData objectForKey:@"sented"];
    if ([[self.dicData objectForKey:@"oneplay"] isEqualToString:@"Y"]) {
        self.labelExpire.text = @"Expires after 1 play";
    }
    else {
        NSString * expireDuration = [self.dicData objectForKey:@"duration"];
        if ([expireDuration length] != 0) {
            self.labelExpire.text = [NSString stringWithFormat:@"Expires in %@", expireDuration];
        }
        else {
            self.labelExpire.text = @"";
        }
    }    
}

#pragma mark - get avatar image
- (void) getAvatar:(NSString*)image_link {
    self.imageCha.image = [UIImage imageNamed:@"default_cha.png"];

    if ([image_link isKindOfClass:[NSNull class]] || image_link == nil) {
        return;
    }
    NSAutoreleasePool*	autoreleasePool	= [[NSAutoreleasePool alloc]init];
    
    NSData * imgData = [[NSUserDefaults standardUserDefaults] objectForKey:image_link];
    if (imgData) {
        self.imageCha.image = [UIImage imageWithData:imgData];
    }
    else {
        imgData	= [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:image_link]];
        if (imgData) {
            self.imageCha.image = [UIImage imageWithData:imgData];
            [[NSUserDefaults standardUserDefaults] setObject:imgData forKey:image_link];
        }
        [imgData release];
    }
	
	[autoreleasePool release];
}

#pragma mark - get photo image
- (void) getPhotoImage:(NSString*)image_link {
    if ([image_link isKindOfClass:[NSNull class]] || image_link == nil) {
        return;
    }
    
    NSAutoreleasePool*	autoreleasePool	= [[NSAutoreleasePool alloc]init];
	NSData * imgData	= [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:image_link]];
	UIImageView * imageView = [[UIImageView alloc] initWithFrame:_rtPhoto];
    imageView.image = [self cropImage:[UIImage imageWithData:imgData] toRect:_rtPhoto];
    NSLog(@"CChatCell : photo size = (%.0f, %.0f)", imageView.image.size.width, imageView.image.size.height);
    [self addSubview:imageView];
    [imageView release];
	[imgData release];
	[autoreleasePool release];
}

#pragma mark - audio section
- (void) onAudioPlay:(UIButton *)sender {
    if (!_audioPlayer) {
        [_delegate showLoadingView];
        NSString * audio_link = [self.dicData objectForKey:@"contents"];
        NSData * audio_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:audio_link]];
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:audio_data error:nil];
        [_audioPlayer setDelegate:self];
        [_delegate hideLoadingView];
    }
    if (_audioPlayer.isPlaying) {
        [_audioPlayer stop];
        [sender setSelected:NO];
        if (_meterTimer) {
            [_meterTimer invalidate];
            _meterTimer = nil;
        }
        
        NSString * onePlay = [self.dicData objectForKey:@"oneplay"];
        if ([onePlay isEqualToString:@"Y"]) {
            NSString * chat_id = [NSString stringWithFormat:@"%d", [[self.dicData objectForKey:@"chatid"] integerValue]];
            [_parentVC deleteChat:chat_id];
        }
    }
    else {
        [_audioPlayer play];
        [sender setSelected:YES];
        [_parentVC setDelegate:self];
        if (_meterTimer) {
            [_meterTimer invalidate];
            _meterTimer = nil;
        }
        _meterTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (_meterTimer) {
        [_meterTimer invalidate];
        _meterTimer = nil;
    }
    UIButton * btnPlay = (UIButton *)[self viewWithTag:PLAY_BTN_TAG];
    if (btnPlay) {
        btnPlay.selected = NO;
    }
    
    NSString * onePlay = [self.dicData objectForKey:@"oneplay"];
    if ([onePlay isEqualToString:@"Y"]) {
        NSString * chat_id = [NSString stringWithFormat:@"%d", [[self.dicData objectForKey:@"chatid"] integerValue]];
        [_parentVC deleteChat:chat_id];
    }
}

- (void) onTimer {
    UIProgressView * progress = (UIProgressView *)[self viewWithTag:PROGRESS_TAG];
    if (progress) {
        progress.progress = _audioPlayer.currentTime / _audioPlayer.duration;
    }
}

#pragma mark - chat cell delegate

- (void) cellWillRelease {
    if (_meterTimer) {
        [_meterTimer invalidate];
        _meterTimer = nil;
    }
}

- (void) scrollTableView {
    if (_audioPlayer.isPlaying) {
        [_audioPlayer stop];
        
        if (_meterTimer) {
            [_meterTimer invalidate];
            _meterTimer = nil;
        }
        
        UIButton * btnPlay = (UIButton *)[self viewWithTag:PLAY_BTN_TAG];
        if (btnPlay) {
            btnPlay.selected = NO;
        }
        
        [_parentVC setDelegate:nil];
    }
}

#pragma mark text view delegate
// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}

- (void) adjustImageView:(UIImageView *)imageView size:(CGSize)imageSize fitRect:(CGRect) fitRect {
    CGSize fitSize = fitRect.size;
    imageView.center = CGPointMake(fitSize.width / 2, fitSize.height / 2);
    imageView.transform = CGAffineTransformIdentity;
    
    if (imageSize.width > fitSize.width) {
        imageSize.height *= (fitSize.width / imageSize.width);
        imageSize.width = fitSize.width;
    }
    if (imageSize.height > fitSize.height) {
        imageSize.width *= (fitSize.height / imageSize.height);
        imageSize.height = fitSize.height;
    }
    CGRect frame = CGRectMake(fitRect.origin.x + (fitSize.width - imageSize.width ) / 2, fitRect.origin.y + (fitSize.height - imageSize.height ) / 2, imageSize.width, imageSize.height);
    [imageView setFrame:frame];
}

- (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect  {
    
    CGSize size = image.size;
    float imageRatio = size.width / size.height;
    float fitRatio = rect.size.width / rect.size.height;
    
    if (imageRatio > fitRatio) {
        size.width = size.height * rect.size.width / rect.size.height;
        rect = CGRectMake((image.size.width - size.width) / 2, 0, size.width, size.height);
    }
    else {
        size.height = size.width * rect.size.height / rect.size.width;
        rect = CGRectMake(0, (image.size.height - size.height) / 2, size.width, size.height);
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height);
    
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    [image drawInRect:drawRect];
    
    UIImage * subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
}

@end
