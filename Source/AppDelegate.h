@interface AppDelegate : UIResponder <UIApplicationDelegate>

STATIC_DECL_READONLY(AppDelegate*, sharedAppDelegate);

@property (strong, nonatomic) UIWindow *window;

@end

#define APP_DELEGATE    [AppDelegate sharedAppDelegate]
