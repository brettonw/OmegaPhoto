#import "ViewController.h"
#import "AppDelegate.h"
#import "GridView.h"

@interface ViewController ()

PROPERTY_OBJECT_DECL(NSMutableArray, viewStack);
PROPERTY_OBJECT_DECL(UIView, editView);
PROPERTY_OBJECT_DECL(GridView, gridView);
PROPERTY_PRIMITIVE_DECL(BOOL, hideStatusBar);

@end

@implementation ViewController

STATIC_IMPL_READONLY(ViewController*, sharedViewController, nil);

PROPERTY_IMPL(baseView);
PROPERTY_IMPL(containerView);
PROPERTY_IMPL(viewStack);
PROPERTY_IMPL(gridView);
PROPERTY_IMPL(editView);
PROPERTY_IMPL(hideStatusBar);

- (void) loadView
{
    sharedViewController = self;
    
    // default to showing the status bar
    hideStatusBar = NO;
    
    UIWindow*   window = APP_DELEGATE.window;
    CGRect      frame = window.frame;
    
    // this view automatically gets resized to fill the window
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor redColor];
    
    // adjust the frame rect based on the orientation
    frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    baseView = [[UIView alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor whiteColor];
    baseView.clipsToBounds = YES;
    [self.view addSubview:baseView];
    
    // put down a view to contain the controls
    containerView = [[UIView alloc] initWithFrame:frame];
    containerView.backgroundColor = [UIColor clearColor];
    containerView.userInteractionEnabled = YES;
    [self.view addSubview:containerView];
    
    // create the view stack
    viewStack = [NSMutableArray arrayWithCapacity:3];
    
    // put a scroll view into place
    CGFloat headerHeight = 60.0;
    gridView = [[GridView alloc]initWithFrame:CGRectMake(0, headerHeight, frame.size.width, frame.size.height - headerHeight)];
    [containerView addSubview:gridView];
}

- (void) pushView:(UIView*)view {
    if (editView == nil) {
        editView = view;
        editView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        [containerView addSubview:editView];
        self.prefersStatusBarHidden = YES;
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(popView) userInfo:nil repeats:NO];
    }
}

- (void) popView {
    if (editView != nil) {
        self.prefersStatusBarHidden = NO;
        [editView removeFromSuperview];
        editView = nil;
    }
}

- (BOOL) prefersStatusBarHidden {
    // override the default behavior so that I can control it...
    return hideStatusBar;
}

- (void) setPrefersStatusBarHidden:(BOOL)hide {
    hideStatusBar = hide;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
