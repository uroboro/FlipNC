#import <flipswitch/FSSwitchPanel.h>
#import "BBWeeAppController-Protocol.h"

#define PREFERENCESFILE @"/User/Library/Preferences/com.uroboro.FlipNC.plist"
//static const char *FNCPreferencesChangedNotification = "com.uroboro.flipncC.preferences.changed";

//static void FNCCreateDefaultPreferences(void);

#ifdef UIUserInterfaceIdiomPad
#define isPad() ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
#else
#define isPad() NO
#endif

#define MyTemplatePath @"/Library/Application Support/FlipNC/IconTemplate.bundle"
#define SIiPhoneTemplatePath @"/Library/Application Support/FlipNC/SwitchIconsTemplate.bundle"
#define SIiPadTemplatePath @"/Library/Application Support/FlipNC/SwitchIconsTemplate~ipad.bundle"
#define SITemplatePath (isPad()?SIiPadTemplatePath:SIiPhoneTemplatePath)


#define NO_DBG
#ifndef NO_DBG

#define UResetStringNotification "com.uroboro.flipnc.resetString"

static char *string;
static long offset;
static long size;
static char *filename;

#define stringify(x) #x
#define U_debug(x) U_debug_(stringify(x))

static inline void U_debug_(char *c) {
	string[offset] = c[0];
	offset++;

	FILE *fp = fopen(filename, "w");
	fprintf(fp, "%s", string);
	fclose(fp);
}

static void UResetString(void) {
	offset = 0;
	memset(string, 0, size);
}

static void UResetStringCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	UResetString();
}

static __attribute__((constructor)) void startup(void) {
	size = 1 << 8;
	string = (char *)malloc(size * sizeof(char));
	filename = "/User/u.log";
	UResetString();

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, UResetStringCallback, CFSTR(UResetStringNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
	[pool release];
}
#else
#define U_debug(x)
#endif





static NSBundle *_FlipNCWeeAppBundle = nil;

@interface FlipNCController: NSObject <BBWeeAppController> {
	UIView *_view;
	UIImageView *_backgroundView;
}
@property (nonatomic, retain) UIView *view;
@end

@implementation FlipNCController
@synthesize view = _view;

+ (void)initialize {
U_debug(0);
	_FlipNCWeeAppBundle = [[NSBundle bundleForClass:[self class]] retain];
//	FNCCreateDefaultPreferences();
}

- (id)init {
U_debug(1);
	if ((self = [super init]) != nil) {
		// do init stuff
	} return self;
}

- (void)dealloc {
U_debug(2);
	[_view release];
	[_backgroundView release];
	[super dealloc];
}

- (void)loadFullView {
U_debug(3);
	// Add subviews to _backgroundView (or _view) here.
	FSSwitchPanel *fsp = [FSSwitchPanel sharedPanel];

	NSMutableArray *ids = [[NSMutableArray alloc] initWithArray:fsp.switchIdentifiers];
	[ids sortUsingSelector:@selector(caseInsensitiveCompare:)];

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:PREFERENCESFILE];
	BOOL useSI = [[prefs objectForKey:@"useSwitchIconsTemplate"] boolValue];
	[prefs release];
	NSBundle *templateBundle = [[NSBundle alloc] initWithPath:useSI?SITemplatePath:MyTemplatePath];

	CGRect r = CGRectMake(_backgroundView.frame.origin.x, _backgroundView.frame.origin.y, _backgroundView.frame.size.width, _backgroundView.frame.size.height - 2);
	UIScrollView *scv = [[UIScrollView alloc] initWithFrame:r];
	[scv setScrollEnabled:YES];
	//[scv setPagingEnabled:YES];
	[scv setContentSize:CGSizeMake(320 * [ids count] / 4, [self viewHeight] - 4)];
	[scv setAutoresizingMask: UIViewAutoresizingFlexibleWidth];

	for (int idx = 0; idx < [ids count]; idx++) {
		NSString *identifier = [ids objectAtIndex:idx];
		UIButton *button = [fsp buttonForSwitchIdentifier:identifier usingTemplate:templateBundle];
		CGRect newFrame = CGRectMake(
//			10 + (idx / 4) * 320 + (idx % 4) * (20 + button.frame.size.width), 4,
			10 + idx * (20 + button.frame.size.width + (60 - button.frame.size.width)), 4,
			button.frame.size.width, button.frame.size.height);
		[button setFrame:newFrame];
		[scv addSubview:button];
	}
	[templateBundle release];
	[ids release];
	[_view addSubview:scv];
	[scv release];
}

- (void)loadPlaceholderView {
U_debug(4);
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

- (void)unloadView {
U_debug(5);
	[_view release];
	_view = nil;
	[_backgroundView release];
	_backgroundView = nil;
	// Destroy any additional subviews you added here. Don't waste memory :(.
}
/*
- (id)view {
U_debug(I);
return _view;
}
*/
- (float)viewHeight {
U_debug(H);
	return 71.f;
}
/*
- (void)loadView {
U_debug(6);
}
- (void)clearShapshotImage {
U_debug(7);
}
- (id)launchURL {
U_debug(8);
return nil;
}
- (id)launchURLForTapLocation:(CGPoint)tapLocation {
U_debug(9);
return nil;
}
- (void)viewWillAppear {
U_debug(A);
}
- (void)viewDidAppear {
U_debug(B);
}
- (void)willRotateToInterfaceOrientation:(int)interfaceOrientation {
U_debug(C);
}
- (void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation {
U_debug(D);
}
- (void)didRotateFromInterfaceOrientation:(int)interfaceOrientation {
U_debug(E);
}
- (void)viewWillDisappear {
U_debug(F);
}
- (void)viewDidDisappear {
U_debug(G);
}
*/
@end
/*
static void FNCCreateDefaultPreferences(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary *d = [[NSDictionary alloc] initWithObjects:
		[NSArray arrayWithObjects:
			[NSNumber numberWithBool:YES],
		nil]
	forKeys:
		[NSArray arrayWithObjects:
			@"useSwitchIconsTemplate",
		nil]
	];
	[d writeToFile:PREFERENCESFILE atomically:YES];
	[d release];

	[pool release];
}

//notification managing

static void FNCPreferencesChanged(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	FNCReloadPreferences();
	[pool release];
}

static void FNCPreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	FNCPreferencesChanged();
}


   FNCPreferencesChanged();

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, FNCPreferencesChangedCallback, CFSTR(FNCPreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
	[pool release];
}

*/