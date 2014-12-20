#ifndef BASEWEEAPP_HEADER
#define BASEWEEAPP_HEADER

#import "BBWeeAppController-Protocol.h"

@interface BaseWeeappController : NSObject <BBWeeAppController> {
	UIView *_view;
	UIImageView *_backgroundView;
}
@property (nonatomic, retain) UIView *view;

+ (NSBundle *)_BaseWeeappBundle;

@end

#endif /* BASEWEEAPP_HEADER */
