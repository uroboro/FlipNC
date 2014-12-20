#import <Preferences/Preferences.h>
#include <objc/runtime.h>

#ifdef UIUserInterfaceIdiomPad
#define isPad() ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
#else
#define isPad() NO
#endif
#define showAlert(t, m) [[[[objc_getClass("UIAlertView") alloc] initWithTitle:(t) message:(m) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];

#define CMCLog(format, ...) \
	NSLog(@"\033[1;36m(%s) in [%s:%d]\033[0m \033[5;32;40m:::\033[0m \033[0;31m%@\033[0m", __PRETTY_FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:format, ## __VA_ARGS__])

#define CMCLogObjDescript(a) \
	CMCLog(@"flipnc :: %s=%@", #a, [a description])

static NSString *templatesPath = @"/Library/Application Support/FlipNC";

@interface FlipNCListController: PSListController {
	NSMutableArray *_values;
	NSMutableArray *_titles;
}

//- (PSSpecifier *)templateListSpecifier;

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
		NSString *InfoPlistPath = [NSString stringWithFormat:@"%@/%@%s.bundle/Info.plist", templatesPath, val, isPad()?"~ipad":""];
		NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:InfoPlistPath];
		NSString *name = [dict objectForKey:@"CFBundleName"];
		[titles addObject:(name)?name:val];
		[dict release];
	}
	_titles = [titles mutableCopy];
	[titles release];
	return _titles;
}

@end
