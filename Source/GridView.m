#import "GridView.h"
#import "ThumbnailRowView.h"
#import "ThumbnailView.h"

@implementation GridView

STATIC_IMPL_READONLY(NSUInteger, thumbnailsPerPage, 0);
STATIC_IMPL_READONLY(NSUInteger, maxThumbnailPages, 20);
STATIC_IMPL_READONLY(NSUInteger, rowsPerPage, 0);

@synthesize scrollContentsView = scrollContentsView;
@synthesize queryLimit = queryLimit;
@synthesize lastContentOffset = lastContentOffset;

- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame]) != null) {
        self.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.25 alpha:1.0];
        self.userInteractionEnabled = YES;

        // put a scroll contents view into place
        scrollContentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:scrollContentsView];
        self.delegate = self;
        lastContentOffset = self.contentOffset.y;
        
        // some setup computations to set limits
        [ThumbnailRowView setupRows:frame];
        CGFloat displayHeight = frame.size.height;
        rowsPerPage = (NSUInteger)((displayHeight - ThumbnailRowView.rowSpacing) / (ThumbnailRowView.totalRowHeight));
        thumbnailsPerPage = rowsPerPage * ThumbnailRowView.columnCount;
        queryLimit = thumbnailsPerPage * maxThumbnailPages;
        
        [self refreshImageList];
        
        //[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(reportRequestCount:) userInfo:null repeats:YES];
    }
    return self;
}

- (void) reportRequestCount:(id)sender {
    NSLog (@"Request Count: %lu", (unsigned long)ThumbnailView.requestCount);
    //[self updateScrollPosition];
}

- (void) refreshImageList {
    // remove the subviews
    [[scrollContentsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // set up a query for the most recent photos, we want the last seven days
    // presented in a 6x4 grid, so 24 per page...
    NSDate* recent = [[NSDate date] dateByAddingTimeInterval:-14*24*60*60];
    PHFetchOptions* fetchOptions = [PHFetchOptions new];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate >= %@", recent];
    fetchOptions.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];
    fetchOptions.fetchLimit = queryLimit;
    PHFetchResult* fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    
    // process the fetch results into a viewing grid
    NSLog (@"Fetch Results: %lu", (unsigned long)fetchResult.count);
    NSUInteger rowCount = (fetchResult.count / ThumbnailRowView.columnCount) + (((fetchResult.count % ThumbnailRowView.columnCount) == 0) ? 0 : 1);
    CGFloat height = (ThumbnailRowView.totalRowHeight * rowCount) + ThumbnailRowView.rowSpacing;
    self.contentSize = CGSizeMake(self.frame.size.width, height);
    scrollContentsView.frame = CGRectMake(0, 0, self.frame.size.width, height);
    
    // loop over all of the rows
    for (NSUInteger i = 0; i < rowCount; ++i) {
        // set up the assets for this row
        NSMutableArray* assets = [NSMutableArray arrayWithCapacity:ThumbnailRowView.columnCount];
        for (NSUInteger j = i * ThumbnailRowView.columnCount, end = MIN (j + ThumbnailRowView.columnCount, fetchResult.count); j < end; ++j) {
            [assets addObject:fetchResult[j]];
        }
        
        // create the thumbnail row view
        ThumbnailRowView* thumbnailRowView = [[ThumbnailRowView alloc] initAtRowIndex:i withAssets:assets];
        [scrollContentsView addSubview:thumbnailRowView];
    }
    
    // save the fetch results, and then update the display
    [self updateScrollPosition];
}


- (void) scrollViewDidScroll:(UIScrollView*)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.3];
    
    // only update the buffered images if the scrolling has gone more than one
    // row since the last tiem we updated them
    if (fabs (lastContentOffset - self.contentOffset.y) >= ThumbnailRowView.totalRowHeight) {
        lastContentOffset = self.contentOffset.y;
        [self updateScrollPosition];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //[self updateScrollPosition];
}

- (void) updateScrollPosition {
    // the current scroll positions
    CGFloat scrollViewTop = self.contentOffset.y;
    CGFloat scrollViewBottom = scrollViewTop + self.frame.size.height;
    
    NSArray* thumbnailRows = [scrollContentsView subviews];
    
    // hide the views that aren't visible
    for (NSUInteger i = 0, end = thumbnailRows.count; i < end; ++i) {
        ThumbnailRowView* rowView = thumbnailRows[i];
        if (![rowView isVisibleBetween:scrollViewBottom and:scrollViewTop]) {
            [rowView hide];
        }
    }
    
    // show the views that are visible
    BOOL success = YES;
    for (NSUInteger i = 0, end = thumbnailRows.count; i < end; ++i) {
        ThumbnailRowView* rowView = thumbnailRows[i];
        if ([rowView isVisibleBetween:scrollViewBottom and:scrollViewTop]) {
            success &= [rowView show];
        }
    }
    if (! success) {
        // try again in a moment if that didn't work
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(updateScrollPosition) withObject:nil afterDelay:0.25];
    }
}

@end
