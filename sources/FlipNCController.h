#ifndef FLIPNC_HEADER
#define FLIPNC_HEADER

#import <flipswitch/FSSwitchPanel.h>
#import "BBWeeAppController-Protocol.h"

#ifdef UIUserInterfaceIdiomPad
#define isPad() ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
#else
#define isPad() NO
#endif

#define MyTemplatePath @"/Library/Application Support/FlipNC/IconTemplate.bundle"
#define SIiPhoneTemplatePath @"/Library/Application Support/FlipNC/SwitchIconsTemplate.bundle"
#define SIiPadTemplatePath @"/Library/Application Support/FlipNC/SwitchIconsTemplate~ipad.bundle"
#define SITemplatePath (isPad()?SIiPadTemplatePath:SIiPhoneTemplatePath)

static NSBundle *_FlipNCWeeAppBundle;

@interface FlipNCController: NSObject <BBWeeAppController, UIScrollViewDelegate> {
	UIView *_view;
	UIImageView *_backgroundView;

	BOOL _landscape;

	int _rows;
	int _switchesPerRow;
	BOOL _unpaged;

	NSArray *_ids;
	
	int _templateIdx;
//	NSString *_templateName;
}

@property (nonatomic, retain) UIView *view;
//@property (nonatomic, retain) NSString *templateName;

- (void)updateSwitchList;
- (void)updateVars;

@end

#endif /* FLIPNC_HEADER */
