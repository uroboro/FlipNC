#ifndef FLIPNC_HEADER
#define FLIPNC_HEADER

#import "BaseWeeappController.h"

#ifdef UIUserInterfaceIdiomPad
#define isPad() ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
#else
#define isPad() NO
#endif

#define showAlert(t, m) [[[[objc_getClass("UIAlertView") alloc] initWithTitle:(t) message:(m) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];

@interface NSUserDefaults (Tweak_Category)
+ (void)resetStandardUserDefaults;
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

#define _standardObjectForKey(key) [[NSUserDefaults standardUserDefaults] objectForKey:(key) inDomain:nsDomainString]
#define _setStandardObjectForKey(object, key) [[NSUserDefaults standardUserDefaults] setObject:(object) forKey:(key) inDomain:nsDomainString];
#define standardObjectForKey(key, defaultObject) (_standardObjectForKey(key)? _standardObjectForKey(key):defaultObject)

@interface FlipNCController : BaseWeeappController {
	BOOL _landscape;

	NSInteger _rows;
	NSInteger _switchesPerRow;

	NSArray *_iconIdentifiers;
	NSInteger _templateIdx;
	NSString *_templateName;
}

@property (nonatomic, retain) NSString *templateName;

- (void)updateVars;

- (NSBundle *)currentBundle;

@end

#endif /* FLIPNC_HEADER */
