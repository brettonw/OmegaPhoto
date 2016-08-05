#import "AppDelegate.h"
#import "ViewController.h"

#import "Test.h"

@implementation AppDelegate

STATIC_IMPL_READONLY(AppDelegate*, sharedAppDelegate, nil);

PROPERTY_IMPL(window);

- (id)init {
    sharedAppDelegate = [super init];
    return sharedAppDelegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [application setStatusBarHidden:NO];

    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.rootViewController = [ViewController new];
    window.backgroundColor = [UIColor redColor];
    [window makeKeyAndVisible];
    
    // run the tests
    [[Test new] testResultHandlerBehavior];
    
    return YES;
}

@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
