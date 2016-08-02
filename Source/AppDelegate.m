#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

STATIC_IMPL_READONLY(AppDelegate*, sharedAppDelegate, nil);

- (id)init {
    sharedAppDelegate = [super init];
    return sharedAppDelegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow*   window = self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.rootViewController = [ViewController new];
    window.backgroundColor = [UIColor redColor];
    [window makeKeyAndVisible];
    return YES;
}

@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
