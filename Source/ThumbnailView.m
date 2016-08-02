#import "ThumbnailView.h"
#import "ViewController.h"

@implementation ThumbnailView

STATIC_IMPL(CGSize, imageSize, ImageSize);
STATIC_IMPL_READONLY (CGFloat, iconSpacing, 6);

@synthesize imageRequestId = imageRequestId;
@synthesize callbackCount = callbackCount;
@synthesize showing = showing;
@synthesize asset = asset;

static UIImage* cloudIcon;
static PHImageRequestOptions* requestOptions;


+ (void) initialize {
    // grab the cloud icon
    cloudIcon = [UIImage imageNamed:@"iCloud@2x.png"];
    
    // set up the request options
    PHImageRequestOptions* requestOptions = [PHImageRequestOptions new];
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    requestOptions.synchronous = NO;
}

- (id) initWithFrame:(CGRect)frame andAsset:(PHAsset*)assetIn {
    if ((self = [super initWithFrame:frame]) != nil) {
        asset = assetIn;
        showing = NO;
        self.backgroundColor = [UIColor colorWithRed:68.0/255.0 green:159.0/255.0 blue:243.0/255.0 alpha:0.75];// 68,159,243
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
    }
    return self;
}

#define CAP_REQUESTS    0

- (BOOL) show {
    // the item should be visible, check to see if there is no
    // image, or no image query on it
    if (! showing) {
#if CAP_REQUESTS
        if (requestCount > ViewController.thumbnailsPerPage) {
            NSLog(@"PUNT (%lu)", (unsigned long)requestCount);
            self.backgroundColor = [UIColor colorWithRed:68.0/255.0 green:159.0/255.0 blue:243.0/255.0 alpha:0.75];// 68,159,243
            return false;
        }
#endif
        // add an image request, save the request id as the imageRequestId
        showing = YES;
        callbackCount = 0;
        imageRequestId = [IMAGE_MANAGER requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage* image, NSDictionary* result) {
            // process cancellation
            if ([[result valueForKey:PHImageCancelledKey] boolValue]) {
                imageRequestId = 0;
                return;
            }
            
            // process error
            if ([[result valueForKey:PHImageErrorKey] boolValue]) {
                NSLog(@"ERROR");
                imageRequestId = 0;
                return;
            }
            
            // if we are being given an image, take it
            if (image != nil) {
                self.image = image;
            }
            
            // this function gets called twice... the first time is a synchronous call
            // before the imageRequestId has been assigned, with a low res image. the second is
            // either a high quality replacement, or nil image (if it needs to be down-
            // loaded from the cloud)
            switch (callbackCount) {
                case 0:
                    // first call, low quality
                    if ([[result valueForKey:PHImageResultIsDegradedKey] boolValue]) {
                        // XXX this is a temporary debugging highlight
                        self.backgroundColor = [UIColor blueColor];
                        UIView* first = [[UIView alloc] initWithFrame:CGRectMake(iconSpacing, iconSpacing, 10, 10)];
                        first.backgroundColor = [UIColor greenColor];
                        [self addSubview:first];
                    } else {
                        NSLog (@"Does this ever happen?");
                    }
                    break;
                    
                case 1: {
                    // this is the final state, clear out any subviews
                    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                    
                    // second call, is either high quality or nil
                    if (image == nil) {
                        if (! [[result valueForKey:PHImageCancelledKey] boolValue]) {
                            // tag it as a cloud image
                            CGSize size = self.frame.size;
                            UIImageView* cloud = [[UIImageView alloc] initWithFrame:CGRectMake(size.width - (cloudIcon.size.width + iconSpacing), size.height - (cloudIcon.size.height + iconSpacing), cloudIcon.size.width, cloudIcon.size.height)];
                            cloud.image = cloudIcon;
                            [self addSubview:cloud];
                        }
                    } else {
                        // don't need anything else
                    }
                    
                    // clear the request id, it won't happen again
                    imageRequestId = 0;
                    break;
                }
            }
            ++callbackCount;
        }];
    }
    
    // if we got all the way here, it's all good
    return true;
}

- (void) hide {
    // the item should not have a thumbnail
    showing = NO;
    self.image = nil;
    
    // cancel any outstanding requests
    if (imageRequestId != 0) {
        // XXX it appears that the app occasionally gets hung up here
        // XXX and it's not clear why, but removing it is worse
        [IMAGE_MANAGER cancelImageRequest:imageRequestId];
    }
    
    // clear out any subviews
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}


@end
