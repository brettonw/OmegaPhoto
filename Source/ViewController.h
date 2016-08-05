#import "GridView.h"

@interface ViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>

STATIC_DECL_READONLY(ViewController*, sharedViewController);

PROPERTY_OBJECT_DECL(UIView, baseView);
PROPERTY_OBJECT_DECL(UIView, containerView);

- (void) pushView:(UIView*)view;
- (void) popView;

@end

#define VIEW_CONTROLLER    [ViewController sharedViewController]
