@interface GridView : UIScrollView <UIScrollViewDelegate>

STATIC_DECL_READONLY(NSUInteger, thumbnailsPerPage);
STATIC_DECL_READONLY(NSUInteger, maxThumbnailPages);
STATIC_DECL_READONLY(NSUInteger, rowsPerPage);

@property (nonatomic, strong) UIView* scrollContentsView;
@property (nonatomic, assign) NSUInteger queryLimit;
@property (nonatomic, assign) CGFloat lastContentOffset;

@end
