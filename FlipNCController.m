#import "FlipNCController.h"

static NSString* const preferencesFilePath = @"/User/Library/Preferences/com.uroboro.FlipNC.plist";
static NSBundle *_FlipNCWeeAppBundle = nil;
static BOOL _landscape;

#define showAlert(t, m) [[[[UIAlertView alloc] initWithTitle:(t) message:(m) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];

@implementation FlipNCController
@synthesize view = _view;

+ (void)initialize {
	_FlipNCWeeAppBundle = [[NSBundle bundleForClass:[self class]] retain];
}

- (id)init {
	if ((self = [super init]) != nil) {
		// do init stuff
	} return self;
}

- (void)dealloc {
	[_view release];
	[_backgroundView release];
	[super dealloc];
}

- (float)viewHeight {
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesFilePath];
	int templateIdx = [[prefs objectForKey:@"TemplateIdx"] intValue];
	int rows = [[prefs objectForKey:@"Rows"] intValue];
	[prefs release];

	NSArray *templates = [[NSArray alloc] initWithObjects:MyTemplatePath, SITemplatePath, nil];
	NSBundle *templateBundle = [[NSBundle alloc] initWithPath:[templates objectAtIndex:templateIdx]];
	[templates release];
	CGFloat iconHeight = [[templateBundle.infoDictionary objectForKey:@"height"] floatValue];
	[templateBundle release];

	return (rows)?rows:1 * (10 + iconHeight) + (float)(2 << 1);
}

- (void)loadFullView {
	// Add subviews to _backgroundView (or _view) here.

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesFilePath];
	NSArray *ids = [[prefs objectForKey:@"Enabled"] retain];
	int templateIdx = [[prefs objectForKey:@"TemplateIdx"] intValue];
	int switchesPerRow = [[prefs objectForKey:@"SwitchesPerRow"] intValue];
	BOOL unpaged = !switchesPerRow;
//	int rows = [[prefs objectForKey:@"Rows"] intValue];
	CGFloat offset = [[prefs objectForKey:@"Offset"] floatValue];
	[prefs release];

	NSArray *templates = [[NSArray alloc] initWithObjects:MyTemplatePath, SITemplatePath, nil];
	NSBundle *templateBundle = [[NSBundle alloc] initWithPath:[templates objectAtIndex:templateIdx]];
	[templates release];

	CGFloat iconWidth = [[templateBundle.infoDictionary objectForKey:@"width"] floatValue];
	CGFloat iconHeight = [[templateBundle.infoDictionary objectForKey:@"height"] floatValue];

	CGFloat screenWidth = _backgroundView.frame.size.width;
	CGFloat screenHeight = _backgroundView.frame.size.height;

	int defaultSwitchesPerRow = (_landscape)?7:4;

	CGFloat xSpacing = (CGFloat)(screenWidth - ((unpaged)? defaultSwitchesPerRow:switchesPerRow) * iconWidth) / (((unpaged)? defaultSwitchesPerRow:switchesPerRow) + 1);
	CGFloat contentWidth = (unpaged)? (xSpacing + [ids count] * (iconWidth + xSpacing)) : (screenWidth * ([ids count] / switchesPerRow + ([ids count] % switchesPerRow != 0)));

	UIScrollView *scv = [[UIScrollView alloc] initWithFrame:CGRectMake(2, 0, screenWidth, screenHeight - 2)];
	[scv setScrollEnabled:YES];
	[scv setPagingEnabled:!unpaged];
	[scv setContentSize:CGSizeMake(contentWidth, screenHeight - 2)];
	[scv setContentOffset:CGPointMake(offset * screenWidth, 0.0) animated:NO];
	[scv setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

	FSSwitchPanel *fsp = [FSSwitchPanel sharedPanel];
	for (int idx = 0; idx < [ids count]; idx++) {
		NSString *identifier = [ids objectAtIndex:idx];
		UIButton *button = [fsp buttonForSwitchIdentifier:identifier usingTemplate:templateBundle];
		CGFloat x = (unpaged)? (xSpacing + idx * (iconWidth + xSpacing)) : (xSpacing + (idx / switchesPerRow) * screenWidth + (idx % switchesPerRow) * (iconWidth + xSpacing));
		[button setFrame:CGRectMake(x, 5, iconWidth, iconHeight)];
		[scv addSubview:button];
	}
	[templateBundle release];
	[ids release];

	[_view addSubview:scv];
	[scv release];
}

- (void)loadPlaceholderView {
	// This should only be a placeholder - it should not connect to any servers or perform any intense
	// data loading operations.
	//
	// All widgets are 316 points wide. Image size calculations match those of the Stocks widget.
	_view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {316.f, [self viewHeight]}}];
	_view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	UIImage *bgImg = [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/StocksWeeApp.bundle/WeeAppBackground.png"];
	UIImage *stretchableBgImg = [bgImg stretchableImageWithLeftCapWidth:floorf(bgImg.size.width / 2.f) topCapHeight:floorf(bgImg.size.height / 2.f)];
	_backgroundView = [[UIImageView alloc] initWithImage:stretchableBgImg];
	_backgroundView.frame = CGRectInset(_view.bounds, 2.f, 0.f);
	_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_view addSubview:_backgroundView];
}

- (void)viewWillDisappear {
	//save scrollview offset
	UIScrollView *scv = ([_view.subviews count] > 1)? (UIScrollView *)[_view.subviews objectAtIndex:1]:nil; //prevent NSRangeException
	if (scv) {
		//offset is a percentage of the "screen" width
		CGFloat offset = scv.contentOffset.x / ((_landscape)? 564:316);
		NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:preferencesFilePath];
		[prefs setObject:[NSNumber numberWithFloat:offset] forKey:@"Offset"];
		[prefs writeToFile:preferencesFilePath atomically:YES];
		[prefs release];
	}
}

- (void)unloadView {
	[_view release];
	_view = nil;
	[_backgroundView release];
	_backgroundView = nil;
	// Destroy any additional subviews you added here. Don't waste memory :(.
}

- (void)willRotateToInterfaceOrientation:(int)interfaceOrientation {
	_landscape = (interfaceOrientation == 3 || interfaceOrientation == 4);
}

@end
