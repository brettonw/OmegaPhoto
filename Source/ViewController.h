@interface ViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>

STATIC_DECL_READONLY(NSUInteger, thumbnailsPerPage);
STATIC_DECL_READONLY(NSUInteger, maxThumbnailPages);
STATIC_DECL_READONLY(NSUInteger, rowsPerPage);

@property (nonatomic, strong) UIView* baseView;
@property (nonatomic, strong) UIView* controlContainerView;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIView* scrollContentsView;
@property (nonatomic, assign) NSUInteger queryLimit;
@property (nonatomic, assign) CGFloat lastContentOffset;

@property (nonatomic, strong) NSMutableArray* rows;
@end
