#import "ViewController.h"
#import "AppDelegate.h"
#import "GridView.h"

@implementation ViewController

@synthesize baseView = baseView;
@synthesize controlContainerView = controlContainerView;

- (void) loadView
{
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
    controlContainerView = [[UIView alloc] initWithFrame:frame];
    controlContainerView.backgroundColor = [UIColor clearColor];
    controlContainerView.userInteractionEnabled = YES;
    [self.view addSubview:controlContainerView];
    
    // put a scroll view into place
    CGFloat headerHeight = 60.0;
    GridView*   gridView = [[GridView alloc]initWithFrame:CGRectMake(0, headerHeight, frame.size.width, frame.size.height - headerHeight)];
    [controlContainerView addSubview:gridView];
}

-(void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
