#import "BaseWeeappController.h"

@implementation BaseWeeappController
@synthesize view = _view;

+ (void)initialize {
	[self _BaseWeeappBundle];
}

- (void)dealloc {
	[_view release];
	[_backgroundView release];
	[super dealloc];
}


+ (NSBundle *)_BaseWeeappBundle {
	static NSBundle *_BaseWeeappBundle = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		_BaseWeeappBundle = [[NSBundle bundleForClass:[self class]] retain];
	});
	return _BaseWeeappBundle;
}

- (CGFloat)viewHeight {
	return 71.f;
}

- (void)loadFullView {
	// Add subviews to _backgroundView (or _view) here.
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

- (void)unloadView {
	[_view release];
	_view = nil;
	[_backgroundView release];
	_backgroundView = nil;
	// Destroy any additional subviews you added here. Don't waste memory :(.
}

@end
