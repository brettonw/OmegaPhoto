#import "ViewController.h"
#import "AppDelegate.h"
#import "ThumbnailRowView.h"
#import "ThumbnailView.h"

#import "Test.h"

@implementation ViewController

STATIC_IMPL_READONLY(NSUInteger, thumbnailsPerPage, 0);
STATIC_IMPL_READONLY(NSUInteger, maxThumbnailPages, 20);
STATIC_IMPL_READONLY(NSUInteger, rowsPerPage, 0);

@synthesize baseView = baseView;
@synthesize controlContainerView = controlContainerView;
@synthesize scrollView = scrollView;
@synthesize scrollContentsView = scrollContentsView;
@synthesize queryLimit = queryLimit;
@synthesize lastContentOffset = lastContentOffset;

@synthesize rows = rows;

- (void) loadView
{
    UIWindow*   window = APP_DELEGATE.window;
    CGRect      frame = window.frame;
    
    // this view automatically gets resized to fill the window
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor redColor];
    
    // adjust the frame rect based on the orientation
    frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    baseView = [[UIView alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor whiteColor];
    baseView.clipsToBounds = YES;
    [self.view addSubview:baseView];
    
    // put down a view to contain the controls
    controlContainerView = [[UIView alloc] initWithFrame:frame];
    controlContainerView.backgroundColor = [UIColor clearColor];
    controlContainerView.userInteractionEnabled = YES;
    [self.view addSubview:controlContainerView];
    
    // put a scroll view into place
    CGFloat headerHeight = 60.0;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, headerHeight, frame.size.width, frame.size.height - headerHeight)];
    scrollView.backgroundColor = [UIColor redColor];
    scrollView.userInteractionEnabled = YES;
    scrollView.delegate = self;
    [controlContainerView addSubview:scrollView];
    
    // put a scroll contents view into place
    scrollContentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, scrollView.frame.size.height)];
    scrollView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.25 alpha:1.0];
    scrollView.userInteractionEnabled = YES;
    lastContentOffset = 0;
    [scrollView addSubview:scrollContentsView];
    
    // and a few values to be stored away
    // some setup computations to set limits
    [ThumbnailRowView setupRows:scrollView.frame];
    CGFloat displayHeight = scrollView.frame.size.height;
    rowsPerPage = (NSUInteger)((displayHeight - ThumbnailRowView.rowSpacing) / (ThumbnailRowView.totalRowHeight));
    thumbnailsPerPage = rowsPerPage * ThumbnailRowView.columnCount;
    queryLimit = thumbnailsPerPage * maxThumbnailPages;
    
    rows = [NSMutableArray arrayWithCapacity:rowsPerPage + 2];
    for (int i = 0; i < rows.count; ++i) {
        
    }
    
    [self refreshImageList];
    
    //[[Test new] testResultHandlerBehavior];
    
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(reportRequestCount:) userInfo:null repeats:YES];
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
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, height);
    scrollContentsView.frame = CGRectMake(0, 0, scrollView.frame.size.width, height);
    
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
    if (fabs (lastContentOffset - scrollView.contentOffset.y) >= ThumbnailRowView.totalRowHeight) {
        lastContentOffset = scrollView.contentOffset.y;
        [self updateScrollPosition];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //[self updateScrollPosition];
}

- (void) updateScrollPosition {
    // the current scroll positions
    CGFloat scrollViewTop = scrollView.contentOffset.y;
    CGFloat scrollViewBottom = scrollViewTop + scrollView.frame.size.height;

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

-(void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
