@interface ViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>

STATIC_DECL_READONLY(ViewController*, sharedViewController);

@property (nonatomic, strong) UIView* baseView;
@property (nonatomic, strong) UIView* controlContainerView;
@property (nonatomic, strong) UIView* editView;

- (void) pushView:(UIView*)view;
- (void) popView;

@end

#define VIEW_CONTROLLER    [ViewController sharedViewController]
