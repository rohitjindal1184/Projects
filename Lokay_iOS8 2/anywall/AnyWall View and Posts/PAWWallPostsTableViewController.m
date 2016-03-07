//
//  PAWWallPostsTableViewController.m
//

static CGFloat const kPAWWallPostTableViewFontSize = 15.f;
static CGFloat const kPAWWallPostTableViewCellWidth = 230.f; // subject to change.

// Cell dimension and positioning constants
static CGFloat const kPAWCellPaddingTop = 5.0f;
static CGFloat const kPAWCellPaddingBottom = 1.0f;
static CGFloat const kPAWCellPaddingSides = 0.0f;
static CGFloat const kPAWCellTextPaddingTop = 4.0f;
static CGFloat const kPAWCellTextPaddingBottom = 5.0f;
static CGFloat const kPAWCellTextPaddingSides = 15.0f;

static CGFloat const kPAWCellUsernameHeight = 15.0f;
static CGFloat const kPAWCellBkgdHeight = 32.0f;
static CGFloat const kPAWCellBkgdOffset = kPAWCellBkgdHeight - kPAWCellUsernameHeight;

static CGFloat const kPAWPhotoWidth = 150.0f;
static CGFloat const kPAWPhotoHeight = 150.0f;

// TableViewCell ContentView tags
static NSInteger kPAWCellBackgroundTag = 2;
static NSInteger kPAWCellTextLabelTag = 3;
static NSInteger kPAWCellNameLabelTag = 4;
static NSInteger kPAWCellImageViewTag = 5;
static NSInteger kPAWCellPhotoButtonTag = 6;

static NSUInteger const kPAWTableViewMainSection = 0;

#import "PAWWallPostsTableViewController.h"

#import "PAWAppDelegate.h"

#import <QuartzCore/QuartzCore.h>

#import "QBPopupMenu.h"

#import "Mailgun.h"

#import "UIAlertView+Blocks.h"


@interface PAWWallPostsTableViewController (){
	Mailgun *mailGun;
}

@property (nonatomic, strong) QBPopupMenu *popupMenu;
// NSNotification callbacks
- (void)distanceFilterDidChange:(NSNotification *)note;
- (void)locationDidChange:(NSNotification *)note;
- (void)postWasCreated:(NSNotification *)note;

@end

