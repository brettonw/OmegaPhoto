#import "ThumbnailRowView.h"
#import "ThumbnailView.h"

@implementation ThumbnailRowView

STATIC_IMPL(CGFloat, rowHeight, RowHeight);
STATIC_IMPL_READONLY(CGFloat,rowSpacing, 2);
+ (CGFloat) totalRowHeight {
    return rowHeight + rowSpacing;
}

STATIC_IMPL_READONLY(CGFloat,columnWidth, 0);
STATIC_IMPL_READONLY(CGFloat,columnSpacing, 2);
+ (CGFloat) totalColumnWidth {
    return rowHeight + rowSpacing;
}

STATIC_IMPL_READONLY(NSUInteger,columnCount, 4);

+ (void) setupRows:(CGRect)frame {
    // compute the sizes we'll need
    displayWidth = frame.size.width - ((columnCount +1) * columnSpacing);
    columnWidth = displayWidth / columnCount;
    rowHeight = columnWidth;
    
    // initialize the thumbnail views static values
    CGFloat screenScale = [UIScreen mainScreen].scale;
    ThumbnailView.imageSize = CGSizeMake (columnWidth * screenScale, rowHeight * screenScale);
}

static CGFloat displayWidth;

PROPERTY_IMPL(showing);
PROPERTY_IMPL(rowIndex);

- (id) initAtRowIndex:(NSUInteger)rowIndexIn withAssets:(NSArray*)assets {
    rowIndex = rowIndexIn;
    CGFloat y = rowSpacing + (rowIndex * ThumbnailRowView.totalRowHeight);
    if ((self = [super initWithFrame:CGRectMake(columnSpacing, y, displayWidth, rowHeight)]) != nil) {
        // create the individual thumbnail views
        for (NSUInteger i = 0, end = assets.count; i < end; ++i) {
            CGRect childFrame = CGRectMake(i * (columnWidth + columnSpacing), 0, columnWidth, rowHeight);
            ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:childFrame andAsset:assets[i]];
            [self addSubview:thumbnailView];
        }
    }
    self.userInteractionEnabled = YES;
    return self;
}

- (BOOL) isVisibleBetween:(CGFloat)scrollViewBottom and:(CGFloat)scrollViewTop {
    CGFloat rowTop = self.frame.origin.y;
    CGFloat rowBottom = rowTop + self.frame.size.height;
    scrollViewTop -= rowHeight;
    scrollViewBottom += rowHeight;
    return ((rowTop <= scrollViewBottom) && (rowBottom >= scrollViewTop));
}

- (BOOL) show {
    if (! showing) {
        //NSLog (@"Show row %lu", (unsigned long)rowIndex);
        NSArray* subviews = [self subviews];
        showing = YES;
        for (int i = 0; i < subviews.count; ++i) {
            showing &= [((ThumbnailView*) subviews[i]) show];
        }
    }
    return showing;
}

- (void) hide {
    if (showing) {
        // NSLog (@"Hide row %lu", (unsigned long)rowIndex);
        [[self subviews] makeObjectsPerformSelector:@selector(hide)];
        showing = false;
    }
}

- (ThumbnailView*) thumbnailAtX:(CGFloat)x {
    NSUInteger columnIndex = (x - columnSpacing) / ThumbnailRowView.totalColumnWidth;
    return [self subviews][columnIndex];
}

@end
