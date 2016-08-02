#import "GridView.h"
#import "ThumbnailRowView.h"
#import "ThumbnailView.h"
#import "ViewController.h"

@implementation GridView

STATIC_IMPL_READONLY(NSUInteger, thumbnailsPerPage, 0);
STATIC_IMPL_READONLY(NSUInteger, maxThumbnailPages, 10);
STATIC_IMPL_READONLY(NSUInteger, rowsPerPage, 0);

@synthesize scrollContentsView = scrollContentsView;
@synthesize queryLimit = queryLimit;
@synthesize lastContentOffset = lastContentOffset;

- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame]) != null) {
        // some basic initialization
        self.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.25 alpha:1.0];
        self.userInteractionEnabled = YES;
        self.delegate = self;
        lastContentOffset = self.contentOffset.y;

        // put a scroll contents view into place
        scrollContentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scrollContentsView.userInteractionEnabled = YES;
        [self addSubview:scrollContentsView];
        
        // some setup computations to set limits
        [ThumbnailRowView setupRows:frame];
        CGFloat displayHeight = frame.size.height;
        rowsPerPage = (NSUInteger)((displayHeight - ThumbnailRowView.rowSpacing) / (ThumbnailRowView.totalRowHeight));
        thumbnailsPerPage = rowsPerPage * ThumbnailRowView.columnCount;
        queryLimit = thumbnailsPerPage * maxThumbnailPages;
        
        // put in a tap gesture recognizer that doesn't swallow events
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapRecognizer];
        
        // force a redraw
        [self refreshImageList];
    }
    return self;
}

- (ThumbnailView*) thumbnailAtPoint:(CGPoint)pt {
    NSUInteger rowIndex = (pt.y - ThumbnailRowView.rowSpacing) / ThumbnailRowView.totalRowHeight;
    ThumbnailRowView* trv = [scrollContentsView subviews][rowIndex];
    return [trv thumbnailAtX:pt.x];
}

- (void) handleTap:(id)sender {
    // now can I figure out what view got tapped?
    UITapGestureRecognizer* tapRecognizer = sender;
    CGPoint touchPoint = [tapRecognizer locationInView:self];
    ThumbnailView* thumbnailView = [self thumbnailAtPoint:touchPoint];
    //    NSLog(@"Grid View Tapped on (%@)", thumbnailView.asset.description);
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor blackColor];
    PHImageRequestOptions* requestOptions = [PHImageRequestOptions new];
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    requestOptions.networkAccessAllowed = YES;
    CGSize retinaSize = CGSizeMake (self.frame.size.width * 2, self.frame.size.height * 2);
    [IMAGE_MANAGER requestImageForAsset:thumbnailView.asset targetSize:retinaSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage* image, NSDictionary* result) {
        imageView.image = image;
    }];
    [VIEW_CONTROLLER pushView:imageView];
}

- (void) refreshImageList {
    // remove the subviews
    [[scrollContentsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // set up a query for the most recent photos, we want the last seven days
    // presented in a 6x4 grid, so 24 per page...
    NSDate* recent = [[NSDate date] dateByAddingTimeInterval:-14*24*60*60];
    PHFetchOptions* fetchOptions = [PHFetchOptions new];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate >= %@", recent];
    fetchOptions.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES] ];
    //fetchOptions.fetchLimit = queryLimit;
    PHFetchResult* fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    
    // process the fetch results into a viewing grid
    NSLog (@"Fetch Results: %lu", (unsigned long)fetchResult.count);
    NSUInteger rowCount = (fetchResult.count / ThumbnailRowView.columnCount) + (((fetchResult.count % ThumbnailRowView.columnCount) == 0) ? 0 : 1);
    CGFloat height = (ThumbnailRowView.totalRowHeight * rowCount) + ThumbnailRowView.rowSpacing;
    self.contentSize = CGSizeMake(self.frame.size.width, height);
    scrollContentsView.frame = CGRectMake(0, 0, self.frame.size.width, height);
    self.contentOffset = CGPointMake(0, height - self.frame.size.height);
    //[self scrollRectToVisible:CGRectMake(self.contentSize.width - 1,scrollview.contentSize.height - 1, 1, 1) animated:YES];

    // loop over all of the rows
    for (NSUInteger i = 0; i < rowCount; ++i) {
        // set up the assets for this row
        NSMutableArray* assets = [NSMutableArray arrayWithCapacity:ThumbnailRowView.columnCount];
        for (NSUInteger j = i * ThumbnailRowView.columnCount, end = MIN (j + ThumbnailRowView.columnCount, fetchResult.count); j < end; ++j) {
            [assets addObject:fetchResult[j]];
        }
        
        // create the thumbnail row view, reverse order to match the photos app
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
