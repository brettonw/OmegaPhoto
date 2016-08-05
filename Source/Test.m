#import "Test.h"
#import "ThumbnailView.h"

@implementation Test

void msg (NSString* name, BOOL condition) {
    NSLog(@"%@: %@", name, condition ? @"YES" : @"NO:");
}

- (void) testResultHandlerBehaviorForAsset:(PHAsset*)asset withId:(NSUInteger)id andOptions:(PHImageRequestOptions*)options {
    CGSize targetSize = CGSizeMake(100, 100);
    __block NSUInteger callbackCount = 0;
    PHImageRequestID imageRequestId = [IMAGE_MANAGER requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage* image, NSDictionary* result) {
        NSLog (@"****************************");                                    \
        NSLog(@"RESULT (ID=%lu)", (unsigned long)id);
        // print out some local information
        NSLog(@"Has Image: %@", (image != nil) ? @"YES" : @"NO:");
        NSLog(@"Has Image Request ID: %@", (imageRequestId != 0) ? @"YES" : @"NO:");
        NSLog(@"Callback Counter: %lu", (unsigned long)callbackCount);
        
        // print out the result contents
        for(NSString *key in [result allKeys]) {
            NSLog(@"%@: %@",key, [result objectForKey:key]);
        }
        
        // update the receiver
        callbackCount++;
    }];
}

#define test(rm,dm,s,id) {                                                      \
    NSLog (@"----------------------------");                                    \
    NSLog (@"Test (%d) with %s, %s, %@", id, #rm, #dm, s ? @"SYNCH" : @"ASYNCH");        \
    PHImageRequestOptions* requestOptions = [PHImageRequestOptions new];        \
    requestOptions.resizeMode = rm;                                             \
    requestOptions.deliveryMode = dm;                                           \
    requestOptions.synchronous = s;                                             \
    [self testResultHandlerBehaviorForAsset:asset withId:id andOptions:requestOptions];   \
}

- (void) testResultHandlerBehaviorForAsset:(PHAsset*)asset {
    test(PHImageRequestOptionsResizeModeFast, PHImageRequestOptionsDeliveryModeOpportunistic, NO, 1);
    test(PHImageRequestOptionsResizeModeExact, PHImageRequestOptionsDeliveryModeOpportunistic, NO, 2);
    test(PHImageRequestOptionsResizeModeNone, PHImageRequestOptionsDeliveryModeOpportunistic, NO, 3);
    
    test(PHImageRequestOptionsResizeModeFast, PHImageRequestOptionsDeliveryModeFastFormat, NO, 4);
    test(PHImageRequestOptionsResizeModeExact, PHImageRequestOptionsDeliveryModeFastFormat, NO, 5);
    test(PHImageRequestOptionsResizeModeNone, PHImageRequestOptionsDeliveryModeFastFormat, NO, 6);
    
    test(PHImageRequestOptionsResizeModeFast, PHImageRequestOptionsDeliveryModeHighQualityFormat, NO, 7);
    test(PHImageRequestOptionsResizeModeExact, PHImageRequestOptionsDeliveryModeHighQualityFormat, NO, 8);
    test(PHImageRequestOptionsResizeModeNone, PHImageRequestOptionsDeliveryModeHighQualityFormat, NO, 9);

    test(PHImageRequestOptionsResizeModeFast, PHImageRequestOptionsDeliveryModeOpportunistic, YES, 10);
    test(PHImageRequestOptionsResizeModeExact, PHImageRequestOptionsDeliveryModeOpportunistic, YES, 11);
    test(PHImageRequestOptionsResizeModeNone, PHImageRequestOptionsDeliveryModeOpportunistic, YES, 12);
    
    test(PHImageRequestOptionsResizeModeFast, PHImageRequestOptionsDeliveryModeFastFormat, YES, 13);
    test(PHImageRequestOptionsResizeModeExact, PHImageRequestOptionsDeliveryModeFastFormat, YES, 14);
    test(PHImageRequestOptionsResizeModeNone, PHImageRequestOptionsDeliveryModeFastFormat, YES, 15);
    
    test(PHImageRequestOptionsResizeModeFast, PHImageRequestOptionsDeliveryModeHighQualityFormat, YES, 16);
    test(PHImageRequestOptionsResizeModeExact, PHImageRequestOptionsDeliveryModeHighQualityFormat, YES, 17);
    test(PHImageRequestOptionsResizeModeNone, PHImageRequestOptionsDeliveryModeHighQualityFormat, YES, 18);
}

- (void) testResultHandlerBehavior {
    NSDate* recent = [[NSDate date] dateByAddingTimeInterval:-7*24*60*60];
    PHFetchOptions* fetchOptions = [PHFetchOptions new];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate >= %@", recent];
    fetchOptions.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];
    fetchOptions.fetchLimit = 3;
    PHFetchResult* fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    if ((fetchResult != nil) && (fetchResult.count > 0)) {
        [self testResultHandlerBehaviorForAsset:fetchResult[2]];
    }
}

@end
