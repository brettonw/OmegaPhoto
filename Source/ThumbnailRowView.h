@interface ThumbnailRowView : UIView

STATIC_DECL(CGFloat, rowHeight, RowHeight);
STATIC_DECL_READONLY(NSUInteger,columnCount);
STATIC_DECL_READONLY(CGFloat,columnSpacing);
STATIC_DECL_READONLY(CGFloat,rowSpacing);
STATIC_DECL_READONLY(CGFloat,totalRowHeight);

+ (void) setupRows:(CGRect)frame;

@property (nonatomic, assign) BOOL showing;
@property (nonatomic, assign) NSUInteger rowIndex;

- (id) initAtRowIndex:(NSUInteger)rowIndex withAssets:(NSArray*)assets;
- (BOOL) isVisibleBetween:(CGFloat)scrollViewBottom and:(CGFloat)scrollViewTop;
- (BOOL) show;
- (void) hide;

@end
