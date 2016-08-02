@interface ViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView* baseView;
@property (nonatomic, strong) UIView* controlContainerView;

@end
