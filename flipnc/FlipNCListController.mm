#import <Preferences/Preferences.h>
#include <objc/runtime.h>

#ifdef UIUserInterfaceIdiomPad
#define isPad() ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
#else
#define isPad() NO
#endif
#define showAlert(t, m) [[[[objc_getClass("UIAlertView") alloc] initWithTitle:(t) message:(m) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];

static NSString *templatesPath = @"/Library/Application Support/FlipNC";

@interface FlipNCListController: PSListController {
	NSMutableArray *_values;
	NSMutableArray *_titles;
}

@end

@implementation FlipNCListController

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"FlipNC" target:self] mutableCopy];
	}
	return _specifiers;
}

- (NSArray *)templateValues {
	NSError *error = nil;
	//get all the directories in templatesPath
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:templatesPath error:&error];
	if (error) {
		showAlert(nil, [error description]);
		return nil;
	}

	//make them unique after some processing through the use of an NSSet
	NSMutableSet *set = [NSMutableSet new];
	for (NSString *dir in contents) {
		//remove ".bundle"
		NSMutableString *str = [[dir stringByDeletingPathExtension] mutableCopy];
		//remove "~ipad"
		[str replaceOccurrencesOfString:@"~ipad" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, str.length)];
		[set addObject:str];
	}
	_values = [[set allObjects] mutableCopy];
	[set release];
	return _values;
}

- (NSArray *)templateTitles {
	//for each unique value, try to get the CFBundleName of its corresponding Info.plist. Default to the value
	NSMutableArray *titles = [NSMutableArray new];
	for (NSString *val in [self templateValues]) {
		NSString *path = [NSString stringWithFormat:@"%@/%@%s.bundle", templatesPath, val, isPad()?"~ipad":""];
		NSBundle *bundle = [NSBundle bundleWithPath:path];
		NSString *name = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
		[titles addObject:(name)?name:val];
	}
	_titles = [titles mutableCopy];
	[titles release];
	return _titles;
}

@end