@implementation PAWWallPostsTableViewController

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWLocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWPostCreatedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWMessageReceivedNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	if (self) {
		// Customize the table:

		// The className to query on
		self.parseClassName = kPAWParsePostsClassKey;

		// The key of the PFObject to display in the label of the default cell style
		self.textKey = kPAWParseTextKey;

        // Whether the built-in pull-to-refresh is enabled
        if (NSClassFromString(@"UIRefreshControl")) {
            self.pullToRefreshEnabled = NO;
        } else {
            self.pullToRefreshEnabled = YES;
        }
		
		// Whether the built-in pagination is enabled
		self.paginationEnabled = YES;

		// The number of objects to show per page
		self.objectsPerPage = kPAWWallPostsSearch;
	}
	return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
		
	//Mailgun Integration
	mailGun = [Mailgun clientWithDomain:@"sandbox97000bf42754497cab804f769b916919.mailgun.org" apiKey:@"key-71587da92a97174674f9ceda35c6f223"];
	
	//Abuse Popup
	QBPopupMenuItem *itemAbuse = [QBPopupMenuItem itemWithTitle:@"Report Abuse" target:self action:@selector(reportAbuseFunction)];
    QBPopupMenuItem *itemCancel = [QBPopupMenuItem itemWithTitle:@"Cancel" target:self action:@selector(cancel)];
	
	NSArray *items = @[itemAbuse, itemCancel];
    
    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] initWithItems:items];
    popupMenu.highlightedColor = [[UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.8];
    self.popupMenu = popupMenu;

	if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor colorWithRed:118.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1.0f];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.pullToRefreshEnabled = NO;
    }
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceFilterDidChange:) name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kPAWLocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWasCreated:) name:kPAWPostCreatedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageReceived:) name:kPAWMessageReceivedNotification object:nil];
	
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorColor = [UIColor clearColor];

	self.tableView.showsVerticalScrollIndicator = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
    if (NSClassFromString(@"UIRefreshControl")) {
        [self.refreshControl endRefreshing];
    }
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
	PFQuery *query = [PFQuery queryWithClassName:@"Posts"];

	// If no objects are loaded in memory, we look to the cache first to fill the table
	// and then subsequently do a query against the network.
	if ([self.objects count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}

	[query whereKey:@"chatroom_id" equalTo:self.chatroom_id];
	[query orderByDescending:@"createdAt"];
//	[query includeKey:@"user"];
	[query includeKey:@"user"];
	query.limit = 50;

	return query;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object. 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
	// Reuse identifiers for left and right cells
	
	static NSString *RightCellIdentifier = @"RightCell";
	static NSString *LeftCellIdentifier = @"LeftCell";
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HideChatButton" object:nil];
	// Try to reuse a cell
	BOOL cellIsRight = [[[object objectForKey:kPAWParseUserKey] objectForKey:kPAWParseUsernameKey] isEqualToString:[[PFUser currentUser] username]];
	UITableViewCell *cell = nil;
	if (cellIsRight) { // User's post so create blue bubble
//		cell = [tableView dequeueReusableCellWithIdentifier:RightCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RightCellIdentifier];
			
			UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"blueBubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 11.0f, 20.0f, 20.0f)]];
			[backgroundImage setUserInteractionEnabled:YES];
			
			[backgroundImage setTag:kPAWCellBackgroundTag];
			[cell.contentView addSubview:backgroundImage];

			UILabel *textLabel = [[UILabel alloc] init];
			[textLabel setTag:kPAWCellTextLabelTag];
			[cell.contentView addSubview:textLabel];
			cell.contentView.backgroundColor = [UIColor clearColor];
			UILabel *nameLabel = [[UILabel alloc] init];
			[nameLabel setTag:kPAWCellNameLabelTag];
			[cell.contentView addSubview:nameLabel];
			
		}
	} else { // Someone else's post so create gray bubble
//		cell = [tableView dequeueReusableCellWithIdentifier:LeftCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LeftCellIdentifier];
			
			UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"grayBubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 11.0f, 16.0f, 11.0f)]];
			[backgroundImage setTag:kPAWCellBackgroundTag];
			[backgroundImage setUserInteractionEnabled:YES];
			[cell.contentView addSubview:backgroundImage];

			UILabel *textLabel = [[UILabel alloc] init];
			[textLabel setTag:kPAWCellTextLabelTag];
			[cell.contentView addSubview:textLabel];
			
			UILabel *nameLabel = [[UILabel alloc] init];
			[nameLabel setTag:kPAWCellNameLabelTag];
			[cell.contentView addSubview:nameLabel];
		}
	}
	
	// Configure the cell content
	UILabel *textLabel = (UILabel*) [cell.contentView viewWithTag:kPAWCellTextLabelTag];
	textLabel.text = [object objectForKey:kPAWParseTextKey];
	textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	textLabel.numberOfLines = 0;
	textLabel.font = [UIFont systemFontOfSize:kPAWWallPostTableViewFontSize];
	textLabel.textColor = [UIColor whiteColor];
	textLabel.backgroundColor = [UIColor clearColor];
	
	

	
	
	
	
	NSLog(@"username  -- %@",[object objectForKey:kPAWParseUserKey] );
	NSString *username = [NSString stringWithFormat:@"%@",[[object objectForKey:kPAWParseUserKey] objectForKey:kPAWParseUsernameKey]];
	UILabel *nameLabel = (UILabel*) [cell.contentView viewWithTag:kPAWCellNameLabelTag];
	nameLabel.text = username;
	nameLabel.font = [UIFont systemFontOfSize:kPAWWallPostTableViewFontSize];
	nameLabel.backgroundColor = [UIColor clearColor];
	if (cellIsRight) {
		nameLabel.textColor = [UIColor blackColor];
//		nameLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.35f];
//		nameLabel.shadowOffset = CGSizeMake(0.0f, 0.5f);
	} else {
		nameLabel.textColor = [UIColor blackColor];
//		nameLabel.shadowColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:0.35f];
//		nameLabel.shadowOffset = CGSizeMake(0.0f, 0.5f);
	}
	
	UIImageView *backgroundImage = (UIImageView*) [cell.contentView viewWithTag:kPAWCellBackgroundTag];
	
	UIView * view = [cell.contentView viewWithTag:kPAWCellImageViewTag];
	if (view) [view removeFromSuperview];
	
	view = [cell.contentView viewWithTag:kPAWCellPhotoButtonTag];
	if (view) [view removeFromSuperview];
	
	PFFile * photo = [object objectForKey:@"photo"];
	float photoHeight = (photo == nil) ? 0 : kPAWPhotoHeight;
	
	// Move cell content to the right position
	// Calculate the size of the post's text and username
	CGSize textSize = [[object objectForKey:kPAWParseTextKey] sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSize] constrainedToSize:CGSizeMake(kPAWWallPostTableViewCellWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	CGSize nameSize = [username sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSize] forWidth:kPAWWallPostTableViewCellWidth lineBreakMode:NSLineBreakByTruncatingTail];
	
	
	CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath]; // Get the height of the cell
	CGFloat textWidth = textSize.width > nameSize.width ? textSize.width : nameSize.width; // Set the width to the largest (text of username)
	
	UIImageView * imageView = nil;
	UIButton * photoButton = nil;
	if (photo) {
		if (textWidth < kPAWPhotoWidth) {
			textWidth = kPAWPhotoWidth;
		}
		
		imageView = [[UIImageView alloc] init];
		imageView.layer.masksToBounds = YES;
		imageView.layer.cornerRadius = 3.0f;
		imageView.backgroundColor = [UIColor lightGrayColor];
		imageView.tag = kPAWCellImageViewTag;
		[cell.contentView addSubview:imageView];
		NSDictionary * arguments = [NSDictionary dictionaryWithObjectsAndKeys:imageView, @"imageView", photo, @"photo", nil];
		[NSThread detachNewThreadSelector:@selector(loadPhoto:) toTarget:self withObject:arguments];
		
		photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		photoButton.tag = indexPath.row;
		[photoButton addTarget:self action:@selector(onPhoto:) forControlEvents:UIControlEventTouchUpInside];
		[cell.contentView addSubview:photoButton];
	}
	// Place the content in the correct position depending on the type
	if (cellIsRight) {
		if (photo) {
			[imageView setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kPAWCellTextPaddingSides-kPAWCellPaddingSides,
										   kPAWCellPaddingTop+kPAWCellTextPaddingTop+textSize.height + nameSize.height,
										   kPAWPhotoWidth,
										   kPAWPhotoHeight)];
			[photoButton setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kPAWCellTextPaddingSides-kPAWCellPaddingSides,
										   kPAWCellPaddingTop+kPAWCellTextPaddingTop+textSize.height,
										   kPAWPhotoWidth,
										   kPAWPhotoHeight)];
		}
		
		[nameLabel setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kPAWCellTextPaddingSides-kPAWCellPaddingSides, 
									   kPAWCellPaddingTop+kPAWCellTextPaddingTop,									   nameSize.width,
									   nameSize.height)];
		[textLabel setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kPAWCellTextPaddingSides-kPAWCellPaddingSides +kPAWCellTextPaddingTop ,
									   kPAWCellPaddingTop+kPAWCellTextPaddingTop+ nameSize.height,
									   textSize.width, 
									   textSize.height)];		
		[backgroundImage setFrame:CGRectMake(self.tableView.frame.size.width-textWidth-kPAWCellTextPaddingSides*2-kPAWCellPaddingSides, 
											 kPAWCellPaddingTop, 
											 textWidth+kPAWCellTextPaddingSides*2, 
											 cellHeight-kPAWCellPaddingTop-kPAWCellPaddingBottom)];
		
	} else {
		if (photo) {
			[imageView setFrame:CGRectMake(kPAWCellTextPaddingSides-kPAWCellPaddingSides,
										   kPAWCellPaddingTop+kPAWCellTextPaddingTop+textSize.height + nameSize.height,
										   kPAWPhotoWidth,
										   kPAWPhotoHeight)];
			[photoButton setFrame:CGRectMake(kPAWCellTextPaddingSides-kPAWCellPaddingSides,
										   kPAWCellPaddingTop+kPAWCellTextPaddingTop+textSize.height,
										   kPAWPhotoWidth,
										   kPAWPhotoHeight)];
		}
		[nameLabel setFrame:CGRectMake(kPAWCellTextPaddingSides-kPAWCellPaddingSides, 
									   kPAWCellPaddingTop+kPAWCellTextPaddingTop,
									   nameSize.width, 
									   nameSize.height)];
		[textLabel setFrame:CGRectMake(kPAWCellPaddingSides+kPAWCellTextPaddingSides, 
									   kPAWCellPaddingTop+kPAWCellTextPaddingTop + nameSize.height,
									   textSize.width, 
									   textSize.height)];
		[backgroundImage setFrame:CGRectMake(kPAWCellPaddingSides, 
											 kPAWCellPaddingTop, 
											 textWidth+kPAWCellTextPaddingSides*2, 
											 cellHeight-kPAWCellPaddingTop-kPAWCellPaddingBottom)];
	}

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	for(UIView *view in cell.contentView.subviews) {
		if(view.tag == kPAWCellBackgroundTag) {
			UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
			[tap setNumberOfTapsRequired:1];
			[tap setDelegate:self];
			[view addGestureRecognizer:tap];
		}
	}
	UILabel *lblTime = [[UILabel alloc]init];
	NSDate *date = [object createdAt];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
	//dateFormatter.dateFormat = @"MM/dd/yy hh:mm a";
	dateFormatter.dateFormat = @"hh:mm a";

	NSString *dateString = [dateFormatter stringFromDate: date];
	
	
	
	//NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
	//timeFormatter.dateFormat = @"HH:mm:ss";
	
	
	//NSString *dateString = [timeFormatter stringFromDate: date];
	int dateLblY = photo?imageView.frame.origin.y+imageView.frame.size.height:textLabel.frame.origin.y+textLabel.frame.size.height;
	int datelblW = backgroundImage.frame.size.width -20;
	lblTime.text = dateString;
	lblTime.lineBreakMode = NSLineBreakByWordWrapping;
	lblTime.numberOfLines = 1;
	lblTime.font = [UIFont systemFontOfSize:11.0f];
	lblTime.textColor = [UIColor grayColor];
	lblTime.backgroundColor = [UIColor clearColor];
	lblTime.frame = nameLabel.frame;
	lblTime.frame = CGRectMake(lblTime.frame.origin.x
							   , dateLblY, datelblW, lblTime.frame.size.height);
	if(cellIsRight)
	{
		lblTime.frame = CGRectMake(lblTime.frame.origin.x
								   , dateLblY, datelblW - 10, lblTime.frame.size.height);

	}
	[cell.contentView addSubview:lblTime];
	lblTime.textAlignment = UITextAlignmentRight;
	cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	nameLabel.textColor = [UIColor colorWithRed:227.0/255.0 green:120.0/255.0 blue:74.0/255.0 alpha:1.0];
	textLabel.textColor = [UIColor blackColor];
	CGFloat indent_large_enought_to_hidden = 10000;
	cell.separatorInset = UIEdgeInsetsMake(0, indent_large_enought_to_hidden, 0, 0); // indent large engough for separator(including cell' content) to hidden separator
	cell.indentationWidth = indent_large_enought_to_hidden * -1; // adjust the cell's content to show normally
	cell.indentationLevel = 1;
	
		UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, cellHeight-1, 320, 1)];
		line.backgroundColor = [UIColor groupTableViewBackgroundColor];
		[cell addSubview:line];
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForNextPageAtIndexPath:indexPath];
	cell.textLabel.font = [cell.textLabel.font fontWithSize:kPAWWallPostTableViewFontSize];
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// call super because we're a custom subclass.
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Account for the load more cell at the bottom of the tableview if we hit the pagination limit:
	if ( (NSUInteger)indexPath.row >= [self.objects count]) {
		return [tableView rowHeight];
	}

	// Retrieve the text and username for this row:
	PFObject *object = [self.objects objectAtIndex:indexPath.row];
	PAWPost *postFromObject = [[PAWPost alloc] initWithPFObject:object];
	NSString *text = postFromObject.title;
	NSString *username = postFromObject.user.username;
	PFFile * photo = [object objectForKey:@"photo"];
	
	// Calculate what the frame to fit the post text and the username
	CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSize] constrainedToSize:CGSizeMake(kPAWWallPostTableViewCellWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	CGSize nameSize = [username sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSize] forWidth:kPAWWallPostTableViewCellWidth lineBreakMode:NSLineBreakByTruncatingTail];

	// And return this height plus cell padding and the offset of the bubble image height (without taking into account the text height twice)
	CGFloat rowHeight = kPAWCellPaddingTop + textSize.height + nameSize.height + kPAWCellBkgdOffset;
	
	if (photo) {
		rowHeight += kPAWPhotoHeight;
	}
	
	return rowHeight + 10;
}


