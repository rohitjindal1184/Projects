//
//  PAWActivityView.m
//

static CGFloat const kPAWActivityViewActivityIndicatorPadding = 10.f;

#import "PAWActivityView.h"

@implementation PAWActivityView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.label = [[UILabel alloc] initWithFrame:CGRectZero];
		self.label.textColor = [UIColor whiteColor];
		self.label.backgroundColor = [UIColor clearColor];
		self.activityIndicator = [[UIActivityIndicatorView alloc] init];
		//self.activityIndicator.frame = CGRectMake(0, 0, 30, 30);
		self.activityIndicator.color = [UIColor orangeColor];
		//self.activityIndicator.center = self.center;
		self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];

		[self addSubview:self.label];
		[self addSubview:self.activityIndicator];
    }
    return self;
}

- (void)setLabel:(UILabel *)aLabel {
	[_label removeFromSuperview];
	[self addSubview:aLabel];
}

- (void)layoutSubviews {
	// center the label and activity indicator.
	[self.label sizeToFit];
	self.label.center = CGPointMake(self.frame.size.width / 2 + 10.f, self.frame.size.height / 2);
	self.label.frame = CGRectIntegral(self.label.frame);

	self.activityIndicator.center = CGPointMake(self.label.frame.origin.x - (self.activityIndicator.frame.size.width / 2) - kPAWActivityViewActivityIndicatorPadding, self.label.frame.origin.y + (self.label.frame.size.height / 2));
}

@end
