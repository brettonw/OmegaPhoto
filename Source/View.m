#import "View.h"

@implementation View

- (void) show {
    
}

- (void) hide {
    
}

+ (void) fadeIn:(UIView*)view
{
    view.alpha = 0.0;
    [UIView animateWithDuration:FADE_ANIMATION_TIME delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations: ^{
                         view.alpha = 1.0;
                     }
                     completion: ^(BOOL finished){
                         view.alpha = 1.0;
                     }
     ];
}

+ (void) fadeOut:(UIView*)view
{
    [UIView animateWithDuration:FADE_ANIMATION_TIME delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations: ^{
                         view.alpha = 0.0;
                     }
                     completion: ^(BOOL finished){
                         [view removeFromSuperview];
                     }
     ];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