#pragma mark - PAWWallViewControllerSelection

- (void)highlightCellForPost:(PAWPost *)post {
	// Find the cell matching this object.
	for (PFObject *object in [self objects]) {
		PAWPost *postFromObject = [[PAWPost alloc] initWithPFObject:object];
		if ([post equalToPost:postFromObject]) {
			// We found the object, scroll to the cell position where this object is.
			NSUInteger index = [[self objects] indexOfObject:object];

			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:kPAWTableViewMainSection];
			[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
			[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

			return;
		}
	}

	// Don't scroll for posts outside the search radius.
	if ([post.title compare:kPAWWallCantViewPost] != NSOrderedSame) {
		// We couldn't find the post, so scroll down to the load more cell.
		NSUInteger rows = [self.tableView numberOfRowsInSection:kPAWTableViewMainSection];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(rows - 1) inSection:kPAWTableViewMainSection];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)unhighlightCellForPost:(PAWPost *)post {
	// Deselect the post's row.
	for (PFObject *object in [self objects]) {
		PAWPost *postFromObject = [[PAWPost alloc] initWithPFObject:object];
		if ([post equalToPost:postFromObject]) {
			NSUInteger index = [[self objects] indexOfObject:object];
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

			return;
		}
	}
}


#pragma mark - ()

- (void)distanceFilterDidChange:(NSNotification *)note {
	[self loadObjects];
}

- (void)locationDidChange:(NSNotification *)note {
	[self loadObjects];
}

- (void)postWasCreated:(NSNotification *)note {
	[self loadObjects];
}

- (void)onMessageReceived:(NSNotification *)note {
	[self loadObjects];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

#pragma mark - load photo thread method 
- (void) loadPhoto:(NSDictionary *)arguments {
	UIImageView * imageView = [arguments objectForKey:@"imageView"];
	PFFile * photo = [arguments objectForKey:@"photo"];
	imageView.image = [UIImage imageWithData:[photo getData]];
}

- (void) onPhoto:(UIButton *)sender {
	NSInteger index = sender.tag;
	PFObject * object = [self.objects objectAtIndex:index];
	PFFile * photo = [object objectForKey:@"photo"];
	NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:photo, @"photo", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kPAWClickPhotoNotification object:nil userInfo:dic];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[self.popupMenu dismissAnimated:YES];
}

- (void)cancel{
	
}

- (void)tapAction:(UIGestureRecognizer*)sender{
	if(sender.state==UIGestureRecognizerStateEnded){
		CGPoint touched=[sender locationInView:self.tableView];
		
		NSIndexPath *touchIndex=[self.tableView indexPathForRowAtPoint:touched];
		CGRect popupRect = CGRectMake(touched.x, touched.y - [self.tableView contentOffset].y, 10, 10);
		[self.popupMenu showInView:self.view targetRect:popupRect animated:YES];
		self.selecetdObject = [self.objects objectAtIndex:touchIndex.row];
	}
}

- (void)reportAbuseFunction{
	
	[[[UIAlertView alloc] initWithTitle:@"Report Abuse?"
	                            message:@"Are you sure you want to report this post as abuse?"
		               cancelButtonItem:[RIButtonItem itemWithLabel:@"Yes" action:^{
		
		PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
		
		// Retrieve the object by id
		[query getObjectInBackgroundWithId:[self.selecetdObject objectId] block:^(PFObject *object, NSError *error) {
			
			object[@"is_spam"] = @YES;
			object[@"reportedBy"] = [self.selecetdObject objectForKey:@"user"];
			
			[object saveInBackground];
			
			NSString *body = [NSString stringWithFormat:@"Report Abuse chat room - %@ ,Post Id - %@, Post User - %@ , Reporter - %@",self.chatroom_id,[self.selecetdObject objectId],[[PFUser currentUser] username],[[object objectForKey:@"user"] objectId]];
			[mailGun sendMessageTo:@"LokeyMe <info@lokayme.com>"
							  from:@"Abuse Reporter <alert@lokay.com>"
						   subject:@"Report Abuse!"
							  body:body];
			
			NSString *message = [NSString stringWithFormat:@"This post is report as abused."];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lokay!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alert show];
		}];
	}]
				       otherButtonItems:[RIButtonItem itemWithLabel:@"No" action:^{
		// Handle "Delete"
	}], nil] show];
	
	
	
}

@end
