#import <objc/runtime.h>
#import "FlipNCController.h"

#define MARGIN (float)(1 << 3)

static NSString *nsDomainString = @"com.uroboro.FlipNC";
static NSString *nsNotificationString = @"com.uroboro.flipnc/preferences.changed";

static FlipNCController *_probablyUnique = nil;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[_probablyUnique updateVars];
}

@implementation FlipNCController
@synthesize templateName = _templateName;

- (id)init {
	if ((self = [super init]) != nil) {
		// do init stuff
		_probablyUnique = self;
		//CMCLog(@"flipnc :: [%@ init]", NSStringFromClass([self class]));
		// Set variables on start up
		[self updateVars];

		// Register for 'PostNotification' notifications
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
	return self;
}

- (void)updateVars {
	[NSUserDefaults resetStandardUserDefaults];

	_rows = [(NSNumber *)standardObjectForKey(@"Rows", @1) intValue];
	_rows = (_rows)? _rows:1;
CMCLog(@"flipnc :: _rows = %d", _rows);

	_switchesPerRow = [(NSNumber *)standardObjectForKey(@"SwitchesPerRow", @1) intValue];
//CMCLog(@"flipnc :: _switchesPerRow = %d", _switchesPerRow);
	_templateName = (NSString *)standardObjectForKey(@"TemplateName", @"FlipNCTemplate");
//CMCLog(@"flipnc :: TemplateName = %@", _templateName);

	_iconIdentifiers = [standardObjectForKey(@"Enabled", nil) retain];
}

- (void)willRotateToInterfaceOrientation:(int)interfaceOrientation {
	_landscape = (interfaceOrientation == 3 || interfaceOrientation == 4);
}

- (NSBundle *)currentBundle {
	return [NSBundle bundleWithPath:[NSString stringWithFormat:@"/Library/Application Support/FlipNC/%@%s.bundle", _templateName, isPad()?"~ipad":""]];
}

- (CGFloat)viewHeight {
	CGFloat iconHeight = [[[self currentBundle].infoDictionary objectForKey:@"height"] floatValue];
	CGFloat r = _rows * (10 + iconHeight + MARGIN);
	return r;
}

- (void)loadFullView {
	// Add subviews to _backgroundView (or _view) here.

	BOOL unpaged = !_switchesPerRow;
	int defaultSwitchesPerRow = (_landscape)? 7:4;
	int actualSwitchesPerRow = (unpaged)? defaultSwitchesPerRow:_switchesPerRow;

	CGFloat offset = [(NSNumber *)standardObjectForKey(@"Offset", @0) floatValue];
	CGRect frame;
	frame = self.view.bounds;
//CMCLog(@"flipnc :: bounds=%@", NSStringFromCGRect(frame));
	frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height/_rows);
//CMCLog(@"flipnc :: _rowFrame=%@", NSStringFromCGRect(frame));

	NSBundle *templateBundle = [self currentBundle];

	for (int idx = 0; idx < _rows; idx++) {
		CGRect _frame = CGRectInset(frame, 2.f, 2.f);
//CMCLog(@"flipnc :: _frame%d=%@", idx, NSStringFromCGRect(_frame));
		_frame = CGRectMake(_frame.origin.x, _frame.origin.y + idx * frame.size.height, _frame.size.width, _frame.size.height);
//CMCLog(@"flipnc :: _frame%d=%@", idx, NSStringFromCGRect(_frame));
		UIView *scv = [self iconContainerWithFrame:_frame
			bundle:templateBundle
			icons:_iconIdentifiers
			switchesPerRow:actualSwitchesPerRow
			paged:!unpaged
			offset:offset];
		[_view addSubview:scv];
	}
}

- (UIView *)iconContainerWithFrame:(CGRect)frame
		bundle:(NSBundle *)templateBundle
		icons:(NSArray *)iconIdentifiers
		switchesPerRow:(NSInteger)switchesPerRow
		paged:(BOOL)paged
		offset:(CGFloat)startingOffset {

	CGFloat iconWidth = [[templateBundle.infoDictionary objectForKey:@"width"] floatValue];
	CGFloat iconHeight = [[templateBundle.infoDictionary objectForKey:@"height"] floatValue];
//CMCLog(@"flipnc :: icon = {%0f, %0f}", iconWidth, iconHeight);

	CGFloat screenWidth = frame.size.width;
	CGFloat screenHeight = frame.size.height;
//CMCLog(@"flipnc :: screen = {%0f, %0f}", screenWidth, screenHeight);

	NSInteger count = [iconIdentifiers count];

	CGFloat xSpacing = (CGFloat)(screenWidth - switchesPerRow * iconWidth) / (switchesPerRow + 1);
	CGFloat contentWidth = (!paged)? (xSpacing + count * (iconWidth + xSpacing)) : (screenWidth * (count / switchesPerRow + (count % switchesPerRow != 0)));
//CMCLog(@"flipnc :: spacing = %0f : contentWidth = %0f", xSpacing, contentWidth);

	CGFloat offset = startingOffset;
	offset *= screenWidth;
	offset = (contentWidth - offset < screenWidth)? contentWidth-screenWidth:offset;
//CMCLog(@"flipnc :: offset = %0f", offset);

	UIScrollView *scv = [[UIScrollView alloc] initWithFrame:frame];
	[scv setScrollEnabled:YES];
	[scv setPagingEnabled:paged];
	[scv setContentSize:CGSizeMake(contentWidth, screenHeight)];
	[scv setContentOffset:CGPointMake(offset, 0.0) animated:NO];
	[scv setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	
	FSSwitchPanel *fsp = [FSSwitchPanel sharedPanel];
	for (int idx = 0; idx < count; idx++) {
		NSString *identifier = [iconIdentifiers objectAtIndex:idx];
		UIButton *button = [fsp buttonForSwitchIdentifier:identifier usingTemplate:templateBundle];
		CGFloat x = (!paged)? (xSpacing + idx * (iconWidth + xSpacing)) : (xSpacing + (idx / switchesPerRow) * screenWidth + (idx % switchesPerRow) * (iconWidth + xSpacing));
		[button setFrame:CGRectMake(x, 5, iconWidth, iconHeight)];
		[scv addSubview:button];
	}
	return [scv autorelease];
}

- (void)viewWillDisappear {
	//save scrollview offset
	UIScrollView *scv = ([self.view.subviews count] > 1)? (UIScrollView *)[self.view.subviews objectAtIndex:1]:nil; //prevent NSRangeException
	if (scv) {
		//offset is a percentage of the "screen" width
		CGFloat offset = scv.contentOffset.x / ((_landscape)? 564:316);
		_setStandardObjectForKey([NSNumber numberWithFloat:offset], @"Offset");
	}
}

@end
