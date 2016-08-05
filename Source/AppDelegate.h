@interface AppDelegate : UIResponder <UIApplicationDelegate>

STATIC_DECL_READONLY(AppDelegate*, sharedAppDelegate);

PROPERTY_OBJECT_DECL(UIWindow, window);

@end

#define APP_DELEGATE    [AppDelegate sharedAppDelegate]
