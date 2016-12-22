@interface View : UIView

// implements a standard interface for animated show and hide, used by the
// ViewController for all views

- (void) show;
- (void) hide;

#define FADE_ANIMATION_TIME 0.5
+ (void) fadeIn:(UIView*)view;
+ (void) fadeOut:(UIView*)view;

@end
