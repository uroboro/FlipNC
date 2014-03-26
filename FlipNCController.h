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

static NSString* const PreferencesFilePath;
static NSBundle *_FlipNCWeeAppBundle;

@interface FlipNCController: NSObject <BBWeeAppController> {
	UIView *_view;
	UIImageView *_backgroundView;
}
@property (nonatomic, retain) UIView *view;
@end


#endif /* FLIPNC_HEADER */
