#import "FlipNCController.h"
/*
NSError *error = nil;
NSArray *bundles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/Application Support/FlipNC/" error:&error];
NSString *bundlePath = [NSString stringWithFormat:@"/Library/Application Support/FlipNC/%@", [bundles objectAtIndex:templateIdx]];
NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
*/

static NSString *nsDomainString = @"com.uroboro.FlipNC";
static NSString *nsNotificationString = @"com.uroboro.flipnc/preferences.changed";
static NSString *fsNotificationString = @"com.uroboro.flipnc/flipswitches.changed";

static NSBundle *_FlipNCWeeAppBundle = nil;
static FlipNCController *_probablyUnique = nil;

#define showAlert(t, m) [[[[UIAlertView alloc] initWithTitle:(t) message:(m) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];

#define CMCLog(format, ...) \
	NSLog(@"\033[1;36m(%s) in [%s:%d]\033[0m \033[5;32;40m:::\033[0m \033[0;31m%@\033[0m", __PRETTY_FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:format, ## __VA_ARGS__])


@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end
#define standardObjectForKey(key) [[NSUserDefaults standardUserDefaults] objectForKey:key inDomain:nsDomainString]

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[_probablyUnique updateVars];
}

static void fsnotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[_probablyUnique updateSwitchList];
}
	
@implementation FlipNCController
@synthesize view = _view;
//@synthesize templateName = _templateName;

+ (void)initialize {
	_FlipNCWeeAppBundle = [[NSBundle bundleForClass:[self class]] retain];
}

- (id)init {
	if ((self = [super init]) != nil) {
		// do init stuff
		_probablyUnique = self;
		//CMCLog(@"uroboro :: [%@ init]", NSStringFromClass([self class]));
		// Set variables on start up
		[self updateVars];
		[self updateSwitchList];
 
		// Register for 'PostNotification' notifications
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, fsnotificationCallback, (CFStringRef)fsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
	return self;
}

- (void)dealloc {
	[_view release];
	[_backgroundView release];
	[super dealloc];
}

- (void)updateSwitchList {
	_ids = [standardObjectForKey(@"Enabled") retain];
}

- (void)updateVars {
	_rows = [(NSNumber *)standardObjectForKey(@"Rows") intValue];

	_switchesPerRow = [(NSNumber *)standardObjectForKey(@"SwitchesPerRow") intValue];
	_unpaged = !_switchesPerRow;

	_templateIdx = [(NSNumber *)standardObjectForKey(@"TemplateIdx") intValue];
}

- (float)viewHeight {

	NSArray *templates = [[NSArray alloc] initWithObjects:MyTemplatePath, SITemplatePath, nil];
	NSBundle *templateBundle = [[NSBundle alloc] initWithPath:[templates objectAtIndex:_templateIdx]];
	[templates release];
	CGFloat iconHeight = [[templateBundle.infoDictionary objectForKey:@"height"] floatValue];
	[templateBundle release];

	return (_rows)?_rows:1 * (10 + iconHeight) + (float)(2 << 1);
}

- (void)loadFullView {
	// Add subviews to _backgroundView (or _view) here.

	NSArray *templates = [[NSArray alloc] initWithObjects:MyTemplatePath, SITemplatePath, nil];
	NSBundle *templateBundle = [[NSBundle alloc] initWithPath:[templates objectAtIndex:_templateIdx]];
	[templates release];

	CGFloat iconWidth = [[templateBundle.infoDictionary objectForKey:@"width"] floatValue];
	CGFloat iconHeight = [[templateBundle.infoDictionary objectForKey:@"height"] floatValue];

	CGFloat screenWidth = _backgroundView.frame.size.width;
	CGFloat screenHeight = _backgroundView.frame.size.height;

	int defaultSwitchesPerRow = (_landscape)? 7:4;
	int actualSwitchesPerRow = (_unpaged)? defaultSwitchesPerRow:_switchesPerRow;

	CGFloat xSpacing = (CGFloat)(screenWidth - actualSwitchesPerRow * iconWidth) / (actualSwitchesPerRow + 1);
	CGFloat contentWidth = (_unpaged)? (xSpacing + [_ids count] * (iconWidth + xSpacing)) : (screenWidth * ([_ids count] / _switchesPerRow + ([_ids count] % _switchesPerRow != 0)));

	CGFloat offset = [(NSNumber *)standardObjectForKey(@"Offset") floatValue];
	offset *= screenWidth;
	offset = (contentWidth - offset < screenWidth)? contentWidth-screenWidth:offset;

	UIScrollView *scv = [[UIScrollView alloc] initWithFrame:CGRectMake(2, 0, screenWidth, screenHeight - 2)];
	[scv setScrollEnabled:YES];
	[scv setPagingEnabled:!_unpaged];
	[scv setContentSize:CGSizeMake(contentWidth, screenHeight - 2)];
	[scv setContentOffset:CGPointMake(offset, 0.0) animated:NO];
	[scv setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

	FSSwitchPanel *fsp = [FSSwitchPanel sharedPanel];
	for (int idx = 0; idx < [_ids count]; idx++) {
		NSString *identifier = [_ids objectAtIndex:idx];
		UIButton *button = [fsp buttonForSwitchIdentifier:identifier usingTemplate:templateBundle];
		CGFloat x = (_unpaged)? (xSpacing + idx * (iconWidth + xSpacing)) : (xSpacing + (idx / _switchesPerRow) * screenWidth + (idx % _switchesPerRow) * (iconWidth + xSpacing));
		[button setFrame:CGRectMake(x, 5, iconWidth, iconHeight)];
		[scv addSubview:button];
	}
	[templateBundle release];

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
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:offset] forKey:@"Offset" inDomain:nsDomainString];
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
