#import "ThumbnailView.h"

@interface ThumbnailRowView : UIView

STATIC_DECL(CGFloat, rowHeight, RowHeight);
STATIC_DECL_READONLY(CGFloat,rowSpacing);
STATIC_DECL_READONLY(CGFloat,totalRowHeight);

STATIC_DECL_READONLY(CGFloat,columnWidth);
STATIC_DECL_READONLY(CGFloat,columnSpacing);
STATIC_DECL_READONLY(CGFloat,totalColumnWidth);

STATIC_DECL_READONLY(NSUInteger,columnCount);

+ (void) setupRows:(CGRect)frame;

PROPERTY_PRIMITIVE_DECL(BOOL, showing);
PROPERTY_PRIMITIVE_DECL(NSUInteger, rowIndex);

- (id) initAtRowIndex:(NSUInteger)rowIndex withAssets:(NSArray*)assets;
- (BOOL) isVisibleBetween:(CGFloat)scrollViewBottom and:(CGFloat)scrollViewTop;
- (BOOL) show;
- (void) hide;
- (ThumbnailView*) thumbnailAtX:(CGFloat)x;

@end
